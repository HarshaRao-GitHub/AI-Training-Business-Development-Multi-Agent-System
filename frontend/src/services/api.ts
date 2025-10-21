/**
 * API client for the multi-agent system
 */
import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api/v1';

export const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error('API Error:', error);
    return Promise.reject(error);
  }
);

// Orchestrator API
export const orchestratorAPI = {
  processRequest: (request: string, parameters: any) =>
    api.post('/orchestrator/process', { task: request, parameters }),

  dailyRoutine: () =>
    api.post('/orchestrator/daily-routine'),

  handleNewLead: (leadData: any) =>
    api.post('/orchestrator/handle-lead', leadData),

  createProposal: (leadData: any, requirements: any) =>
    api.post('/orchestrator/create-proposal', { lead_data: leadData, requirements }),
};

// Research Agent API
export const researchAPI = {
  marketAnalysis: (params: any) =>
    api.post('/research/market-analysis', { parameters: params }),

  competitorAnalysis: (params: any) =>
    api.post('/research/competitor-analysis', { parameters: params }),

  monitorTrends: (params: any) =>
    api.post('/research/trends', { parameters: params }),

  getIntelligenceBrief: (type: string = 'daily') =>
    api.get(`/research/intelligence-brief?brief_type=${type}`),
};

// Lead Generation API
export const leadAPI = {
  identifyLeads: (criteria: any) =>
    api.post('/leads/identify', { parameters: { criteria } }),

  qualifyLead: (leadData: any) =>
    api.post('/leads/qualify', leadData),

  scoreLead: (leadData: any) =>
    api.post('/leads/score', leadData),

  enrichLead: (leadData: any) =>
    api.post('/leads/enrich', leadData),

  findDecisionMakers: (companyName: string) =>
    api.post('/leads/decision-makers', null, { params: { company_name: companyName } }),
};

// Content Agent API
export const contentAPI = {
  createProposal: (leadData: any, trainingRequirements: any) =>
    api.post('/content/proposal', null, { params: { lead_data: leadData, training_requirements: trainingRequirements } }),

  createCaseStudy: (engagementData: any, anonymize: boolean = false) =>
    api.post('/content/case-study', null, { params: { engagement_data: engagementData, anonymize } }),

  createEmail: (emailType: string, recipientData: any, context: any = {}) =>
    api.post('/content/email', null, { params: { email_type: emailType, recipient_data: recipientData, context } }),

  createPresentation: (presentationType: string, audienceData: any, durationMinutes: number = 30) =>
    api.post('/content/presentation', null, {
      params: { presentation_type: presentationType, audience_data: audienceData, duration_minutes: durationMinutes }
    }),
};

// Relationship Agent API
export const relationshipAPI = {
  analyzeInteraction: (interactionData: any, leadData: any) =>
    api.post('/relationship/analyze-interaction', null, { params: { interaction_data: interactionData, lead_data: leadData } }),

  suggestFollowup: (leadData: any, lastInteraction: any, stage: string) =>
    api.post('/relationship/suggest-followup', null, {
      params: { lead_data: leadData, last_interaction: lastInteraction, stage }
    }),

  prepareMeeting: (meetingData: any, leadData: any) =>
    api.post('/relationship/prepare-meeting', null, { params: { meeting_data: meetingData, lead_data: leadData } }),
};

// Knowledge Agent API
export const knowledgeAPI = {
  findSimilarCases: (queryData: any) =>
    api.post('/knowledge/find-similar', queryData),

  extractLessons: (params: any) =>
    api.post('/knowledge/lessons-learned', { parameters: params }),

  getBestPractices: (scenario: string, context: any = {}) =>
    api.post('/knowledge/best-practices', null, { params: { scenario, context } }),
};

// Analytics Agent API
export const analyticsAPI = {
  analyzePipeline: (pipelineData: any, timePeriod: string = 'current_quarter') =>
    api.post('/analytics/pipeline', null, { params: { pipeline_data: pipelineData, time_period: timePeriod } }),

  analyzeWinLoss: (dealsData: any[], timePeriod: string = 'last_quarter') =>
    api.post('/analytics/win-loss', null, { params: { deals_data: dealsData, time_period: timePeriod } }),

  forecastRevenue: (pipelineData: any, historicalData: any, forecastPeriod: string = 'next_quarter') =>
    api.post('/analytics/forecast', null, {
      params: { pipeline_data: pipelineData, historical_data: historicalData, forecast_period: forecastPeriod }
    }),

  getPerformanceReport: (period: string, metricsData: any, comparisonPeriod: string = 'previous_period') =>
    api.post('/analytics/performance-report', null, {
      params: { period, metrics_data: metricsData, comparison_period: comparisonPeriod }
    }),
};

// Database API
export const dbAPI = {
  createLead: (leadData: any) =>
    api.post('/db/leads', leadData),

  getLead: (leadId: number) =>
    api.get(`/db/leads/${leadId}`),
};

// Health Check
export const healthCheck = () => api.get('/health');
