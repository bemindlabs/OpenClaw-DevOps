export type UserRole = 'admin' | 'operator' | 'viewer'

export interface User {
  id: string
  email: string
  name: string
  image?: string
  role: UserRole
}

export interface Session {
  user: User
  expires: string
}
