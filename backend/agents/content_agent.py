"""
Content & Proposal Agent
Generates business development materials, proposals, and presentations
"""
from typing import Dict, Any, List
from .base_agent import BaseAgent
from datetime import datetime
import json


class ContentAgent(BaseAgent):
    """Content and Proposal Generation Agent"""

    def __init__(self):
        system_prompt = """You are an expert Content and Proposal Agent for AI corporate training services.

Your responsibilities:
1. Create customized training proposals tailored to client needs
2. Develop compelling case studies and success stories
3. Generate professional presentation decks
4. Write persuasive follow-up emails and outreach messages
5. Adapt content for different industries, regions, and audiences

Your expertise includes:
- Persuasive business writing and value proposition development
- Training program design and curriculum structuring
- ROI calculation and business case development
- Industry-specific customization
- Cultural and regional adaptation
- Professional formatting and presentation

You create content that is:
- Client-centric and outcome-focused
- Data-driven with specific metrics and examples
- Professional and polished
- Compelling and persuasive
- Customized to the audience

You always emphasize business value, ROI, and practical outcomes rather than just features."""

        super().__init__(
            agent_type="content",
            agent_name="Content & Proposal Agent",
            system_prompt=system_prompt
        )

    async def execute(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        """Execute content generation task"""
        task = input_data.get("task")
        parameters = input_data.get("parameters", {})

        self.log_execution("execute", {"task": task, "parameters": parameters})

        if task == "create_proposal":
            return await self.create_proposal(parameters)
        elif task == "create_case_study":
            return await self.create_case_study(parameters)
        elif task == "create_email":
            return await self.create_email(parameters)
        elif task == "create_presentation":
            return await self.create_presentation(parameters)
        elif task == "customize_content":
            return await self.customize_content(parameters)
        else:
            return {"error": f"Unknown task: {task}"}

    async def create_proposal(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Create a customized training proposal"""
        lead_data = parameters.get("lead_data", {})
        training_requirements = parameters.get("training_requirements", {})
        company_name = lead_data.get("company_name", "Prospective Client")

        # Search for similar successful proposals
        similar_proposals = await self.search_knowledge_base(
            query=f"successful proposal {lead_data.get('industry', '')} AI training",
            collection_name="proposals",
            n_results=3
        )

        # Search for relevant case studies
        case_studies = await self.search_knowledge_base(
            query=f"case study {lead_data.get('industry', '')} training success",
            collection_name="case_studies",
            n_results=2
        )

        context = {
            "lead_data": lead_data,
            "training_requirements": training_requirements,
            "similar_proposals": [item["content"][:400] for item in similar_proposals],
            "relevant_case_studies": [item["content"][:400] for item in case_studies]
        }

        prompt = f"""Create a comprehensive, customized training proposal for {company_name}.

Lead Information:
{json.dumps(lead_data, indent=2)}

Training Requirements:
{json.dumps(training_requirements, indent=2)}

Create a complete proposal with the following sections:

1. EXECUTIVE SUMMARY
   - Brief overview of the proposed solution
   - Key benefits and expected outcomes
   - Investment summary

2. UNDERSTANDING YOUR NEEDS
   - Client's business context and challenges
   - Specific training requirements identified
   - Strategic alignment with their goals

3. PROPOSED SOLUTION
   - Training program overview and objectives
   - Detailed curriculum and modules
   - Delivery methodology (in-person/virtual/hybrid)
   - Duration and schedule

4. PROGRAM DETAILS
   For each module:
   - Learning objectives
   - Key topics covered
   - Hands-on exercises and projects
   - Expected outcomes

5. OUR EXPERTISE
   - Relevant experience and credentials
   - Subject matter experts and instructors
   - Success with similar clients

6. EXPECTED OUTCOMES & ROI
   - Specific, measurable outcomes
   - ROI framework and metrics
   - Timeline for value realization

7. INVESTMENT
   - Pricing structure (per participant or total)
   - What's included
   - Payment terms
   - Options and add-ons

8. NEXT STEPS
   - Proposed timeline
   - Implementation approach
   - Required resources from client

9. CASE STUDIES
   - 1-2 relevant success stories

Make it professional, specific to their industry and needs, and highly persuasive. Use concrete numbers and examples."""

        response = await self.invoke_llm([{
            "role": "user",
            "content": f"{prompt}\n\nReference Context:\n{self.format_context(context, max_length=2000)}"
        }])

        # Extract key proposal elements
        schema = {
            "title": "string",
            "executive_summary": "string",
            "training_modules": [
                {
                    "module_name": "string",
                    "duration": "string",
                    "objectives": ["list"]
                }
            ],
            "total_duration": "string",
            "proposed_price": "number",
            "key_benefits": ["list"],
            "next_steps": ["list"]
        }

        structured_proposal = await self.generate_structured_output(
            f"Extract key elements from this proposal:\n\n{response[:3000]}",
            schema
        )

        # Store proposal in vector database for future reference
        await self.store_knowledge(
            content=response,
            metadata={
                "type": "proposal",
                "company_name": company_name,
                "industry": lead_data.get("industry", "unknown"),
                "status": "draft",
                "date": datetime.utcnow().isoformat(),
                "agent": self.agent_name
            },
            collection_name="proposals"
        )

        return {
            "proposal_content": response,
            "structured_data": structured_proposal,
            "metadata": {
                "company_name": company_name,
                "date": datetime.utcnow().isoformat(),
                "word_count": len(response.split())
            }
        }

    async def create_case_study(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Create a case study from a successful engagement"""
        engagement_data = parameters.get("engagement_data", {})
        client_name = engagement_data.get("client_name", "Client")
        anonymize = parameters.get("anonymize", False)

        prompt = f"""Create a compelling case study from this successful training engagement.

Engagement Data:
{json.dumps(engagement_data, indent=2)}

{"Use a pseudonym instead of the real client name." if anonymize else ""}

Structure the case study as follows:

1. CLIENT OVERVIEW
   - Industry and company profile
   - Size and scale of operations
   - Business context

2. THE CHALLENGE
   - Initial situation and pain points
   - Specific problems they needed to solve
   - Why they needed AI training
   - Consequences of not addressing the challenge

3. OUR SOLUTION
   - Training program designed
   - Approach and methodology
   - Customizations made for their needs
   - Duration and format

4. IMPLEMENTATION
   - How we rolled out the training
   - Number of participants
   - Timeline
   - Any special considerations

5. RESULTS
   - Specific, measurable outcomes
   - Quantitative metrics (productivity, ROI, etc.)
   - Qualitative improvements
   - Timeline of results

6. CLIENT TESTIMONIAL
   - Quote from a key stakeholder
   - Their perspective on the value delivered

7. KEY TAKEAWAYS
   - Critical success factors
   - What made this engagement successful
   - Lessons learned

Make it specific, credible, and results-focused. Use real metrics and data points."""

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        # Store case study
        await self.store_knowledge(
            content=response,
            metadata={
                "type": "case_study",
                "client_name": client_name if not anonymize else "Anonymous",
                "industry": engagement_data.get("industry", "unknown"),
                "date": datetime.utcnow().isoformat(),
                "agent": self.agent_name,
                "anonymized": anonymize
            },
            collection_name="case_studies"
        )

        return {
            "case_study_content": response,
            "metadata": {
                "client_name": client_name if not anonymize else "Anonymous",
                "date": datetime.utcnow().isoformat(),
                "word_count": len(response.split())
            }
        }

    async def create_email(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Create outreach or follow-up email"""
        email_type = parameters.get("email_type", "initial_outreach")
        recipient_data = parameters.get("recipient_data", {})
        context_data = parameters.get("context", {})

        recipient_name = recipient_data.get("name", "there")
        company_name = recipient_data.get("company_name", "your organization")

        # Define email templates based on type
        email_prompts = {
            "initial_outreach": f"""Create a compelling initial outreach email.

Recipient: {recipient_name}, {recipient_data.get('title', 'Training Decision Maker')}
Company: {company_name}
Industry: {recipient_data.get('industry', 'unknown')}

The email should:
1. Have a personalized, attention-grabbing subject line
2. Open with a relevant insight or observation about their industry/company
3. Briefly introduce our AI training services
4. Highlight specific value we can provide to them
5. Include a clear, low-friction call-to-action
6. Be concise (250-300 words max)
7. Professional but conversational tone

Avoid:
- Generic sales language
- Excessive self-promotion
- Long paragraphs
- Multiple CTAs

Make it personalized and valuable.""",

            "follow_up": f"""Create a follow-up email after {context_data.get('previous_interaction', 'our initial contact')}.

Recipient: {recipient_name}
Company: {company_name}
Previous Context: {context_data.get('previous_context', 'Initial outreach sent')}

The email should:
1. Reference previous interaction naturally
2. Provide additional value (insight, resource, case study)
3. Address any concerns or questions raised
4. Propose a specific next step
5. Be brief and respectful of their time
6. Include a clear ask

Tone: Professional, helpful, not pushy.""",

            "proposal_followup": f"""Create a follow-up email after sending a proposal.

Recipient: {recipient_name}
Company: {company_name}
Proposal Sent: {context_data.get('proposal_date', 'recently')}

The email should:
1. Confirm they received the proposal
2. Offer to answer questions or clarify anything
3. Highlight 2-3 key benefits from the proposal
4. Suggest a specific time to discuss
5. Create gentle urgency without being pushy
6. Provide easy next steps

Tone: Consultative, helpful, confident.""",

            "meeting_request": f"""Create an email requesting a meeting.

Recipient: {recipient_name}
Company: {company_name}
Purpose: {context_data.get('meeting_purpose', 'Discuss AI training needs')}

The email should:
1. Clearly state the purpose of the meeting
2. Explain the value they'll get from the meeting
3. Suggest specific dates/times
4. Specify the duration (typically 30 min)
5. Offer virtual meeting option
6. Make it easy to accept

Include calendar meeting request language."""
        }

        prompt = email_prompts.get(email_type, email_prompts["initial_outreach"])

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        # Extract email components
        schema = {
            "subject_line": "string",
            "email_body": "string",
            "call_to_action": "string"
        }

        structured_email = await self.generate_structured_output(
            f"Extract email components (subject, body, CTA) from:\n\n{response}",
            schema
        )

        return {
            "email_content": response,
            "structured_email": structured_email,
            "metadata": {
                "email_type": email_type,
                "recipient": recipient_name,
                "company": company_name,
                "date": datetime.utcnow().isoformat()
            }
        }

    async def create_presentation(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Create presentation outline and content"""
        presentation_type = parameters.get("presentation_type", "capabilities")
        audience_data = parameters.get("audience_data", {})
        duration_minutes = parameters.get("duration_minutes", 30)

        company_name = audience_data.get("company_name", "Prospective Client")

        prompt = f"""Create a detailed presentation outline and slide content.

Presentation Type: {presentation_type}
Audience: {audience_data.get('audience_level', 'Mixed (executives and practitioners)')}
Company: {company_name}
Industry: {audience_data.get('industry', 'General')}
Duration: {duration_minutes} minutes

Create a slide-by-slide outline with:
1. Slide number and title
2. Key points and content for each slide
3. Suggested visuals or graphics
4. Speaker notes
5. Estimated time per slide

For a {duration_minutes}-minute presentation, create approximately {duration_minutes // 2} slides.

Presentation should include:
- Opening/Hook (1-2 slides)
- Problem/Challenge (2-3 slides)
- Our Solution/Approach (3-4 slides)
- Proof/Results (2-3 slides)
- Specific Proposal for Them (2-3 slides)
- Next Steps/CTA (1 slide)

Make it:
- Visually oriented (more images than text)
- Data-driven with specific metrics
- Customized to their industry
- Focused on outcomes and ROI
- Professional and polished

Include specific content recommendations for each slide."""

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        return {
            "presentation_outline": response,
            "metadata": {
                "presentation_type": presentation_type,
                "company": company_name,
                "duration_minutes": duration_minutes,
                "date": datetime.utcnow().isoformat(),
                "estimated_slides": duration_minutes // 2
            }
        }

    async def customize_content(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Customize existing content for a specific audience"""
        original_content = parameters.get("original_content", "")
        customization_params = parameters.get("customization_params", {})

        target_industry = customization_params.get("industry")
        target_region = customization_params.get("region")
        target_audience = customization_params.get("audience_level")

        prompt = f"""Customize this content for a specific audience.

Original Content:
{original_content[:2000]}

Customization Requirements:
- Industry: {target_industry}
- Region: {target_region}
- Audience Level: {target_audience}

Adapt the content to:
1. Use industry-specific terminology and examples
2. Reference industry-specific challenges and use cases
3. Adjust tone and formality for the audience level
4. Include region-specific considerations if relevant
5. Modify examples to be culturally appropriate
6. Adjust value propositions to industry priorities

Maintain the original structure and key messages, but make it feel custom-created for this specific audience."""

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        return {
            "customized_content": response,
            "metadata": {
                "original_length": len(original_content.split()),
                "customized_length": len(response.split()),
                "industry": target_industry,
                "region": target_region,
                "date": datetime.utcnow().isoformat()
            }
        }
