/**
 * Mock Backend API Server
 * Provides sample data for the BD Assistant frontend
 */

import express from 'express';
import cors from 'cors';

const app = express();
const PORT = 8000;

app.use(cors());
app.use(express.json());

// Sample data
const sampleLeads = [
  {
    id: 1,
    company_name: "TechCorp Industries",
    industry: "Technology",
    company_size: "500-1000",
    website: "https://techcorp.example.com",
    contact_name: "Jane Smith",
    contact_email: "jane@techcorp.example.com",
    contact_title: "VP of Training",
    status: "QUALIFIED",
    score: "HOT",
    qualification_score: 92,
    estimated_value: 150000,
    ai_adoption_signals: ["ChatGPT Enterprise", "GitHub Copilot", "AI job postings"],
    training_needs: ["Prompt Engineering", "AI Ethics", "LLM Integration"],
    created_at: new Date().toISOString()
  },
  {
    id: 2,
    company_name: "FinanceFlow Inc",
    industry: "Finance",
    company_size: "1000-5000",
    website: "https://financeflow.example.com",
    contact_name: "Robert Chen",
    contact_email: "rchen@financeflow.example.com",
    contact_title: "Director of L&D",
    status: "CONTACTED",
    score: "WARM",
    qualification_score: 78,
    estimated_value: 250000,
    ai_adoption_signals: ["AI strategy initiative", "Data science team expansion"],
    training_needs: ["AI for Finance", "Risk Assessment with AI"],
    created_at: new Date().toISOString()
  },
  {
    id: 3,
    company_name: "HealthTech Solutions",
    industry: "Healthcare",
    company_size: "200-500",
    contact_name: "Maria Garcia",
    contact_email: "mgarcia@healthtech.example.com",
    contact_title: "CEO",
    status: "NEW",
    score: "WARM",
    qualification_score: 65,
    estimated_value: 85000,
    ai_adoption_signals: ["HIPAA-compliant AI interest"],
    training_needs: ["AI in Healthcare", "Medical AI Ethics"],
    created_at: new Date().toISOString()
  },
  {
    id: 4,
    company_name: "RetailMax Global",
    industry: "Retail",
    company_size: "5000+",
    contact_name: "David Park",
    contact_email: "dpark@retailmax.example.com",
    contact_title: "Chief Learning Officer",
    status: "PROPOSAL_SENT",
    score: "HOT",
    qualification_score: 88,
    estimated_value: 320000,
    ai_adoption_signals: ["Customer service AI", "Inventory AI", "Demand forecasting"],
    training_needs: ["AI Customer Experience", "Supply Chain AI"],
    created_at: new Date().toISOString()
  }
];

const sampleAgents = [
  { name: "orchestrator", display_name: "Orchestrator", status: "online", description: "Coordinates all agents" },
  { name: "research", display_name: "Research & Intelligence", status: "online", description: "Market research and analysis" },
  { name: "lead_gen", display_name: "Lead Generation", status: "online", description: "Lead qualification and scoring" },
  { name: "content", display_name: "Content & Proposals", status: "online", description: "Generate proposals and content" },
  { name: "relationship", display_name: "Relationship Management", status: "online", description: "Track and manage relationships" },
  { name: "knowledge", display_name: "Knowledge Management", status: "online", description: "Institutional knowledge and RAG" },
  { name: "analytics", display_name: "Analytics & Reporting", status: "online", description: "Pipeline and performance analytics" }
];

// Health Check
app.get('/api/v1/health', (req, res) => {
  res.json({ status: 'healthy', version: '1.0.0', agents: sampleAgents.length });
});

// Orchestrator endpoints
app.post('/api/v1/orchestrator/daily-routine', (req, res) => {
  res.json({
    success: true,
    data: {
      date: new Date().toISOString(),
      morning_brief: "Good morning! Today you have 4 hot leads to follow up with. The AI training market shows continued growth with 15% increase in enterprise inquiries this quarter.",
      priority_leads: sampleLeads.filter(l => l.score === "HOT"),
      scheduled_follow_ups: [
        { lead_id: 1, company: "TechCorp Industries", action: "Discovery call", due_time: "10:00 AM" },
        { lead_id: 4, company: "RetailMax Global", action: "Proposal review call", due_time: "2:00 PM" }
      ],
      suggested_actions: [
        { action: "Follow up with FinanceFlow Inc", reason: "No response in 5 days", impact: "HIGH" },
        { action: "Generate proposal for HealthTech", reason: "Strong qualification score", impact: "MEDIUM" }
      ],
      market_updates: [
        "Enterprise AI training budgets increased 25% YoY",
        "New competitor entered market with aggressive pricing",
        "Regulatory changes in EU affecting AI training requirements"
      ]
    }
  });
});

