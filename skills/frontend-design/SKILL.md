---
name: frontend-design
description: Create distinctive, production-grade frontend interfaces with high design quality and accessibility.
---
## Design Thinking

Before coding, understand the context and commit to a BOLD aesthetic direction:
- **Tone**: Pick an extreme (brutally minimal, maximalist chaos, retro-futuristic, etc).
- **Differentiation**: What makes this UNFORGETTABLE?

**CRITICAL**: Choose a clear conceptual direction and execute it with precision.

---

## Frontend Aesthetics Guidelines

### Typography
- Unexpected, characterful font choices
- Pair distinctive display with refined body
- Consider readability at all sizes
- Ensure proper line height and letter spacing

### Color & Theme
- Dominant colors with sharp accents outperform timid palettes
- Use CSS variables for theming
- Support light and dark modes
- **Accessibility**: Ensure 4.5:1 contrast ratio (WCAG AA)

### Motion
- CSS-only or Motion library (Framer Motion, GSAP)
- Focus on high-impact moments (staggered reveals)
- Respect `prefers-reduced-motion`
- Keep animations under 300ms for UI feedback

### Spatial Composition
- Asymmetry, overlap, diagonal flow
- Generous negative space
- Clear visual hierarchy
- Consistent spacing system

### Backgrounds
- Create atmosphere and depth
- Gradients, noise, geometric patterns
- Performance-conscious (optimize images)

**NEVER** use generic AI-generated aesthetics (Inter, Roboto, purple gradients on white).

---

## Accessibility Checklist

**CRITICAL**: Accessibility is not optional. Every design must pass:

### Visual
- [ ] Color contrast ratio >= 4.5:1 (text), >= 3:1 (large text)
- [ ] No information conveyed by color alone
- [ ] Text resizable up to 200% without loss
- [ ] Focus indicators clearly visible

### Interaction
- [ ] All interactive elements keyboard accessible
- [ ] Focus order is logical
- [ ] No keyboard traps
- [ ] Touch targets >= 44x44px

### Screen Readers
- [ ] ARIA labels on icons and buttons
- [ ] Proper heading hierarchy (h1→h2→h3)
- [ ] Alt text for meaningful images
- [ ] Skip links for navigation

### Forms
- [ ] Labels associated with inputs
- [ ] Error messages linked to fields
- [ ] Required fields clearly marked
- [ ] Helpful error descriptions

### Motion
- [ ] Respect `prefers-reduced-motion`
- [ ] No flashing content (seizure risk)
- [ ] Auto-playing media has controls

---

## Component Design Principles

### Atomic Design
- **Atoms**: Basic elements (buttons, inputs, labels)
- **Molecules**: Simple combinations (form fields)
- **Organisms**: Complex UI sections (headers, cards)
- **Templates**: Page layouts
- **Pages**: Specific instances

### State Design
Design for all states:
- Default
- Hover
- Focus
- Active
- Disabled
- Loading
- Error
- Success
- Empty

### Responsive Breakpoints
```css
/* Mobile first */
@media (min-width: 640px) { /* sm */ }
@media (min-width: 768px) { /* md */ }
@media (min-width: 1024px) { /* lg */ }
@media (min-width: 1280px) { /* xl */ }
```

---

## Design Token System

```css
:root {
  /* Colors */
  --color-primary: ;
  --color-primary-hover: ;
  --color-secondary: ;
  --color-accent: ;
  --color-background: ;
  --color-surface: ;
  --color-text-primary: ;
  --color-text-secondary: ;
  --color-error: ;
  --color-success: ;
  --color-warning: ;

  /* Typography */
  --font-display: ;
  --font-body: ;
  --font-mono: ;
  --text-xs: 0.75rem;
  --text-sm: 0.875rem;
  --text-base: 1rem;
  --text-lg: 1.125rem;
  --text-xl: 1.25rem;
  --text-2xl: 1.5rem;
  --text-3xl: 1.875rem;

  /* Spacing */
  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-3: 0.75rem;
  --space-4: 1rem;
  --space-6: 1.5rem;
  --space-8: 2rem;
  --space-12: 3rem;
  --space-16: 4rem;

  /* Border Radius */
  --radius-sm: 0.25rem;
  --radius-md: 0.5rem;
  --radius-lg: 1rem;
  --radius-full: 9999px;

  /* Shadows */
  --shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
  --shadow-md: 0 4px 6px rgba(0,0,0,0.1);
  --shadow-lg: 0 10px 15px rgba(0,0,0,0.15);

  /* Transitions */
  --transition-fast: 150ms ease;
  --transition-normal: 300ms ease;
  --transition-slow: 500ms ease;
}
```

---

## Performance Considerations

- Lazy load images below the fold
- Use next-gen image formats (WebP, AVIF)
- Minimize JavaScript bundle size
- Avoid layout shifts (CLS)
- Prioritize LCP element loading

---

## Output Format

```markdown
## Design Direction: Issue #<num>

### Aesthetic
- Tone: <chosen direction>
- Differentiator: <what makes it unique>

### Color Palette
- Primary: <color>
- Secondary: <color>
- Accent: <color>

### Typography
- Display: <font>
- Body: <font>

### Key Components
- <component 1>: <design notes>
- <component 2>: <design notes>

### Accessibility
- Contrast verified: ✓
- Keyboard nav: ✓
- Screen reader: ✓

### Motion
- <animation 1>: <description>
- Reduced motion: ✓
```

---

**CRITICAL - Respect the Architecture**: You MUST read `PROJECT_CONTEXT.md`. While this skill focuses on aesthetics, all design system choices (e.g., CSS modules vs Tailwind) and component libraries must follow the core project architecture.
