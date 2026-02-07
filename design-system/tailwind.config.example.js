/**
 * OpenClaw DevOps - Tailwind CSS Configuration
 *
 * This configuration integrates the design system tokens with Tailwind CSS.
 * Copy this to your app's tailwind.config.js and adjust as needed.
 */

const colors = require('./tokens/colors.json');
const typography = require('./tokens/typography.json');
const spacing = require('./tokens/spacing.json');
const shadows = require('./tokens/shadows.json');
const breakpoints = require('./tokens/breakpoints.json');

/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ['class'],
  content: [
    './pages/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    './app/**/*.{ts,tsx}',
    './src/**/*.{ts,tsx}',
  ],
  theme: {
    container: {
      center: true,
      padding: '2rem',
      screens: {
        '2xl': '1400px',
      },
    },
    extend: {
      colors: {
        // Primary green palette
        primary: colors.colors.primary,
        // Accent green palette
        accent: colors.colors.accent,
        // Neutral grays
        neutral: colors.colors.neutral,
        // Semantic colors
        success: colors.colors.semantic.success,
        error: colors.colors.semantic.error,
        warning: colors.colors.semantic.warning,
        info: colors.colors.semantic.info,
        // Background colors
        background: {
          primary: colors.colors.background.primary,
          secondary: colors.colors.background.secondary,
          tertiary: colors.colors.background.tertiary,
          elevated: colors.colors.background.elevated,
        },
        // Surface colors
        surface: colors.colors.surface,
        // Text colors
        text: {
          primary: colors.colors.text.primary,
          secondary: colors.colors.text.secondary,
          tertiary: colors.colors.text.tertiary,
          inverse: colors.colors.text.inverse,
          accent: colors.colors.text.accent,
        },
        // Border colors
        border: {
          DEFAULT: colors.colors.border.default,
          hover: colors.colors.border.hover,
          focus: colors.colors.border.focus,
          error: colors.colors.border.error,
        },
        // Interactive colors
        interactive: colors.colors.interactive,
      },
      // Typography
      fontFamily: {
        sans: typography.fontFamily.sans.split(',').map(f => f.trim()),
        mono: typography.fontFamily.mono.split(',').map(f => f.trim()),
        display: typography.fontFamily.display.split(',').map(f => f.trim()),
      },
      fontSize: typography.fontSize,
      fontWeight: typography.fontWeight,
      lineHeight: typography.lineHeight,
      letterSpacing: typography.letterSpacing,
      // Spacing
      spacing: spacing.spacing,
      // Shadows & Effects
      boxShadow: {
        ...shadows.shadows,
        'glow-sm': shadows.glows['green-sm'],
        'glow-md': shadows.glows['green-md'],
        'glow-lg': shadows.glows['green-lg'],
        'glow-xl': shadows.glows['green-xl'],
        'glow-accent-sm': shadows.glows['accent-sm'],
        'glow-accent-md': shadows.glows['accent-md'],
        'glow-accent-lg': shadows.glows['accent-lg'],
      },
      borderRadius: shadows.borderRadius,
      // Breakpoints
      screens: breakpoints.breakpoints,
      // Animations
      keyframes: {
        'accordion-down': {
          from: { height: 0 },
          to: { height: 'var(--radix-accordion-content-height)' },
        },
        'accordion-up': {
          from: { height: 'var(--radix-accordion-content-height)' },
          to: { height: 0 },
        },
        'fade-in': {
          from: { opacity: 0 },
          to: { opacity: 1 },
        },
        'fade-out': {
          from: { opacity: 1 },
          to: { opacity: 0 },
        },
        'slide-in-from-top': {
          from: { transform: 'translateY(-100%)' },
          to: { transform: 'translateY(0)' },
        },
        'slide-in-from-bottom': {
          from: { transform: 'translateY(100%)' },
          to: { transform: 'translateY(0)' },
        },
        'slide-in-from-left': {
          from: { transform: 'translateX(-100%)' },
          to: { transform: 'translateX(0)' },
        },
        'slide-in-from-right': {
          from: { transform: 'translateX(100%)' },
          to: { transform: 'translateX(0)' },
        },
        pulse: {
          '0%, 100%': { opacity: 1 },
          '50%': { opacity: 0.5 },
        },
        glow: {
          '0%, 100%': { boxShadow: '0 0 20px rgba(34, 197, 94, 0.3)' },
          '50%': { boxShadow: '0 0 40px rgba(34, 197, 94, 0.6)' },
        },
      },
      animation: {
        'accordion-down': 'accordion-down 0.2s ease-out',
        'accordion-up': 'accordion-up 0.2s ease-out',
        'fade-in': 'fade-in 0.3s ease-out',
        'fade-out': 'fade-out 0.3s ease-out',
        'slide-in-from-top': 'slide-in-from-top 0.3s ease-out',
        'slide-in-from-bottom': 'slide-in-from-bottom 0.3s ease-out',
        'slide-in-from-left': 'slide-in-from-left 0.3s ease-out',
        'slide-in-from-right': 'slide-in-from-right 0.3s ease-out',
        pulse: 'pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        glow: 'glow 2s ease-in-out infinite',
      },
      // Gradients
      backgroundImage: {
        'gradient-primary': colors.gradients.primary,
        'gradient-dark': colors.gradients.dark,
        'gradient-accent': colors.gradients.accent,
        'gradient-subtle': colors.gradients.subtle,
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
};
