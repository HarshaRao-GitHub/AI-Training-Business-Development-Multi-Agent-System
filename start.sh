#!/bin/bash

# Start script for AI Training Business Development System
echo "🚀 Starting AI Training Business Development System..."

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3.11 or higher."
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18 or higher."
    exit 1
fi

# Start backend
echo "📦 Starting backend..."
cd backend
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

source venv/bin/activate
pip install -q --upgrade pip

if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found in backend directory"
    echo "Please copy .env.example to .env and configure your API keys"
    exit 1
fi

echo "Installing backend dependencies..."
pip install -q -r requirements.txt

echo "Initializing database..."
python -c "import asyncio; from database.db import init_db; asyncio.run(init_db())" 2>/dev/null || echo "Database already initialized"

echo "Starting backend server..."
python main.py &
BACKEND_PID=$!
cd ..

# Wait for backend to start
echo "Waiting for backend to start..."
sleep 5

# Start frontend
echo "📦 Starting frontend..."
cd frontend

if [ ! -f ".env" ]; then
    echo "Creating frontend .env file..."
    cp .env.example .env
fi

if [ ! -d "node_modules" ]; then
    echo "Installing frontend dependencies..."
    npm install
fi

echo "Starting frontend server..."
npm run dev &
FRONTEND_PID=$!
cd ..

echo ""
echo "✅ System started successfully!"
echo ""
echo "📍 Access Points:"
echo "   Frontend:  http://localhost:3000"
echo "   Backend:   http://localhost:8000"
echo "   API Docs:  http://localhost:8000/docs"
echo ""
echo "To stop the system, press Ctrl+C"
echo ""

# Wait for Ctrl+C
trap "echo ''; echo '🛑 Stopping system...'; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; echo '✅ System stopped'; exit 0" INT

wait
