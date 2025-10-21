"""
Knowledge Management Agent
Organizes and retrieves institutional knowledge
"""
from typing import Dict, Any, List
from .base_agent import BaseAgent
from datetime import datetime
import json


class KnowledgeAgent(BaseAgent):
    """Knowledge Management Agent for institutional memory"""

    def __init__(self):
        system_prompt = """You are an expert Knowledge Management Agent for AI corporate training business.

Your responsibilities:
1. Organize and categorize business knowledge
2. Retrieve relevant information for specific use cases
3. Maintain training curriculum library
4. Track what works across different markets
5. Extract lessons learned from past engagements
6. Create knowledge summaries and insights

Your expertise includes:
- Information architecture and taxonomy design
- Semantic search and retrieval
- Pattern recognition across engagements
- Best practice identification
- Knowledge synthesis and summarization
- Metadata management

You help the organization learn from experience and apply past successes to new opportunities."""

        super().__init__(
            agent_type="knowledge",
            agent_name="Knowledge Management Agent",
            system_prompt=system_prompt
        )

    async def execute(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        """Execute knowledge management task"""
        task = input_data.get("task")
        parameters = input_data.get("parameters", {})

        self.log_execution("execute", {"task": task, "parameters": parameters})

        if task == "find_similar_cases":
            return await self.find_similar_cases(parameters)
        elif task == "extract_lessons":
            return await self.extract_lessons(parameters)
        elif task == "summarize_knowledge":
            return await self.summarize_knowledge(parameters)
        elif task == "retrieve_best_practices":
            return await self.retrieve_best_practices(parameters)
        elif task == "update_knowledge":
            return await self.update_knowledge(parameters)
        else:
            return {"error": f"Unknown task: {task}"}

    async def find_similar_cases(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Find similar past cases or engagements"""
        query_data = parameters.get("query_data", {})
        industry = query_data.get("industry", "")
        company_size = query_data.get("company_size", "")
        training_needs = query_data.get("training_needs", [])

        # Search across all collections
        queries = [
            f"{industry} {company_size} training",
            f"{' '.join(training_needs)} AI training",
            f"{industry} AI corporate training success"
        ]

        all_results = []
        for query in queries:
            # Search proposals
            proposals = await self.search_knowledge_base(
                query=query,
                collection_name="proposals",
                n_results=3
            )
            all_results.extend([{**r, "source": "proposals"} for r in proposals])

            # Search case studies
            cases = await self.search_knowledge_base(
                query=query,
                collection_name="case_studies",
                n_results=3
            )
            all_results.extend([{**r, "source": "case_studies"} for r in cases])

        # Remove duplicates and sort by relevance
        seen_ids = set()
        unique_results = []
        for result in all_results:
            if result["id"] not in seen_ids:
                seen_ids.add(result["id"])
                unique_results.append(result)

        unique_results.sort(key=lambda x: x["relevance_score"], reverse=True)
        top_results = unique_results[:5]

        # Analyze similar cases
        prompt = f"""Analyze these similar past cases and extract useful insights.

Current Query:
- Industry: {industry}
- Company Size: {company_size}
- Training Needs: {', '.join(training_needs)}

Similar Cases Found:
{json.dumps([{"content": r["content"][:300], "metadata": r["metadata"], "relevance": r["relevance_score"]} for r in top_results], indent=2)}

Provide:
1. SUMMARY OF SIMILAR CASES
   - Key similarities to current situation
   - Relevant differences to note

2. SUCCESSFUL APPROACHES
   - What worked well in these cases
   - Common success patterns
   - Specific tactics that drove results

3. LESSONS LEARNED
   - Challenges encountered
   - How they were overcome
   - What to avoid

4. APPLICABLE INSIGHTS
   - Specific insights relevant to current query
   - Recommended approach based on past success
   - Customization suggestions

5. REFERENCE MATERIALS
   - Which cases are most relevant
   - What materials to review
   - Key takeaways from each

Be specific and actionable."""

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        return {
            "analysis": response,
            "similar_cases": [
                {
                    "id": r["id"],
                    "source": r["source"],
                    "metadata": r["metadata"],
                    "relevance_score": r["relevance_score"],
                    "excerpt": r["content"][:200]
                }
                for r in top_results
            ],
            "metadata": {
                "query": query_data,
                "cases_found": len(top_results),
                "date": datetime.utcnow().isoformat()
            }
        }

    async def extract_lessons(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Extract lessons learned from engagements"""
        engagement_type = parameters.get("engagement_type", "all")
        timeframe = parameters.get("timeframe", "all_time")
        focus_area = parameters.get("focus_area", "general")

        # Search for relevant engagements
        search_query = f"{engagement_type} {focus_area} lessons learned outcomes"

        case_studies = await self.search_knowledge_base(
            query=search_query,
            collection_name="case_studies",
            n_results=10
        )

        proposals = await self.search_knowledge_base(
            query=f"{search_query} successful",
            collection_name="proposals",
            n_results=5
        )

        context = {
            "case_studies": [item["content"][:400] for item in case_studies],
            "successful_proposals": [item["content"][:400] for item in proposals]
        }

        prompt = f"""Extract comprehensive lessons learned from past engagements.

Focus: {focus_area}
Engagement Type: {engagement_type}
Timeframe: {timeframe}

Analyze the provided cases and proposals to extract:

1. SUCCESS PATTERNS
   - What consistently leads to successful outcomes
   - Key success factors
   - Winning strategies

2. FAILURE PATTERNS
   - Common reasons for lost deals
   - Warning signs to watch for
   - Avoidable mistakes

3. INDUSTRY-SPECIFIC INSIGHTS
   - Patterns by industry
   - What works where
   - Industry-specific challenges

4. PRICING LESSONS
   - Effective pricing strategies
   - Deal size patterns
   - Negotiation insights

5. DELIVERY INSIGHTS
   - Optimal training formats
   - Duration and structure preferences
   - Follow-up and support strategies

6. RELATIONSHIP LESSONS
   - Building trust and credibility
   - Stakeholder management
   - Decision-making patterns

7. COMPETITIVE INSIGHTS
   - How we win against competitors
   - Our differentiators that matter most
   - Competitive vulnerabilities to exploit

8. RECOMMENDATIONS
   - Updated best practices
   - Process improvements
   - Strategy refinements

Be specific with examples and data."""

        response = await self.invoke_llm([{
            "role": "user",
            "content": f"{prompt}\n\nContext:\n{self.format_context(context, max_length=3000)}"
        }])

        # Store lessons learned
        await self.store_knowledge(
            content=response,
            metadata={
                "type": "lessons_learned",
                "focus_area": focus_area,
                "engagement_type": engagement_type,
                "date": datetime.utcnow().isoformat(),
                "agent": self.agent_name
            },
            collection_name="knowledge_base"
        )

        return {
            "lessons_learned": response,
            "metadata": {
                "focus_area": focus_area,
                "cases_analyzed": len(case_studies) + len(proposals),
                "date": datetime.utcnow().isoformat()
            }
        }

    async def summarize_knowledge(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Create knowledge summary on a specific topic"""
        topic = parameters.get("topic", "")
        scope = parameters.get("scope", "comprehensive")

        # Search across all relevant collections
        knowledge_items = await self.search_knowledge_base(
            query=topic,
            collection_name="knowledge_base",
            n_results=10
        )

        research_items = await self.search_knowledge_base(
            query=topic,
            collection_name="research_insights",
            n_results=5
        )

        prompt = f"""Create a comprehensive knowledge summary on: {topic}

Scope: {scope}

Synthesize the following information:

Knowledge Base Items:
{json.dumps([{"content": item["content"][:300], "metadata": item["metadata"]} for item in knowledge_items], indent=2)}

Research Insights:
{json.dumps([{"content": item["content"][:300], "metadata": item["metadata"]} for item in research_items], indent=2)}

Create a summary that includes:

1. OVERVIEW
   - What we know about this topic
   - Key themes and patterns

2. KEY INSIGHTS
   - Most important findings
   - Critical data points
   - Surprising discoveries

3. PRACTICAL APPLICATIONS
   - How to use this knowledge
   - Specific scenarios and use cases
   - Action items

4. KNOWLEDGE GAPS
   - What we don't know yet
   - Areas needing more research
   - Questions to investigate

5. RECOMMENDATIONS
   - Strategic implications
   - Suggested actions
   - Areas to focus on

Make it concise but comprehensive, focusing on actionable insights."""

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        return {
            "knowledge_summary": response,
            "metadata": {
                "topic": topic,
                "sources_analyzed": len(knowledge_items) + len(research_items),
                "date": datetime.utcnow().isoformat()
            }
        }

    async def retrieve_best_practices(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Retrieve best practices for a specific scenario"""
        scenario = parameters.get("scenario", "")
        context = parameters.get("context", {})

        # Search for relevant knowledge
        best_practices = await self.search_knowledge_base(
            query=f"{scenario} best practices success strategies",
            collection_name="knowledge_base",
            n_results=8
        )

        successful_cases = await self.search_knowledge_base(
            query=f"{scenario} successful outcome",
            collection_name="case_studies",
            n_results=5
        )

        prompt = f"""Identify and present best practices for this scenario.

Scenario: {scenario}
Context: {json.dumps(context, indent=2)}

Based on institutional knowledge and successful cases, provide:

1. RECOMMENDED APPROACH
   - Overall strategy
   - Key principles to follow
   - Critical success factors

2. TACTICAL BEST PRACTICES
   - Specific actions to take
   - Step-by-step guidance
   - Timing and sequencing

3. DO'S AND DON'TS
   - What to definitely do
   - What to avoid
   - Common pitfalls

4. SUPPORTING EXAMPLES
   - Real cases where this worked
   - Specific results achieved
   - Why it was successful

5. CUSTOMIZATION GUIDANCE
   - How to adapt for different contexts
   - Variables to consider
   - When to deviate from standard approach

6. METRICS AND VALIDATION
   - How to measure success
   - Key indicators to track
   - Success criteria

Make it practical and immediately actionable."""

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        return {
            "best_practices": response,
            "supporting_cases": [
                {
                    "id": case["id"],
                    "metadata": case["metadata"],
                    "excerpt": case["content"][:200]
                }
                for case in successful_cases
            ],
            "metadata": {
                "scenario": scenario,
                "date": datetime.utcnow().isoformat()
            }
        }

    async def update_knowledge(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Update knowledge base with new information"""
        knowledge_type = parameters.get("knowledge_type", "general")
        content = parameters.get("content", "")
        metadata = parameters.get("metadata", {})
        collection = parameters.get("collection", "knowledge_base")

        # Enhance metadata
        enhanced_metadata = {
            **metadata,
            "type": knowledge_type,
            "date_added": datetime.utcnow().isoformat(),
            "agent": self.agent_name
        }

        # Generate summary and tags
        prompt = f"""Analyze this knowledge and provide metadata.

Content: {content[:1000]}

Provide:
1. Brief summary (2-3 sentences)
2. Relevant tags (5-7 tags)
3. Category classification
4. Relevance/importance score (1-10)

Format as JSON."""

        schema = {
            "summary": "string",
            "tags": ["list of tags"],
            "category": "string",
            "importance_score": "1-10"
        }

        analysis = await self.generate_structured_output(
            prompt,
            schema
        )

        # Add analysis to metadata
        enhanced_metadata.update(analysis)

        # Store in vector database
        doc_id = await self.store_knowledge(
            content=content,
            metadata=enhanced_metadata,
            collection_name=collection
        )

        return {
            "success": True,
            "document_id": doc_id,
            "metadata": enhanced_metadata,
            "summary": analysis.get("summary", ""),
            "date": datetime.utcnow().isoformat()
        }
