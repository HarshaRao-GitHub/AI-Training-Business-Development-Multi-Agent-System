"""
API routes for the multi-agent system
"""
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import Dict, Any, Optional, List
from agents.orchestrator_agent import OrchestratorAgent
from agents.research_agent import ResearchAgent
from agents.lead_gen_agent import LeadGenerationAgent
from agents.content_agent import ContentAgent
from agents.relationship_agent import RelationshipAgent
from agents.knowledge_agent import KnowledgeAgent
from agents.analytics_agent import AnalyticsAgent
from database.db import get_db
from sqlalchemy.ext.asyncio import AsyncSession
from models.entities import Lead, LeadStatus, LeadScore, Proposal, Interaction
from datetime import datetime

router = APIRouter()

# Initialize agents
orchestrator = OrchestratorAgent()
research_agent = ResearchAgent()
lead_gen_agent = LeadGenerationAgent()
content_agent = ContentAgent()
relationship_agent = RelationshipAgent()
knowledge_agent = KnowledgeAgent()
analytics_agent = AnalyticsAgent()


# Request/Response Models
class AgentRequest(BaseModel):
    task: str
    parameters: Dict[str, Any] = {}


class AgentResponse(BaseModel):
    success: bool
    data: Dict[str, Any]
    error: Optional[str] = None


class LeadCreate(BaseModel):
    company_name: str
    industry: Optional[str] = None
    company_size: Optional[str] = None
    region: Optional[str] = None
    country: Optional[str] = None
    primary_contact_name: Optional[str] = None
    primary_contact_email: Optional[str] = None


# ============== Orchestrator Routes ==============

