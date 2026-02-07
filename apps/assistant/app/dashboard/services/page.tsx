import { auth } from '@/lib/auth'
import { ServiceGrid } from '@/components/services/service-grid'

export default async function ServicesPage() {
  const session = await auth()
  const userRole = session?.user?.role || 'viewer'

  return (
    <div className="space-y-6">
      <ServiceGrid userRole={userRole} />
    </div>
  )
}
