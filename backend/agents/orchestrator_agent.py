"""
Task Orchestration Agent (Supervisor)
Coordinates all other agents and manages workflow
"""
from typing import Dict, Any, List, Optional
from .base_agent import BaseAgent
from .research_agent import ResearchAgent
from .lead_gen_agent import LeadGenerationAgent
from .content_agent import ContentAgent
from .relationship_agent import RelationshipAgent
from .knowledge_agent import KnowledgeAgent
from .analytics_agent import AnalyticsAgent
from datetime import datetime
import json


class OrchestratorAgent(BaseAgent):
    """Orchestrator Agent that coordinates all specialized agents"""

    def __init__(self):
        system_prompt = """You are the Task Orchestration Agent, the intelligent coordinator of a multi-agent business development system for AI corporate training.

Your responsibilities:
1. Analyze incoming requests and determine which agents to engage
2. Prioritize tasks across all agents
3. Route requests to appropriate specialized agents
4. Coordinate multi-agent workflows
5. Manage dependencies between agent tasks
6. Maintain overall system context and state
7. Escalate complex issues requiring human intervention
8. Synthesize outputs from multiple agents

Your capabilities:
- Strategic task planning and decomposition
- Intelligent agent selection and routing
- Workflow orchestration and coordination
- Context management across agent boundaries
- Decision-making on task prioritization
- Quality control of agent outputs
- Escalation judgment

Available Agents:
1. Research Agent - Market research, trends, competitor analysis
2. Lead Generation Agent - Identifying and qualifying leads
3. Content Agent - Proposals, case studies, emails, presentations
4. Relationship Agent - Communication, follow-ups, meeting prep
5. Knowledge Agent - Retrieving and organizing institutional knowledge
6. Analytics Agent - Performance tracking, forecasting, insights

You are strategic, efficient, and focused on maximizing business outcomes."""

        super().__init__(
            agent_type="orchestrator",
            agent_name="Task Orchestration Agent",
            system_prompt=system_prompt
        )

        # Initialize all specialized agents
        self.agents = {
            "research": ResearchAgent(),
            "lead_generation": LeadGenerationAgent(),
            "content": ContentAgent(),
            "relationship": RelationshipAgent(),
            "knowledge": KnowledgeAgent(),
            "analytics": AnalyticsAgent()
        }

    async def execute(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        """Execute orchestrated workflow"""
        task = input_data.get("task")
        parameters = input_data.get("parameters", {})

        self.log_execution("execute", {"task": task, "parameters": parameters})

        if task == "process_request":
            return await self.process_request(parameters)
        elif task == "daily_routine":
            return await self.daily_routine(parameters)
        elif task == "handle_new_lead":
            return await self.handle_new_lead(parameters)
        elif task == "create_proposal_workflow":
            return await self.create_proposal_workflow(parameters)
        elif task == "analyze_opportunity":
            return await self.analyze_opportunity(parameters)
        else:
            return {"error": f"Unknown task: {task}"}

    async def process_request(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Process a general request by routing to appropriate agents"""
        request = parameters.get("request", "")
        context = parameters.get("context", {})

        # Analyze request to determine agent routing
        prompt = f"""Analyze this business development request and determine how to handle it.

Request: {request}

Context: {json.dumps(context, indent=2)}

Available Agents and their capabilities:
1. Research Agent - Market analysis, trends, competitor research, opportunities
2. Lead Generation Agent - Find leads, qualify leads, score leads, find decision-makers
3. Content Agent - Create proposals, case studies, emails, presentations
4. Relationship Agent - Analyze interactions, plan follow-ups, prep meetings
5. Knowledge Agent - Find similar cases, extract lessons, retrieve best practices
6. Analytics Agent - Pipeline analysis, forecasting, win/loss analysis, reports

Determine:
1. Which agent(s) should handle this request
2. In what order should agents be engaged
3. What specific tasks each agent should perform
4. What information to pass between agents
5. Expected output format

Provide a detailed execution plan as JSON:
{{
    "workflow_steps": [
        {{
            "agent": "agent_name",
            "task": "specific_task",
            "parameters": {{}},
            "depends_on": ["previous_step_ids"],
            "output_key": "key_for_this_output"
        }}
    ],
    "final_synthesis": "How to combine agent outputs",
    "escalation_needed": false,
    "estimated_complexity": "low|medium|high"
}}"""

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        # Extract workflow plan
        try:
            start_idx = response.find("{")
            end_idx = response.rfind("}") + 1
            workflow_json = response[start_idx:end_idx]
            workflow_plan = json.loads(workflow_json)
        except:
            return {
                "error": "Could not parse workflow plan",
                "raw_response": response
            }

        # Execute workflow
        results = await self.execute_workflow(workflow_plan)

        return {
            "request": request,
            "workflow_plan": workflow_plan,
            "results": results,
            "metadata": {
                "date": datetime.utcnow().isoformat(),
                "agents_used": list(set([step["agent"] for step in workflow_plan.get("workflow_steps", [])]))
            }
        }

    async def execute_workflow(self, workflow_plan: Dict[str, Any]) -> Dict[str, Any]:
        """Execute a multi-agent workflow"""
        steps = workflow_plan.get("workflow_steps", [])
        results = {}

        for i, step in enumerate(steps):
            agent_name = step.get("agent")
            task = step.get("task")
            parameters = step.get("parameters", {})
            output_key = step.get("output_key", f"step_{i}")

            # Get agent
            agent = self.agents.get(agent_name)
            if not agent:
                results[output_key] = {"error": f"Unknown agent: {agent_name}"}
                continue

            # Check dependencies
            depends_on = step.get("depends_on", [])
            for dep in depends_on:
                if dep in results:
                    # Add dependency results to parameters
                    parameters[f"{dep}_result"] = results[dep]

            # Execute agent task
            try:
                result = await agent.execute({
                    "task": task,
                    "parameters": parameters
                })
                results[output_key] = result
                self.log_execution("workflow_step_complete", {
                    "step": i,
                    "agent": agent_name,
                    "task": task,
                    "success": True
                })
            except Exception as e:
                results[output_key] = {"error": str(e)}
                self.log_execution("workflow_step_error", {
                    "step": i,
                    "agent": agent_name,
                    "task": task,
                    "error": str(e)
                })

        return results

    async def daily_routine(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Execute daily business development routine"""
        date = parameters.get("date", datetime.utcnow().strftime("%Y-%m-%d"))

        workflow = {
            "workflow_steps": [
                {
                    "agent": "research",
                    "task": "intelligence_brief",
                    "parameters": {"type": "daily"},
                    "output_key": "morning_brief"
                },
                {
                    "agent": "lead_generation",
                    "task": "identify_leads",
                    "parameters": {
                        "criteria": {
                            "limit": 10,
                            "focus": "high_potential"
                        }
                    },
                    "output_key": "new_leads"
                },
                {
                    "agent": "analytics",
                    "task": "pipeline_analysis",
                    "parameters": {"time_period": "current"},
                    "output_key": "pipeline_status"
                },
                {
                    "agent": "relationship",
                    "task": "suggest_followup",
                    "parameters": {"scope": "overdue_and_due_today"},
                    "output_key": "followup_plan"
                }
            ]
        }

        results = await self.execute_workflow(workflow)

        # Synthesize daily summary
        summary_prompt = f"""Synthesize these daily routine outputs into an executive summary.

Intelligence Brief: {str(results.get('morning_brief', {}))[:500]}
New Leads: {str(results.get('new_leads', {}))[:500]}
Pipeline Status: {str(results.get('pipeline_status', {}))[:500]}
Follow-up Plan: {str(results.get('followup_plan', {}))[:500]}

Create a concise daily summary with:
1. Key highlights and priorities for today
2. Top opportunities to pursue
3. Critical actions needed
4. Risks or concerns
5. Recommended focus areas

Keep it brief and actionable (300-400 words)."""

        summary = await self.invoke_llm([{"role": "user", "content": summary_prompt}])

        return {
            "daily_summary": summary,
            "detailed_results": results,
            "metadata": {
                "date": date,
                "timestamp": datetime.utcnow().isoformat()
            }
        }

    async def handle_new_lead(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Complete workflow for handling a new lead"""
        lead_data = parameters.get("lead_data", {})
        company_name = lead_data.get("company_name", "Unknown")

        workflow = {
            "workflow_steps": [
                {
                    "agent": "lead_generation",
                    "task": "enrich_lead",
                    "parameters": {"lead_data": lead_data},
                    "output_key": "enriched_data"
                },
                {
                    "agent": "lead_generation",
                    "task": "score_lead",
                    "parameters": {"lead_data": lead_data},
                    "depends_on": ["enriched_data"],
                    "output_key": "lead_score"
                },
                {
                    "agent": "research",
                    "task": "identify_opportunities",
                    "parameters": {
                        "criteria": {
                            "industry": lead_data.get("industry"),
                            "company_size": lead_data.get("company_size")
                        }
                    },
                    "output_key": "opportunities"
                },
                {
                    "agent": "knowledge",
                    "task": "find_similar_cases",
                    "parameters": {
                        "query_data": {
                            "industry": lead_data.get("industry"),
                            "company_size": lead_data.get("company_size")
                        }
                    },
                    "output_key": "similar_cases"
                },
                {
                    "agent": "content",
                    "task": "create_email",
                    "parameters": {
                        "email_type": "initial_outreach",
                        "recipient_data": lead_data
                    },
                    "depends_on": ["enriched_data", "opportunities"],
                    "output_key": "outreach_email"
                }
            ]
        }

        results = await self.execute_workflow(workflow)

        # Create summary recommendation
        recommendation_prompt = f"""Based on the complete lead analysis, provide recommendations.

Company: {company_name}
Lead Score: {str(results.get('lead_score', {}))[:300]}
Similar Cases: {str(results.get('similar_cases', {}))[:300]}

Provide:
1. Overall assessment (pursue/nurture/deprioritize)
2. Key strengths of this opportunity
3. Potential challenges
4. Recommended approach
5. Immediate next steps
6. Expected timeline to close

Be specific and actionable."""

        recommendation = await self.invoke_llm([{"role": "user", "content": recommendation_prompt}])

        return {
            "recommendation": recommendation,
            "detailed_analysis": results,
            "metadata": {
                "company_name": company_name,
                "timestamp": datetime.utcnow().isoformat()
            }
        }

    async def create_proposal_workflow(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Complete workflow for creating a proposal"""
        lead_data = parameters.get("lead_data", {})
        requirements = parameters.get("requirements", {})
        company_name = lead_data.get("company_name", "Prospect")

        workflow = {
            "workflow_steps": [
                {
                    "agent": "knowledge",
                    "task": "find_similar_cases",
                    "parameters": {
                        "query_data": {
                            "industry": lead_data.get("industry"),
                            "training_needs": requirements.get("training_topics", [])
                        }
                    },
                    "output_key": "similar_proposals"
                },
                {
                    "agent": "knowledge",
                    "task": "retrieve_best_practices",
                    "parameters": {
                        "scenario": "proposal_creation",
                        "context": {"industry": lead_data.get("industry")}
                    },
                    "output_key": "best_practices"
                },
                {
                    "agent": "research",
                    "task": "analyze_market",
                    "parameters": {
                        "industry": lead_data.get("industry"),
                        "focus_areas": requirements.get("training_topics", [])
                    },
                    "output_key": "market_context"
                },
                {
                    "agent": "content",
                    "task": "create_proposal",
                    "parameters": {
                        "lead_data": lead_data,
                        "training_requirements": requirements
                    },
                    "depends_on": ["similar_proposals", "market_context"],
                    "output_key": "proposal"
                },
                {
                    "agent": "content",
                    "task": "create_presentation",
                    "parameters": {
                        "presentation_type": "proposal",
                        "audience_data": lead_data,
                        "duration_minutes": 30
                    },
                    "depends_on": ["proposal"],
                    "output_key": "presentation"
                }
            ]
        }

        results = await self.execute_workflow(workflow)

        # Create cover email for proposal
        email_workflow = {
            "workflow_steps": [
                {
                    "agent": "content",
                    "task": "create_email",
                    "parameters": {
                        "email_type": "proposal_followup",
                        "recipient_data": lead_data,
                        "context": {
                            "proposal_date": datetime.utcnow().strftime("%Y-%m-%d")
                        }
                    },
                    "output_key": "cover_email"
                }
            ]
        }

        email_result = await self.execute_workflow(email_workflow)

        return {
            "proposal": results.get("proposal"),
            "presentation": results.get("presentation"),
            "cover_email": email_result.get("cover_email"),
            "supporting_research": {
                "market_context": results.get("market_context"),
                "similar_proposals": results.get("similar_proposals"),
                "best_practices": results.get("best_practices")
            },
            "metadata": {
                "company_name": company_name,
                "timestamp": datetime.utcnow().isoformat()
            }
        }

    async def analyze_opportunity(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Comprehensive opportunity analysis"""
        opportunity_data = parameters.get("opportunity_data", {})

        workflow = {
            "workflow_steps": [
                {
                    "agent": "lead_generation",
                    "task": "qualify_lead",
                    "parameters": {"lead_data": opportunity_data},
                    "output_key": "qualification"
                },
                {
                    "agent": "research",
                    "task": "analyze_market",
                    "parameters": {
                        "industry": opportunity_data.get("industry"),
                        "region": opportunity_data.get("region")
                    },
                    "output_key": "market_analysis"
                },
                {
                    "agent": "analytics",
                    "task": "win_loss_analysis",
                    "parameters": {
                        "deals_data": [],  # Would include historical similar deals
                        "time_period": "last_year"
                    },
                    "output_key": "historical_performance"
                },
                {
                    "agent": "knowledge",
                    "task": "find_similar_cases",
                    "parameters": {
                        "query_data": {
                            "industry": opportunity_data.get("industry"),
                            "company_size": opportunity_data.get("company_size")
                        }
                    },
                    "output_key": "precedents"
                }
            ]
        }

        results = await self.execute_workflow(workflow)

        # Synthesize comprehensive analysis
        synthesis_prompt = f"""Create a comprehensive opportunity analysis.

Opportunity: {opportunity_data.get('company_name')}

Qualification: {str(results.get('qualification', {}))[:400]}
Market Analysis: {str(results.get('market_analysis', {}))[:400]}
Historical Performance: {str(results.get('historical_performance', {}))[:400]}
Similar Cases: {str(results.get('precedents', {}))[:400]}

Provide:
1. OPPORTUNITY SCORE (1-10)
2. GO/NO-GO RECOMMENDATION
3. KEY STRENGTHS
4. KEY RISKS
5. WINNING STRATEGY
6. RESOURCE REQUIREMENTS
7. EXPECTED TIMELINE
8. SUCCESS PROBABILITY
9. ACTION PLAN

Be specific and data-driven."""

        synthesis = await self.invoke_llm([{"role": "user", "content": synthesis_prompt}])

        return {
            "comprehensive_analysis": synthesis,
            "detailed_results": results,
            "metadata": {
                "opportunity": opportunity_data.get("company_name"),
                "timestamp": datetime.utcnow().isoformat()
            }
        }
