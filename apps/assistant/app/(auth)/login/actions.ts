'use server'

import { signIn } from '@/lib/auth'
import { redirect } from 'next/navigation'

export async function handleGoogleSignIn() {
  try {
    await signIn('google', { redirectTo: '/dashboard' })
  } catch (error) {
    // NextAuth signIn throws NEXT_REDIRECT which is expected
    // Re-throw it so Next.js can handle the redirect
    if (error instanceof Error && error.message === 'NEXT_REDIRECT') {
      throw error
    }
    // For other errors, log and redirect to error page
    console.error('Sign in error:', error)
    redirect('/error')
  }
}
