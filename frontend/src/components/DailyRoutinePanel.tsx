import { useState } from 'react';
import { useMutation } from '@tanstack/react-query';
import { Play, Loader2, CheckCircle, AlertCircle } from 'lucide-react';
import { orchestratorAPI } from '../services/api';

export default function DailyRoutinePanel() {
  const [result, setResult] = useState<any>(null);

  const dailyRoutineMutation = useMutation({
    mutationFn: orchestratorAPI.dailyRoutine,
    onSuccess: (response) => {
      setResult(response.data.data);
    },
  });

  return (
    <div className="space-y-6">
      <div className="bg-white border border-gray-200 rounded-lg p-6">
        <h2 className="text-xl font-semibold text-gray-900 mb-4">Daily Business Development Routine</h2>
        <p className="text-gray-600 mb-6">
          Execute the automated daily routine that includes market intelligence briefing, lead identification,
          pipeline analysis, and follow-up recommendations.
        </p>

        <button
          onClick={() => dailyRoutineMutation.mutate()}
          disabled={dailyRoutineMutation.isPending}
          className="flex items-center space-x-2 px-6 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
        >
          {dailyRoutineMutation.isPending ? (
            <>
              <Loader2 className="h-5 w-5 animate-spin" />
              <span>Running Daily Routine...</span>
            </>
          ) : (
            <>
              <Play className="h-5 w-5" />
              <span>Run Daily Routine</span>
            </>
          )}
        </button>

        {dailyRoutineMutation.isError && (
          <div className="mt-4 p-4 bg-red-50 border border-red-200 rounded-lg flex items-start space-x-2">
            <AlertCircle className="h-5 w-5 text-red-600 flex-shrink-0 mt-0.5" />
            <div>
              <h4 className="font-medium text-red-900">Error</h4>
              <p className="text-sm text-red-700">
                {(dailyRoutineMutation.error as any)?.message || 'Failed to run daily routine'}
              </p>
            </div>
          </div>
        )}
      </div>

      {result && (
        <div className="space-y-6">
          {/* Daily Summary */}
          <div className="bg-white border border-gray-200 rounded-lg p-6">
            <div className="flex items-center space-x-2 mb-4">
              <CheckCircle className="h-6 w-6 text-green-600" />
              <h3 className="text-lg font-semibold text-gray-900">Daily Summary</h3>
            </div>
            <div className="prose max-w-none">
              <p className="text-gray-700 whitespace-pre-wrap">{result.daily_summary}</p>
            </div>
          </div>

          {/* Detailed Results */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {/* Morning Brief */}
            {result.detailed_results?.morning_brief && (
              <div className="bg-white border border-gray-200 rounded-lg p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Intelligence Brief</h3>
                <div className="text-sm text-gray-700">
                  <p className="line-clamp-6">{JSON.stringify(result.detailed_results.morning_brief, null, 2)}</p>
                </div>
              </div>
            )}

            {/* New Leads */}
            {result.detailed_results?.new_leads && (
              <div className="bg-white border border-gray-200 rounded-lg p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">New Leads Identified</h3>
                <div className="text-sm text-gray-700">
                  <p className="line-clamp-6">{JSON.stringify(result.detailed_results.new_leads, null, 2)}</p>
                </div>
              </div>
            )}

            {/* Pipeline Status */}
            {result.detailed_results?.pipeline_status && (
              <div className="bg-white border border-gray-200 rounded-lg p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Pipeline Status</h3>
                <div className="text-sm text-gray-700">
                  <p className="line-clamp-6">{JSON.stringify(result.detailed_results.pipeline_status, null, 2)}</p>
                </div>
              </div>
            )}

            {/* Follow-up Plan */}
            {result.detailed_results?.followup_plan && (
              <div className="bg-white border border-gray-200 rounded-lg p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Follow-up Plan</h3>
                <div className="text-sm text-gray-700">
                  <p className="line-clamp-6">{JSON.stringify(result.detailed_results.followup_plan, null, 2)}</p>
                </div>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
