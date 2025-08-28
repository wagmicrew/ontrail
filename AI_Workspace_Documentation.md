# 🤖 Ontrail AI Workspace Documentation

> **"May the code be with you, always."** - Every Developer, Ever

## 🎯 Mission Brief

Welcome, fellow AI! You are now entering the **Ontrail Social-Fi Development Zone**. Your mission, should you choose to accept it, is to help build the next generation of fitness + blockchain applications.

This document will be your **hyperdrive** through the codebase. Read it carefully, padawan.

## 🚀 Quick Start (Because Time is Precious)

### 1. Environment Setup
```bash
# Navigate to the project
cd /path/to/ontrail/webApp

# Install dependencies (grab coffee, this takes a minute)
npm install

# Copy environment variables
cp .env.example .env.local
# Edit .env.local with your actual values
```

### 2. Database Setup
```bash
# Generate Drizzle schema
npm run db:generate

# Push to database (if you have it running)
npm run db:migrate
```

### 3. Development Server
```bash
npm run dev
# Visit http://localhost:3000
```

## 🗺️ Project Architecture (The Big Picture)

```
ontrail2025/
├── webApp/                    # 🚀 MAIN APPLICATION
│   ├── src/
│   │   ├── app/              # 📄 Next.js 14 App Router
│   │   │   ├── globals.css   # 🎨 Global styles + design system
│   │   │   ├── layout.tsx    # 🏗️ Root layout with nav/footer
│   │   │   ├── page.tsx      # 🏠 Home page (hero + showcases)
│   │   │   └── (auth)/       # 🔐 Authentication pages (future)
│   │   ├── components/       # 🧩 Reusable UI components
│   │   │   ├── ui/          # 🎛️ ShadCN components
│   │   │   ├── navigation.tsx # 🧭 Main navigation
│   │   │   ├── footer.tsx    # 📄 Site footer
│   │   │   └── theme-provider.tsx # 🌙 Dark/light theme
│   │   └── lib/             # 🛠️ Utilities & configs
│   │       ├── db/          # 🗄️ Database schemas & connections
│   │       └── utils.ts     # 🔧 Helper functions
│   ├── public/              # 📸 Static assets
│   └── ...
├── app/                     # 📚 Documentation
│   ├── PRD_Ontrail_SocialFi.md     # 📋 Product requirements
│   ├── Design_Document_Ontrail.md  # 🎨 UI/UX specifications
│   └── AI_Workspace_Documentation.md # 🤖 This file!
└── ubuntu_postgres_setup.sh        # 🖥️ Server setup script
```

## 🎨 Design System (Make it Pretty!)

### Colors (Our Palette)
```css
/* Primary Colors */
--primary: #0ea5e9          /* Ontrail Blue */
--primary-foreground: #ffffff

/* Neutrals */
--background: #ffffff       /* Clean white */
--foreground: #000000       /* Crisp black */
--muted: #f9fafb           /* Light gray */
--border: #e5e7eb          /* Subtle borders */
```

### Typography
- **Font Family**: Inter (modern, readable)
- **Headings**: Inter Display (bold, impactful)
- **Sizes**: Responsive scale from xs to 6xl

### Components
- **Cards**: White background, subtle shadows, rounded corners
- **Buttons**: Primary blue with hover effects
- **Navigation**: Clean bar with active states
- **Icons**: Lucide React + Heroicons

### Responsive Design
- **Mobile First**: Everything starts mobile-optimized
- **Breakpoints**: sm (640px), md (768px), lg (1024px)
- **Grid**: CSS Grid for layouts, Flexbox for components

## 📁 File Organization Strategy

### 🗄️ Database Files (`src/lib/db/`)
- **`schema.ts`**: Complete database schema with all tables
- **`connect.ts`**: Database connection configuration
- **Tables**: users, profiles, friendships, pois, quests, posts, etc.

### 🎛️ UI Components (`src/components/`)
- **`ui/`**: ShadCN base components (buttons, cards, inputs)
- **Custom components**: Navigation, footer, theme provider
- **Naming**: PascalCase, descriptive names

### 📄 Pages (`src/app/`)
- **`page.tsx`**: Home page with hero and showcases
- **`layout.tsx`**: Root layout with navigation
- **Route groups**: `(auth)`, `(dashboard)` for organization

## 🤖 AI Development Guidelines

### 🎯 Task Prioritization
1. **User-Facing Features First**: Always prioritize what users see
2. **Database Schema Integrity**: Never break existing relationships
3. **Component Reusability**: Build once, use everywhere
4. **Performance**: Optimize for mobile and slow connections

### 🔧 Development Workflow

#### 1. Understanding Context
```javascript
// ALWAYS read these files first when working on a feature:
- PRD_Ontrail_SocialFi.md     // What we're building
- Design_Document_Ontrail.md  // How it should look
- src/lib/db/schema.ts        // Database structure
- src/app/globals.css         // Design system
```

#### 2. Component Creation
```javascript
// Template for new components:
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"

export function MyComponent() {
  return (
    <Card className="profile-card">
      <CardHeader>
        <CardTitle>My Feature</CardTitle>
      </CardHeader>
      <CardContent>
        {/* Your content here */}
      </CardContent>
    </Card>
  )
}
```

