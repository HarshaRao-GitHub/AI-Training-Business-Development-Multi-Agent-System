"""
Base agent class with common functionality for all specialized agents
"""
from typing import Dict, Any, List, Optional
from langchain_anthropic import ChatAnthropic
from langchain.prompts import ChatPromptTemplate
from langchain.schema import HumanMessage, SystemMessage
from core.config import settings
from database.vector_store import vector_store
from datetime import datetime
import json


class BaseAgent:
    """Base class for all specialized agents"""

    def __init__(self, agent_type: str, agent_name: str, system_prompt: str):
        """
        Initialize base agent

        Args:
            agent_type: Type of agent (research, lead_generation, etc.)
            agent_name: Display name for the agent
            system_prompt: System prompt defining agent's role and capabilities
        """
        self.agent_type = agent_type
        self.agent_name = agent_name
        self.system_prompt = system_prompt

        # Initialize Claude model
        self.llm = ChatAnthropic(
            model=settings.ANTHROPIC_MODEL,
            anthropic_api_key=settings.ANTHROPIC_API_KEY,
            temperature=0.7,
            max_tokens=4096
        )

        # Agent state
        self.state = {}
        self.execution_history = []

    async def execute(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Execute agent task (to be implemented by subclasses)

        Args:
            input_data: Input data for the agent

        Returns:
            Dict containing execution results
        """
        raise NotImplementedError("Subclasses must implement execute method")

    async def invoke_llm(
        self,
        messages: List[Dict[str, str]],
        temperature: Optional[float] = None
    ) -> str:
        """
        Invoke Claude LLM with messages

        Args:
            messages: List of message dictionaries with 'role' and 'content'
            temperature: Optional temperature override

        Returns:
            Model response as string
        """
        formatted_messages = []

        # Add system message
        formatted_messages.append(SystemMessage(content=self.system_prompt))

        # Add other messages
        for msg in messages:
            if msg["role"] == "user":
                formatted_messages.append(HumanMessage(content=msg["content"]))

        # Invoke model
        if temperature is not None:
            llm = ChatAnthropic(
                model=settings.ANTHROPIC_MODEL,
                anthropic_api_key=settings.ANTHROPIC_API_KEY,
                temperature=temperature,
                max_tokens=4096
            )
            response = await llm.ainvoke(formatted_messages)
        else:
            response = await self.llm.ainvoke(formatted_messages)

        return response.content

    async def search_knowledge_base(
        self,
        query: str,
        collection_name: str = "knowledge_base",
        n_results: int = 5
    ) -> List[Dict[str, Any]]:
        """
        Search the knowledge base for relevant information

        Args:
            query: Search query
            collection_name: Vector store collection to search
            n_results: Number of results to return

        Returns:
            List of relevant documents with metadata
        """
        results = await vector_store.search(
            collection_name=collection_name,
            query=query,
            n_results=n_results
        )

        formatted_results = []
        for i, doc_id in enumerate(results["ids"]):
            formatted_results.append({
                "id": doc_id,
                "content": results["documents"][i],
                "metadata": results["metadatas"][i],
                "relevance_score": 1 - results["distances"][i]  # Convert distance to similarity
            })

        return formatted_results

    async def store_knowledge(
        self,
        content: str,
        metadata: Dict[str, Any],
        collection_name: str = "knowledge_base"
    ) -> str:
        """
        Store information in the knowledge base

        Args:
            content: Content to store
            metadata: Metadata about the content
            collection_name: Vector store collection to use

        Returns:
            Document ID
        """
        doc_id = await vector_store.add_document(
            collection_name=collection_name,
            document=content,
            metadata=metadata
        )

        return doc_id

    def log_execution(self, action: str, details: Dict[str, Any]):
        """
        Log agent execution step

        Args:
            action: Action taken by agent
            details: Details about the action
        """
        log_entry = {
            "timestamp": datetime.utcnow().isoformat(),
            "agent_type": self.agent_type,
            "agent_name": self.agent_name,
            "action": action,
            "details": details
        }
        self.execution_history.append(log_entry)

    def get_execution_history(self) -> List[Dict[str, Any]]:
        """Get agent execution history"""
        return self.execution_history

    def update_state(self, key: str, value: Any):
        """Update agent state"""
        self.state[key] = value
        self.log_execution("state_update", {"key": key, "value": str(value)[:200]})

    def get_state(self, key: str, default: Any = None) -> Any:
        """Get value from agent state"""
        return self.state.get(key, default)

    async def generate_structured_output(
        self,
        prompt: str,
        schema: Dict[str, Any],
        context: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """
        Generate structured output from LLM

        Args:
            prompt: Prompt for generation
            schema: Expected output schema
            context: Optional context to include

        Returns:
            Structured output as dictionary
        """
        context_str = ""
        if context:
            context_str = f"\n\nContext:\n{json.dumps(context, indent=2)}"

        full_prompt = f"""{prompt}{context_str}

Please provide your response in the following JSON format:
{json.dumps(schema, indent=2)}

Return ONLY the JSON, no additional text."""

        response = await self.invoke_llm([{"role": "user", "content": full_prompt}])

        # Try to extract JSON from response
        try:
            # Find JSON in response
            start_idx = response.find("{")
            end_idx = response.rfind("}") + 1
            if start_idx != -1 and end_idx > start_idx:
                json_str = response[start_idx:end_idx]
                return json.loads(json_str)
            else:
                # If no JSON found, return as is
                return {"raw_response": response}
        except json.JSONDecodeError:
            return {"raw_response": response}

    def format_context(self, data: Dict[str, Any], max_length: int = 4000) -> str:
        """
        Format data as context string with length limit

        Args:
            data: Data to format
            max_length: Maximum length of output

        Returns:
            Formatted context string
        """
        formatted = json.dumps(data, indent=2)
        if len(formatted) > max_length:
            formatted = formatted[:max_length] + "\n... (truncated)"
        return formatted
