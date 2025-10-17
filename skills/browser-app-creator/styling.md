# Browser App Styling Guide

Complete CSS patterns and design guidelines for ADHD-optimized browser apps.

## Core CSS Framework

### Base Reset & Variables

```css
/* CSS Reset */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

/* CSS Variables for easy theming */
:root {
  /* Dark Mode Colors (Default) */
  --bg-primary: #1a1a1a;
  --bg-secondary: #2a2a2a;
  --bg-tertiary: #333;

  --text-primary: #e0e0e0;
  --text-secondary: #aaa;
  --text-muted: #888;

  --accent-primary: #4a9eff;
  --accent-hover: #357abd;
  --accent-success: #44ff88;
  --accent-error: #ff4444;
  --accent-warning: #ffaa44;

  /* Spacing */
  --spacing-xs: 5px;
  --spacing-sm: 10px;
  --spacing-md: 15px;
  --spacing-lg: 20px;
  --spacing-xl: 30px;

  /* Border Radius */
  --radius-sm: 6px;
  --radius-md: 8px;
  --radius-lg: 12px;

  /* Shadows */
  --shadow-sm: 0 2px 8px rgba(0,0,0,0.2);
  --shadow-md: 0 4px 12px rgba(0,0,0,0.3);
  --shadow-lg: 0 10px 30px rgba(0,0,0,0.4);
}

/* Light Mode Override */
[data-theme="light"] {
  --bg-primary: #f5f5f5;
  --bg-secondary: #ffffff;
  --bg-tertiary: #e0e0e0;

  --text-primary: #1a1a1a;
  --text-secondary: #555;
  --text-muted: #888;

  --accent-primary: #2b7de9;
  --accent-hover: #1a5bb8;
}
```

### Body & Layout

```css
body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto,
    'Helvetica Neue', Arial, sans-serif;
  background: var(--bg-primary);
  color: var(--text-primary);
  padding: var(--spacing-lg);
  max-width: 1200px;
  margin: 0 auto;
  line-height: 1.6;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

/* Responsive container */
.container {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 var(--spacing-lg);
}
```

## ADHD-Optimized Components

### Buttons (60px+ minimum)

```css
button {
  /* Size Requirements */
  min-height: 60px;
  padding: 15px 30px;

  /* Typography */
  font-size: 18px;
  font-weight: 600;

  /* Visual */
  border: none;
  border-radius: var(--radius-md);
  background: var(--accent-primary);
  color: white;

  /* Interaction */
  cursor: pointer;
  transition: all 0.2s ease;

  /* Accessibility */
  -webkit-tap-highlight-color: transparent;
  touch-action: manipulation;
}

button:hover {
  background: var(--accent-hover);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(74, 158, 255, 0.4);
}

button:active {
  transform: translateY(0);
  box-shadow: 0 2px 4px rgba(74, 158, 255, 0.3);
}

button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none !important;
}

/* Button Variants */
.btn-success {
  background: var(--accent-success);
  color: #000;
}

.btn-success:hover {
  background: #33dd77;
}

.btn-error {
  background: var(--accent-error);
}

.btn-error:hover {
  background: #cc0000;
}

.btn-secondary {
  background: var(--bg-tertiary);
  color: var(--text-primary);
}

.btn-secondary:hover {
  background: #444;
}
```

### Input Fields

```css
input,
textarea,
select {
  /* Size */
  min-height: 50px;
  padding: 12px 15px;

  /* Typography */
  font-size: 16px;
  font-family: inherit;

  /* Visual */
  border: 2px solid var(--bg-tertiary);
  border-radius: var(--radius-sm);
  background: var(--bg-secondary);
  color: var(--text-primary);
  width: 100%;

  /* Interaction */
  transition: all 0.2s ease;
}

input:focus,
textarea:focus,
select:focus {
  outline: none;
  border-color: var(--accent-primary);
  box-shadow: 0 0 0 3px rgba(74, 158, 255, 0.2);
}

input::placeholder,
textarea::placeholder {
  color: var(--text-muted);
}

/* Input with error */
input.error,
textarea.error,
select.error {
  border-color: var(--accent-error);
}

input.error:focus,
textarea.error:focus,
select.error:focus {
  box-shadow: 0 0 0 3px rgba(255, 68, 68, 0.2);
}
```

