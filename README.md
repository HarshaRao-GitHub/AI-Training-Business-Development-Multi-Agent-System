# AI Training Business Development Multi-Agent System

A world-class, end-to-end multi-agent productivity system designed specifically for business development in the AI corporate training space. This system leverages specialized AI agents that collaborate to handle different aspects of business development, from market research to proposal generation.

![System Architecture](docs/architecture-diagram.png)

## Overview

This comprehensive platform uses 7 specialized AI agents coordinated by an intelligent orchestrator to automate and enhance business development workflows:

1. **Task Orchestration Agent (Supervisor)** - Coordinates all agents and manages complex workflows
2. **Research & Intelligence Agent** - Market research, competitor analysis, trend monitoring
3. **Lead Generation & Qualification Agent** - Identifies and qualifies potential clients
4. **Content & Proposal Agent** - Generates proposals, case studies, emails, presentations
5. **Relationship Management Agent** - Manages client communication and follow-ups
6. **Knowledge Management Agent** - Organizes and retrieves institutional knowledge
7. **Analytics & Reporting Agent** - Tracks performance metrics and generates insights

## Key Features

### Multi-Agent Architecture
- **Specialized Agents**: Each agent is an expert in its domain
- **Intelligent Coordination**: Orchestrator manages dependencies and workflows
- **Shared Memory**: Vector database for semantic search and knowledge retrieval
- **Context Awareness**: Agents maintain state across interactions

### Core Capabilities
- 🔍 **Market Intelligence**: Automated daily briefs on AI training market trends
- 🎯 **Lead Management**: Smart lead identification, qualification, and scoring
- 📝 **Proposal Generation**: AI-powered customized training proposals
- 💬 **Relationship Management**: Communication analysis and follow-up optimization
- 📊 **Analytics**: Pipeline tracking, forecasting, and performance insights
- 🧠 **Knowledge Base**: Learn from past successes and failures

### Technical Stack

**Backend:**
- FastAPI (Python 3.11+)
- LangChain & LangGraph for agent orchestration
- Claude 3.5 Sonnet (Anthropic) for intelligent reasoning
- ChromaDB for vector storage
- SQLAlchemy with SQLite/PostgreSQL
- Redis for caching and task queuing

**Frontend:**
- React 18 with TypeScript
- Vite for fast builds
- TailwindCSS for styling
- React Query for state management
- Axios for API communication

## Quick Start

### Prerequisites

- Python 3.11 or higher
- Node.js 18 or higher
- Anthropic API key

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd ai-training-biz-dev-system
```

2. **Backend Setup**
```bash
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env and add your ANTHROPIC_API_KEY and other settings

# Initialize database
python -c "import asyncio; from database.db import init_db; asyncio.run(init_db())"
```

3. **Frontend Setup**
```bash
cd frontend

# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env if needed (defaults to http://localhost:8000)
```

### Running the Application

1. **Start the Backend**
```bash
cd backend
python main.py
```
The API will be available at http://localhost:8000

2. **Start the Frontend** (in a new terminal)
```bash
cd frontend
npm run dev
```
The UI will be available at http://localhost:3000

3. **Access the Application**
- Frontend UI: http://localhost:3000
- API Documentation: http://localhost:8000/docs
- API Health Check: http://localhost:8000/api/v1/health

## Usage Guide

### Daily Business Development Routine

Execute the automated daily routine that provides:
- Morning intelligence brief
- New qualified leads
- Pipeline status analysis
- Follow-up recommendations

```bash
# Via UI: Navigate to "Daily Routine" tab and click "Run Daily Routine"

# Via API:
curl -X POST http://localhost:8000/api/v1/orchestrator/daily-routine
```

### Lead Management

Process a new lead through the complete workflow:

1. Navigate to "Leads" tab
2. Enter company information
3. Click "Process Lead"
4. Receive comprehensive analysis including:
   - Enriched company data
   - Lead score and qualification
   - Similar past cases
   - Recommended outreach email

### Proposal Generation

Create a customized training proposal:

1. Navigate to "Proposals" tab
2. Enter company details and training requirements
3. Click "Generate Proposal"
4. Receive complete package including:
   - Detailed proposal document
   - Presentation outline
   - Cover email

### API Integration

All agents are accessible via REST API:

```python
import requests

