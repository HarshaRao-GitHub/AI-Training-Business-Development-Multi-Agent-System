#!/bin/bash

# Setup script for AI Training Business Development System
echo "🔧 Setting up AI Training Business Development System..."
echo ""

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed"
    echo "Please install Python 3.11 or higher from https://www.python.org/downloads/"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d " " -f 2 | cut -d "." -f 1,2)
echo "✅ Python $PYTHON_VERSION found"

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed"
    echo "Please install Node.js 18 or higher from https://nodejs.org/"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d "v" -f 2 | cut -d "." -f 1)
echo "✅ Node.js v$NODE_VERSION found"

# Backend setup
echo ""
echo "📦 Setting up backend..."
cd backend

# Create virtual environment
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --quiet --upgrade pip

# Install dependencies
echo "Installing Python dependencies..."
pip install --quiet -r requirements.txt

# Create .env if it doesn't exist
if [ ! -f ".env" ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
    echo "⚠️  Please edit backend/.env and add your ANTHROPIC_API_KEY"
fi

# Initialize database
echo "Initializing database..."
python -c "import asyncio; from database.db import init_db; asyncio.run(init_db())"

echo "✅ Backend setup complete"
cd ..

# Frontend setup
echo ""
echo "📦 Setting up frontend..."
cd frontend

# Create .env if it doesn't exist
if [ ! -f ".env" ]; then
    echo "Creating frontend .env file..."
    cp .env.example .env
fi

# Install dependencies
echo "Installing Node.js dependencies..."
npm install

echo "✅ Frontend setup complete"
cd ..

# Final instructions
echo ""
echo "✨ Setup complete!"
echo ""
echo "⚠️  IMPORTANT: Before running the system:"
echo "   1. Edit backend/.env and add your ANTHROPIC_API_KEY"
echo "   2. Get your API key from: https://console.anthropic.com"
echo ""
echo "To start the system:"
echo "   ./start.sh"
echo ""
echo "Or manually:"
echo "   Terminal 1: cd backend && source venv/bin/activate && python main.py"
echo "   Terminal 2: cd frontend && npm run dev"
echo ""