@router.post("/orchestrator/process", response_model=AgentResponse)
async def process_request(request: AgentRequest):
    """Process a general request through the orchestrator"""
    try:
        result = await orchestrator.execute({
            "task": "process_request",
            "parameters": request.parameters
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/orchestrator/daily-routine", response_model=AgentResponse)
async def daily_routine():
    """Execute daily business development routine"""
    try:
        result = await orchestrator.execute({
            "task": "daily_routine",
            "parameters": {}
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/orchestrator/handle-lead", response_model=AgentResponse)
async def handle_new_lead(lead_data: Dict[str, Any]):
    """Complete workflow for handling a new lead"""
    try:
        result = await orchestrator.execute({
            "task": "handle_new_lead",
            "parameters": {"lead_data": lead_data}
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/orchestrator/create-proposal", response_model=AgentResponse)
async def create_proposal_workflow(
    lead_data: Dict[str, Any],
    requirements: Dict[str, Any]
):
    """Complete workflow for creating a proposal"""
    try:
        result = await orchestrator.execute({
            "task": "create_proposal_workflow",
            "parameters": {
                "lead_data": lead_data,
                "requirements": requirements
            }
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ============== Research Agent Routes ==============

@router.post("/research/market-analysis", response_model=AgentResponse)
async def market_analysis(request: AgentRequest):
    """Conduct market analysis"""
    try:
        result = await research_agent.execute({
            "task": "market_analysis",
            "parameters": request.parameters
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/research/competitor-analysis", response_model=AgentResponse)
async def competitor_analysis(request: AgentRequest):
    """Analyze competitors"""
    try:
        result = await research_agent.execute({
            "task": "competitor_analysis",
            "parameters": request.parameters
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/research/trends", response_model=AgentResponse)
async def monitor_trends(request: AgentRequest):
    """Monitor industry trends"""
    try:
        result = await research_agent.execute({
            "task": "trend_monitoring",
            "parameters": request.parameters
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/research/intelligence-brief", response_model=AgentResponse)
async def get_intelligence_brief(brief_type: str = "daily"):
    """Get intelligence brief"""
    try:
        result = await research_agent.execute({
            "task": "intelligence_brief",
            "parameters": {"type": brief_type}
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ============== Lead Generation Agent Routes ==============

@router.post("/leads/identify", response_model=AgentResponse)
async def identify_leads(request: AgentRequest):
    """Identify new leads"""
    try:
        result = await lead_gen_agent.execute({
            "task": "identify_leads",
            "parameters": request.parameters
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/leads/qualify", response_model=AgentResponse)
async def qualify_lead(lead_data: Dict[str, Any]):
    """Qualify a lead"""
    try:
        result = await lead_gen_agent.execute({
            "task": "qualify_lead",
            "parameters": {"lead_data": lead_data}
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/leads/score", response_model=AgentResponse)
async def score_lead(lead_data: Dict[str, Any]):
    """Score a lead"""
    try:
        result = await lead_gen_agent.execute({
            "task": "score_lead",
            "parameters": {"lead_data": lead_data}
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/leads/enrich", response_model=AgentResponse)
async def enrich_lead(lead_data: Dict[str, Any]):
    """Enrich lead data"""
    try:
        result = await lead_gen_agent.execute({
            "task": "enrich_lead",
            "parameters": {"lead_data": lead_data}
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/leads/decision-makers", response_model=AgentResponse)
async def find_decision_makers(company_name: str):
    """Find decision makers at a company"""
    try:
        result = await lead_gen_agent.execute({
            "task": "find_decision_makers",
            "parameters": {"company_name": company_name}
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ============== Content Agent Routes ==============

@router.post("/content/proposal", response_model=AgentResponse)
async def create_proposal(lead_data: Dict[str, Any], training_requirements: Dict[str, Any]):
    """Create a training proposal"""
    try:
        result = await content_agent.execute({
            "task": "create_proposal",
            "parameters": {
                "lead_data": lead_data,
                "training_requirements": training_requirements
            }
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/content/case-study", response_model=AgentResponse)
async def create_case_study(engagement_data: Dict[str, Any], anonymize: bool = False):
    """Create a case study"""
    try:
        result = await content_agent.execute({
            "task": "create_case_study",
            "parameters": {
                "engagement_data": engagement_data,
                "anonymize": anonymize
            }
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/content/email", response_model=AgentResponse)
async def create_email(
    email_type: str,
    recipient_data: Dict[str, Any],
    context: Dict[str, Any] = {}
):
    """Create an email"""
    try:
        result = await content_agent.execute({
            "task": "create_email",
            "parameters": {
                "email_type": email_type,
                "recipient_data": recipient_data,
                "context": context
            }
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/content/presentation", response_model=AgentResponse)
async def create_presentation(
    presentation_type: str,
    audience_data: Dict[str, Any],
    duration_minutes: int = 30
):
    """Create a presentation"""
    try:
        result = await content_agent.execute({
            "task": "create_presentation",
            "parameters": {
                "presentation_type": presentation_type,
                "audience_data": audience_data,
                "duration_minutes": duration_minutes
            }
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ============== Relationship Agent Routes ==============

@router.post("/relationship/analyze-interaction", response_model=AgentResponse)
async def analyze_interaction(interaction_data: Dict[str, Any], lead_data: Dict[str, Any]):
    """Analyze a communication interaction"""
    try:
        result = await relationship_agent.execute({
            "task": "analyze_interaction",
            "parameters": {
                "interaction_data": interaction_data,
                "lead_data": lead_data
            }
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/relationship/suggest-followup", response_model=AgentResponse)
async def suggest_followup(lead_data: Dict[str, Any], last_interaction: Dict[str, Any], stage: str):
    """Suggest follow-up strategy"""
    try:
        result = await relationship_agent.execute({
            "task": "suggest_followup",
            "parameters": {
                "lead_data": lead_data,
                "last_interaction": last_interaction,
                "stage": stage
            }
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/relationship/prepare-meeting", response_model=AgentResponse)
async def prepare_meeting(meeting_data: Dict[str, Any], lead_data: Dict[str, Any]):
    """Prepare meeting briefing"""
    try:
        result = await relationship_agent.execute({
            "task": "prepare_meeting",
            "parameters": {
                "meeting_data": meeting_data,
                "lead_data": lead_data
            }
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ============== Knowledge Agent Routes ==============

@router.post("/knowledge/find-similar", response_model=AgentResponse)
async def find_similar_cases(query_data: Dict[str, Any]):
    """Find similar past cases"""
    try:
        result = await knowledge_agent.execute({
            "task": "find_similar_cases",
            "parameters": {"query_data": query_data}
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/knowledge/lessons-learned", response_model=AgentResponse)
async def extract_lessons(request: AgentRequest):
    """Extract lessons learned"""
    try:
        result = await knowledge_agent.execute({
            "task": "extract_lessons",
            "parameters": request.parameters
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/knowledge/best-practices", response_model=AgentResponse)
async def retrieve_best_practices(scenario: str, context: Dict[str, Any] = {}):
    """Retrieve best practices"""
    try:
        result = await knowledge_agent.execute({
            "task": "retrieve_best_practices",
            "parameters": {
                "scenario": scenario,
                "context": context
            }
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ============== Analytics Agent Routes ==============

@router.post("/analytics/pipeline", response_model=AgentResponse)
async def analyze_pipeline(pipeline_data: Dict[str, Any], time_period: str = "current_quarter"):
    """Analyze pipeline"""
    try:
        result = await analytics_agent.execute({
            "task": "pipeline_analysis",
            "parameters": {
                "pipeline_data": pipeline_data,
                "time_period": time_period
            }
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/analytics/win-loss", response_model=AgentResponse)
async def analyze_win_loss(deals_data: List[Dict[str, Any]], time_period: str = "last_quarter"):
    """Analyze win/loss patterns"""
    try:
        result = await analytics_agent.execute({
            "task": "win_loss_analysis",
            "parameters": {
                "deals_data": deals_data,
                "time_period": time_period
            }
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/analytics/forecast", response_model=AgentResponse)
async def forecast_revenue(
    pipeline_data: Dict[str, Any],
    historical_data: Dict[str, Any],
    forecast_period: str = "next_quarter"
):
    """Generate revenue forecast"""
    try:
        result = await analytics_agent.execute({
            "task": "forecast_revenue",
            "parameters": {
                "pipeline_data": pipeline_data,
                "historical_data": historical_data,
                "forecast_period": forecast_period
            }
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/analytics/performance-report", response_model=AgentResponse)
async def performance_report(
    period: str,
    metrics_data: Dict[str, Any],
    comparison_period: str = "previous_period"
):
    """Create performance report"""
    try:
        result = await analytics_agent.execute({
            "task": "performance_report",
            "parameters": {
                "period": period,
                "metrics_data": metrics_data,
                "comparison_period": comparison_period
            }
        })
        return AgentResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ============== Database CRUD Routes ==============

@router.post("/db/leads", response_model=Dict[str, Any])
async def create_lead_db(lead: LeadCreate, db: AsyncSession = Depends(get_db)):
    """Create a new lead in database"""
    try:
        new_lead = Lead(**lead.dict())
        db.add(new_lead)
        await db.commit()
        await db.refresh(new_lead)
        return {"success": True, "lead_id": new_lead.id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/db/leads/{lead_id}", response_model=Dict[str, Any])
async def get_lead_db(lead_id: int, db: AsyncSession = Depends(get_db)):
    """Get a lead from database"""
    try:
        from sqlalchemy import select
        result = await db.execute(select(Lead).filter(Lead.id == lead_id))
        lead = result.scalar_one_or_none()
        if not lead:
            raise HTTPException(status_code=404, detail="Lead not found")
        return {
            "id": lead.id,
            "company_name": lead.company_name,
            "industry": lead.industry,
            "status": lead.status,
            "score": lead.score
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ============== Health Check ==============

@router.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "agents": {
            "orchestrator": "active",
            "research": "active",
            "lead_generation": "active",
            "content": "active",
            "relationship": "active",
            "knowledge": "active",
            "analytics": "active"
        }
    }
