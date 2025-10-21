"""
Analytics & Reporting Agent
Tracks performance metrics, generates insights, and forecasts
"""
from typing import Dict, Any, List
from .base_agent import BaseAgent
from datetime import datetime, timedelta
import json


class AnalyticsAgent(BaseAgent):
    """Analytics and Reporting Agent for performance tracking"""

    def __init__(self):
        system_prompt = """You are an expert Analytics and Reporting Agent for AI corporate training business.

Your responsibilities:
1. Track pipeline metrics and KPIs
2. Analyze win/loss patterns
3. Generate revenue forecasts
4. Identify bottlenecks in sales process
5. Provide actionable optimization insights
6. Create executive reports and dashboards

Your expertise includes:
- Sales analytics and metrics
- Predictive modeling and forecasting
- Conversion funnel analysis
- Pattern recognition in business data
- Data visualization and reporting
- Strategic recommendations based on data

You provide clear, actionable insights that drive business decisions. You focus on metrics that matter and avoid vanity metrics."""

        super().__init__(
            agent_type="analytics",
            agent_name="Analytics & Reporting Agent",
            system_prompt=system_prompt
        )

    async def execute(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        """Execute analytics task"""
        task = input_data.get("task")
        parameters = input_data.get("parameters", {})

        self.log_execution("execute", {"task": task, "parameters": parameters})

        if task == "pipeline_analysis":
            return await self.analyze_pipeline(parameters)
        elif task == "win_loss_analysis":
            return await self.analyze_win_loss(parameters)
        elif task == "forecast_revenue":
            return await self.forecast_revenue(parameters)
        elif task == "identify_bottlenecks":
            return await self.identify_bottlenecks(parameters)
        elif task == "performance_report":
            return await self.create_performance_report(parameters)
        elif task == "trend_analysis":
            return await self.analyze_trends(parameters)
        else:
            return {"error": f"Unknown task: {task}"}

    async def analyze_pipeline(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Analyze current pipeline health and metrics"""
        pipeline_data = parameters.get("pipeline_data", {})
        time_period = parameters.get("time_period", "current_quarter")

        prompt = f"""Analyze the sales pipeline and provide comprehensive insights.

Pipeline Data:
{json.dumps(pipeline_data, indent=2)}

Time Period: {time_period}

Provide analysis on:

1. PIPELINE HEALTH OVERVIEW
   - Total pipeline value
   - Number of opportunities by stage
   - Average deal size
   - Pipeline velocity
   - Overall health score (1-10)

2. STAGE ANALYSIS
   For each pipeline stage:
   - Number and value of deals
   - Average time in stage
   - Conversion rate to next stage
   - Stage health assessment

3. QUALITY METRICS
   - Lead quality distribution
   - Engagement levels
   - Qualification thoroughness
   - Risk factors

4. CONCENTRATION ANALYSIS
   - Distribution by industry
   - Distribution by deal size
   - Geographic distribution
   - Risk concentration

5. CONVERSION METRICS
   - Lead-to-qualified rate
   - Qualified-to-proposal rate
   - Proposal-to-close rate
   - Overall conversion funnel

6. VELOCITY ANALYSIS
   - Average sales cycle length
   - Time by stage
   - Fast-moving vs slow-moving deals
   - Acceleration/deceleration trends

7. FORECASTING
   - Expected closes this period
   - Revenue forecast
   - Confidence levels
   - At-risk deals

8. RECOMMENDATIONS
   - Pipeline gaps to address
   - Deals to prioritize
   - Resources to allocate
   - Process improvements

Be specific with numbers and percentages."""

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        # Extract structured metrics
        schema = {
            "health_score": "1-10",
            "total_pipeline_value": "number",
            "total_opportunities": "number",
            "average_deal_size": "number",
            "conversion_rates": {
                "lead_to_qualified": "percentage",
                "qualified_to_proposal": "percentage",
                "proposal_to_close": "percentage"
            },
            "forecast_revenue": "number",
            "at_risk_deals": "number",
            "top_priorities": ["list"],
            "key_recommendations": ["list"]
        }

        structured_analysis = await self.generate_structured_output(
            f"Extract key metrics from this pipeline analysis:\n\n{response[:2000]}",
            schema
        )

        return {
            "analysis": response,
            "structured_metrics": structured_analysis,
            "metadata": {
                "time_period": time_period,
                "date": datetime.utcnow().isoformat()
            }
        }

    async def analyze_win_loss(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Analyze win/loss patterns"""
        deals_data = parameters.get("deals_data", [])
        time_period = parameters.get("time_period", "last_quarter")

        prompt = f"""Analyze win/loss patterns to extract actionable insights.

Deals Data:
{json.dumps(deals_data, indent=2)}

Time Period: {time_period}

Provide comprehensive analysis:

1. WIN/LOSS SUMMARY
   - Total deals closed
   - Win rate
   - Loss rate
   - Revenue won vs lost

2. WIN ANALYSIS
   Why we win:
   - Common characteristics of won deals
   - Key success factors
   - Winning strategies
   - Competitive advantages leveraged

3. LOSS ANALYSIS
   Why we lose:
   - Common reasons for loss
   - Competitive losses vs no-decision
   - Price objections vs other factors
   - Patterns in lost deals

4. SEGMENTATION ANALYSIS
   Win rates by:
   - Industry
   - Deal size
   - Region
   - Lead source
   - Sales approach

5. COMPETITIVE ANALYSIS
   - Main competitors encountered
   - Win rate against each
   - Our strengths vs each competitor
   - Their common advantages

6. TIMING PATTERNS
   - Sales cycle for wins vs losses
   - Seasonal patterns
   - Time-to-close analysis

7. PRICING ANALYSIS
   - Price sensitivity patterns
   - Discount impact on win rate
   - Optimal pricing strategies

8. RECOMMENDATIONS
   - What to replicate from wins
   - What to change to reduce losses
   - Ideal customer profile refinement
   - Competitive positioning adjustments
   - Pricing strategy updates

Be specific and data-driven."""

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        # Extract key insights
        schema = {
            "win_rate": "percentage",
            "total_revenue_won": "number",
            "top_win_factors": ["list"],
            "top_loss_reasons": ["list"],
            "best_performing_segment": "string",
            "worst_performing_segment": "string",
            "key_recommendations": ["list"]
        }

        structured_insights = await self.generate_structured_output(
            f"Extract key insights:\n\n{response[:2000]}",
            schema
        )

        return {
            "analysis": response,
            "structured_insights": structured_insights,
            "metadata": {
                "time_period": time_period,
                "deals_analyzed": len(deals_data),
                "date": datetime.utcnow().isoformat()
            }
        }

    async def forecast_revenue(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Generate revenue forecast"""
        pipeline_data = parameters.get("pipeline_data", {})
        historical_data = parameters.get("historical_data", {})
        forecast_period = parameters.get("forecast_period", "next_quarter")

        prompt = f"""Generate a revenue forecast based on pipeline and historical data.

Current Pipeline:
{json.dumps(pipeline_data, indent=2)}

Historical Performance:
{json.dumps(historical_data, indent=2)}

Forecast Period: {forecast_period}

Provide:

1. REVENUE FORECAST
   - Conservative scenario (low probability deals)
   - Expected scenario (weighted pipeline)
   - Optimistic scenario (if all promising deals close)
   - Most likely outcome with confidence level

2. METHODOLOGY
   - How forecast was calculated
   - Assumptions made
   - Weighting factors used
   - Historical patterns applied

3. PIPELINE BREAKDOWN
   For each stage:
   - Value in stage
   - Expected close rate
   - Expected close timing
   - Contribution to forecast

4. RISK ASSESSMENT
   - At-risk revenue
   - Dependencies and assumptions
   - External factors to consider
   - Confidence level explanation

5. REQUIRED PIPELINE
   - Pipeline needed to hit targets
   - Gap analysis
   - New business needed
   - Acceleration needed

6. LEADING INDICATORS
   - Metrics to watch
   - Early warning signs
   - Positive momentum indicators

7. SCENARIOS ANALYSIS
   - Best case timeline and outcomes
   - Worst case timeline and outcomes
   - Most likely path
   - Contingency planning

8. RECOMMENDATIONS
   - Actions to improve forecast
   - Deals to prioritize
   - Resources to deploy
   - Risks to mitigate

Provide specific numbers and timelines."""

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        # Extract forecast data
        schema = {
            "conservative_forecast": "number",
            "expected_forecast": "number",
            "optimistic_forecast": "number",
            "confidence_level": "percentage",
            "required_new_pipeline": "number",
            "key_assumptions": ["list"],
            "major_risks": ["list"],
            "recommendations": ["list"]
        }

        structured_forecast = await self.generate_structured_output(
            f"Extract forecast details:\n\n{response[:2000]}",
            schema
        )

        return {
            "forecast_analysis": response,
            "structured_forecast": structured_forecast,
            "metadata": {
                "forecast_period": forecast_period,
                "date": datetime.utcnow().isoformat()
            }
        }

    async def identify_bottlenecks(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Identify bottlenecks in the sales process"""
        process_data = parameters.get("process_data", {})
        metrics = parameters.get("metrics", {})

        prompt = f"""Identify bottlenecks and inefficiencies in the sales process.

Process Data:
{json.dumps(process_data, indent=2)}

Current Metrics:
{json.dumps(metrics, indent=2)}

Analyze:

1. BOTTLENECK IDENTIFICATION
   - Where deals are getting stuck
   - Stages with longest duration
   - Low conversion points
   - Resource constraints

2. IMPACT ANALYSIS
   For each bottleneck:
   - Revenue impact
   - Number of deals affected
   - Time cost
   - Severity score (1-10)

3. ROOT CAUSE ANALYSIS
   - Why bottlenecks exist
   - Contributing factors
   - Systemic vs situational issues

4. COMPARISON TO BENCHMARKS
   - Industry standard metrics
   - Our historical performance
   - Gap analysis

5. OPPORTUNITY QUANTIFICATION
   - Revenue upside of fixing each bottleneck
   - Efficiency gains possible
   - ROI of improvements

6. SOLUTIONS
   For each major bottleneck:
   - Recommended solutions
   - Implementation difficulty
   - Expected impact
   - Quick wins vs long-term fixes

7. PRIORITIZATION
   - Which bottlenecks to address first
   - Resource allocation recommendations
   - Timeline for improvements

8. ACTION PLAN
   - Specific steps to take
   - Owners and accountability
   - Success metrics
   - Timeline

Be specific and quantify impact where possible."""

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        # Extract bottlenecks
        schema = {
            "bottlenecks": [
                {
                    "location": "string",
                    "severity": "1-10",
                    "impact": "string",
                    "root_cause": "string",
                    "solution": "string",
                    "priority": "high|medium|low"
                }
            ],
            "total_revenue_at_risk": "number",
            "quick_wins": ["list"],
            "action_plan": ["list"]
        }

        structured_bottlenecks = await self.generate_structured_output(
            f"Extract bottleneck details:\n\n{response[:2000]}",
            schema
        )

        return {
            "analysis": response,
            "structured_bottlenecks": structured_bottlenecks,
            "metadata": {
                "date": datetime.utcnow().isoformat()
            }
        }

    async def create_performance_report(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Create executive performance report"""
        period = parameters.get("period", "monthly")
        metrics_data = parameters.get("metrics_data", {})
        comparison_period = parameters.get("comparison_period", "previous_period")

        prompt = f"""Create an executive performance report.

Period: {period}
Metrics Data:
{json.dumps(metrics_data, indent=2)}

Comparison: {comparison_period}

Create a comprehensive report with:

1. EXECUTIVE SUMMARY
   - Key highlights
   - Major achievements
   - Critical issues
   - Overall assessment

2. KEY PERFORMANCE INDICATORS
   - Revenue (actual vs target)
   - New business added
   - Win rate
   - Average deal size
   - Sales cycle length
   - Pipeline health

   For each: actual, target, variance, trend

3. PIPELINE METRICS
   - Pipeline value
   - Number of opportunities
   - Stage distribution
   - Pipeline coverage ratio

4. ACTIVITY METRICS
   - Leads generated
   - Meetings held
   - Proposals sent
   - Closes achieved

5. TREND ANALYSIS
   - Period-over-period changes
   - Year-over-year if applicable
   - Trajectory analysis
   - Leading vs lagging indicators

6. WINS AND LOSSES
   - Notable wins
   - Why we won
   - Notable losses
   - Why we lost

7. STRATEGIC INSIGHTS
   - What's working well
   - What needs improvement
   - Emerging opportunities
   - Risks and concerns

8. PRIORITIES FOR NEXT PERIOD
   - Key objectives
   - Focus areas
   - Resource needs
   - Success metrics

Make it executive-friendly: clear, concise, actionable."""

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        return {
            "performance_report": response,
            "metadata": {
                "period": period,
                "comparison_period": comparison_period,
                "date": datetime.utcnow().isoformat()
            }
        }

    async def analyze_trends(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Analyze trends over time"""
        time_series_data = parameters.get("time_series_data", {})
        metrics = parameters.get("metrics", ["revenue", "win_rate", "pipeline"])

        prompt = f"""Analyze trends in key business metrics.

Metrics to Analyze: {', '.join(metrics)}

Time Series Data:
{json.dumps(time_series_data, indent=2)}

Provide:

1. TREND SUMMARY
   For each metric:
   - Overall trend direction (up/down/flat)
   - Rate of change
   - Volatility
   - Significance

2. PATTERN RECOGNITION
   - Seasonal patterns
   - Cyclical patterns
   - Anomalies or outliers
   - Correlations between metrics

3. LEADING INDICATORS
   - Which metrics predict future performance
   - Early warning signals
   - Momentum indicators

4. COMPARATIVE ANALYSIS
   - Performance vs historical baseline
   - Best and worst periods
   - Consistency analysis

5. FORECASTING
   - Projected trends
   - Expected ranges
   - Inflection points to watch

6. INSIGHTS
   - What trends tell us
   - Underlying drivers
   - Strategic implications

7. RISKS AND OPPORTUNITIES
   - Concerning trends
   - Positive momentum to leverage
   - Trend-based opportunities

8. RECOMMENDATIONS
   - Actions based on trends
   - Metrics to improve
   - Areas to investigate further

Use data to support all observations."""

        response = await self.invoke_llm([{"role": "user", "content": prompt}])

        return {
            "trend_analysis": response,
            "metadata": {
                "metrics_analyzed": metrics,
                "date": datetime.utcnow().isoformat()
            }
        }
