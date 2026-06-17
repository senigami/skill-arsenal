# Project Rules: Basis

**This is the project-specific configuration for the code-quality-checklist skill.** It defines verification commands, triggered workflows, anti-patterns, and stack conventions for this codebase. When adapting this skill to a new project, edit this file (and `scripts/verify.sh`) — the rest of the skill is generic.

> **Maintainers:** Keep this file in sync with `scripts/verify.sh`. The verification commands listed here must match what the script runs.

---

## Stack Summary

- **Frontend:** Next.js 15 (App Router) + React 19 + TypeScript + TailwindCSS + shadcn/ui
- **Backend:** Fastify server + tRPC + NextAuth
- **Database:** PostgreSQL + Drizzle ORM, Redis for cache/queues
- **Real-time:** WebSockets + BullMQ
- **Orchestration:** Apache Airflow for data sync
- **Testing:** Vitest (unit) + Playwright (E2E) + Pytest (Airflow DAGs)
- **Package manager:** pnpm (≥9.x); Node ≥24
- **Logging:** Winston (server) with structured logging + module identification

---

## Verification Commands

These are run by `scripts/verify.sh`. Keep this section and the script in sync.

```bash
pnpm type-check                # Type checking (tsc --noEmit)
pnpm lint                       # Full repo lint (NOT the staged-files-only pre-commit hook)
pnpm vibecheck:all:run          # Full unit test suite (NOT vibecheck:changed)
pnpm test                       # Playwright E2E (only when UI flows changed; --e2e flag on verify.sh)
```

### What NOT to use as your verification gate

- `pnpm vibecheck:changed` — this is the **pre-push hook**, runs only on changed files. Doesn't match CI. Don't use it for the verification gate.
- `lint-staged` — that's the pre-commit hook (staged paths only).

### Coverage commands

```bash
# Server coverage
pnpm exec vitest run --config vitest.config.server.mjs --coverage

# Client coverage
pnpm exec vitest run --config vitest.config.client.mjs --coverage

# All
pnpm vibecheck:coverage:all
```

Coverage reports land in `coverage-server/` and `coverage-client/`.

### Coverage growth rule

If the modified file's coverage is **below 80%** (statements or lines), raise it by **at least 5 percentage points** vs. before your changes. Above 80%, no minimum bump required (but keep tests in sync with behavior).

Coverage growth must come from **meaningful tests** for the file you changed — not hollow assertions or unrelated tests.

---

## Triggered Workflows

When any of these triggers fire during your work, run the matching workflow before marking the task complete.

### Trigger: Modified Database Schema

**Files edited under `src/db/schema/**`?**

```bash
pnpm db:generate    # Generate migrations from schema diff
pnpm db:migrate     # Apply migrations locally
```

**Rules:**
- **Never hand-write SQL under `src/db/drizzle/`.** The journal and migration files are generated artifacts.
- Review the generated migration before committing — Drizzle occasionally generates surprising SQL (renames → drop+add, type changes).
- Verify the change in `pnpm db:studio` if uncertain.
- For migrations that touch production data (NOT NULL on existing column, type changes, drops): plan a backfill strategy, consider lock duration on large tables, prefer multi-step migrations (add nullable → backfill → enforce NOT NULL).

### Trigger: Modified Provider UI Configuration

**Files edited under `src/providers/configurations/{provider}/`?**

```bash
pnpm generate:frontend-registries
```

Restart TypeScript server in your IDE if type errors persist after regeneration.

**You do NOT need to run this when:**
- Adding backend integration for an existing provider (Airflow DAGs, Azure Functions) — UI config is unchanged
- Editing `route-posts.ts` (backend routing logic, not UI config)
- After `git pull` — registries are version-controlled
- Adding env vars / secrets

**For brand-new providers:** use `pnpm create:provider --name ... --title ... --type ...` — it scaffolds the configuration and runs the registry generator automatically.

### Trigger: UI / Frontend Changes

**Files edited under `src/app/**` or `src/components/**`?**

1. Start the dev server with **`pnpm dev:log`** (not `pnpm dev`) — writes logs to `/tmp/basis-dev-*.log` for AI debugging.
2. **Actually use the feature in a browser** at `http://localhost:3000`. Type-check and tests verify code correctness, not feature correctness.
3. Test the golden path AND edge cases (loading, error, empty data, long content, boundaries).
4. Watch for regressions in adjacent features.

If you can't open a browser (no display, headless env), **say so explicitly** in your handoff. Don't claim the feature works just because type-check passed.

### Trigger: Modified API / Webhook Handler

**Files edited under `src/server/api/`, `src/server/webhook/`, or `src/server/routers/`?**

Check:
- **Auth correct for the API layer?**
  - Fastify REST (`/api/v1/*`): JWT Bearer tokens (obtained via `POST /api/v1/auth/token`)
  - tRPC (`/api/trpc`): NextAuth session tokens; use `protectedProcedure` for authenticated endpoints
