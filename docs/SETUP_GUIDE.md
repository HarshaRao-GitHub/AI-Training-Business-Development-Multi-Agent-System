# Setup Guide - AI Training Business Development System

This guide will walk you through setting up the complete multi-agent system from scratch.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Backend Setup](#backend-setup)
3. [Frontend Setup](#frontend-setup)
4. [Database Configuration](#database-configuration)
5. [Environment Configuration](#environment-configuration)
6. [First Run](#first-run)
7. [Verification](#verification)

## System Requirements

### Minimum Requirements
- **Operating System**: Linux, macOS, or Windows 10/11
- **Python**: 3.11 or higher
- **Node.js**: 18.0 or higher
- **RAM**: 4GB minimum, 8GB recommended
- **Disk Space**: 2GB for application and dependencies

### Required Accounts
- **Anthropic API**: You need an Anthropic API key to use Claude
  - Sign up at: https://console.anthropic.com
  - Generate an API key from the dashboard
  - Recommended: Start with Claude Pro or API credits

## Backend Setup

### Step 1: Python Environment

1. **Check Python Version**
```bash
python --version  # Should be 3.11 or higher
```

2. **Navigate to Backend Directory**
```bash
cd ai-training-biz-dev-system/backend
```

3. **Create Virtual Environment**
```bash
# On Linux/macOS
python -m venv venv
source venv/bin/activate

# On Windows
python -m venv venv
venv\Scripts\activate
```

4. **Verify Virtual Environment**
```bash
which python  # Should show path in venv directory
```

### Step 2: Install Dependencies

1. **Upgrade pip**
```bash
pip install --upgrade pip
```

2. **Install Requirements**
```bash
pip install -r requirements.txt
```

This will install:
- FastAPI and Uvicorn
- LangChain and LangGraph
- Anthropic Python SDK
- ChromaDB and sentence-transformers
- SQLAlchemy and database drivers
- All other dependencies

3. **Verify Installation**
```bash
python -c "import fastapi, langchain, anthropic; print('All core packages installed successfully')"
```

### Step 3: Configure Environment

1. **Create .env File**
```bash
cp .env.example .env
```

2. **Edit .env File**
```bash
# Use your preferred text editor
nano .env  # or vim, code, etc.
```

3. **Required Configuration**
```env
# Add your Anthropic API key (REQUIRED)
ANTHROPIC_API_KEY=sk-ant-your-actual-api-key-here

# Other settings can use defaults for now
DEBUG=True
ENVIRONMENT=development
DATABASE_URL=sqlite+aiosqlite:///./ai_training_system.db
```

### Step 4: Initialize Database

```bash
# Initialize database tables
python -c "import asyncio; from database.db import init_db; asyncio.run(init_db())"
```

Expected output:
```
Database initialized successfully
```

## Frontend Setup

### Step 1: Node.js Environment

1. **Check Node.js Version**
```bash
node --version  # Should be 18.0 or higher
npm --version
```

2. **Navigate to Frontend Directory**
```bash
cd ../frontend  # If coming from backend directory
# OR
cd ai-training-biz-dev-system/frontend
```

### Step 2: Install Dependencies

```bash
npm install
```

This will install:
- React and React DOM
- TypeScript
- Vite (build tool)
- TailwindCSS
- React Query
- Axios
- All UI dependencies

### Step 3: Configure Environment

1. **Create .env File**
```bash
cp .env.example .env
```

2. **Verify Configuration**
```bash
cat .env
```

Should show:
```env
VITE_API_URL=http://localhost:8000/api/v1
```

## Database Configuration

### SQLite (Default - Development)

SQLite is configured by default and requires no additional setup.

```env
DATABASE_URL=sqlite+aiosqlite:///./ai_training_system.db
```

### PostgreSQL (Recommended for Production)

1. **Install PostgreSQL**
```bash
# Ubuntu/Debian
sudo apt-get install postgresql postgresql-contrib

# macOS
brew install postgresql
```

2. **Create Database**
```bash
# Start PostgreSQL
sudo service postgresql start  # Linux
brew services start postgresql  # macOS

# Create database
createdb ai_training_db
```

3. **Update .env**
```env
DATABASE_URL=postgresql+asyncpg://username:password@localhost:5432/ai_training_db
```

4. **Install PostgreSQL Driver**
```bash
pip install asyncpg
```

## Environment Configuration

### Critical Environment Variables

**Backend (.env)**

```env
# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
DEBUG=True
ENVIRONMENT=development

# Anthropic API (REQUIRED)
ANTHROPIC_API_KEY=sk-ant-your-key-here
ANTHROPIC_MODEL=claude-3-5-sonnet-20241022

# Database
DATABASE_URL=sqlite+aiosqlite:///./ai_training_system.db

# Redis (Optional for development)
REDIS_URL=redis://localhost:6379/0

# Security
SECRET_KEY=your-secret-key-change-in-production-use-64-char-random-string
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Vector Store
CHROMA_PERSIST_DIRECTORY=./chroma_db
EMBEDDING_MODEL=all-MiniLM-L6-v2

# Agent Configuration
MAX_AGENT_ITERATIONS=10
AGENT_TIMEOUT_SECONDS=300

# Logging
LOG_LEVEL=INFO
LOG_FILE=logs/app.log
```

**Frontend (.env)**

```env
VITE_API_URL=http://localhost:8000/api/v1
```

## First Run

### Start Backend

1. **Activate Virtual Environment** (if not already active)
```bash
cd ai-training-biz-dev-system/backend
source venv/bin/activate  # Linux/macOS
# OR
venv\Scripts\activate  # Windows
```

2. **Start Server**
```bash
python main.py
```

Expected output:
```
INFO: Starting AI Training Business Development System...
INFO: Environment: development
INFO: Database initialized successfully
INFO: All agents initialized and ready
INFO: API server starting on 0.0.0.0:8000
INFO: Uvicorn running on http://0.0.0.0:8000
```

3. **Keep Terminal Open** - Backend must stay running

### Start Frontend

1. **Open New Terminal**

2. **Navigate to Frontend**
```bash
cd ai-training-biz-dev-system/frontend
```

3. **Start Development Server**
```bash
npm run dev
```

Expected output:
```
VITE v5.1.0  ready in 500 ms

➜  Local:   http://localhost:3000/
➜  Network: http://192.168.1.x:3000/
```

4. **Keep Terminal Open** - Frontend must stay running

## Verification

### Test Backend

1. **Health Check**
```bash
curl http://localhost:8000/api/v1/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2025-01-15T10:30:00.000Z",
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
```

2. **API Documentation**

Visit: http://localhost:8000/docs

You should see the Swagger UI with all API endpoints.

### Test Frontend

1. **Open Browser**

Navigate to: http://localhost:3000

2. **Verify UI Loads**

You should see:
- Header with "AI Training Business Development System"
- Navigation tabs (Overview, Daily Routine, Leads, Proposals, Analytics)
- Agent cards showing all 7 agents
- System status showing "System Online"

3. **Test Agent Connection**

- Click on "Daily Routine" tab
- You should see the "Run Daily Routine" button
- This confirms frontend can communicate with backend

### Test Core Functionality

1. **Run Daily Routine**
```bash
curl -X POST http://localhost:8000/api/v1/orchestrator/daily-routine
```

Should return a structured response with daily summary.

2. **Process a Test Lead**

Via UI:
- Go to "Leads" tab
- Enter:
  - Company Name: "Test Corp"
  - Industry: "Technology"
  - Company Size: "201-1000"
  - Region: "North America"
- Click "Process Lead"
- Wait for results (may take 30-60 seconds)

3. **Generate a Test Proposal**

Via UI:
- Go to "Proposals" tab
- Enter:
  - Company Name: "Test Corp"
  - Industry: "Technology"
  - Training Topics: Add "Machine Learning", "AI Ethics"
  - Duration: 5 days
  - Participants: 20
- Click "Generate Proposal"
- Wait for results (may take 60-90 seconds)

## Troubleshooting

### "Module not found" errors

```bash
# Ensure virtual environment is activated
source venv/bin/activate  # Linux/macOS
venv\Scripts\activate     # Windows

# Reinstall dependencies
pip install -r requirements.txt
```

### "Anthropic API key not valid"

1. Check your API key at https://console.anthropic.com
2. Ensure there are no extra spaces in .env file
3. Verify format: `ANTHROPIC_API_KEY=sk-ant-...`
4. Check you have API credits available

### "Database locked" error (SQLite)

```bash
# This can happen if another process is using the database
# Solution: Use PostgreSQL for production, or restart the application
rm ai_training_system.db
python -c "import asyncio; from database.db import init_db; asyncio.run(init_db())"
```

### Frontend can't connect to backend

1. **Check backend is running**
```bash
curl http://localhost:8000/api/v1/health
```

2. **Check CORS settings**

In `backend/core/config.py`, verify:
```python
CORS_ORIGINS: list = [
    "http://localhost:3000",
    # ... other origins
]
```

3. **Check .env in frontend**
```bash
cat frontend/.env
# Should show: VITE_API_URL=http://localhost:8000/api/v1
```

### Port already in use

**Backend (port 8000):**
```bash
# Linux/macOS
lsof -i :8000
kill -9 <PID>

# Windows
netstat -ano | findstr :8000
taskkill /PID <PID> /F
```

**Frontend (port 3000):**
```bash
# Linux/macOS
lsof -i :3000
kill -9 <PID>

# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

## Next Steps

After successful setup:

1. **Read Usage Guide**: `docs/USAGE_GUIDE.md`
2. **Explore API Documentation**: http://localhost:8000/docs
3. **Try Example Workflows**: Run daily routine, process leads, generate proposals
4. **Review Agent Capabilities**: `docs/AGENT_GUIDE.md`
5. **Configure for Production**: `docs/DEPLOYMENT_GUIDE.md`

## Getting Help

If you encounter issues:

1. Check the troubleshooting section above
2. Review error messages in terminal
3. Check application logs: `backend/logs/app.log`
4. Verify all prerequisites are installed
5. Ensure API keys are valid and have credits

## Success Checklist

- [ ] Python 3.11+ installed
- [ ] Node.js 18+ installed
- [ ] Anthropic API key obtained
- [ ] Backend dependencies installed
- [ ] Frontend dependencies installed
- [ ] Database initialized
- [ ] .env files configured
- [ ] Backend starts without errors
- [ ] Frontend starts without errors
- [ ] Health check passes
- [ ] UI loads in browser
- [ ] Can run daily routine
- [ ] Can process test lead
- [ ] Can generate test proposal

Once all items are checked, your system is fully operational!
