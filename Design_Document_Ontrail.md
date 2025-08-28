# Ontrail Social-Fi Application - Design Document

## Design Philosophy

Ontrail embraces a **Modern Pixelated Clean Design** philosophy that prioritizes:

- **Crisp Clear Fonts:** High readability with modern typography
- **Breathless Designs:** Clean, uncluttered interfaces that don't overwhelm
- **Explorer/Trail Runner Friendly:** Intuitive navigation and mobile-optimized experience
- **Light Theming:** Clean white backgrounds with crisp dark fonts for optimal readability
- **Responsive Excellence:** Seamless experience across all devices

## Color Palette

### Primary Colors
```css
--primary-50: #f0f9ff
--primary-100: #e0f2fe
--primary-500: #0ea5e9
--primary-600: #0284c7
--primary-900: #0c4a6e
```

### Neutral Colors
```css
--white: #ffffff
--gray-50: #f9fafb
--gray-100: #f3f4f6
--gray-200: #e5e7eb
--gray-300: #d1d5db
--gray-600: #4b5563
--gray-700: #374151
--gray-800: #1f2937
--gray-900: #111827
--black: #000000
```

### Semantic Colors
```css
--success: #10b981
--warning: #f59e0b
--error: #ef4444
--info: #3b82f6
```

## Typography

### Font Families
- **Primary Font:** Inter (Modern, highly readable)
- **Secondary Font:** JetBrains Mono (For code/monospace elements)
- **Display Font:** Inter Display (For headings and branding)

### Font Scale
```css
--text-xs: 0.75rem (12px)
--text-sm: 0.875rem (14px)
--text-base: 1rem (16px)
--text-lg: 1.125rem (18px)
--text-xl: 1.25rem (20px)
--text-2xl: 1.5rem (24px)
--text-3xl: 1.875rem (30px)
--text-4xl: 2.25rem (36px)
--text-5xl: 3rem (48px)
--text-6xl: 3.75rem (60px)
```

### Font Weights
- **Light:** 300
- **Regular:** 400
- **Medium:** 500
- **Semibold:** 600
- **Bold:** 700

## Component Design System

### Cards

#### Standard Card
```css
.card {
  background: var(--white);
  border: 1px solid var(--gray-200);
  border-radius: 12px;
  box-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1);
  overflow: hidden;
}

.card-header {
  padding: 1.5rem 1.5rem 0;
  border-bottom: 1px solid var(--gray-100);
}

.card-body {
  padding: 1.5rem;
}

.card-footer {
  padding: 0 1.5rem 1.5rem;
  border-top: 1px solid var(--gray-100);
}
```

#### Profile Valuation Card
```css
.profile-card {
  background: linear-gradient(135deg, var(--primary-50) 0%, var(--white) 100%);
  border: 2px solid var(--primary-200);
  border-radius: 16px;
  position: relative;
  overflow: hidden;
}

.profile-card::before {
  content: '';
  position: absolute;
  top: 0;
  right: 0;
  width: 100px;
  height: 100px;
  background: radial-gradient(circle, var(--primary-200) 0%, transparent 70%);
  opacity: 0.3;
}
```

### Buttons

#### Primary Button
```css
.btn-primary {
  background: var(--primary-500);
  color: var(--white);
  border: none;
  border-radius: 8px;
  padding: 0.75rem 1.5rem;
  font-weight: 600;
  font-size: var(--text-sm);
  transition: all 0.2s ease;
}

.btn-primary:hover {
  background: var(--primary-600);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgb(14 165 233 / 0.3);
}
```

#### Icon Buttons
```css
.btn-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border-radius: 8px;
  border: none;
  background: transparent;
  color: var(--gray-600);
  transition: all 0.2s ease;
}

.btn-icon:hover {
  background: var(--gray-100);
  color: var(--gray-900);
}
```

### Icons

#### Standard Icons
- **Edit Actions:** Pen icon (`<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"/></svg>`)
- **Save Actions:** Disc icon (`<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M9 19l3 3m0 0l3-3m-3 3V10"/></svg>`)
- **Navigation:** Chevron icons for breadcrumbs and menus
- **Social:** Heart, share, comment icons for interactions

## Layout System

### Navigation

#### Main Navigation
```css
.nav-main {
  background: var(--white);
  border-bottom: 1px solid var(--gray-200);
  position: sticky;
  top: 0;
  z-index: 50;
}

.nav-menu {
  display: flex;
  align-items: center;
  gap: 2rem;
  padding: 0 1rem;
}

.nav-item {
  color: var(--gray-600);
  font-weight: 500;
  padding: 1rem 0;
  transition: color 0.2s ease;
}

.nav-item:hover,
.nav-item.active {
  color: var(--primary-600);
}

.nav-item.active {
  position: relative;
}

.nav-item.active::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 2px;
  background: var(--primary-500);
}
```

#### Mobile Navigation
- Hamburger menu for mobile devices
- Slide-out navigation drawer
- Bottom tab navigation for core sections

### Grid System

#### Responsive Grid
```css
.grid-responsive {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
}

@media (max-width: 768px) {
  .grid-responsive {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
}
```

