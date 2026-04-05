# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personalized_Clothing_Design_System-backend production backend using Supabase best practices: Auth + RLS + Edge Functions + SQL Migration.

## Tech Stack

- **Supabase CLI**: Local development, migrations, and deployment
- **Deno**: Edge Functions runtime and testing (>= 2.7)
- **PostgreSQL**: Database (version 17)
- **Gitea CI**: Preview and production deployment workflows

## Common Commands

### Local Development Setup

```bash
# Install dependencies (macOS)
brew install supabase/tap/supabase deno

# Start local Supabase
supabase start

# Reset database and apply migrations (DESTRUCTIVE - local only)
supabase db reset

# Serve Edge Function locally
supabase functions serve auth-api --env-file .env.example
```

`serve` currently uses native Supabase CLI command; `build.sh` focuses on migration, deployment, and test orchestration.

### Testing

```bash
# Run scoped tests for changed modules (MINIMUM baseline below)
deno test supabase/functions/auth-api

# Run scoped type checks for changed modules (MINIMUM baseline below)
deno check supabase/functions/auth-api/*.ts
```

### Build Script (`build.sh`)

```bash
# View configuration
./build.sh print-config

# Deploy to specific project (recommended path for deployment)
./build.sh <project_ref> db-push                           # Push migrations
./build.sh <project_ref> deploy-function auth-api          # Deploy single function
./build.sh <project_ref> deploy-functions-all              # Deploy all functions
./build.sh <project_ref> test-function auth-api            # Run function tests
./build.sh <project_ref> test-functions auth-api,profile-api # Run tests for specific functions
./build.sh <project_ref> test-functions all                # Run tests for all functions
./build.sh <project_ref> test-functions changed            # Run tests for changed functions
./build.sh <project_ref> test-functions changed --base-ref origin/main # Run changed-function tests with explicit base ref
./build.sh <project_ref> test-functions changed --base-ref origin/main --head-ref HEAD # Run changed-function tests with explicit refs
./build.sh <project_ref> test-functions changed --base-ref origin/main --no-fallback # Fail when no changed function found
./build.sh <project_ref> verify-migrations                 # Verify remote migration status (read-only)
./build.sh <project_ref> verify-functions                  # Verify remote functions status (read-only)
./build.sh auto sync-branch                                # Sync current git branch to Supabase Preview Branch
```

Equivalent native commands (for understanding underlying actions):

```bash
supabase link --project-ref <project_ref>
supabase db push
supabase functions deploy auth-api --no-verify-jwt
```

Configuration via `.build.env` (copy from `.build.env.example`):
- `ENABLE_DB_RESET`: Set to `0` for production safety
- `FUNCTION_ALLOWLIST`: Comma-separated list of allowed functions
- `SUPABASE_PROJECT_REF`: Default project reference

## Architecture

### Directory Structure

```
supabase/
├── functions/           # Edge Functions
│   └── auth-api/       # Authentication API
│       ├── index.ts    # Entry point (Deno.serve)
│       ├── handler.ts  # Business logic with injectable deps
│       └── handler.test.ts  # TDD tests
├── migrations/         # SQL migrations (timestamp-named)
│   └── 202603110001_init.sql
types/supabase/         # TypeScript type definitions
├── database.ts         # Database schema types
├── index.ts            # Type exports
└── json.ts             # JSON utility types
```

### Edge Function Pattern

Functions follow a dependency injection pattern for testability:

- `index.ts`: Entry point that creates runtime deps and calls handler
- `handler.ts`: Contains pure business logic with `AuthApiDeps` interface for injectable dependencies
- `handler.test.ts`: Unit tests using mocked dependencies

Example from `auth-api/handler.ts`:
- Routes: `/register` (POST), `/login` (POST), `/me` (GET)
- CORS headers applied to all responses
- Error handling returns JSON with appropriate HTTP status codes

### Database Architecture

**Current Schema**:
- `public.profiles`: User profile data linked to `auth.users`
  - RLS enabled with user-isolation (`auth.uid() = id`)
  - Auto-created on user registration via `handle_new_user()` trigger
  - Auto-updates `updated_at` via trigger

**Migration Rules**:
- Location: `supabase/migrations/`
- Naming: `YYYYMMDDHHmmss_<feature>.sql`
- Always additive - never modify existing migrations
- Include: DDL + RLS policies + indexes + necessary triggers

### Type System

Types are manually maintained in `types/supabase/database.ts`:
- Define `Database` interface with Tables, Views, Functions, Enums
- Each table has `Row`, `Insert`, `Update` subtypes
- Must be updated when schema changes

## Development Workflow

### TDD Requirement (Mandatory)

1. Write failing test first
2. Implement to make test pass
3. Run scoped tests and type checks for changed modules before commit
4. Treat auth-api test/check as current minimum baseline

### SQL Change Workflow

1. Create new migration: `supabase/migrations/YYYYMMDDHHmmss_<feature>.sql`
2. Update `types/supabase/database.ts` with new types
3. Run `supabase db reset` to verify
4. Run scoped tests for changed modules (minimum baseline: `deno test supabase/functions/auth-api`)
5. Run scoped type checks for changed modules (minimum baseline: `deno check supabase/functions/auth-api/*.ts`)
6. Update docs: `docs/db_schema.md`, `docs/api_endpoints.md` if needed

### CI/CD Workflows

**Preview** (`.gitea/workflows/supabase-preview.yml`):
- Triggers: Push to any branch, PR
- Steps: Test changed functions (fallback auth-api) → Sync branch → DB push → Deploy functions

**Production** (`.gitea/workflows/supabase-production.yml`):
- Triggers: Manual dispatch, `release/**` tags
- Steps: Test all functions → DB push → Deploy functions
- Safety: Validates release tags are on main branch

## Critical Constraints

- **NEVER** modify existing migration files
- **NEVER** use `supabase db reset` on production
- **ALWAYS** run tests and type checks before commits
- **ALWAYS** follow TDD: test first, implementation second
- SQL migrations must include RLS policies for new tables
- Production deployments only through CI/CD
