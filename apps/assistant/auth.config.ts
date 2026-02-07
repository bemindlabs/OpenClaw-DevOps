import type { NextAuthConfig } from 'next-auth'
import Google from 'next-auth/providers/google'

export const authConfig = {
  providers: [
    Google({
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
      authorization: {
        params: {
          prompt: 'consent',
          access_type: 'offline',
          response_type: 'code',
        },
      },
    }),
  ],
  pages: {
    signIn: '/login',
    error: '/login',
  },
  callbacks: {
    async signIn({ user, account, profile }) {
      // Whitelist check: Only allow specific domains
      const allowedDomains = process.env.ALLOWED_OAUTH_DOMAINS?.split(',') || []
      const emailDomain = user.email?.split('@')[1]

      if (!emailDomain || !allowedDomains.includes(emailDomain)) {
        console.log(`Rejected login attempt from: ${user.email}`)
        return false
      }

      console.log(`Successful login: ${user.email}`)
      return true
    },
    async jwt({ token, user, account, trigger }) {
      // Initial sign in
      if (account && user) {
        token.userId = user.id
        token.email = user.email
        token.name = user.name
        token.picture = user.image
        token.role = 'admin' // Default role, can be fetched from database later
      }

      return token
    },
    async session({ session, token }) {
      if (session.user) {
        session.user.id = token.userId as string
        session.user.email = token.email as string
        session.user.name = token.name as string
        session.user.image = token.picture as string
        session.user.role = token.role as 'admin' | 'operator' | 'viewer'
      }
      return session
    },
    authorized({ auth, request: { nextUrl } }) {
      const isLoggedIn = !!auth?.user
      const isOnDashboard = nextUrl.pathname.startsWith('/dashboard')
      const isOnLogin = nextUrl.pathname.startsWith('/login')

      if (isOnDashboard) {
        if (isLoggedIn) return true
        return false // Redirect unauthenticated users to login page
      } else if (isLoggedIn && isOnLogin) {
        return Response.redirect(new URL('/dashboard', nextUrl))
      }
      return true
    },
  },
  session: {
    strategy: 'jwt',
    maxAge: 24 * 60 * 60, // 24 hours
  },
  // Note: secret is automatically read from AUTH_SECRET environment variable in NextAuth v5
} satisfies NextAuthConfig