#### Content Layout
```css
.layout-main {
  display: grid;
  grid-template-columns: 1fr;
  gap: 2rem;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1rem;
}

@media (min-width: 1024px) {
  .layout-main {
    grid-template-columns: 1fr 300px;
    gap: 3rem;
  }
}
```

## Page-Specific Designs

### Home Page

#### Jumbotron Hero
```css
.hero-jumbotron {
  background: linear-gradient(135deg, var(--primary-500) 0%, var(--primary-600) 100%);
  color: var(--white);
  padding: 4rem 2rem;
  text-align: center;
  position: relative;
  overflow: hidden;
}

.hero-jumbotron::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: url('path-to-attached-image') center/cover;
  opacity: 0.1;
}

.hero-title {
  font-size: var(--text-5xl);
  font-weight: 700;
  margin-bottom: 1rem;
  text-shadow: 0 2px 4px rgb(0 0 0 / 0.3);
}

.hero-subtitle {
  font-size: var(--text-xl);
  opacity: 0.9;
  max-width: 600px;
  margin: 0 auto 2rem;
}
```

#### User Showcase Cards
```css
.user-showcase {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

.user-card {
  background: var(--white);
  border-radius: 12px;
  padding: 1.5rem;
  text-align: center;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.user-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgb(0 0 0 / 0.1);
}
```

### Community Page

#### Google Maps Integration
```css
.map-container {
  height: 500px;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgb(0 0 0 / 0.1);
}

.poi-marker {
  background: var(--primary-500);
  color: var(--white);
  border-radius: 50%;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  box-shadow: 0 2px 8px rgb(0 0 0 / 0.2);
}
```

### Quests Page

#### Quest Cards
```css
.quest-card {
  background: var(--white);
  border: 1px solid var(--gray-200);
  border-radius: 12px;
  padding: 1.5rem;
  transition: all 0.2s ease;
}

.quest-card:hover {
  border-color: var(--primary-300);
  box-shadow: 0 4px 12px rgb(14 165 233 / 0.1);
}

.quest-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1rem;
}

.quest-title {
  font-size: var(--text-lg);
  font-weight: 600;
  color: var(--gray-900);
}

.quest-reward {
  background: var(--primary-50);
  color: var(--primary-700);
  padding: 0.25rem 0.75rem;
  border-radius: 6px;
  font-size: var(--text-sm);
  font-weight: 600;
}
```

### Profile Page

#### Profile Header
```css
.profile-header {
  background: linear-gradient(135deg, var(--primary-50) 0%, var(--white) 100%);
  padding: 3rem 2rem;
  text-align: center;
  border-radius: 12px;
  margin-bottom: 2rem;
}

.profile-avatar {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  border: 4px solid var(--white);
  box-shadow: 0 4px 12px rgb(0 0 0 / 0.1);
  margin: 0 auto 1.5rem;
}

.profile-name {
  font-size: var(--text-3xl);
  font-weight: 700;
  color: var(--gray-900);
  margin-bottom: 0.5rem;
}

.profile-valuation {
  font-size: var(--text-2xl);
  font-weight: 600;
  color: var(--primary-600);
}
```

## Responsive Design

### Breakpoints
```css
--sm: 640px
--md: 768px
--lg: 1024px
--xl: 1280px
--2xl: 1536px
```

### Mobile-First Approach
- **320px - 640px:** Single column, stacked layout
- **640px - 768px:** Two-column layout where appropriate
- **768px+:** Full multi-column layouts

### Touch-Friendly Interactions
- Minimum 44px touch targets
- Swipe gestures for navigation
- Pull-to-refresh functionality
- Optimized spacing for thumb navigation

## Accessibility Guidelines

### Color Contrast
- Text on background: Minimum 4.5:1 contrast ratio
- Large text: Minimum 3:1 contrast ratio
- Interactive elements: Clear focus states

### Keyboard Navigation
- Tab order follows logical content flow
- Skip links for main content areas
- Focus indicators on all interactive elements

### Screen Reader Support
- Semantic HTML structure
- ARIA labels where needed
- Alt text for all images
- Live regions for dynamic content

## Animation & Micro-Interactions

### Loading States
```css
.loading-spinner {
  width: 40px;
  height: 40px;
  border: 3px solid var(--gray-200);
  border-top: 3px solid var(--primary-500);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
```

### Hover Effects
- Subtle scale transforms (1.02x)
- Color transitions (0.2s ease)
- Shadow elevation changes

### Page Transitions
- Fade in/out for route changes
- Slide transitions for mobile navigation
- Smooth scrolling for anchor links

## Performance Considerations

### Image Optimization
- WebP format with fallbacks
- Responsive images with srcset
- Lazy loading for below-the-fold content
- Optimized file sizes (<100KB per image)

### Bundle Optimization
- Code splitting by route
- Tree shaking for unused components
- Optimized font loading
- Minimal CSS framework footprint

---

**Design Document Version:** 1.0
**Date:** January 2025
**Author:** Ontrail Design Team
**Status:** Ready for Implementation