### Cards & Containers

```css
.card {
  background: var(--bg-secondary);
  padding: var(--spacing-xl);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  transition: all 0.2s ease;
}

.card:hover {
  box-shadow: var(--shadow-md);
  transform: translateY(-2px);
}

.card-title {
  font-size: 14px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: var(--text-muted);
  margin-bottom: var(--spacing-sm);
}

.card-value {
  font-size: 36px;
  font-weight: 700;
  color: var(--accent-primary);
  margin-bottom: var(--spacing-xs);
}

.card-subtitle {
  font-size: 14px;
  color: var(--text-secondary);
}
```

## Layout Patterns

### Grid Layout

```css
/* Auto-fit responsive grid */
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: var(--spacing-lg);
}

/* 2-column grid */
.grid-2 {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: var(--spacing-lg);
}

/* 3-column grid */
.grid-3 {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: var(--spacing-lg);
}

/* Responsive breakpoints */
@media (max-width: 768px) {
  .grid-2,
  .grid-3 {
    grid-template-columns: 1fr;
  }
}
```

### Flexbox Utilities

```css
.flex {
  display: flex;
}

.flex-column {
  display: flex;
  flex-direction: column;
}

.flex-center {
  display: flex;
  justify-content: center;
  align-items: center;
}

.flex-between {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.flex-gap-sm {
  gap: var(--spacing-sm);
}

.flex-gap-md {
  gap: var(--spacing-md);
}

.flex-gap-lg {
  gap: var(--spacing-lg);
}
```

## Visual Feedback

### Toast Notifications

```css
.toast {
  position: fixed;
  top: var(--spacing-lg);
  right: var(--spacing-lg);
  padding: 15px 25px;
  border-radius: var(--radius-md);
  font-weight: 600;
  box-shadow: var(--shadow-lg);
  z-index: 1000;
  animation: slideIn 0.3s ease;
}

.toast-success {
  background: var(--accent-success);
  color: #000;
}

.toast-error {
  background: var(--accent-error);
  color: white;
}

.toast-info {
  background: var(--accent-primary);
  color: white;
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}
```

### Loading States

```css
.loading {
  display: inline-block;
  width: 20px;
  height: 20px;
  border: 3px solid rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  border-top-color: white;
  animation: spin 0.6s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

/* Skeleton loading */
.skeleton {
  background: linear-gradient(
    90deg,
    var(--bg-secondary) 25%,
    var(--bg-tertiary) 50%,
    var(--bg-secondary) 75%
  );
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  border-radius: var(--radius-sm);
}

@keyframes shimmer {
  0% {
    background-position: 200% 0;
  }
  100% {
    background-position: -200% 0;
  }
}
```

### Progress Indicators

```css
.progress-bar {
  width: 100%;
  height: 8px;
  background: var(--bg-tertiary);
  border-radius: 4px;
  overflow: hidden;
}

.progress-bar-fill {
  height: 100%;
  background: var(--accent-primary);
  transition: width 0.3s ease;
  border-radius: 4px;
}

/* Circular progress */
.progress-circle {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  background: conic-gradient(
    var(--accent-primary) 0deg,
    var(--bg-tertiary) 0deg
  );
  display: flex;
  align-items: center;
  justify-content: center;
}

.progress-circle::before {
  content: '';
  width: 80px;
  height: 80px;
  background: var(--bg-secondary);
  border-radius: 50%;
}
```

## Status Indicators

```css
.status-indicator {
  display: inline-block;
  width: 12px;
  height: 12px;
  border-radius: 50%;
  margin-right: 8px;
}

.status-online {
  background: var(--accent-success);
  box-shadow: 0 0 10px rgba(68, 255, 136, 0.5);
}

.status-offline {
  background: var(--accent-error);
  box-shadow: 0 0 10px rgba(255, 68, 68, 0.5);
}

.status-warning {
  background: var(--accent-warning);
  box-shadow: 0 0 10px rgba(255, 170, 68, 0.5);
}

/* Pulsing animation */
.status-indicator.pulse {
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%,
  100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}
```