app.post('/api/v1/orchestrator/process', (req, res) => {
  res.json({
    success: true,
    result: {
      task_id: `task-${Date.now()}`,
      status: "completed",
      message: "Request processed successfully by the orchestrator agent"
    }
  });
});

app.post('/api/v1/orchestrator/handle-lead', (req, res) => {
  res.json({
    success: true,
    result: {
      lead_id: Date.now(),
      status: "processed",
      qualification_score: Math.floor(Math.random() * 40) + 60,
      recommended_actions: ["Schedule discovery call", "Send company overview"]
    }
  });
});

app.post('/api/v1/orchestrator/create-proposal', (req, res) => {
  res.json({
    success: true,
    proposal: {
      id: `prop-${Date.now()}`,
      title: "AI Training Program Proposal",
      executive_summary: "Comprehensive AI training program tailored to your organization's needs...",
      modules: ["Prompt Engineering Fundamentals", "AI Ethics & Governance", "LLM Integration Best Practices"],
      pricing: { base: 150000, discount: 10, final: 135000 },
      timeline: "6 weeks"
    }
  });
});

// Research endpoints
app.post('/api/v1/research/market-analysis', (req, res) => {
  res.json({
    success: true,
    analysis: {
      industry: req.body?.parameters?.industry || "Technology",
      market_size: "$45.2 billion",
      growth_rate: "18.5% CAGR",
      key_trends: [
        "Increased demand for generative AI training",
        "Focus on responsible AI practices",
        "Integration of AI into existing workflows"
      ],
      opportunities: [
        "Enterprise prompt engineering training",
        "AI governance and compliance programs",
        "Industry-specific AI applications"
      ],
      ai_adoption_rate: "67% of enterprises"
    }
  });
});

app.get('/api/v1/research/intelligence-brief', (req, res) => {
  res.json({
    success: true,
    brief: {
      type: req.query.brief_type || "daily",
      date: new Date().toISOString(),
      title: "Daily Intelligence Brief",
      summary: "Key developments in AI training market show continued enterprise adoption...",
      insights: [
        { title: "Enterprise LLM Adoption", description: "Fortune 500 adoption up 40%", confidence: 0.85 },
        { title: "Healthcare AI Training Gap", description: "Significant opportunity in clinical AI training", confidence: 0.78 }
      ],
      recommendations: [
        "Focus outreach on healthcare sector",
        "Develop compliance-focused training modules",
        "Partner with industry associations"
      ]
    }
  });
});

app.post('/api/v1/research/competitor-analysis', (req, res) => {
  res.json({
    success: true,
    analysis: {
      competitors: [
        { name: "AITrainingPro", strengths: ["Brand recognition", "Large course library"], weaknesses: ["Generic content", "No customization"] },
        { name: "EnterpriseAI Academy", strengths: ["Enterprise focus", "Good support"], weaknesses: ["High pricing", "Long timelines"] }
      ],
      market_position: "Strong differentiation through AI-powered customization",
      opportunities: ["Vertical-specific programs", "Faster delivery", "Better pricing"]
    }
  });
});

// Lead endpoints
app.post('/api/v1/leads/qualify', (req, res) => {
  const score = Math.floor(Math.random() * 30) + 70;
  res.json({
    success: true,
    qualification: {
      score: score,
      grade: score >= 80 ? "A" : score >= 60 ? "B" : "C",
      recommendation: score >= 80 ? "Hot lead - prioritize outreach" : "Warm lead - nurture with content",
      bant_analysis: {
        budget: { score: 8, notes: "Budget approved for Q2" },
        authority: { score: 9, notes: "Direct decision maker" },
        need: { score: 7, notes: "Clear training gaps identified" },
        timeline: { score: 8, notes: "Implementation target within 3 months" }
      },
      next_steps: ["Schedule discovery call", "Send relevant case studies", "Prepare preliminary proposal"]
    }
  });
});