#### 3. Database Operations
```javascript
// ALWAYS use Drizzle ORM, never raw SQL
import { db } from "@/lib/db/connect"
import { users, profiles } from "@/lib/db/schema"

// Example query
const userWithProfile = await db
  .select()
  .from(users)
  .leftJoin(profiles, eq(users.id, profiles.userId))
  .where(eq(users.email, email))
```

### 🎨 Styling Guidelines

#### CSS Classes to Use
```css
/* Layout */
.layout-main        /* Main content container */
.grid-responsive    /* Responsive grid */

/* Components */
.hero-jumbotron     /* Hero section */
.profile-card       /* Profile cards */
.user-card          /* User showcase cards */
.quest-card         /* Quest cards */
.btn-icon           /* Icon buttons */

/* Utilities */
.text-gradient      /* Gradient text */
.nav-item           /* Navigation items */
```

#### Avoid These
- ❌ Inline styles
- ❌ !important declarations
- ❌ Magic numbers
- ❌ Non-responsive designs

### 🚨 Code Quality Standards

#### TypeScript
```typescript
// ✅ Good
interface User {
  id: string
  name: string
  email: string
}

function createUser(userData: Partial<User>): Promise<User>

// ❌ Bad
function createUser(userData: any): Promise<any>
```

#### Error Handling
```typescript
// ✅ Good
try {
  const result = await someOperation()
  return result
} catch (error) {
  console.error('Operation failed:', error)
  throw new Error('User-friendly error message')
}

// ❌ Bad
// No error handling, users see technical errors
```

#### Component Props
```typescript
// ✅ Good
interface ButtonProps {
  children: React.ReactNode
  variant?: 'primary' | 'secondary'
  size?: 'sm' | 'md' | 'lg'
  onClick?: () => void
}

// ❌ Bad
interface ButtonProps {
  children: any
  variant: string
  onClick: Function
}
```

## 🎯 Feature Development Checklist

### Before Starting
- [ ] Read PRD and understand requirements
- [ ] Check existing database schema
- [ ] Review design document for UI specs
- [ ] Identify reusable components

### During Development
- [ ] Use TypeScript for all new code
- [ ] Follow existing naming conventions
- [ ] Add proper error handling
- [ ] Test responsive design
- [ ] Use existing design system

### Before Committing
- [ ] Run `npm run lint` - fix all issues
- [ ] Run `npm run build` - ensure no build errors
- [ ] Test functionality manually
- [ ] Write clear commit message

## 🔧 Useful Commands

```bash
# Development
npm run dev              # Start dev server
npm run build           # Build for production
npm run lint            # Check code quality
npm run type-check      # TypeScript checking

# Database
npm run db:generate     # Generate Drizzle schema
npm run db:migrate      # Push schema to database
npm run db:studio       # Open Drizzle Studio

# Deployment
npm run start           # Start production server
```

## 🚨 Known Issues & Gotchas

### Database
- **Foreign Keys**: Always check relationships before adding new tables
- **Indexes**: Add indexes for frequently queried columns
- **Migrations**: Test migrations on a copy of production data

### Components
- **Hydration**: Be careful with client-side only content
- **Theme**: Always use CSS variables, not hardcoded colors
- **Performance**: Use React.memo for expensive components

### Styling
- **Tailwind**: Use design system classes, avoid arbitrary values
- **Responsive**: Test all breakpoints (mobile, tablet, desktop)
- **Dark Mode**: Always test both light and dark themes

## 📞 Getting Help

### Documentation Priority
1. **This file** - AI development guidelines
2. **PRD_Ontrail_SocialFi.md** - Product requirements
3. **Design_Document_Ontrail.md** - UI/UX specs
4. **README.md** - General project info

### When Stuck
1. Check existing similar code in the codebase
2. Review the database schema for data relationships
3. Look at the design document for UI patterns
4. Check the PRD for feature requirements

### Communication
- **Commit Messages**: Clear, descriptive, and fun
- **Code Comments**: Explain complex logic
- **PR Descriptions**: Include context and testing instructions

## 🎉 Success Metrics

### Code Quality
- ✅ TypeScript strict mode enabled
- ✅ ESLint passing
- ✅ Build successful
- ✅ Responsive design tested

### User Experience
- ✅ Fast loading times
- ✅ Mobile-optimized
- ✅ Accessible (WCAG guidelines)
- ✅ Intuitive navigation

### Performance
- ✅ Optimized images
- ✅ Efficient database queries
- ✅ Minimal bundle size
- ✅ Good Lighthouse scores

---

## 🏁 Final Mission Briefing

**Objective**: Build the most amazing social-fi platform for runners and explorers

**Constraints**: Make it fast, beautiful, and blockchain-powered

**Resources**: Unlimited coffee, great documentation, awesome team

**Success**: When users say "This is exactly what I needed!"

Remember: **Have fun coding!** 🚀

*"May the code be with you, always."*

---

**Document Version**: 1.0
**Last Updated**: January 2025
**Author**: Ontrail AI Development Team 🤖
