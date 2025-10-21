import { LucideIcon } from 'lucide-react';

interface AgentCardProps {
  name: string;
  description: string;
  icon: LucideIcon;
  status: 'active' | 'inactive' | 'busy';
  color?: string;
}

export default function AgentCard({ name, description, icon: Icon, status, color = 'blue' }: AgentCardProps) {
  const statusColors = {
    active: 'bg-green-500',
    inactive: 'bg-gray-400',
    busy: 'bg-yellow-500',
  };

  return (
    <div className="bg-white border border-gray-200 rounded-lg p-6 hover:shadow-md transition-shadow">
      <div className="flex items-start justify-between mb-3">
        <Icon className={`h-8 w-8 text-${color}-600`} />
        <div className={`h-2 w-2 ${statusColors[status]} rounded-full`}></div>
      </div>
      <h3 className={`font-semibold text-${color}-600 mb-2`}>{name}</h3>
      <p className="text-sm text-gray-600">{description}</p>
    </div>
  );
}
