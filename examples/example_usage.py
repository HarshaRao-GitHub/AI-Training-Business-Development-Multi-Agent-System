"""
Example usage of the AI Training Business Development System agents

This file demonstrates how to use the agents programmatically.
"""

import asyncio
from agents.orchestrator_agent import OrchestratorAgent
from agents.research_agent import ResearchAgent
from agents.lead_gen_agent import LeadGenerationAgent
from agents.content_agent import ContentAgent


async def example_daily_routine():
    """Example: Run daily business development routine"""
    print("=" * 60)
    print("Example 1: Daily Business Development Routine")
    print("=" * 60)

    orchestrator = OrchestratorAgent()

    result = await orchestrator.execute({
        "task": "daily_routine",
        "parameters": {}
    })

    print("\n✅ Daily Routine Complete!")
    print(f"\n📊 Summary:\n{result['daily_summary'][:500]}...")


async def example_market_research():
    """Example: Conduct market research"""
    print("\n" + "=" * 60)
    print("Example 2: Market Research")
    print("=" * 60)

    research_agent = ResearchAgent()

    result = await research_agent.execute({
        "task": "market_analysis",
        "parameters": {
            "industry": "Healthcare",
            "region": "North America",
            "focus_areas": ["Machine Learning in diagnostics", "AI in patient care"]
        }
    })

    print("\n✅ Market Analysis Complete!")
    print(f"\n📈 Analysis Preview:\n{result['analysis'][:500]}...")


async def example_lead_processing():
    """Example: Process a new lead"""
    print("\n" + "=" * 60)
    print("Example 3: Lead Processing")
    print("=" * 60)

    orchestrator = OrchestratorAgent()

    lead_data = {
        "company_name": "TechCorp Industries",
        "industry": "Technology",
        "company_size": "1001-5000",
        "region": "North America",
        "primary_contact_name": "Jane Smith",
        "primary_contact_email": "jane.smith@techcorp.com"
    }

    result = await orchestrator.execute({
        "task": "handle_new_lead",
        "parameters": {"lead_data": lead_data}
    })

    print("\n✅ Lead Processing Complete!")
    print(f"\n📋 Recommendation:\n{result['recommendation'][:500]}...")


async def example_proposal_generation():
    """Example: Generate a training proposal"""
    print("\n" + "=" * 60)
    print("Example 4: Proposal Generation")
    print("=" * 60)

    orchestrator = OrchestratorAgent()

    lead_data = {
        "company_name": "FinanceFirst Bank",
        "industry": "Finance"
    }

    requirements = {
        "training_topics": [
            "AI in Financial Services",
            "Machine Learning for Risk Assessment",
            "AI Ethics and Compliance"
        ],
        "duration_days": 5,
        "participants": 25
    }

    result = await orchestrator.execute({
        "task": "create_proposal_workflow",
        "parameters": {
            "lead_data": lead_data,
            "requirements": requirements
        }
    })

    print("\n✅ Proposal Generation Complete!")
    if result.get('proposal'):
        proposal_content = result['proposal'].get('proposal_content', '')
        print(f"\n📄 Proposal Preview:\n{proposal_content[:500]}...")


async def example_lead_identification():
    """Example: Identify new leads"""
    print("\n" + "=" * 60)
    print("Example 5: Lead Identification")
    print("=" * 60)

    lead_gen_agent = LeadGenerationAgent()

    result = await lead_gen_agent.execute({
        "task": "identify_leads",
        "parameters": {
            "criteria": {
                "industry": "Healthcare",
                "region": "Europe",
                "company_size": "1001-5000"
            }
        }
    })

    print("\n✅ Lead Identification Complete!")
    leads = result.get('structured_leads', [])
    print(f"\n👥 Found {len(leads)} potential leads")
    if leads:
        print(f"\nFirst lead: {leads[0].get('company_name', 'N/A')}")


async def example_content_creation():
    """Example: Create marketing email"""
    print("\n" + "=" * 60)
    print("Example 6: Content Creation - Email")
    print("=" * 60)

    content_agent = ContentAgent()

    result = await content_agent.execute({
        "task": "create_email",
        "parameters": {
            "email_type": "initial_outreach",
            "recipient_data": {
                "name": "John Doe",
                "title": "VP of Technology",
                "company_name": "Innovation Labs",
                "industry": "Technology"
            },
            "context": {}
        }
    })

    print("\n✅ Email Creation Complete!")
    if result.get('structured_email'):
        subject = result['structured_email'].get('subject_line', 'N/A')
        print(f"\n📧 Subject: {subject}")
        body = result['structured_email'].get('email_body', '')
        print(f"\n📝 Body Preview:\n{body[:300]}...")


async def main():
    """Run all examples"""
    print("\n" + "🤖" * 30)
    print("AI Training Business Development System - Usage Examples")
    print("🤖" * 30 + "\n")

    print("Note: These examples use the Claude API and may take some time to complete.")
    print("Ensure your ANTHROPIC_API_KEY is set in the backend/.env file.\n")

    # Run examples
    await example_daily_routine()
    await example_market_research()
    await example_lead_processing()
    await example_proposal_generation()
    await example_lead_identification()
    await example_content_creation()

    print("\n" + "=" * 60)
    print("✨ All examples completed successfully!")
    print("=" * 60 + "\n")


if __name__ == "__main__":
    # Make sure to run this from the backend directory with venv activated
    asyncio.run(main())
