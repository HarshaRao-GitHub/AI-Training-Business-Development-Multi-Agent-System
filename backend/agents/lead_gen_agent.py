"""
Lead Generation & Qualification Agent
Identifies and qualifies potential clients for AI training
"""
from typing import Dict, Any, List
from .base_agent import BaseAgent
from datetime import datetime
import json


class LeadGenerationAgent(BaseAgent):
    """Lead Generation and Qualification Agent"""

    def __init__(self):
        system_prompt = """You are an expert Lead Generation and Qualification Agent for AI corporate training services.

Your responsibilities:
1. Identify companies showing AI adoption signals
2. Score and qualify leads based on multiple criteria
3. Research decision-makers and organizational structures
4. Track RFPs and tender opportunities
5. Maintain enriched lead pipeline data

You evaluate leads based on:
- Company size and growth trajectory
- Industry and AI readiness
- Budget indicators and financial health
- Existing AI initiatives and maturity
- Decision-maker accessibility
- Organizational structure and procurement process
- Competitive situation
- Timing and urgency indicators

You are analytical, thorough, and prioritize quality over quantity. You provide detailed lead intelligence to maximize conversion rates."""

        super().__init__(
            agent_type="lead_generation",
            agent_name="Lead Generation & Qualification Agent",
            system_prompt=system_prompt
        )

    async def execute(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        """Execute lead generation task"""
        task = input_data.get("task")
        parameters = input_data.get("parameters", {})

        self.log_execution("execute", {"task": task, "parameters": parameters})

        if task == "identify_leads":
            return await self.identify_leads(parameters)
        elif task == "qualify_lead":
            return await self.qualify_lead(parameters)
        elif task == "enrich_lead":
            return await self.enrich_lead(parameters)
        elif task == "score_lead":
            return await self.score_lead(parameters)
        elif task == "find_decision_makers":
            return await self.find_decision_makers(parameters)
        else:
            return {"error": f"Unknown task: {task}"}

    async def identify_leads(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Identify potential leads based on criteria"""
        criteria = parameters.get("criteria", {})
        industry = criteria.get("industry", "all")
        region = criteria.get("region", "global")
        company_size = criteria.get("company_size", "all")

        prompt = f"""Identify companies that are ideal prospects for AI corporate training services.

Search Criteria:
- Industry: {industry}
- Region: {region}
- Company Size: {company_size}
- AI Adoption Stage: {criteria.get('ai_adoption_stage', 'any')}

For each company identified, provide:
1. Company name and basic details
2. Why they are a good fit (AI adoption signals)
3. Estimated training needs
4. Estimated budget capacity
5. Urgency/timing indicators
6. Key contact information (if available)

Focus on companies showing these signals:
- Recent AI-related announcements or initiatives
- Job postings for AI/ML roles
- Technology stack indicating AI adoption
- Industry pressure to adopt AI
- Digital transformation initiatives
- Regulatory requirements for AI

Provide 10-15 high-quality leads."""

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        # Extract structured leads
        schema = {
            "leads": [
                {
                    "company_name": "string",
                    "industry": "string",
                    "region": "string",
                    "company_size": "string",
                    "ai_adoption_signals": ["list"],
                    "training_needs": "string",
                    "estimated_budget": "string",
                    "urgency": "high|medium|low",
                    "preliminary_score": "1-10"
                }
            ]
        }

        structured_leads = await self.generate_structured_output(
            f"Extract lead information from this analysis:\n\n{response}",
            schema
        )

        return {
            "analysis": response,
            "structured_leads": structured_leads.get("leads", []),
            "metadata": {
                "criteria": criteria,
                "date": datetime.utcnow().isoformat(),
                "total_leads": len(structured_leads.get("leads", []))
            }
        }

    async def qualify_lead(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Qualify a specific lead"""
        lead_data = parameters.get("lead_data", {})
        company_name = lead_data.get("company_name", "Unknown")

        # Search for existing knowledge about this company
        existing_knowledge = await self.search_knowledge_base(
            query=f"{company_name} AI training corporate",
            collection_name="knowledge_base",
            n_results=3
        )

        context = {
            "lead_data": lead_data,
            "existing_knowledge": [item["content"][:300] for item in existing_knowledge]
        }

        prompt = f"""Qualify this lead for AI corporate training services using the BANT framework and additional criteria.

Company: {company_name}

Qualification Criteria:
1. BUDGET: Financial capacity and budget allocation for training
2. AUTHORITY: Access to decision-makers and procurement process
3. NEED: Specific AI training requirements and pain points
4. TIMELINE: Urgency and expected timeline for engagement

Additional Factors:
5. AI Maturity: Current AI adoption stage
6. Competitive Situation: Other vendors they might be considering
7. Strategic Fit: Alignment with our expertise and capabilities
8. Risk Factors: Potential challenges or red flags

For each criterion, provide:
- Assessment (strong/moderate/weak/unknown)
- Supporting evidence
- Specific concerns or opportunities
- Recommended next steps

Provide an overall qualification rating (A/B/C/D) and recommendation (pursue/nurture/deprioritize)."""

        response = await self.invoke_llm([{
            "role": "user",
            "content": f"{prompt}\n\nContext:\n{self.format_context(context)}"
        }])

        # Extract qualification details
        schema = {
            "qualification_rating": "A|B|C|D",
            "recommendation": "pursue|nurture|deprioritize",
            "bant_assessment": {
                "budget": {"rating": "string", "notes": "string"},
                "authority": {"rating": "string", "notes": "string"},
                "need": {"rating": "string", "notes": "string"},
                "timeline": {"rating": "string", "notes": "string"}
            },
            "ai_maturity": "string",
            "strategic_fit": "string",
            "risk_factors": ["list"],
            "next_steps": ["list"]
        }

        structured_qualification = await self.generate_structured_output(
            f"Extract qualification assessment:\n\n{response}",
            schema
        )

        return {
            "analysis": response,
            "structured_qualification": structured_qualification,
            "metadata": {
                "company_name": company_name,
                "date": datetime.utcnow().isoformat()
            }
        }

    async def enrich_lead(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Enrich lead with additional intelligence"""
        lead_data = parameters.get("lead_data", {})
        company_name = lead_data.get("company_name", "Unknown")

        prompt = f"""Provide comprehensive enrichment data for this lead.

Company: {company_name}
Known Information: {json.dumps(lead_data, indent=2)}

Research and provide:
1. Company Profile:
   - Full legal name and headquarters
   - Industry classification and sub-sectors
   - Company size (employees, revenue if public)
   - Geographic presence and key locations

2. Technology & AI Context:
   - Current technology stack and infrastructure
   - Known AI/ML initiatives or projects
   - Digital transformation maturity
   - Technology partnerships and vendors

3. Business Context:
   - Recent news and developments
   - Growth trajectory and market position
   - Strategic priorities and challenges
   - Competitive pressures

4. Decision-Making Structure:
   - Organizational hierarchy
   - Key departments involved in training decisions
   - Procurement process characteristics
   - Budget cycles and approval workflows

5. Training Context:
   - Historical training programs and vendors
   - Learning & development culture
   - Remote vs in-person preferences
   - Typical engagement sizes

Provide specific, verifiable information where possible."""

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        # Store enriched data in knowledge base
        await self.store_knowledge(
            content=response,
            metadata={
                "type": "lead_enrichment",
                "company_name": company_name,
                "date": datetime.utcnow().isoformat(),
                "agent": self.agent_name
            },
            collection_name="knowledge_base"
        )

        return {
            "enriched_data": response,
            "metadata": {
                "company_name": company_name,
                "date": datetime.utcnow().isoformat()
            }
        }

    async def score_lead(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Score a lead numerically"""
        lead_data = parameters.get("lead_data", {})
        scoring_criteria = parameters.get("scoring_criteria", self._default_scoring_criteria())

        prompt = f"""Score this lead on a scale of 0-100 based on the following criteria.

Lead Data: {json.dumps(lead_data, indent=2)}

Scoring Criteria:
{json.dumps(scoring_criteria, indent=2)}

For each criterion:
1. Provide a score
2. Explain your reasoning
3. Cite specific evidence from the lead data

Then calculate:
- Total weighted score (0-100)
- Confidence level in this score (high/medium/low)
- Category (Hot: 80+, Warm: 60-79, Cold: <60)

Also provide:
- Top 3 positive factors
- Top 3 concerns or gaps
- Recommended priority level"""

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        # Extract scoring details
        schema = {
            "total_score": "number 0-100",
            "category": "hot|warm|cold",
            "confidence_level": "high|medium|low",
            "criterion_scores": {},
            "positive_factors": ["list"],
            "concerns": ["list"],
            "priority": "high|medium|low"
        }

        structured_score = await self.generate_structured_output(
            f"Extract scoring details:\n\n{response}",
            schema
        )

        return {
            "analysis": response,
            "structured_score": structured_score,
            "metadata": {
                "date": datetime.utcnow().isoformat(),
                "criteria_used": scoring_criteria
            }
        }

    async def find_decision_makers(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Identify decision-makers at a company"""
        company_name = parameters.get("company_name", "Unknown")
        department_focus = parameters.get("department_focus", ["Learning & Development", "HR", "IT"])

        prompt = f"""Identify key decision-makers at {company_name} for AI corporate training purchases.

Target Departments: {', '.join(department_focus)}

For each decision-maker, provide:
1. Name and current title
2. Department and reporting structure
3. Role in training decisions (decision maker / influencer / gatekeeper)
4. Background and expertise areas
5. LinkedIn profile (if known)
6. Recent activities or posts relevant to AI/training
7. Best approach to reach them

Identify at least:
- 1-2 C-level executives (sponsors)
- 2-3 VP/Director level (decision makers)
- 2-3 Manager level (influencers/users)

For each, note:
- Their likely priorities and concerns
- How to position our services to them
- Potential objections they might raise"""

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        # Extract decision-maker details
        schema = {
            "decision_makers": [
                {
                    "name": "string",
                    "title": "string",
                    "department": "string",
                    "role_type": "decision_maker|influencer|gatekeeper",
                    "linkedin": "string",
                    "priorities": ["list"],
                    "approach_strategy": "string"
                }
            ]
        }

        structured_contacts = await self.generate_structured_output(
            f"Extract decision-maker information:\n\n{response}",
            schema
        )

        # Store in knowledge base
        await self.store_knowledge(
            content=response,
            metadata={
                "type": "decision_makers",
                "company_name": company_name,
                "date": datetime.utcnow().isoformat(),
                "agent": self.agent_name
            },
            collection_name="knowledge_base"
        )

        return {
            "analysis": response,
            "structured_contacts": structured_contacts.get("decision_makers", []),
            "metadata": {
                "company_name": company_name,
                "date": datetime.utcnow().isoformat()
            }
        }

    def _default_scoring_criteria(self) -> Dict[str, Any]:
        """Default lead scoring criteria"""
        return {
            "company_size": {
                "weight": 15,
                "description": "Company size and scale (employees, revenue)"
            },
            "budget_capacity": {
                "weight": 20,
                "description": "Financial capacity and training budget allocation"
            },
            "ai_readiness": {
                "weight": 20,
                "description": "AI maturity and adoption readiness"
            },
            "need_urgency": {
                "weight": 15,
                "description": "Urgency of training needs and timeline"
            },
            "decision_maker_access": {
                "weight": 10,
                "description": "Ability to reach decision-makers"
            },
            "strategic_fit": {
                "weight": 10,
                "description": "Alignment with our capabilities"
            },
            "competitive_situation": {
                "weight": 10,
                "description": "Competitive intensity and our positioning"
            }
        }
