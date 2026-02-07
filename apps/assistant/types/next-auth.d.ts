import { DefaultSession } from 'next-auth'
import { UserRole } from './auth'

declare module 'next-auth' {
  interface Session {
    user: {
      id: string
      role: UserRole
    } & DefaultSession['user']
  }

  interface User {
    role?: UserRole
  }
}

declare module 'next-auth/jwt' {
  interface JWT {
    userId: string
    role: UserRole
  }
}