# Example: Market Analysis
response = requests.post(
    'http://localhost:8000/api/v1/research/market-analysis',
    json={
        'parameters': {
            'industry': 'Technology',
            'region': 'North America'
        }
    }
)
analysis = response.json()
```

## Architecture

### System Design

```
┌─────────────────────────────────────┐
│   Task Orchestration Agent          │
│   (Coordinator/Supervisor)           │
└──────────────┬──────────────────────┘
               │
    ┌──────────┴──────────┐
    │                     │
┌───▼────┐           ┌───▼────┐
│Research│           │Lead Gen│
│ Agent  │           │ Agent  │
└───┬────┘           └───┬────┘
    │                    │
    │   ┌────────────┐   │
    └──►│  Shared    │◄──┘
        │  Memory/   │
        │   Vector   │◄────┐
    ┌──►│    DB      │     │
    │   └────────────┘     │
    │                      │
┌───┴────┐           ┌────┴───┐
│Content │           │Relation│
│ Agent  │           │  Mgmt  │
└───┬────┘           └───┬────┘
    │                    │
    └──────────┬─────────┘
               │
        ┌──────▼───────┐
        │  Analytics   │
        │    Agent     │
        └──────────────┘
```

### Agent Workflows

#### New Lead Processing
```
User Input → Orchestrator
  ├─→ Lead Gen Agent: Enrich lead data
  ├─→ Lead Gen Agent: Score lead
  ├─→ Research Agent: Identify opportunities
  ├─→ Knowledge Agent: Find similar cases
  └─→ Content Agent: Draft outreach email

Orchestrator → Synthesize results → Return to user
```

#### Proposal Generation
```
User Input → Orchestrator
  ├─→ Knowledge Agent: Find similar proposals
  ├─→ Knowledge Agent: Retrieve best practices
  ├─→ Research Agent: Market context
  ├─→ Content Agent: Create proposal
  ├─→ Content Agent: Create presentation
  └─→ Content Agent: Draft cover email

Orchestrator → Package deliverables → Return to user
```

## Agent Capabilities

### 1. Research & Intelligence Agent
- Market analysis by industry and region
- Competitor analysis and benchmarking
- Trend monitoring and forecasting
- Daily/weekly intelligence briefs
- Opportunity identification

### 2. Lead Generation Agent
- Lead identification based on criteria
- BANT qualification (Budget, Authority, Need, Timeline)
- Lead scoring (0-100 with confidence levels)
- Company enrichment and research
- Decision-maker identification

### 3. Content Agent
- Customized training proposals
- Case study creation
- Email templates (outreach, follow-up, proposal delivery)
- Presentation deck outlines
- Content adaptation for different audiences

### 4. Relationship Management Agent
- Communication analysis and sentiment tracking
- Follow-up strategy recommendations
- Meeting preparation briefings
- Objection handling guidance
- Touchpoint planning

### 5. Knowledge Management Agent
- Similar case retrieval
- Lessons learned extraction
- Best practice identification
- Knowledge summarization
- Institutional memory maintenance

### 6. Analytics Agent
- Pipeline health analysis
- Win/loss pattern analysis
- Revenue forecasting
- Bottleneck identification
- Performance reporting

### 7. Orchestrator Agent
- Multi-agent workflow coordination
- Task prioritization and routing
- Context management
- Dependency resolution
- Result synthesis

## Configuration

### Environment Variables

**Backend (.env)**
```env
# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
DEBUG=True
ENVIRONMENT=development

# Anthropic API
ANTHROPIC_API_KEY=your_anthropic_api_key_here
ANTHROPIC_MODEL=claude-3-5-sonnet-20241022

# Database
DATABASE_URL=sqlite+aiosqlite:///./ai_training_system.db
# For PostgreSQL: postgresql://user:password@localhost:5432/ai_training_db

# Vector Store
CHROMA_PERSIST_DIRECTORY=./chroma_db
EMBEDDING_MODEL=all-MiniLM-L6-v2

