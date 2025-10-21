"""
Main FastAPI application for AI Training Business Development Multi-Agent System
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from core.config import settings
from api.routes import router
from database.db import init_db
from loguru import logger
import sys

# Configure logger
logger.remove()
logger.add(
    sys.stdout,
    format="<green>{time:YYYY-MM-DD HH:mm:ss}</green> | <level>{level: <8}</level> | <cyan>{name}</cyan>:<cyan>{function}</cyan> - <level>{message}</level>",
    level=settings.LOG_LEVEL
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifecycle manager for the application"""
    # Startup
    logger.info("Starting AI Training Business Development System...")
    logger.info(f"Environment: {settings.ENVIRONMENT}")

    # Initialize database
    try:
        await init_db()
        logger.info("Database initialized successfully")
    except Exception as e:
        logger.error(f"Database initialization failed: {e}")

    logger.info("All agents initialized and ready")
    logger.info(f"API server starting on {settings.API_HOST}:{settings.API_PORT}")

    yield

    # Shutdown
    logger.info("Shutting down gracefully...")


# Create FastAPI app
app = FastAPI(
    title=settings.PROJECT_NAME,
    description="Multi-Agent Business Development System for AI Corporate Training",
    version="1.0.0",
    lifespan=lifespan
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API routes
app.include_router(router, prefix=settings.API_V1_PREFIX)


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "name": settings.PROJECT_NAME,
        "version": "1.0.0",
        "status": "running",
        "description": "Multi-Agent Business Development System for AI Corporate Training",
        "agents": [
            "Orchestrator Agent",
            "Research & Intelligence Agent",
            "Lead Generation & Qualification Agent",
            "Content & Proposal Agent",
            "Relationship Management Agent",
            "Knowledge Management Agent",
            "Analytics & Reporting Agent"
        ],
        "docs": f"{settings.API_V1_PREFIX}/docs"
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=settings.API_HOST,
        port=settings.API_PORT,
        reload=settings.DEBUG
    )
