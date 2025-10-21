"""
Database models for all entities in the system
"""
from sqlalchemy import Column, Integer, String, Float, Boolean, Text, JSON, ForeignKey, Enum as SQLEnum
from sqlalchemy.orm import relationship
import enum
from .base import BaseModel


class LeadStatus(str, enum.Enum):
    """Lead status enumeration"""
    NEW = "new"
    QUALIFIED = "qualified"
    CONTACTED = "contacted"
    PROPOSAL_SENT = "proposal_sent"
    NEGOTIATION = "negotiation"
    WON = "won"
    LOST = "lost"
    INACTIVE = "inactive"


class LeadScore(str, enum.Enum):
    """Lead quality score"""
    HOT = "hot"
    WARM = "warm"
    COLD = "cold"


class TaskStatus(str, enum.Enum):
    """Task status"""
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    FAILED = "failed"


class AgentType(str, enum.Enum):
    """Agent types"""
    RESEARCH = "research"
    LEAD_GENERATION = "lead_generation"
    CONTENT = "content"
    RELATIONSHIP = "relationship"
    KNOWLEDGE = "knowledge"
    ANALYTICS = "analytics"
    ORCHESTRATOR = "orchestrator"


# Core Business Entities

class Lead(BaseModel):
    """Lead/Prospect entity"""
    __tablename__ = "leads"

    company_name = Column(String(255), nullable=False, index=True)
    industry = Column(String(100))
    company_size = Column(String(50))
    region = Column(String(100))
    country = Column(String(100))

    # Contact Information
    primary_contact_name = Column(String(255))
    primary_contact_title = Column(String(255))
    primary_contact_email = Column(String(255))
    primary_contact_linkedin = Column(String(500))

    # Lead Qualification
    status = Column(SQLEnum(LeadStatus), default=LeadStatus.NEW, index=True)
    score = Column(SQLEnum(LeadScore), default=LeadScore.COLD)
    score_numeric = Column(Float, default=0.0)

    # Business Details
    estimated_budget = Column(Float)
    training_needs = Column(JSON)  # List of training topics needed
    decision_makers = Column(JSON)  # List of decision makers

    # Metadata
    source = Column(String(100))  # Where the lead came from
    notes = Column(Text)
    metadata = Column(JSON)  # Additional flexible data

    # Relationships
    interactions = relationship("Interaction", back_populates="lead", cascade="all, delete-orphan")
    proposals = relationship("Proposal", back_populates="lead", cascade="all, delete-orphan")
    analytics = relationship("LeadAnalytics", back_populates="lead", uselist=False)


class Interaction(BaseModel):
    """Track all interactions with leads"""
    __tablename__ = "interactions"

    lead_id = Column(Integer, ForeignKey("leads.id"), nullable=False, index=True)
    interaction_type = Column(String(50))  # email, call, meeting, linkedin, etc.
    subject = Column(String(500))
    content = Column(Text)
    sentiment = Column(String(20))  # positive, neutral, negative
    outcome = Column(String(100))
    next_action = Column(String(500))
    metadata = Column(JSON)

    lead = relationship("Lead", back_populates="interactions")


class Proposal(BaseModel):
    """Training proposals sent to leads"""
    __tablename__ = "proposals"

    lead_id = Column(Integer, ForeignKey("leads.id"), nullable=False, index=True)
    title = Column(String(500), nullable=False)
    content = Column(Text, nullable=False)

    # Proposal Details
    training_topics = Column(JSON)  # List of training modules
    duration_days = Column(Integer)
    proposed_price = Column(Float)
    currency = Column(String(10), default="USD")

    # Status
    status = Column(String(50), default="draft")  # draft, sent, accepted, rejected
    sent_date = Column(String(50))
    response_date = Column(String(50))

    # Metadata
    version = Column(Integer, default=1)
    metadata = Column(JSON)

    lead = relationship("Lead", back_populates="proposals")


