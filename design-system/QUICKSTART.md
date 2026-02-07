# Design System Quick Start

Get up and running with the OpenClaw design system in 5 minutes.

## 🚀 Installation

### 1. Copy Design Tokens

```bash
# Copy design system to your project
cp -r design-system/ your-project/
```

### 2. Install Dependencies

```bash
npm install tailwindcss @tailwindcss/forms @tailwindcss/typography
# or
pnpm add tailwindcss @tailwindcss/forms @tailwindcss/typography
```

### 3. Configure Tailwind

```bash
# Copy example config
cp design-system/tailwind.config.example.js tailwind.config.js
```

Or manually merge into your existing config:

```javascript
// tailwind.config.js
const colors = require('./design-system/tokens/colors.json');

module.exports = {
  theme: {
    extend: {
      colors: {
        primary: colors.colors.primary,
        // ... add other tokens
      },
    },
  },
};
```

### 4. Add Fonts

```html
<!-- In your HTML <head> -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;700&family=Space+Grotesk:wght@400;500;600;700&display=swap" rel="stylesheet">
```

### 5. Set Base Styles

```css
/* globals.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  body {
    @apply bg-neutral-950 text-neutral-50 font-sans;
  }
}
```

## 🎨 Using the Design System

### Colors

```tsx
// Primary green
<div className="bg-primary-500 text-white">Primary Button</div>

// Dark backgrounds
<div className="bg-neutral-950">Base Background</div>
<div className="bg-neutral-900">Surface</div>
<div className="bg-neutral-800">Elevated</div>

// Semantic colors
<div className="text-green-500">Success</div>
<div className="text-red-500">Error</div>
<div className="text-amber-500">Warning</div>
```

### Typography

```tsx
// Headings
<h1 className="text-6xl font-bold font-display">Heading 1</h1>
<h2 className="text-4xl font-semibold font-display">Heading 2</h2>

// Body text
<p className="text-base text-neutral-50">Primary text</p>
<p className="text-sm text-neutral-300">Secondary text</p>

// Code
<code className="font-mono text-sm">pnpm install</code>
```

### Spacing

```tsx
// Margins & Padding
<div className="p-4">Padding 1rem (16px)</div>
<div className="mt-8">Margin top 2rem (32px)</div>

// Gaps
<div className="flex gap-4">
  <div>Item 1</div>
  <div>Item 2</div>
</div>
```

### Components

```tsx
// Button
<button className="bg-primary-500 hover:bg-primary-600 text-white px-6 py-3 rounded-lg font-medium transition-colors">
  Deploy Now
</button>

// Card
<div className="bg-neutral-900 rounded-lg p-6 shadow-lg border border-neutral-800">
  <h3 className="text-xl font-semibold text-primary-500 mb-2">
    Service Status
  </h3>
  <p className="text-neutral-400">Monitor your services</p>
</div>

// Badge
<span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-950 text-green-400 border border-green-700">
  Running
</span>
```

### Effects

```tsx
// Shadow
<div className="shadow-md">Standard shadow</div>

// Glow
<div className="shadow-glow-md">Green glow</div>

// Hover lift
<div className="transition-all hover:-translate-y-1 hover:shadow-lg">
  Hover me
</div>
```

## 📱 Responsive Design

```tsx
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
  {/* Mobile: 1 column, Tablet: 2 columns, Desktop: 3 columns */}
</div>

<h1 className="text-3xl md:text-5xl lg:text-6xl">
  {/* Responsive typography */}
</h1>
```

## 🎯 Common Patterns

### Page Layout

```tsx
function Page() {
  return (
    <div className="min-h-screen bg-neutral-950">
      <div className="container mx-auto px-4 md:px-6 lg:px-8 py-8">
        <h1 className="text-5xl font-bold font-display text-primary-500 mb-8">
          Dashboard
        </h1>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Content */}
        </div>
      </div>
    </div>
  );
}
```

### Form

```tsx
<form className="space-y-4">
  <div className="space-y-2">
    <label className="block text-sm font-medium text-neutral-200">
      Service Name
    </label>
    <input
      type="text"
      className="w-full bg-neutral-900 border border-neutral-700 rounded-lg px-4 py-2 text-neutral-50 focus:outline-none focus:ring-2 focus:ring-primary-500"
      placeholder="e.g., api-gateway"
    />
  </div>

  <button
    type="submit"
    className="bg-primary-500 hover:bg-primary-600 text-white px-6 py-3 rounded-lg font-medium transition-colors"
  >
    Create Service
  </button>
</form>
```

### Status Indicator

```tsx
<div className="flex items-center gap-2">
  <span className="w-2 h-2 bg-green-500 rounded-full animate-pulse" />
  <span className="text-sm text-neutral-300">Online</span>
</div>
```

## 📚 Next Steps

1. **Read the principles**: [Design Principles](docs/principles.md)
2. **Review guidelines**: [Implementation Guidelines](docs/guidelines.md)
3. **Explore tokens**: Check JSON files in `tokens/` directory
4. **View components**: [Component Documentation](components/)
5. **Color reference**: [Color Palette Guide](docs/color-palette.md)

## 🆘 Need Help?

- **Documentation**: [Full README](README.md)
- **Examples**: Check the [guidelines](docs/guidelines.md) for more examples
- **Issues**: [GitHub Issues](https://github.com/bemindlabs/OpenClaw-DevOps/issues)
- **Discussions**: [GitHub Discussions](https://github.com/bemindlabs/OpenClaw-DevOps/discussions)

## 💡 Tips

1. **Use design tokens** - Never hardcode colors, spacing, or typography
2. **Start with components** - Build reusable components using the patterns
3. **Test accessibility** - Check color contrast and keyboard navigation
4. **Mobile-first** - Design for mobile, then enhance for larger screens
5. **Consistent spacing** - Use the spacing scale (multiples of 4px)

---

**Happy building!** 🚀

**Last Updated**: 2026-02-07
