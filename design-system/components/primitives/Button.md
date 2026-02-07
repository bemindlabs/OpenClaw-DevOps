# Component: Button

## Overview

Buttons trigger actions or navigate users through the application. They come in multiple variants to communicate different levels of emphasis and intent.

## Variants

### Primary
Primary actions, highest emphasis. Use sparingly for main CTAs.

```tsx
<Button variant="primary" size="md">
  Deploy Application
</Button>
```

### Secondary
Secondary actions, medium emphasis. Common actions that complement primary.

```tsx
<Button variant="secondary" size="md">
  View Logs
</Button>
```

### Ghost
Tertiary actions, low emphasis. Less prominent actions.

```tsx
<Button variant="ghost" size="md">
  Cancel
</Button>
```

### Danger
Destructive actions. Use for delete, remove, or other irreversible actions.

```tsx
<Button variant="danger" size="md">
  Delete Service
</Button>
```

## Sizes

```tsx
<Button size="sm">Small</Button>
<Button size="md">Medium (default)</Button>
<Button size="lg">Large</Button>
<Button size="xl">Extra Large</Button>
<Button size="icon"><IconPlus /></Button>
```

## States

### Default
```tsx
<Button variant="primary">Default State</Button>
```

### Hover
Automatically handled via CSS:
```css
.button-primary:hover {
  background-color: var(--primary-600);
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.6);
}
```

### Active
```tsx
<Button variant="primary" className="active">
  Active State
</Button>
```

### Disabled
```tsx
<Button variant="primary" disabled>
  Disabled State
</Button>
```

### Loading
```tsx
<Button variant="primary" disabled>
  <Spinner className="mr-2 h-4 w-4 animate-spin" />
  Loading...
</Button>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| variant | `'primary' \| 'secondary' \| 'ghost' \| 'danger'` | `'primary'` | Button style variant |
| size | `'sm' \| 'md' \| 'lg' \| 'xl' \| 'icon'` | `'md'` | Button size |
| disabled | `boolean` | `false` | Disable button interaction |
| loading | `boolean` | `false` | Show loading state |
| fullWidth | `boolean` | `false` | Make button full width |
| onClick | `() => void` | - | Click handler |
| type | `'button' \| 'submit' \| 'reset'` | `'button'` | HTML button type |
| className | `string` | - | Additional CSS classes |
| children | `ReactNode` | - | Button content |

## Usage

### Basic Button

```tsx
import { Button } from '@/components/primitives/Button';

function Example() {
  return (
    <Button variant="primary" onClick={() => console.log('Clicked!')}>
      Click Me
    </Button>
  );
}
```

### With Icon

```tsx
import { Button } from '@/components/primitives/Button';
import { IconDownload } from '@/components/icons';

function Example() {
  return (
    <Button variant="primary">
      <IconDownload className="mr-2 h-4 w-4" />
      Download
    </Button>
  );
}
```

### Loading State

```tsx
import { Button } from '@/components/primitives/Button';
import { Spinner } from '@/components/primitives/Spinner';

function Example() {
  const [loading, setLoading] = useState(false);

  const handleDeploy = async () => {
    setLoading(true);
    await deployService();
    setLoading(false);
  };

  return (
    <Button variant="primary" disabled={loading} onClick={handleDeploy}>
      {loading ? (
        <>
          <Spinner className="mr-2 h-4 w-4" />
          Deploying...
        </>
      ) : (
        'Deploy'
      )}
    </Button>
  );
}
```

### Button Group

```tsx
function Example() {
  return (
    <div className="flex gap-2">
      <Button variant="primary">Save</Button>
      <Button variant="secondary">Save Draft</Button>
      <Button variant="ghost">Cancel</Button>
    </div>
  );
}
```

## Implementation

```tsx
import { forwardRef } from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const buttonVariants = cva(
  // Base styles
  'inline-flex items-center justify-center rounded-lg font-medium transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500 focus-visible:ring-offset-2 focus-visible:ring-offset-neutral-950 disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        primary:
          'bg-primary-500 text-white hover:bg-primary-600 active:bg-primary-700 shadow-sm hover:shadow-md hover:-translate-y-0.5',
        secondary:
          'bg-neutral-800 text-neutral-100 hover:bg-neutral-700 active:bg-neutral-600 border border-neutral-700',
        ghost:
          'text-primary-500 hover:bg-primary-950/50 active:bg-primary-950',
        danger:
          'bg-red-600 text-white hover:bg-red-700 active:bg-red-800 shadow-sm hover:shadow-md hover:-translate-y-0.5',
      },
      size: {
        sm: 'h-9 px-4 text-sm',
        md: 'h-10 px-6 text-base',
        lg: 'h-12 px-8 text-lg',
        xl: 'h-14 px-10 text-xl',
        icon: 'h-10 w-10',
      },
    },
    defaultVariants: {
      variant: 'primary',
      size: 'md',
    },
  }
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  fullWidth?: boolean;
}

const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, fullWidth, ...props }, ref) => {
    return (
      <button
        className={cn(
          buttonVariants({ variant, size }),
          fullWidth && 'w-full',
          className
        )}
        ref={ref}
        {...props}
      />
    );
  }
);

Button.displayName = 'Button';

export { Button, buttonVariants };
```

## Accessibility

### Role
- Default role: `button`
- For links that look like buttons: use `<a>` with button styles

### Keyboard Support
- `Enter` or `Space` - Activates the button
- `Tab` - Moves focus to/from button

### ARIA Attributes

```tsx
// Loading state
<Button aria-busy="true" disabled>
  Loading...
</Button>

// Disabled
<Button aria-disabled="true" disabled>
  Disabled
</Button>

// Icon button requires label
<Button aria-label="Close dialog">
  <XIcon />
</Button>

// Toggle button
<Button
  aria-pressed={isPressed}
  onClick={() => setIsPressed(!isPressed)}
>
  Toggle
</Button>
```

### Focus Management

```tsx
// Always visible focus indicator
<Button className="focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500">
  Accessible Button
</Button>
```

## Best Practices

### Do's ✅

- Use primary buttons for main actions
- Provide clear, action-oriented labels ("Deploy", not "OK")
- Show loading states for async actions
- Use icon buttons for common actions in toolbars
- Include aria-labels for icon-only buttons
- Keep button text concise (1-3 words)

### Don'ts ❌

- Don't use multiple primary buttons in the same section
- Don't remove focus indicators
- Don't use buttons for navigation (use links)
- Don't make buttons too small (min 44x44px touch target)
- Don't use vague labels ("Click here", "Submit")

## Related Components

- [IconButton](IconButton.md) - Icon-only button variant
- [Link](Link.md) - For navigation
- [ButtonGroup](../patterns/ButtonGroup.md) - Multiple related buttons

---

**Last Updated**: 2026-02-07