class ResearchInsight(BaseModel):
    """Market research and intelligence insights"""
    __tablename__ = "research_insights"

    category = Column(String(100), index=True)  # market_trend, competitor, technology, etc.
    title = Column(String(500), nullable=False)
    summary = Column(Text)
    full_content = Column(Text)

    # Classification
    relevance_score = Column(Float, default=0.0)
    priority = Column(String(20))  # high, medium, low
    tags = Column(JSON)  # List of tags

    # Source
    source_type = Column(String(50))  # web, linkedin, report, conference, etc.
    source_url = Column(String(1000))
    source_name = Column(String(255))

    # Metadata
    metadata = Column(JSON)


class ContentAsset(BaseModel):
    """Reusable content assets (proposals, case studies, templates)"""
    __tablename__ = "content_assets"

    asset_type = Column(String(50), nullable=False, index=True)  # proposal, case_study, email_template, etc.
    title = Column(String(500), nullable=False)
    content = Column(Text, nullable=False)

    # Classification
    industry = Column(String(100))
    use_case = Column(String(100))
    tags = Column(JSON)

    # Performance tracking
    usage_count = Column(Integer, default=0)
    success_rate = Column(Float, default=0.0)

    # Metadata
    metadata = Column(JSON)


class Task(BaseModel):
    """Agent tasks and workflow tracking"""
    __tablename__ = "tasks"

    agent_type = Column(SQLEnum(AgentType), nullable=False, index=True)
    task_type = Column(String(100), nullable=False)
    description = Column(Text)

    # Task Details
    input_data = Column(JSON)
    output_data = Column(JSON)
    status = Column(SQLEnum(TaskStatus), default=TaskStatus.PENDING, index=True)

    # Execution
    started_at = Column(String(50))
    completed_at = Column(String(50))
    error_message = Column(Text)

    # Priority & Scheduling
    priority = Column(Integer, default=5)  # 1-10, higher is more urgent
    scheduled_for = Column(String(50))

    # Relationships
    parent_task_id = Column(Integer, ForeignKey("tasks.id"))
    metadata = Column(JSON)


class LeadAnalytics(BaseModel):
    """Analytics data for each lead"""
    __tablename__ = "lead_analytics"

    lead_id = Column(Integer, ForeignKey("leads.id"), nullable=False, unique=True, index=True)

    # Engagement Metrics
    total_interactions = Column(Integer, default=0)
    last_interaction_date = Column(String(50))
    avg_response_time_hours = Column(Float)

    # Conversion Metrics
    time_to_qualification_days = Column(Float)
    time_to_proposal_days = Column(Float)
    time_to_close_days = Column(Float)

    # Value Metrics
    estimated_deal_value = Column(Float)
    actual_deal_value = Column(Float)

    # Predictions
    conversion_probability = Column(Float, default=0.0)
    predicted_close_date = Column(String(50))

    # Metadata
    metadata = Column(JSON)

    lead = relationship("Lead", back_populates="analytics")


class AgentSession(BaseModel):
    """Track agent execution sessions"""
    __tablename__ = "agent_sessions"

    session_id = Column(String(100), unique=True, index=True, nullable=False)
    agent_type = Column(SQLEnum(AgentType), nullable=False)

    # Session Data
    input_data = Column(JSON)
    output_data = Column(JSON)
    state = Column(JSON)  # LangGraph state

    # Execution
    status = Column(String(50), default="active")
    started_at = Column(String(50))
    completed_at = Column(String(50))

    # Metadata
    metadata = Column(JSON)


class KnowledgeBase(BaseModel):
    """Knowledge base entries for RAG"""
    __tablename__ = "knowledge_base"

    title = Column(String(500), nullable=False)
    content = Column(Text, nullable=False)
    content_type = Column(String(50))  # document, qa, lesson_learned, etc.

    # Classification
    category = Column(String(100), index=True)
    tags = Column(JSON)

    # Vector Store Reference
    vector_id = Column(String(100), unique=True)  # Reference to ChromaDB

    # Usage
    access_count = Column(Integer, default=0)
    last_accessed = Column(String(50))

    # Metadata
    metadata = Column(JSON)
