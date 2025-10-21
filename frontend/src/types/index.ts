/**
 * TypeScript types for the application
 */

export interface Agent {
  id: string;
  name: string;
  type: AgentType;
  status: 'active' | 'inactive' | 'busy';
  description: string;
}

export enum AgentType {
  ORCHESTRATOR = 'orchestrator',
  RESEARCH = 'research',
  LEAD_GENERATION = 'lead_generation',
  CONTENT = 'content',
  RELATIONSHIP = 'relationship',
  KNOWLEDGE = 'knowledge',
  ANALYTICS = 'analytics',
}

export interface Lead {
  id?: number;
  company_name: string;
  industry?: string;
  company_size?: string;
  region?: string;
  country?: string;
  primary_contact_name?: string;
  primary_contact_email?: string;
  status?: LeadStatus;
  score?: LeadScore;
  score_numeric?: number;
}

export enum LeadStatus {
  NEW = 'new',
  QUALIFIED = 'qualified',
  CONTACTED = 'contacted',
  PROPOSAL_SENT = 'proposal_sent',
  NEGOTIATION = 'negotiation',
  WON = 'won',
  LOST = 'lost',
  INACTIVE = 'inactive',
}

export enum LeadScore {
  HOT = 'hot',
  WARM = 'warm',
  COLD = 'cold',
}

export interface AgentTask {
  id: string;
  agent: AgentType;
  task: string;
  status: 'pending' | 'running' | 'completed' | 'failed';
  created_at: string;
  completed_at?: string;
  result?: any;
  error?: string;
}

export interface DailyRoutineResult {
  daily_summary: string;
  detailed_results: {
    morning_brief?: any;
    new_leads?: any;
    pipeline_status?: any;
    followup_plan?: any;
  };
  metadata: {
    date: string;
    timestamp: string;
  };
}

export interface Proposal {
  proposal_content: string;
  structured_data: {
    title: string;
    executive_summary: string;
    training_modules: Array<{
      module_name: string;
      duration: string;
      objectives: string[];
    }>;
    total_duration: string;
    proposed_price: number;
    key_benefits: string[];
    next_steps: string[];
  };
  metadata: {
    company_name: string;
    date: string;
    word_count: number;
  };
}
