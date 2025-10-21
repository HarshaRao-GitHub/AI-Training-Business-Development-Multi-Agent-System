import { useState } from 'react';
import { useQuery, useMutation } from '@tanstack/react-query';
import {
  Brain,
  Search,
  Users,
  FileText,
  MessageSquare,
  Database,
  BarChart3,
  Settings,
  Play,
  Loader2,
} from 'lucide-react';
import { orchestratorAPI, healthCheck } from '../services/api';
import { AgentType } from '../types';
import AgentCard from '../components/AgentCard';
import DailyRoutinePanel from '../components/DailyRoutinePanel';
import LeadManagementPanel from '../components/LeadManagementPanel';
import ProposalGeneratorPanel from '../components/ProposalGeneratorPanel';
import AnalyticsPanel from '../components/AnalyticsPanel';

const agents = [
  {
    id: 'orchestrator',
    name: 'Task Orchestrator',
    type: AgentType.ORCHESTRATOR,
    icon: Settings,
    description: 'Coordinates all agents and manages workflows',
    color: 'purple',
  },
  {
    id: 'research',
    name: 'Research & Intelligence',
    type: AgentType.RESEARCH,
    icon: Search,
    description: 'Market research, trends, and competitor analysis',
    color: 'blue',
  },
  {
    id: 'lead_generation',
    name: 'Lead Generation',
    type: AgentType.LEAD_GENERATION,
    icon: Users,
    description: 'Identify and qualify potential clients',
    color: 'green',
  },
  {
    id: 'content',
    name: 'Content & Proposals',
    type: AgentType.CONTENT,
    icon: FileText,
    description: 'Generate proposals, case studies, and emails',
    color: 'yellow',
  },
  {
    id: 'relationship',
    name: 'Relationship Management',
    type: AgentType.RELATIONSHIP,
    icon: MessageSquare,
    description: 'Client communication and follow-ups',
    color: 'pink',
  },
  {
    id: 'knowledge',
    name: 'Knowledge Management',
    type: AgentType.KNOWLEDGE,
    icon: Database,
    description: 'Organize and retrieve institutional knowledge',
    color: 'indigo',
  },
  {
    id: 'analytics',
    name: 'Analytics & Reporting',
    type: AgentType.ANALYTICS,
    icon: BarChart3,
    description: 'Performance tracking and insights',
    color: 'red',
  },
];

type TabType = 'overview' | 'daily-routine' | 'leads' | 'proposals' | 'analytics';

export default function Dashboard() {
  const [activeTab, setActiveTab] = useState<TabType>('overview');

  // Health check query
  const { data: healthData, isLoading: healthLoading } = useQuery({
    queryKey: ['health'],
    queryFn: async () => {
      const response = await healthCheck();
      return response.data;
    },
    refetchInterval: 30000, // Refresh every 30 seconds
  });

  const getColorClasses = (color: string) => {
    const colors: Record<string, { bg: string; text: string; border: string }> = {
      purple: { bg: 'bg-purple-50', text: 'text-purple-600', border: 'border-purple-200' },
      blue: { bg: 'bg-blue-50', text: 'text-blue-600', border: 'border-blue-200' },
      green: { bg: 'bg-green-50', text: 'text-green-600', border: 'border-green-200' },
      yellow: { bg: 'bg-yellow-50', text: 'text-yellow-600', border: 'border-yellow-200' },
      pink: { bg: 'bg-pink-50', text: 'text-pink-600', border: 'border-pink-200' },
      indigo: { bg: 'bg-indigo-50', text: 'text-indigo-600', border: 'border-indigo-200' },
      red: { bg: 'bg-red-50', text: 'text-red-600', border: 'border-red-200' },
    };
    return colors[color] || colors.blue;
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <Brain className="h-8 w-8 text-primary-600" />
              <div>
                <h1 className="text-2xl font-bold text-gray-900">
                  AI Training Business Development System
                </h1>
                <p className="text-sm text-gray-500">Multi-Agent Productivity Platform</p>
              </div>
            </div>
            <div className="flex items-center space-x-2">
              {healthLoading ? (
                <Loader2 className="h-5 w-5 animate-spin text-gray-400" />
              ) : (
                <div className="flex items-center space-x-2">
                  <div className="h-2 w-2 bg-green-500 rounded-full animate-pulse"></div>
                  <span className="text-sm text-gray-600">System Online</span>
                </div>
              )}
            </div>
          </div>
        </div>
      </header>

      {/* Navigation Tabs */}
      <div className="bg-white border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <nav className="flex space-x-8" aria-label="Tabs">
            {[
              { id: 'overview', label: 'Overview', icon: Brain },
              { id: 'daily-routine', label: 'Daily Routine', icon: Play },
              { id: 'leads', label: 'Leads', icon: Users },
              { id: 'proposals', label: 'Proposals', icon: FileText },
              { id: 'analytics', label: 'Analytics', icon: BarChart3 },
            ].map((tab) => {
              const Icon = tab.icon;
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id as TabType)}
                  className={`
                    flex items-center space-x-2 py-4 px-1 border-b-2 font-medium text-sm
                    ${
                      activeTab === tab.id
                        ? 'border-primary-500 text-primary-600'
                        : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                    }
                  `}
                >
                  <Icon className="h-5 w-5" />
                  <span>{tab.label}</span>
                </button>
              );
            })}
          </nav>
        </div>
      </div>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {activeTab === 'overview' && (
          <div className="space-y-8">
            <div>
              <h2 className="text-xl font-semibold text-gray-900 mb-4">Active Agents</h2>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                {agents.map((agent) => {
                  const Icon = agent.icon;
                  const colors = getColorClasses(agent.color);
                  return (
                    <div
                      key={agent.id}
                      className={`
                        ${colors.bg} border ${colors.border} rounded-lg p-6
                        hover:shadow-md transition-shadow duration-200
                      `}
                    >
                      <div className="flex items-start justify-between mb-3">
                        <Icon className={`h-8 w-8 ${colors.text}`} />
                        <div className="h-2 w-2 bg-green-500 rounded-full"></div>
                      </div>
                      <h3 className={`font-semibold ${colors.text} mb-2`}>{agent.name}</h3>
                      <p className="text-sm text-gray-600">{agent.description}</p>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Quick Stats */}
            <div>
              <h2 className="text-xl font-semibold text-gray-900 mb-4">System Status</h2>
              <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
                <div className="bg-white border border-gray-200 rounded-lg p-6">
                  <div className="text-sm text-gray-500 mb-1">Active Agents</div>
                  <div className="text-3xl font-bold text-gray-900">7</div>
                </div>
                <div className="bg-white border border-gray-200 rounded-lg p-6">
                  <div className="text-sm text-gray-500 mb-1">Tasks Completed</div>
                  <div className="text-3xl font-bold text-green-600">--</div>
                </div>
                <div className="bg-white border border-gray-200 rounded-lg p-6">
                  <div className="text-sm text-gray-500 mb-1">Leads Processed</div>
                  <div className="text-3xl font-bold text-blue-600">--</div>
                </div>
                <div className="bg-white border border-gray-200 rounded-lg p-6">
                  <div className="text-sm text-gray-500 mb-1">Proposals Generated</div>
                  <div className="text-3xl font-bold text-purple-600">--</div>
                </div>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'daily-routine' && <DailyRoutinePanel />}
        {activeTab === 'leads' && <LeadManagementPanel />}
        {activeTab === 'proposals' && <ProposalGeneratorPanel />}
        {activeTab === 'analytics' && <AnalyticsPanel />}
      </main>
    </div>
  );
}
