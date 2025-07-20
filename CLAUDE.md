# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MoneyMate is a currency converter web application built with Next.js 15.4.1, React 19, and TailwindCSS 4. The project follows Next.js App Router architecture and is configured with TypeScript for type safety.

## Development Commands

```bash
# Start development server with Turbopack
npm run dev

# Build for production
npm run build

# Start production server
npm start

# Run ESLint
npm run lint
```

The development server runs on http://localhost:3000 with Turbopack enabled for faster builds.

## Architecture & Structure

### Technology Stack
- **Framework**: Next.js 15.4.1 with App Router
- **UI Library**: React 19
- **Styling**: TailwindCSS 4 with PostCSS
- **Language**: TypeScript with strict mode
- **Fonts**: Geist Sans and Geist Mono from next/font/google

### Key Configuration Files
- `tsconfig.json`: TypeScript configuration with strict mode, path mapping (@/* aliases), and Next.js plugin
- `next.config.ts`: Next.js configuration (currently minimal)
- `postcss.config.mjs`: PostCSS setup for TailwindCSS 4
- `app/globals.css`: Global styles with CSS custom properties for theming and dark mode support

### App Router Structure
The project uses Next.js App Router with the following structure:
- `app/layout.tsx`: Root layout with font loading and global styles
- `app/page.tsx`: Homepage component
- `app/globals.css`: Global CSS with theme variables and dark mode support

### Styling System
- TailwindCSS 4 with inline theme configuration
- CSS custom properties for theming (`--background`, `--foreground`)
- Automatic dark mode support via `prefers-color-scheme`
- Font variables integrated with TailwindCSS config

## Project Goals

Based on the product requirements document (`docs/moneymate.md`), this is planned to be an iOS currency converter app (MoneyMate) with the following key features:
- Real-time currency rate tracking
- Currency conversion functionality
- Interactive charts and graphs
- User customization for currency preferences
- Offline mode support

Note: The current codebase is a Next.js web starter, suggesting this may be for a web version or early prototyping of the iOS app concept.

## Development Notes

- The project is currently a fresh Next.js installation with minimal customization
- TypeScript path mapping is configured for `@/*` imports
- TailwindCSS 4 is used with modern inline theme configuration
- Dark mode is automatically handled via CSS custom properties