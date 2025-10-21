import { BarChart3 } from 'lucide-react';

export default function AnalyticsPanel() {
  return (
    <div className="space-y-6">
      <div className="bg-white border border-gray-200 rounded-lg p-6">
        <div className="flex items-center space-x-3 mb-6">
          <BarChart3 className="h-6 w-6 text-primary-600" />
          <h2 className="text-xl font-semibold text-gray-900">Analytics & Reporting</h2>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <div className="bg-gradient-to-br from-blue-50 to-blue-100 border border-blue-200 rounded-lg p-6">
            <div className="text-sm text-blue-600 font-medium mb-1">Pipeline Value</div>
            <div className="text-3xl font-bold text-blue-900">$--</div>
            <div className="text-xs text-blue-600 mt-2">Awaiting data</div>
          </div>

          <div className="bg-gradient-to-br from-green-50 to-green-100 border border-green-200 rounded-lg p-6">
            <div className="text-sm text-green-600 font-medium mb-1">Win Rate</div>
            <div className="text-3xl font-bold text-green-900">--%</div>
            <div className="text-xs text-green-600 mt-2">Awaiting data</div>
          </div>

          <div className="bg-gradient-to-br from-purple-50 to-purple-100 border border-purple-200 rounded-lg p-6">
            <div className="text-sm text-purple-600 font-medium mb-1">Avg Deal Size</div>
            <div className="text-3xl font-bold text-purple-900">$--</div>
            <div className="text-xs text-purple-600 mt-2">Awaiting data</div>
          </div>

          <div className="bg-gradient-to-br from-orange-50 to-orange-100 border border-orange-200 rounded-lg p-6">
            <div className="text-sm text-orange-600 font-medium mb-1">Sales Cycle</div>
            <div className="text-3xl font-bold text-orange-900">-- days</div>
            <div className="text-xs text-orange-600 mt-2">Awaiting data</div>
          </div>
        </div>

        <div className="mt-8">
          <p className="text-gray-600 text-center">
            Analytics dashboard will populate with data as you process leads and create proposals.
          </p>
        </div>
      </div>
    </div>
  );
}