app.post('/api/v1/leads/score', (req, res) => {
  const score = Math.floor(Math.random() * 40) + 60;
  res.json({
    success: true,
    scoring: {
      total_score: score,
      category: score >= 80 ? "HOT" : score >= 60 ? "WARM" : "COLD",
      breakdown: {
        company_fit: Math.floor(score * 0.3),
        engagement_level: Math.floor(score * 0.25),
        budget_signals: Math.floor(score * 0.25),
        timing: Math.floor(score * 0.2)
      }
    }
  });
});

app.post('/api/v1/leads/enrich', (req, res) => {
  res.json({
    success: true,
    enrichment: {
      company_info: {
        employees: "500-1000",
        revenue: "$50M-100M",
        founded: "2015",
        headquarters: "San Francisco, CA"
      },
      technology_stack: ["AWS", "Python", "React", "TensorFlow"],
      recent_news: [
        "Announced AI initiative in Q4 2025",
        "Hired VP of AI Strategy"
      ],
      social_presence: {
        linkedin_followers: 15000,
        twitter_followers: 8500
      }
    }
  });
});

app.post('/api/v1/leads/decision-makers', (req, res) => {
  res.json({
    success: true,
    decision_makers: [
      { name: "Sarah Johnson", title: "Chief Learning Officer", influence: "High", linkedin: "#" },
      { name: "Michael Chen", title: "VP of Engineering", influence: "High", linkedin: "#" },
      { name: "Emily Davis", title: "HR Director", influence: "Medium", linkedin: "#" }
    ]
  });
});

app.post('/api/v1/leads/identify', (req, res) => {
  res.json({
    success: true,
    leads: sampleLeads.slice(0, 3)
  });
});

// Content endpoints
app.post('/api/v1/content/proposal', (req, res) => {
  res.json({
    success: true,
    proposal: {
      id: `proposal-${Date.now()}`,
      title: "AI Training Program Proposal",
      executive_summary: "A comprehensive, customized AI training program designed to upskill your workforce in practical AI applications, prompt engineering, and responsible AI usage.",
      modules: [
        { name: "Prompt Engineering Fundamentals", duration: "2 days", format: "Workshop" },
        { name: "AI Ethics & Governance", duration: "1 day", format: "Seminar" },
        { name: "LLM Integration Best Practices", duration: "3 days", format: "Hands-on Lab" }
      ],
      pricing: {
        base_price: 150000,
        discount_percentage: 10,
        final_price: 135000,
        payment_terms: "50% upfront, 50% on completion"
      },
      timeline: "6 weeks",
      deliverables: [
        "Customized training materials",
        "Hands-on exercises with real scenarios",
        "Certification for all participants",
        "30-day post-training support"
      ]
    }
  });
});

app.post('/api/v1/content/email', (req, res) => {
  res.json({
    success: true,
    email: {
      subject: "Transform Your Team with AI Training",
      body: "Dear [Name],\n\nI hope this email finds you well. Following our conversation about AI adoption challenges, I wanted to share how our customized AI training programs have helped similar organizations...",
      call_to_action: "Schedule a 30-minute discovery call"
    }
  });
});

// Analytics endpoints
app.post('/api/v1/analytics/pipeline', (req, res) => {
  res.json({
    success: true,
    analysis: {
      total_value: 1250000,
      weighted_value: 875000,
      stage_breakdown: [
        { stage: "New", count: 15, value: 180000 },
        { stage: "Qualified", count: 12, value: 320000 },
        { stage: "Proposal", count: 8, value: 450000 },
        { stage: "Negotiation", count: 5, value: 300000 }
      ],
      health_score: 78,
      velocity: "32 days average",
      conversion_rate: "24%",
      forecast: {
        q1: 450000,
        q2: 520000,
        q3: 380000,
        q4: 600000
      }
    }
  });
});

app.post('/api/v1/analytics/win-loss', (req, res) => {
  res.json({
    success: true,
    analysis: {
      win_rate: 0.32,
      total_deals: 45,
      wins: 14,
      losses: 31,
      win_factors: ["Strong customization", "Competitive pricing", "Quick response time"],
      loss_factors: ["Budget constraints", "Timing issues", "Competitor selection"],
      recommendations: [
        "Focus on value demonstration early",
        "Improve follow-up cadence",
        "Develop more case studies"
      ]
    }
  });
});

