"""
Research & Intelligence Agent
Handles market research, competitor analysis, and trend monitoring
"""
from typing import Dict, Any, List
from .base_agent import BaseAgent
from datetime import datetime, timedelta
import json


class ResearchAgent(BaseAgent):
    """Research and Intelligence Agent for market insights"""

    def __init__(self):
        system_prompt = """You are an expert Research and Intelligence Agent specializing in the AI corporate training market.

Your responsibilities:
1. Analyze AI/ML industry trends and training needs
2. Monitor competitor offerings and pricing strategies
3. Identify emerging markets and sectors requiring AI training
4. Aggregate insights from various sources
5. Create comprehensive intelligence briefs

You have deep knowledge of:
- AI/ML technologies and their business applications
- Corporate training methodologies and best practices
- Global market dynamics in AI education
- Competitive landscape analysis
- Industry-specific AI adoption patterns

Always provide data-driven, actionable insights with specific recommendations."""

        super().__init__(
            agent_type="research",
            agent_name="Research & Intelligence Agent",
            system_prompt=system_prompt
        )

    async def execute(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Execute research task

        Args:
            input_data: {
                "task": "market_analysis" | "competitor_analysis" | "trend_monitoring" | "intelligence_brief",
                "parameters": {...}
            }
        """
        task = input_data.get("task")
        parameters = input_data.get("parameters", {})

        self.log_execution("execute", {"task": task, "parameters": parameters})

        if task == "market_analysis":
            return await self.analyze_market(parameters)
        elif task == "competitor_analysis":
            return await self.analyze_competitors(parameters)
        elif task == "trend_monitoring":
            return await self.monitor_trends(parameters)
        elif task == "intelligence_brief":
            return await self.create_intelligence_brief(parameters)
        elif task == "identify_opportunities":
            return await self.identify_opportunities(parameters)
        else:
            return {"error": f"Unknown task: {task}"}

    async def analyze_market(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Analyze market for AI training opportunities"""
        industry = parameters.get("industry", "all")
        region = parameters.get("region", "global")
        focus_areas = parameters.get("focus_areas", [])

        prompt = f"""Conduct a comprehensive market analysis for AI corporate training opportunities.

Industry: {industry}
Region: {region}
Focus Areas: {', '.join(focus_areas) if focus_areas else 'General AI/ML training'}

Analyze:
1. Current market size and growth trends
2. Key drivers for AI training adoption
3. Typical training budgets and procurement cycles
4. Decision-maker profiles and organizational structures
5. Common pain points and training needs
6. Emerging opportunities in the next 6-12 months

Provide specific, actionable insights."""

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        # Extract structured insights
        schema = {
            "market_size_estimate": "string",
            "growth_rate": "string",
            "key_drivers": ["list of drivers"],
            "typical_budget_range": "string",
            "decision_makers": ["list of roles"],
            "pain_points": ["list of pain points"],
            "opportunities": ["list of opportunities"],
            "recommendations": ["list of recommendations"]
        }

        structured_insights = await self.generate_structured_output(
            f"Based on this market analysis, extract key data points:\n\n{response}",
            schema
        )

        # Store in knowledge base
        await self.store_knowledge(
            content=response,
            metadata={
                "type": "market_analysis",
                "industry": industry,
                "region": region,
                "date": datetime.utcnow().isoformat(),
                "agent": self.agent_name
            },
            collection_name="research_insights"
        )

        return {
            "analysis": response,
            "structured_insights": structured_insights,
            "metadata": {
                "industry": industry,
                "region": region,
                "date": datetime.utcnow().isoformat()
            }
        }

    async def analyze_competitors(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Analyze competitors in the AI training space"""
        competitors = parameters.get("competitors", [])
        focus = parameters.get("focus", "general")

        prompt = f"""Analyze competitors in the AI corporate training market.

Competitors to analyze: {', '.join(competitors) if competitors else 'Top 5 major players'}
Analysis Focus: {focus}

For each competitor, analyze:
1. Training offerings and curriculum structure
2. Pricing models and typical engagement sizes
3. Target industries and customer segments
4. Unique value propositions and differentiators
5. Strengths and weaknesses
6. Recent developments and strategic moves

Also identify:
- White spaces and underserved segments
- Opportunities to differentiate
- Pricing strategies that are working
- Market positioning insights"""

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        # Store in knowledge base
        await self.store_knowledge(
            content=response,
            metadata={
                "type": "competitor_analysis",
                "competitors": competitors,
                "date": datetime.utcnow().isoformat(),
                "agent": self.agent_name
            },
            collection_name="research_insights"
        )

        return {
            "analysis": response,
            "metadata": {
                "competitors": competitors,
                "date": datetime.utcnow().isoformat()
            }
        }

    async def monitor_trends(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Monitor AI industry trends relevant to training"""
        timeframe = parameters.get("timeframe", "current")
        categories = parameters.get("categories", ["technology", "industry", "education"])

        prompt = f"""Monitor and analyze current trends in AI that are relevant to corporate training needs.

Timeframe: {timeframe}
Categories: {', '.join(categories)}

Identify and analyze:
1. Emerging AI technologies creating training demand
2. Industry shifts driving AI adoption
3. Skills gaps in the current workforce
4. New AI use cases in business
5. Regulatory and compliance requirements
6. Evolution in training delivery methods

For each trend:
- Explain its significance
- Estimate timeline for mainstream adoption
- Identify which industries are most affected
- Suggest training implications"""

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        # Extract key trends
        schema = {
            "trends": [
                {
                    "name": "string",
                    "category": "string",
                    "significance": "string",
                    "timeline": "string",
                    "affected_industries": ["list"],
                    "training_implications": "string"
                }
            ]
        }

        structured_trends = await self.generate_structured_output(
            f"Extract key trends from this analysis:\n\n{response}",
            schema
        )

        # Store in knowledge base
        await self.store_knowledge(
            content=response,
            metadata={
                "type": "trend_monitoring",
                "timeframe": timeframe,
                "categories": categories,
                "date": datetime.utcnow().isoformat(),
                "agent": self.agent_name
            },
            collection_name="research_insights"
        )

        return {
            "analysis": response,
            "structured_trends": structured_trends,
            "metadata": {
                "timeframe": timeframe,
                "date": datetime.utcnow().isoformat()
            }
        }

    async def create_intelligence_brief(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Create daily/weekly intelligence brief"""
        brief_type = parameters.get("type", "daily")  # daily or weekly
        focus_areas = parameters.get("focus_areas", [])

        # Search knowledge base for recent insights
        recent_research = await self.search_knowledge_base(
            query="recent AI training market insights trends opportunities",
            collection_name="research_insights",
            n_results=10
        )

        context = {
            "brief_type": brief_type,
            "focus_areas": focus_areas,
            "recent_insights": [
                {
                    "content": item["content"][:500],
                    "metadata": item["metadata"]
                }
                for item in recent_research
            ]
        }

        prompt = f"""Create a comprehensive intelligence brief for the AI corporate training business.

Brief Type: {brief_type.upper()}
Focus Areas: {', '.join(focus_areas) if focus_areas else 'All areas'}

Include:
1. Executive Summary (key highlights)
2. Market Movements (significant developments)
3. Competitive Intelligence (competitor activities)
4. Opportunities Identified (actionable leads)
5. Trend Analysis (emerging patterns)
6. Action Items (recommended next steps)

Make it concise, actionable, and prioritize information by business impact."""

        response = await self.invoke_llm([{
            "role": "user",
            "content": f"{prompt}\n\nContext:\n{self.format_context(context)}"
        }])

        return {
            "brief": response,
            "metadata": {
                "type": brief_type,
                "date": datetime.utcnow().isoformat(),
                "sources_analyzed": len(recent_research)
            }
        }

    async def identify_opportunities(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Identify new business opportunities based on research"""
        criteria = parameters.get("criteria", {})

        # Search for relevant market insights
        insights = await self.search_knowledge_base(
            query="opportunities markets emerging AI training needs",
            collection_name="research_insights",
            n_results=5
        )

        prompt = f"""Based on market research and trends, identify specific business opportunities for AI corporate training.

Criteria: {json.dumps(criteria, indent=2) if criteria else 'All viable opportunities'}

For each opportunity, specify:
1. Market segment (industry, company size, region)
2. Specific training need or pain point
3. Estimated market size and growth potential
4. Key decision-makers to target
5. Competitive intensity (low/medium/high)
6. Estimated deal size and sales cycle
7. Recommended approach to capture this opportunity

Prioritize by attractiveness and feasibility."""

        response = await self.invoke_llm([{
            "role": "user",
            "content": f"{prompt}\n\nRecent Insights:\n{self.format_context({'insights': insights})}"
        }])

        # Extract structured opportunities
        schema = {
            "opportunities": [
                {
                    "title": "string",
                    "market_segment": "string",
                    "training_need": "string",
                    "market_size": "string",
                    "priority": "high|medium|low",
                    "estimated_deal_size": "string",
                    "recommended_approach": "string"
                }
            ]
        }

        structured_opportunities = await self.generate_structured_output(
            f"Extract opportunities from this analysis:\n\n{response}",
            schema
        )

        return {
            "analysis": response,
            "structured_opportunities": structured_opportunities,
            "metadata": {
                "date": datetime.utcnow().isoformat(),
                "criteria": criteria
            }
        }
