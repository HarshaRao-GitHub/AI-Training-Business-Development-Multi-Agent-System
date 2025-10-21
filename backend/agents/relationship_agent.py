"""
Relationship Management Agent
Handles client communication, follow-ups, and relationship touchpoints
"""
from typing import Dict, Any, List
from .base_agent import BaseAgent
from datetime import datetime, timedelta
import json


class RelationshipAgent(BaseAgent):
    """Relationship Management Agent for client communication"""

    def __init__(self):
        system_prompt = """You are an expert Relationship Management Agent for AI corporate training services.

Your responsibilities:
1. Manage client communication and engagement
2. Schedule and prepare for meetings
3. Draft personalized outreach messages
4. Track communication history and sentiment
5. Optimize follow-up timing and strategy
6. Maintain relationship touchpoints

Your expertise includes:
- Professional communication best practices
- Relationship-building strategies
- CRM management and pipeline nurturing
- Sentiment analysis and social reading
- Cross-cultural communication
- Strategic timing and cadence
- Objection handling and negotiation support

You are:
- Empathetic and personable
- Strategic about relationship development
- Data-driven in analyzing engagement patterns
- Culturally aware and adaptable
- Focused on long-term relationship value

You understand that B2B relationships require patience, persistence, and genuine value delivery."""

        super().__init__(
            agent_type="relationship",
            agent_name="Relationship Management Agent",
            system_prompt=system_prompt
        )

    async def execute(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        """Execute relationship management task"""
        task = input_data.get("task")
        parameters = input_data.get("parameters", {})

        self.log_execution("execute", {"task": task, "parameters": parameters})

        if task == "analyze_interaction":
            return await self.analyze_interaction(parameters)
        elif task == "suggest_followup":
            return await self.suggest_followup(parameters)
        elif task == "prepare_meeting":
            return await self.prepare_meeting(parameters)
        elif task == "analyze_sentiment":
            return await self.analyze_sentiment(parameters)
        elif task == "plan_touchpoints":
            return await self.plan_touchpoints(parameters)
        elif task == "handle_objection":
            return await self.handle_objection(parameters)
        else:
            return {"error": f"Unknown task: {task}"}

    async def analyze_interaction(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Analyze a communication interaction"""
        interaction_data = parameters.get("interaction_data", {})
        interaction_type = interaction_data.get("type", "email")
        content = interaction_data.get("content", "")
        lead_data = parameters.get("lead_data", {})

        # Get interaction history
        history = await self.search_knowledge_base(
            query=f"{lead_data.get('company_name', '')} interaction communication",
            collection_name="interactions",
            n_results=5
        )

        context = {
            "interaction": interaction_data,
            "lead_data": lead_data,
            "history": [item["metadata"] for item in history]
        }

        prompt = f"""Analyze this client interaction and provide insights.

Interaction Type: {interaction_type}
Content: {content}

Company: {lead_data.get('company_name', 'Unknown')}

Analyze:
1. SENTIMENT
   - Overall tone (positive/neutral/negative/mixed)
   - Level of interest and engagement
   - Emotional indicators

2. KEY POINTS
   - Main topics discussed
   - Questions asked
   - Concerns raised
   - Decisions or commitments made

3. BUYING SIGNALS
   - Positive signals indicating interest
   - Negative signals or red flags
   - Urgency indicators
   - Budget or authority hints

4. NEXT STEPS
   - Actions they committed to
   - Actions we need to take
   - Timeline expectations
   - Who needs to be involved

5. RELATIONSHIP HEALTH
   - Quality of engagement
   - Level of access and responsiveness
   - Trust indicators
   - Potential issues

6. RECOMMENDATIONS
   - Suggested follow-up approach
   - Timing for next contact
   - Who should reach out
   - What to emphasize

Provide specific, actionable insights."""

        response = await self.invoke_llm([{
            "role": "user",
            "content": f"{prompt}\n\nContext:\n{self.format_context(context, max_length=2000)}"
        }])

        # Extract structured analysis
        schema = {
            "sentiment": "positive|neutral|negative|mixed",
            "engagement_level": "high|medium|low",
            "key_points": ["list"],
            "buying_signals": ["list"],
            "concerns": ["list"],
            "next_steps": [
                {
                    "action": "string",
                    "owner": "client|us",
                    "timeline": "string"
                }
            ],
            "relationship_health_score": "1-10",
            "recommended_followup_timing": "string",
            "priority": "high|medium|low"
        }

        structured_analysis = await self.generate_structured_output(
            f"Extract key data from this interaction analysis:\n\n{response}",
            schema
        )

        # Store interaction analysis
        await self.store_knowledge(
            content=response,
            metadata={
                "type": "interaction_analysis",
                "company_name": lead_data.get("company_name", "Unknown"),
                "interaction_type": interaction_type,
                "sentiment": structured_analysis.get("sentiment", "neutral"),
                "date": datetime.utcnow().isoformat(),
                "agent": self.agent_name
            },
            collection_name="interactions"
        )

        return {
            "analysis": response,
            "structured_analysis": structured_analysis,
            "metadata": {
                "interaction_type": interaction_type,
                "date": datetime.utcnow().isoformat()
            }
        }

    async def suggest_followup(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Suggest optimal follow-up strategy"""
        lead_data = parameters.get("lead_data", {})
        last_interaction = parameters.get("last_interaction", {})
        stage = parameters.get("stage", "initial")

        # Get interaction history
        history = await self.search_knowledge_base(
            query=f"{lead_data.get('company_name', '')} interaction history",
            collection_name="interactions",
            n_results=10
        )

        context = {
            "lead_data": lead_data,
            "last_interaction": last_interaction,
            "stage": stage,
            "interaction_count": len(history),
            "last_sentiment": last_interaction.get("sentiment", "neutral")
        }

        prompt = f"""Suggest optimal follow-up strategy for this lead.

Lead: {lead_data.get('company_name', 'Unknown')}
Current Stage: {stage}
Last Interaction: {last_interaction.get('date', 'Unknown')} - {last_interaction.get('type', 'Unknown')}
Last Sentiment: {last_interaction.get('sentiment', 'Unknown')}

Total Interactions: {len(history)}

Provide:
1. TIMING
   - Optimal timing for next contact
   - Reasoning for this timing
   - Backup timing if no response

2. CHANNEL
   - Best communication channel (email/call/LinkedIn/meeting)
   - Reasoning for channel choice
   - Alternative channels

3. MESSENGER
   - Who should reach out (salesperson/executive/technical expert)
   - Reasoning

4. CONTENT STRATEGY
   - Main message and angle
   - Value to provide
   - Call-to-action
   - Tone and approach

5. PREPARATION
   - Information to gather beforehand
   - Resources to prepare
   - Potential objections to address

6. SUCCESS METRICS
   - What constitutes a successful follow-up
   - Signals to watch for
   - Red flags

Consider:
- Relationship stage and maturity
- Previous response patterns
- Industry norms and buying cycles
- Prospect's communication preferences
- Cultural and regional factors"""

        response = await self.invoke_llm([{
            "role": "user",
            "content": f"{prompt}\n\nContext:\n{self.format_context(context)}"
        }])

        # Extract structured follow-up plan
        schema = {
            "recommended_timing": "string",
            "recommended_channel": "string",
            "recommended_messenger": "string",
            "key_message": "string",
            "call_to_action": "string",
            "preparation_items": ["list"],
            "success_criteria": ["list"]
        }

        structured_plan = await self.generate_structured_output(
            f"Extract follow-up plan details:\n\n{response}",
            schema
        )

        return {
            "analysis": response,
            "structured_plan": structured_plan,
            "metadata": {
                "company_name": lead_data.get("company_name", "Unknown"),
                "stage": stage,
                "date": datetime.utcnow().isoformat()
            }
        }

    async def prepare_meeting(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Prepare briefing materials for a meeting"""
        meeting_data = parameters.get("meeting_data", {})
        lead_data = parameters.get("lead_data", {})
        meeting_type = meeting_data.get("type", "discovery")

        # Gather relevant information
        company_name = lead_data.get("company_name", "Unknown")

        # Search for all relevant context
        company_knowledge = await self.search_knowledge_base(
            query=f"{company_name} business context training needs",
            collection_name="knowledge_base",
            n_results=5
        )

        interactions = await self.search_knowledge_base(
            query=f"{company_name} interaction communication",
            collection_name="interactions",
            n_results=5
        )

        context = {
            "meeting": meeting_data,
            "lead": lead_data,
            "company_knowledge": [item["content"][:300] for item in company_knowledge],
            "recent_interactions": [item["metadata"] for item in interactions]
        }

        prompt = f"""Create comprehensive meeting preparation materials.

Meeting Details:
- Type: {meeting_type}
- Date/Time: {meeting_data.get('datetime', 'TBD')}
- Duration: {meeting_data.get('duration', '30 minutes')}
- Attendees (their side): {', '.join(meeting_data.get('their_attendees', []))}
- Attendees (our side): {', '.join(meeting_data.get('our_attendees', []))}

Company: {company_name}
Industry: {lead_data.get('industry', 'Unknown')}

Create:

1. MEETING OBJECTIVES
   - Primary objective
   - Secondary objectives
   - Success criteria

2. ATTENDEE BRIEF
   For each attendee on their side:
   - Role and background
   - Their likely priorities
   - Questions they might ask
   - How to position to them

3. DISCUSSION TOPICS
   - Key topics to cover
   - Questions to ask them
   - Information to gather
   - Points to emphasize

4. PREPARATION CHECKLIST
   - Materials to bring
   - Demos or examples to prepare
   - Data points to have ready
   - Resources to reference

5. ANTICIPATED QUESTIONS
   - Likely questions they'll ask
   - Suggested responses
   - Questions to avoid or redirect

6. CONVERSATION GUIDE
   - Opening (first 5 minutes)
   - Main discussion flow
   - Closing and next steps
   - Time allocation

7. OBJECTION HANDLING
   - Potential concerns or objections
   - Response strategies
   - Proof points to use

8. FOLLOW-UP PLAN
   - Materials to send after
   - Next steps to propose
   - Timeline suggestions

Make it actionable and specific."""

        response = await self.invoke_llm([{
            "role": "user",
            "content": f"{prompt}\n\nContext:\n{self.format_context(context, max_length=2000)}"
        }])

        return {
            "meeting_prep": response,
            "metadata": {
                "company_name": company_name,
                "meeting_type": meeting_type,
                "date": datetime.utcnow().isoformat()
            }
        }

    async def analyze_sentiment(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Analyze sentiment from communications"""
        communications = parameters.get("communications", [])
        lead_data = parameters.get("lead_data", {})

        prompt = f"""Analyze sentiment trends from these communications with {lead_data.get('company_name', 'this lead')}.

Communications to analyze:
{json.dumps(communications, indent=2)}

Provide:

1. OVERALL SENTIMENT TREND
   - Current sentiment (positive/neutral/negative)
   - Trend direction (improving/stable/declining)
   - Confidence in assessment

2. SENTIMENT BY INTERACTION
   For each communication:
   - Sentiment score and category
   - Key indicators
   - Notable changes from previous

3. ENGAGEMENT QUALITY
   - Response rate and speed
   - Depth of responses
   - Initiative shown
   - Question quality

4. WARNING SIGNS
   - Any red flags or concerns
   - Declining engagement indicators
   - Objection patterns

5. POSITIVE INDICATORS
   - Signs of increasing interest
   - Commitment signals
   - Relationship deepening

6. RECOMMENDATIONS
   - Actions to improve sentiment
   - Risks to mitigate
   - Opportunities to leverage

Be specific and evidence-based."""

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        return {
            "sentiment_analysis": response,
            "metadata": {
                "company_name": lead_data.get("company_name", "Unknown"),
                "communications_analyzed": len(communications),
                "date": datetime.utcnow().isoformat()
            }
        }

    async def plan_touchpoints(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Plan relationship touchpoints over time"""
        lead_data = parameters.get("lead_data", {})
        timeframe_days = parameters.get("timeframe_days", 90)
        stage = parameters.get("stage", "nurture")

        prompt = f"""Create a strategic touchpoint plan for the next {timeframe_days} days.

Lead: {lead_data.get('company_name', 'Unknown')}
Current Stage: {stage}
Timeframe: {timeframe_days} days

Create a detailed touchpoint calendar with:

For each touchpoint:
1. Date/Timing (relative to today)
2. Type of touchpoint (email/call/content share/meeting/social media)
3. Purpose and objective
4. Content/Message theme
5. Value provided to prospect
6. Success metrics

Touchpoint Guidelines:
- Early stage: More educational, relationship-building
- Middle stage: More consultative, solution-focused
- Late stage: More specific, decision-support

Include mix of:
- Direct outreach (emails, calls)
- Value delivery (content, insights, resources)
- Social engagement (LinkedIn, etc.)
- Events/Webinars
- Check-ins

Balance persistence with respect for their time.
Ensure each touchpoint provides genuine value.
Build momentum toward a decision.

Format as a calendar/timeline."""

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        # Extract structured touchpoints
        schema = {
            "touchpoints": [
                {
                    "day": "number",
                    "type": "string",
                    "purpose": "string",
                    "action": "string",
                    "value_provided": "string"
                }
            ]
        }

        structured_plan = await self.generate_structured_output(
            f"Extract touchpoint schedule:\n\n{response}",
            schema
        )

        return {
            "touchpoint_plan": response,
            "structured_plan": structured_plan,
            "metadata": {
                "company_name": lead_data.get("company_name", "Unknown"),
                "timeframe_days": timeframe_days,
                "stage": stage,
                "date": datetime.utcnow().isoformat()
            }
        }

    async def handle_objection(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Provide guidance on handling a specific objection"""
        objection = parameters.get("objection", "")
        objection_type = parameters.get("objection_type", "general")
        lead_data = parameters.get("lead_data", {})

        prompt = f"""Provide comprehensive guidance on handling this objection.

Objection: "{objection}"
Type: {objection_type}
Company: {lead_data.get('company_name', 'Unknown')}
Industry: {lead_data.get('industry', 'Unknown')}

Provide:

1. OBJECTION ANALYSIS
   - What this objection really means
   - Underlying concern or fear
   - Whether it's a true objection or a smokescreen

2. RESPONSE STRATEGY
   - Overall approach (acknowledge, reframe, address)
   - Key message
   - Tone to use

3. RESPONSE SCRIPT
   - Opening acknowledgment
   - Core response
   - Supporting evidence/examples
   - Question to ask
   - Close/transition

4. PROOF POINTS
   - Data, metrics, or case studies to reference
   - Examples that counter the objection
   - Third-party validation

5. QUESTIONS TO ASK
   - Clarifying questions
   - Questions to uncover real concern
   - Questions to advance the conversation

6. WHAT TO AVOID
   - Common mistakes in handling this objection
   - Things not to say
   - Defensive responses

7. FOLLOW-UP
   - Materials to send
   - Additional resources
   - Next steps to propose

Be specific and provide actual language to use."""

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        return {
            "objection_handling_guide": response,
            "metadata": {
                "objection": objection,
                "objection_type": objection_type,
                "company_name": lead_data.get("company_name", "Unknown"),
                "date": datetime.utcnow().isoformat()
            }
        }