app.post('/api/v1/analytics/forecast', (req, res) => {
  res.json({
    success: true,
    forecast: {
      period: "Q2 2026",
      predicted_revenue: 520000,
      confidence: 0.78,
      scenarios: {
        optimistic: 680000,
        expected: 520000,
        conservative: 380000
      },
      key_drivers: ["Enterprise deal pipeline", "Healthcare sector expansion"],
      risks: ["Economic uncertainty", "Competitive pressure"]
    }
  });
});

// Knowledge endpoints
app.post('/api/v1/knowledge/find-similar', (req, res) => {
  res.json({
    success: true,
    cases: [
      {
        title: "Enterprise AI Training - TechGiant Corp",
        industry: "Technology",
        outcome: "Successful",
        value: 280000,
        duration: "8 weeks",
        key_learnings: ["Executive sponsorship critical", "Phased rollout worked well"]
      },
      {
        title: "Financial Services AI Upskilling",
        industry: "Finance",
        outcome: "Successful",
        value: 195000,
        duration: "6 weeks",
        key_learnings: ["Compliance focus important", "Hands-on labs most valued"]
      }
    ]
  });
});

app.post('/api/v1/knowledge/best-practices', (req, res) => {
  res.json({
    success: true,
    practices: [
      { practice: "Start with executive alignment", importance: "Critical", evidence: "92% success correlation" },
      { practice: "Use real company data in exercises", importance: "High", evidence: "Improves engagement 3x" },
      { practice: "Include post-training support", importance: "High", evidence: "Reduces churn by 40%" }
    ]
  });
});

// Relationship endpoints
app.post('/api/v1/relationship/analyze-interaction', (req, res) => {
  res.json({
    success: true,
    analysis: {
      sentiment: "Positive",
      engagement_level: "High",
      key_topics: ["Budget timing", "Implementation timeline", "Team size"],
      concerns_raised: ["Internal approval process", "Resource availability"],
      next_steps: ["Send ROI calculator", "Schedule technical deep-dive"],
      relationship_score: 85
    }
  });
});

app.post('/api/v1/relationship/suggest-followup', (req, res) => {
  res.json({
    success: true,
    suggestion: {
      recommended_action: "Send case study and schedule follow-up call",
      timing: "Within 48 hours",
      channel: "Email + LinkedIn",
      talking_points: [
        "Reference their specific challenges",
        "Share relevant success story",
        "Propose next steps"
      ],
      risk_if_delayed: "Medium - competitor actively engaging"
    }
  });
});

app.post('/api/v1/relationship/prepare-meeting', (req, res) => {
  res.json({
    success: true,
    preparation: {
      agenda: [
        { topic: "Recap previous discussion", duration: "5 min" },
        { topic: "Present tailored solution", duration: "15 min" },
        { topic: "Address concerns", duration: "10 min" },
        { topic: "Discuss next steps", duration: "10 min" }
      ],
      key_stakeholders: ["VP Training", "CTO", "Finance Director"],
      potential_objections: [
        { objection: "Budget constraints", response: "Flexible payment terms, ROI within 6 months" },
        { objection: "Time commitment", response: "Modular approach, minimal disruption" }
      ],
      success_metrics: ["Agreement on pilot program", "Access to technical team"]
    }
  });
});

// Database endpoints
app.post('/api/v1/db/leads', (req, res) => {
  const newLead = {
    id: sampleLeads.length + 1,
    ...req.body,
    created_at: new Date().toISOString(),
    status: "NEW",
    score: "COLD"
  };
  sampleLeads.push(newLead);
  res.json({ success: true, lead: newLead });
});

app.get('/api/v1/db/leads/:id', (req, res) => {
  const lead = sampleLeads.find(l => l.id === parseInt(req.params.id));
  if (lead) {
    res.json({ success: true, lead });
  } else {
    res.status(404).json({ success: false, error: "Lead not found" });
  }
});

app.get('/api/v1/db/leads', (req, res) => {
  res.json({ success: true, leads: sampleLeads });
});

// Start server
app.listen(PORT, () => {
  console.log(`\n🚀 BD Assistant Mock API running at http://localhost:${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/api/v1/health`);
  console.log(`\n✅ Ready for frontend connection!\n`);
});