- **Input validated with Zod?** All inputs go through Zod schemas at the boundary
- **Idempotency for webhooks?** Webhooks may be retried — handler tolerates replay?
- **No sensitive data in logs?** Tokens, secrets, PII redacted
- **User/org context propagated?** Especially for multi-tenant operations
- **Error codes meaningful?** Use tRPC error codes (`UNAUTHORIZED`, `NOT_FOUND`) rather than generic 500s
- For REST endpoints: add OpenAPI schema in `src/server/api/schema/` and register the route in `src/server/api/register.ts`

---

## Stack Conventions

### Logging

```typescript
// Server-side
import { getLogger } from '@/server/logger';
const logger = getLogger('feature-name');
logger.info('Operation completed', { userId, result });

// Client-side
import { getLogger } from '@/lib/logger/client';
const logger = getLogger('component-name');
logger.debug('State updated', newState);
```

- Module identification via `getLogger('descriptive-name')`
- Structured context: pass objects, not concatenated strings
- Server logs are JSON in production (Winston) with file output to `logs/`
- Client logs use multi-colored browser console output

### State Management

- **Server state:** tRPC + React Query — `useQuery(trpc.resource.method.queryOptions({...}))`
- **Client UI state:** Zustand (with persistence middleware where needed) — **prefer over React Context** for shared state
- **Form state:** React Hook Form + Zod via `zodResolver`
- **Auth/theme:** React Context is fine

### Component Patterns

- Use shadcn/ui + Radix UI primitives — don't reinvent
- Use `'use client'` directive explicitly for client components
- Co-locate component props (`Props` suffix for interfaces, e.g. `ButtonProps`)
- Place static content and interfaces at the end of the file
- Toast notifications: use sonner

### Data Fetching

```typescript
import { useQuery, useMutation } from '@tanstack/react-query';
import { useTRPC } from '@/app/query-provider';

const trpc = useTRPC();
const { data } = useQuery(trpc.project.getById.queryOptions({ id }));
```

For React Query options, spread the tRPC options:
```typescript
useQuery({ ...trpc.foo.bar.queryOptions({...}), staleTime: 30_000 })
```

### Internationalization

- **Preferred:** `import { useTranslation } from '@/app/i18n/client'` (custom wrapper)
- **Legacy:** Some files use `'react-i18next'` directly (being migrated) — don't add new imports of the legacy form

---

## Project-Specific Anti-Patterns

These have caused real damage and should NOT happen without explicit user approval:

1. **Hand-writing SQL under `src/db/drizzle/`** — always use `pnpm db:generate` to produce migrations from schema diffs.
2. **Using `pnpm vibecheck:changed` as the verification gate** — that's the pre-push hook. Use `pnpm vibecheck:all:run`.
3. **Using `pnpm dev` instead of `pnpm dev:log`** — the `:log` variant writes logs for AI debugging; prefer it unconditionally.
4. **Adding new integrations under `src/providers/integrations/legacy-server/`** — that path is deprecated. New integrations use Airflow (for scheduled sync + webhook triggers) or Azure Functions (for event-driven webhooks).
5. **Auto-generating markdown summary files** (`*_FIX.md`, `*_SUMMARY.md`) — never. Summarize in chat.
6. **Editing generated provider registries directly** (`shared/provider-*-registry.ts`) — edit `configurations/{provider}/` and regenerate.

---

## Quick Reference: Common Commands

```bash
# Development
pnpm dev:log                    # Full stack with log file output (preferred)
pnpm dev                        # Full stack without log file (avoid for AI debugging)
pnpm dev:client                 # Next.js only (port 3000)
pnpm dev:server                 # Fastify only (port 4000)

# Database
pnpm db:generate                # Generate migrations from schema
pnpm db:migrate                 # Apply migrations
pnpm db:studio                  # Drizzle Studio (visual DB inspector)
pnpm db:reset                   # Reset + reseed (DESTRUCTIVE)
pnpm seed                       # Seed test data (DESTRUCTIVE — resets data)

# Providers
pnpm create:provider --name ... --title ... --type ...   # Scaffold new provider UI
pnpm generate:frontend-registries                         # Regenerate after config edits

# Airflow
pnpm airflow:start              # Start Airflow services
pnpm airflow:logs               # View Airflow logs
pnpm airflow:test               # Run DAG tests (Pytest)
./scripts/airflow.sh dags ...   # Airflow CLI via Docker

# Build
pnpm build                      # Build client + server
pnpm preview:prod               # Preview production build

# Logs
tail -f /tmp/basis-dev-*.log    # Dev logs (from pnpm dev:log)
docker compose logs -f <service>  # Container logs
```

---

## When You Find Documentation Drift

If something in this file is wrong or stale (commands changed, paths moved, conventions updated), **fix it as part of your task** — keeping `project-rules.md` accurate is in-scope when you discover drift. Mention the fix in your handoff so the user sees the update.