## Responsive Design

### Mobile Breakpoints

```css
/* Mobile First Approach */

/* Small phones */
@media (max-width: 480px) {
  body {
    padding: var(--spacing-sm);
  }

  button {
    min-height: 55px;
    font-size: 16px;
  }

  .card {
    padding: var(--spacing-md);
  }
}

/* Tablets */
@media (min-width: 768px) {
  body {
    padding: var(--spacing-xl);
  }
}

/* Desktop */
@media (min-width: 1024px) {
  body {
    padding: var(--spacing-xl);
  }
}
```

### Touch Optimization

```css
/* Increase touch targets on mobile */
@media (max-width: 768px) {
  button,
  a,
  input[type="checkbox"],
  input[type="radio"] {
    min-height: 44px;
    min-width: 44px;
  }

  /* Prevent text selection on buttons */
  button {
    -webkit-user-select: none;
    user-select: none;
  }

  /* Remove tap highlight */
  * {
    -webkit-tap-highlight-color: transparent;
  }
}
```

## Accessibility

### Focus States

```css
/* Keyboard navigation focus */
*:focus-visible {
  outline: 3px solid var(--accent-primary);
  outline-offset: 2px;
}

/* Remove default focus */
*:focus {
  outline: none;
}
```

### Screen Reader Only

```css
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border-width: 0;
}
```

## Utility Classes

### Spacing

```css
.m-0 { margin: 0; }
.m-sm { margin: var(--spacing-sm); }
.m-md { margin: var(--spacing-md); }
.m-lg { margin: var(--spacing-lg); }
.m-xl { margin: var(--spacing-xl); }

.mt-sm { margin-top: var(--spacing-sm); }
.mt-md { margin-top: var(--spacing-md); }
.mt-lg { margin-top: var(--spacing-lg); }
.mt-xl { margin-top: var(--spacing-xl); }

.mb-sm { margin-bottom: var(--spacing-sm); }
.mb-md { margin-bottom: var(--spacing-md); }
.mb-lg { margin-bottom: var(--spacing-lg); }
.mb-xl { margin-bottom: var(--spacing-xl); }

.p-0 { padding: 0; }
.p-sm { padding: var(--spacing-sm); }
.p-md { padding: var(--spacing-md); }
.p-lg { padding: var(--spacing-lg); }
.p-xl { padding: var(--spacing-xl); }
```

### Typography

```css
.text-center { text-align: center; }
.text-left { text-align: left; }
.text-right { text-align: right; }

.text-xs { font-size: 12px; }
.text-sm { font-size: 14px; }
.text-md { font-size: 16px; }
.text-lg { font-size: 20px; }
.text-xl { font-size: 24px; }
.text-2xl { font-size: 32px; }
.text-3xl { font-size: 48px; }

.font-normal { font-weight: 400; }
.font-medium { font-weight: 500; }
.font-semibold { font-weight: 600; }
.font-bold { font-weight: 700; }
```

### Display

```css
.hidden { display: none; }
.block { display: block; }
.inline-block { display: inline-block; }
.flex { display: flex; }
.grid { display: grid; }

.w-full { width: 100%; }
.h-full { height: 100%; }
```

## Color Schemes

### Alternative Palettes

```css
/* Blue (Default) */
--accent-blue: #4a9eff;

/* Green */
--accent-green: #44ff88;

/* Purple */
--accent-purple: #a78bfa;

/* Orange */
--accent-orange: #ffaa44;

/* Red */
--accent-red: #ff4444;

/* Use by overriding --accent-primary */
:root {
  --accent-primary: var(--accent-purple);
}
```

See main [SKILL.md](SKILL.md) for complete workflow and [templates.md](templates.md) for working examples.
