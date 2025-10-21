import { useState } from 'react';
import { useMutation } from '@tanstack/react-query';
import { FileText, Loader2, AlertCircle, Download } from 'lucide-react';
import { orchestratorAPI } from '../services/api';

export default function ProposalGeneratorPanel() {
  const [formData, setFormData] = useState({
    company_name: '',
    industry: '',
    training_topics: [] as string[],
    duration_days: 5,
    participants: 20,
  });
  const [topicInput, setTopicInput] = useState('');
  const [result, setResult] = useState<any>(null);

  const proposalMutation = useMutation({
    mutationFn: () =>
      orchestratorAPI.createProposal(
        {
          company_name: formData.company_name,
          industry: formData.industry,
        },
        {
          training_topics: formData.training_topics,
          duration_days: formData.duration_days,
          participants: formData.participants,
        }
      ),
    onSuccess: (response) => {
      setResult(response.data.data);
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    proposalMutation.mutate();
  };

  const addTopic = () => {
    if (topicInput.trim()) {
      setFormData({
        ...formData,
        training_topics: [...formData.training_topics, topicInput.trim()],
      });
      setTopicInput('');
    }
  };

  const removeTopic = (index: number) => {
    setFormData({
      ...formData,
      training_topics: formData.training_topics.filter((_, i) => i !== index),
    });
  };

  return (
    <div className="space-y-6">
      <div className="bg-white border border-gray-200 rounded-lg p-6">
        <div className="flex items-center space-x-3 mb-6">
          <FileText className="h-6 w-6 text-primary-600" />
          <h2 className="text-xl font-semibold text-gray-900">Proposal Generator</h2>
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
                value={formData.company_name}
                onChange={(e) => setFormData({ ...formData, company_name: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                placeholder="e.g., Acme Corporation"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Industry</label>
              <select
                value={formData.industry}
                onChange={(e) => setFormData({ ...formData, industry: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              >
                <option value="">Select industry...</option>
                <option value="Technology">Technology</option>
                <option value="Finance">Finance</option>
                <option value="Healthcare">Healthcare</option>
                <option value="Manufacturing">Manufacturing</option>
                <option value="Retail">Retail</option>
                <option value="Consulting">Consulting</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Duration (Days)
              </label>
              <input
                type="number"
                min="1"
                max="30"
                value={formData.duration_days}
                onChange={(e) =>
                  setFormData({ ...formData, duration_days: parseInt(e.target.value) })
                }
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Number of Participants
              </label>
              <input
                type="number"
                min="1"
                value={formData.participants}
                onChange={(e) => setFormData({ ...formData, participants: parseInt(e.target.value) })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Training Topics *
            </label>
            <div className="flex space-x-2 mb-2">
              <input
                type="text"
                value={topicInput}
                onChange={(e) => setTopicInput(e.target.value)}
                onKeyPress={(e) => e.key === 'Enter' && (e.preventDefault(), addTopic())}
                className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                placeholder="e.g., Machine Learning Fundamentals"
              />
              <button
                type="button"
                onClick={addTopic}
                className="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
              >
                Add
              </button>
            </div>
            <div className="flex flex-wrap gap-2">
              {formData.training_topics.map((topic, index) => (
                <span
                  key={index}
                  className="inline-flex items-center space-x-1 px-3 py-1 bg-primary-100 text-primary-700 rounded-full text-sm"
                >
                  <span>{topic}</span>
                  <button
                    type="button"
                    onClick={() => removeTopic(index)}
                    className="hover:text-primary-900"
                  >
                    ×
                  </button>
                </span>
              ))}
            </div>
          </div>

          <button
            type="submit"
            disabled={
              proposalMutation.isPending ||
              !formData.company_name ||
              formData.training_topics.length === 0
            }
            className="flex items-center space-x-2 px-6 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            {proposalMutation.isPending ? (
              <>
                <Loader2 className="h-5 w-5 animate-spin" />
                <span>Generating Proposal...</span>
              </>
            ) : (
              <>
                <FileText className="h-5 w-5" />
                <span>Generate Proposal</span>
              </>
            )}
          </button>
        </form>

        {proposalMutation.isError && (
          <div className="mt-4 p-4 bg-red-50 border border-red-200 rounded-lg flex items-start space-x-2">
            <AlertCircle className="h-5 w-5 text-red-600 flex-shrink-0 mt-0.5" />
            <div>
              <h4 className="font-medium text-red-900">Error</h4>
              <p className="text-sm text-red-700">
                {(proposalMutation.error as any)?.message || 'Failed to generate proposal'}
              </p>
            </div>
          </div>
        )}
      </div>

      {result && (
        <div className="space-y-6">
          {/* Proposal Content */}
          <div className="bg-white border border-gray-200 rounded-lg p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-gray-900">Generated Proposal</h3>
              <button className="flex items-center space-x-2 px-4 py-2 bg-primary-100 text-primary-700 rounded-lg hover:bg-primary-200 transition-colors">
                <Download className="h-4 w-4" />
                <span>Download</span>
              </button>
            </div>
            <div className="prose max-w-none bg-gray-50 p-6 rounded-lg">
              <pre className="whitespace-pre-wrap text-sm">
                {result.proposal?.proposal_content || JSON.stringify(result.proposal, null, 2)}
              </pre>
            </div>
          </div>

          {/* Supporting Materials */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {result.presentation && (
              <div className="bg-white border border-gray-200 rounded-lg p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Presentation Outline</h3>
                <div className="text-sm text-gray-700 overflow-auto max-h-96">
                  <pre className="whitespace-pre-wrap">
                    {JSON.stringify(result.presentation, null, 2)}
                  </pre>
                </div>
              </div>
            )}

            {result.cover_email && (
              <div className="bg-white border border-gray-200 rounded-lg p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Cover Email</h3>
                <div className="text-sm text-gray-700 overflow-auto max-h-96">
                  <pre className="whitespace-pre-wrap">{JSON.stringify(result.cover_email, null, 2)}</pre>
                </div>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
