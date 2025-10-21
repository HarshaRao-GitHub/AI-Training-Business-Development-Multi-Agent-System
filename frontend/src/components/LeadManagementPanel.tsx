import { useState } from 'react';
import { useMutation } from '@tanstack/react-query';
import { Users, Loader2, CheckCircle, AlertCircle, Star } from 'lucide-react';
import { leadAPI, orchestratorAPI } from '../services/api';
import { Lead } from '../types';

export default function LeadManagementPanel() {
  const [lead, setLead] = useState<Lead>({
    company_name: '',
    industry: '',
    company_size: '',
    region: '',
  });
  const [result, setResult] = useState<any>(null);

  const handleLeadMutation = useMutation({
    mutationFn: () => orchestratorAPI.handleNewLead(lead),
    onSuccess: (response) => {
      setResult(response.data.data);
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    handleLeadMutation.mutate();
  };

  return (
    <div className="space-y-6">
      <div className="bg-white border border-gray-200 rounded-lg p-6">
        <div className="flex items-center space-x-3 mb-6">
          <Users className="h-6 w-6 text-primary-600" />
          <h2 className="text-xl font-semibold text-gray-900">Lead Management</h2>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Company Name *
              </label>
              <input
                type="text"
                required
                value={lead.company_name}
                onChange={(e) => setLead({ ...lead, company_name: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                placeholder="e.g., Acme Corporation"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Industry</label>
              <select
                value={lead.industry}
                onChange={(e) => setLead({ ...lead, industry: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              >
                <option value="">Select industry...</option>
                <option value="Technology">Technology</option>
                <option value="Finance">Finance</option>
                <option value="Healthcare">Healthcare</option>
                <option value="Manufacturing">Manufacturing</option>
                <option value="Retail">Retail</option>
                <option value="Consulting">Consulting</option>
                <option value="Other">Other</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Company Size</label>
              <select
                value={lead.company_size}
                onChange={(e) => setLead({ ...lead, company_size: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              >
                <option value="">Select size...</option>
                <option value="1-50">1-50 employees</option>
                <option value="51-200">51-200 employees</option>
                <option value="201-1000">201-1,000 employees</option>
                <option value="1001-5000">1,001-5,000 employees</option>
                <option value="5001+">5,001+ employees</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Region</label>
              <select
                value={lead.region}
                onChange={(e) => setLead({ ...lead, region: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              >
                <option value="">Select region...</option>
                <option value="North America">North America</option>
                <option value="Europe">Europe</option>
                <option value="Asia Pacific">Asia Pacific</option>
                <option value="Latin America">Latin America</option>
                <option value="Middle East & Africa">Middle East & Africa</option>
              </select>
            </div>
          </div>

          <button
            type="submit"
            disabled={handleLeadMutation.isPending || !lead.company_name}
            className="flex items-center space-x-2 px-6 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            {handleLeadMutation.isPending ? (
              <>
                <Loader2 className="h-5 w-5 animate-spin" />
                <span>Processing Lead...</span>
              </>
            ) : (
              <>
                <Users className="h-5 w-5" />
                <span>Process Lead</span>
              </>
            )}
          </button>
        </form>

        {handleLeadMutation.isError && (
          <div className="mt-4 p-4 bg-red-50 border border-red-200 rounded-lg flex items-start space-x-2">
            <AlertCircle className="h-5 w-5 text-red-600 flex-shrink-0 mt-0.5" />
            <div>
              <h4 className="font-medium text-red-900">Error</h4>
              <p className="text-sm text-red-700">
                {(handleLeadMutation.error as any)?.message || 'Failed to process lead'}
              </p>
            </div>
          </div>
        )}
      </div>

      {result && (
        <div className="space-y-6">
          {/* Recommendation */}
          <div className="bg-gradient-to-r from-primary-50 to-blue-50 border border-primary-200 rounded-lg p-6">
            <div className="flex items-center space-x-2 mb-4">
              <Star className="h-6 w-6 text-primary-600" />
              <h3 className="text-lg font-semibold text-gray-900">Lead Analysis & Recommendation</h3>
            </div>
            <div className="prose max-w-none">
              <p className="text-gray-700 whitespace-pre-wrap">{result.recommendation}</p>
            </div>
          </div>

          {/* Detailed Analysis */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {/* Enriched Data */}
            {result.detailed_analysis?.enriched_data && (
              <div className="bg-white border border-gray-200 rounded-lg p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Enriched Data</h3>
                <div className="text-sm text-gray-700 overflow-auto max-h-96">
                  <pre className="whitespace-pre-wrap">
                    {JSON.stringify(result.detailed_analysis.enriched_data, null, 2)}
                  </pre>
                </div>
              </div>
            )}

            {/* Lead Score */}
            {result.detailed_analysis?.lead_score && (
              <div className="bg-white border border-gray-200 rounded-lg p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Lead Score</h3>
                <div className="text-sm text-gray-700 overflow-auto max-h-96">
                  <pre className="whitespace-pre-wrap">
                    {JSON.stringify(result.detailed_analysis.lead_score, null, 2)}
                  </pre>
                </div>
              </div>
            )}

            {/* Similar Cases */}
            {result.detailed_analysis?.similar_cases && (
              <div className="bg-white border border-gray-200 rounded-lg p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Similar Cases</h3>
                <div className="text-sm text-gray-700 overflow-auto max-h-96">
                  <pre className="whitespace-pre-wrap">
                    {JSON.stringify(result.detailed_analysis.similar_cases, null, 2)}
                  </pre>
                </div>
              </div>
            )}

            {/* Outreach Email */}
            {result.detailed_analysis?.outreach_email && (
              <div className="bg-white border border-gray-200 rounded-lg p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Recommended Outreach Email</h3>
                <div className="text-sm text-gray-700 overflow-auto max-h-96">
                  <pre className="whitespace-pre-wrap">
                    {JSON.stringify(result.detailed_analysis.outreach_email, null, 2)}
                  </pre>
                </div>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