# Agent Configuration
MAX_AGENT_ITERATIONS=10
AGENT_TIMEOUT_SECONDS=300
```

**Frontend (.env)**
```env
VITE_API_URL=http://localhost:8000/api/v1
```

## Development

### Project Structure
```
ai-training-biz-dev-system/
├── backend/
│   ├── agents/              # All 7 specialized agents
│   │   ├── base_agent.py
│   │   ├── orchestrator_agent.py
│   │   ├── research_agent.py
│   │   ├── lead_gen_agent.py
│   │   ├── content_agent.py
│   │   ├── relationship_agent.py
│   │   ├── knowledge_agent.py
│   │   └── analytics_agent.py
│   ├── api/                 # API routes
│   │   └── routes.py
│   ├── core/                # Configuration
│   │   └── config.py
│   ├── database/            # Database & vector store
│   │   ├── db.py
│   │   └── vector_store.py
│   ├── models/              # Data models
│   │   ├── base.py
│   │   └── entities.py
│   └── main.py              # FastAPI application
├── frontend/
│   ├── src/
│   │   ├── components/      # React components
│   │   ├── pages/           # Page components
│   │   ├── services/        # API client
│   │   ├── types/           # TypeScript types
│   │   └── App.tsx
│   └── package.json
├── docs/                    # Documentation
└── README.md
```

### Adding a New Agent

1. Create agent class in `backend/agents/`:
```python
from .base_agent import BaseAgent

class MyNewAgent(BaseAgent):
    def __init__(self):
        super().__init__(
            agent_type="my_agent",
            agent_name="My New Agent",
            system_prompt="Your agent's system prompt"
        )

    async def execute(self, input_data):
        # Implement agent logic
        pass
```

2. Add to orchestrator's agent registry
3. Create API endpoints in `api/routes.py`
4. Add UI components in frontend

## Deployment

### Production Deployment

1. **Update Environment Variables**
   - Set `DEBUG=False`
   - Use production database (PostgreSQL recommended)
   - Configure Redis for production
   - Set secure `SECRET_KEY`

2. **Database Migration**
```bash
# For PostgreSQL
export DATABASE_URL=postgresql://user:password@localhost:5432/ai_training_db
python -c "import asyncio; from database.db import init_db; asyncio.run(init_db())"
```

3. **Deploy Backend**
```bash
# Using Gunicorn with Uvicorn workers
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

4. **Deploy Frontend**
```bash
npm run build
# Serve the dist/ folder with nginx or similar
```

### Docker Deployment

(Docker configuration files are included in the repository)

```bash
docker-compose up -d
```

## API Documentation

Interactive API documentation is available at:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

### Example API Calls

**Run Daily Routine**
```bash
POST /api/v1/orchestrator/daily-routine
```

**Process New Lead**
```bash
POST /api/v1/orchestrator/handle-lead
Content-Type: application/json

{
  "company_name": "Acme Corp",
  "industry": "Technology",
  "company_size": "1001-5000",
  "region": "North America"
}
```

**Generate Proposal**
```bash
POST /api/v1/orchestrator/create-proposal
Content-Type: application/json

{
  "lead_data": {
    "company_name": "Acme Corp",
    "industry": "Technology"
  },
  "requirements": {
    "training_topics": ["Machine Learning", "AI Ethics"],
    "duration_days": 5,
    "participants": 20
  }
}
```

## Performance Optimization

- **Caching**: Redis caching for frequent queries
- **Vector Search**: ChromaDB for fast semantic search
- **Async Operations**: All agents use async/await for concurrency
- **Connection Pooling**: Database connection pooling enabled
- **Rate Limiting**: API rate limiting configured

## Security Considerations

- API key management via environment variables
- Input validation on all endpoints
- SQL injection prevention through ORM
- CORS configuration for frontend access
- Authentication middleware ready for integration

## Troubleshooting

### Common Issues

**"Anthropic API Key not found"**
- Ensure `.env` file exists in backend directory
- Verify `ANTHROPIC_API_KEY` is set correctly

**"Database connection error"**
- Check `DATABASE_URL` in `.env`
- Ensure database is initialized: `python -c "import asyncio; from database.db import init_db; asyncio.run(init_db())"`

**"Frontend can't connect to backend"**
- Verify backend is running on port 8000
- Check CORS settings in `backend/core/config.py`
- Ensure `VITE_API_URL` is set correctly in frontend

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is proprietary and confidential.

## Support

For support, please contact the development team or open an issue in the repository.

## Roadmap

- [ ] Integration with CRM systems (Salesforce, HubSpot)
- [ ] Email automation with Gmail/Outlook
- [ ] LinkedIn integration for lead research
- [ ] Advanced analytics dashboard with charts
- [ ] Multi-language support
- [ ] Mobile application
- [ ] Real-time collaboration features
- [ ] Custom agent creation interface

## Acknowledgments

- Built with Claude 3.5 Sonnet by Anthropic
- Powered by LangChain and LangGraph
- UI components inspired by modern design systems

---

**Version:** 1.0.0
**Last Updated:** 2025
**Status:** Production Ready
