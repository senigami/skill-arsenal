---
name: style-guide
description: >-
  Generate or update a visual style guide (docs/style-guide/) for a product —
  covering colors, typography, spacing, components, iconography, accessibility,
  and voice/tone. Use when the user wants to "create a style guide", "document
  our visual design", "set up a design system", "document our UI components",
  "what fonts/colors do we use", or "create brand guidelines".
  Reverse-engineers visual DNA from code (CSS custom properties, Tailwind
  @theme, design token files, component variant patterns); asks for screenshots
  when code alone can't reveal color schemes, component states, or brand
  identity. Produces a navigable docs/style-guide/ directory with numbered spec
  files, an index router agents can follow, and an optional machine-readable
  tokens.json (DTCG 2025.10 format). Also audits and updates existing style
  guides — detects drift between documented styles and current code, adds
  missing components, retires obsolete patterns.
---

# Style Guide Generator

Generate a visual style guide for a product — a navigable `docs/style-guide/` directory that documents every visual decision: colors, typography, spacing, components, iconography, accessibility standards, and copy/tone guidelines. The output is the **visual source of truth** — specific enough that an AI agent can implement a new component and match the existing design, and clear enough that a new designer can onboard from it alone.

## Why this shape

- **Numbered docs** give stable references. "Per style-guide/02" in a code review never rots.
- **The index** is the router. Any agent or developer finds the relevant rule in one hop.
- **Design tokens** are the machine-readable layer. Semantic names ("color-action-primary", not "#2563EB") let agents apply visual decisions programmatically and make rebranding a one-file change.
- **Components as rules, not screenshots.** A style guide that only has images breaks in code review. This skill documents components as named patterns with properties, variants, states, and usage rules — what an agent needs to implement correctly.
- **Screenshots as evidence, not output.** When code doesn't reveal the visual truth — colors without semantic names, fonts loaded remotely, component states only visible in a browser — the skill asks for screenshots to ground the documentation. The guide itself stays in code and markdown.

## Workflow

### Step 1 — Determine the mode

Check three things independently:

**1. Does a style guide already exist?** Look for `docs/style-guide/`, `STYLEGUIDE.md`, a Storybook config, or a `tokens.json`. If found → **update/audit mode**: reconcile the existing guide against current code, update drifted sections, add missing components. Do not regenerate from scratch.

**2. Does a codebase exist?** If yes → **reverse-engineering mode**: read the code first (Step 2), then ask for screenshots to fill visual gaps. If no code yet → **greenfield mode**: interview the user. Batch all questions into one round; don't drip them.

**3. Does a design system package exist?** Check `package.json` for MUI, shadcn/ui, Ant Design, Chakra, Mantine, Radix, etc. If found, the base visual system is documented externally. The style guide records *how this project customizes it* — theme overrides, custom components, usage constraints — not the base system itself. Note the package and version; focus on project-specific tokens.

In greenfield mode, ask the user in a single batch: what the app does and for whom, the intended stack, major components and boundaries, what's explicitly out of scope for v1, and decisions already made (these seed ADRs or notes in the style guide).

### Step 2 — Survey the codebase for visual DNA

Read enough to understand the visual system before writing anything. Fan this out to parallel light agents where the codebase is large. Cover:

**Design token sources (highest signal — read first):**
- CSS custom properties in `globals.css`, `variables.css`, `:root` blocks — semantic names like `--color-primary`, `--font-sans`
- Tailwind: `tailwind.config.js/ts` (v3: `theme.extend.colors`, `fontFamily`, `fontSize`, `spacing`, `borderRadius`) or `@theme` blocks in CSS (v4: `--color-*`, `--font-*`, `--text-*`, `--spacing`, `--radius-*`, `--shadow-*`)
- `theme.ts`, `tokens.json`, `design-tokens.*`, `style-dictionary.*` — dedicated token files
- MUI/Chakra/Mantine theme config objects (usually `createTheme({...})`)

**Component files (structural signal):**
- Component directory — list all components; note which are design primitives vs. domain-specific
- `cva()`, `clsx()`, `cn()`, `variants` patterns — these encode the full variant system
- Button, Input, Card, Badge, Alert, Modal, Table, Nav, Toast — highest-value reads; they reveal the visual grammar

**Assets and brand:**
- `public/` or `assets/` — logo files, favicon, brand SVGs, illustration assets
- Font imports in `layout.tsx`, `_app.tsx`, `index.html`, or CSS `@import`/`@font-face` blocks
- `manifest.json` or `site.webmanifest` — brand color, app name

**Existing docs:**
- `README.md`, any `docs/` content — mine for stated conventions
- Storybook stories — encode variant and state documentation if present

**Note every visual gap** — colors without semantic names, fonts loaded from a remote CDN, component states not captured in static CSS, dark mode without explicit token definitions — for Step 3.

### Step 3 — Request visual evidence (screenshots)

After the code survey, identify what code cannot reveal. Ask for screenshots in **one batched request** — never drip questions across turns. Frame each ask specifically so the user knows what to capture.

**Ask for screenshots when:**
- Color values exist but semantic meaning is unclear — which is the primary CTA vs. hover vs. pressed state?
- Typography loads from a remote font (Google Fonts, Typekit) — the name is in code but rendering weight and optical size need visual confirmation
- Component states (hover, focus, disabled, error, loading, skeleton) aren't in static CSS
- Brand imagery style (illustration vs. photography vs. icon-only) can't be inferred from code
- Dark mode tokens are undefined or aliased from runtime variables
- The overall visual character — playful vs. corporate, minimal vs. dense — isn't apparent from code alone

**Batched screenshot request format:**
> "To complete the style guide I need a few visual references the code can't fully answer. Could you share screenshots of:
> 1. [Specific screen] showing [specific element in specific state]
> 2. [Specific component] showing [hover/error/disabled state]
> 3. [Any brand asset not in the repo]
>
> These are reference only — the guide itself is code and markdown."

Mark values that can't be confirmed from code: `[visual unconfirmed — verify]`. Never stall waiting for "nice to have" screenshots; annotate and continue.

### Step 4 — Extract and catalog design tokens

From the survey and any screenshots provided, extract every named visual value into a canonical token set. Use **semantic names, not raw values** — agents need to know what a color means, not just its hex.

**Color token structure:**
```
color-brand-primary: #2563EB       # main brand / identity color
color-brand-secondary: #7C3AED     # secondary brand accent
color-surface-default: #FFFFFF     # page and card background
color-surface-subtle: #F9FAFB      # depressed / secondary surface
color-surface-inverse: #111827     # dark surface (tooltips, badges)
color-text-primary: #111827        # body and heading text
color-text-secondary: #6B7280      # muted / helper / caption text
color-text-inverse: #FFFFFF        # text on dark surfaces
color-text-disabled: #9CA3AF       # disabled text
color-border-default: #E5E7EB      # standard borders and dividers
color-border-strong: #9CA3AF       # emphasized borders
color-action-primary: #2563EB      # CTA button background
color-action-primary-hover: #1D4ED8
color-action-primary-active: #1E40AF
color-action-secondary: #F3F4F6    # secondary button background
color-semantic-danger: #EF4444     # errors and destructive actions only
color-semantic-warning: #F59E0B    # warnings — never use for errors
color-semantic-success: #10B981    # confirmations and success states
color-semantic-info: #3B82F6       # informational highlights
```

**Typography token structure:**
```
font-family-sans: "Inter", system-ui, sans-serif
font-family-mono: "JetBrains Mono", monospace
font-size-xs: 12px / 0.75rem
font-size-sm: 14px / 0.875rem
font-size-base: 16px / 1rem
font-size-lg: 18px / 1.125rem
font-size-xl: 20px / 1.25rem
font-size-2xl: 24px / 1.5rem
font-size-3xl: 30px / 1.875rem
font-size-4xl: 36px / 2.25rem
font-weight-normal: 400
font-weight-medium: 500
font-weight-semibold: 600
font-weight-bold: 700
line-height-tight: 1.25   # headings
line-height-normal: 1.5   # body text
line-height-relaxed: 1.75 # long-form / marketing
letter-spacing-tight: -0.02em
letter-spacing-normal: 0
letter-spacing-wide: 0.05em
```

**Spacing and layout token structure:**
```
space-1: 4px
space-2: 8px
space-3: 12px
space-4: 16px
space-5: 20px
space-6: 24px
space-8: 32px
space-10: 40px
space-12: 48px
space-16: 64px
space-20: 80px
space-24: 96px
```

Also record: border radii (`radius-sm: 4px`, `radius-md: 8px`, `radius-lg: 12px`, `radius-full: 9999px`), box shadows (with elevation semantics), z-index scale, breakpoints, transition durations and easing curves.

**Token source rule:** If tokens are already defined in code (CSS vars, Tailwind config, theme object), extract and name them exactly — don't invent new names. If undefined, derive from observed usage patterns and mark `[inferred from usage]`.

**DTCG format (for `tokens.json`):** Use the W3C Design Token Community Group stable format (2025.10) — `$value`, `$type`, `$description`. This format is compatible with Style Dictionary v4+, Tokens Studio, and Figma's token integration.

```json
{
  "color": {
    "$type": "color",
    "action": {
      "primary": {
        "$value": "#2563EB",
        "$description": "CTA button background — use for the single most important action per view"
      }
    },
    "semantic": {
      "danger": {
        "$value": "#EF4444",
        "$description": "Errors and destructive actions only. Never use for warnings."
      }
    }
  }
}
```

### Step 5 — Inventory and document components

List every UI component in the codebase. Classify each:
- **Primitive** — design-system building blocks: Button, Input, Select, Checkbox, Radio, Badge, Tag, Avatar, Icon, Spinner, Skeleton
- **Composite** — composed of primitives: Card, Modal, Dropdown, Toast/Notification, DataTable, Tooltip, Popover, Accordion
- **Layout** — structural: PageLayout, Sidebar, Header, Footer, Grid, Stack, Divider
- **Domain** — product-specific (e.g., UserCard, PricingTable, StatusBadge): list only with a one-line description

For each **Primitive** and key **Composite**, document:
- **Name and import path**: `import { Button } from "@/components/ui/button"`
- **Variants**: size (sm / md / lg), intent (primary / secondary / ghost / danger / link), state (default / hover / focus / disabled / loading)
- **Key visual props**: type and visual default ("variant: 'primary' | 'secondary' | 'ghost' | 'danger'; size: 'sm' | 'md' | 'lg'; default md")
- **Usage rule**: when to use this vs. alternatives — "Use Ghost for tertiary actions. Use Danger only for destructive, irreversible actions — never for errors that can be retried."
- **Anti-pattern**: what not to do — "Never use Primary for more than one action per page view. Don't use danger-colored text outside of error and destructive-action contexts."

Document component **states** explicitly: what changes between default, hover, focus, active, disabled, loading, and error. If states aren't in static CSS, note `[visual unconfirmed — verify]`.

### Step 6 — Write the style guide documents

Output to `docs/style-guide/`. Adapt the set to the product — don't create empty stubs. Standard set:

| File | Contents |
|------|----------|
| `00-index.md` | Router: doc map, visual summary, key design decisions |
| `01-brand-identity.md` | Logo usage rules, primary brand palette, imagery style, favicon |
| `02-color-palette.md` | Full token set with hex values, semantic names, usage rules, contrast ratios |
| `03-typography.md` | Font families, size scale, weight usage, line-height, heading hierarchy |
| `04-spacing-layout.md` | Spacing scale, grid system, breakpoints, layout patterns |
| `05-components.md` | Full component catalog (Step 5) |
| `06-iconography.md` | Icon package + version, sizing rules, color rules, accessibility (aria-label, title) |
| `07-accessibility.md` | WCAG level target, contrast requirements, focus style rules, motion reduction |
| `08-voice-tone.md` | UI copy rules: error messages, CTAs, empty states, confirmations, loading states |
| `tokens.json` | Machine-readable DTCG 2025.10 token export |

Add domain-specific docs only when the project has the surface: dark mode, motion guidelines, data visualization color palette, print styles, AI/agent interaction patterns.

For every document:
- H1 title + `> **TL;DR:**` blockquote — the punchline before any prose
- **Specific values, never approximations** — "16px base font, 1.5 line-height" not "comfortable font size"
- **Decision rules in the imperative with why** — "Error text always uses `color-semantic-danger`. Never use orange for errors, even if orange looks similar — orange is reserved for warnings, and color alone is never the sole error signal (accessibility requirement)."
- Tables for token values; prose for rationale
- Code snippets for common usage patterns (`class="btn btn-primary"`, `style={{ color: 'var(--color-action-primary)' }}`)
- Mark visually unconfirmed values: `[visual unconfirmed — verify]`

**In update mode:** preserve existing numbering and voice. Update drifted sections in place. For removed surface: mark retired with a note rather than deleting. For new surface: add at the next free number. Leave a changelog at the bottom of `00-index.md`: what changed, what was added, what was retired, what discrepancies were surfaced.

### Step 7 — Write the index and wire up agent instructions

`00-index.md` contains, in order:

1. What this directory is and the authority rule: "The style guide is the visual source of truth. Code that contradicts it is a bug, not an update to the guide. Resolve drift explicitly in the same change."
2. **Document Index** — table of every file: filename, one-line purpose written so any agent can pick the right doc from it alone
3. **Visual Summary** — 3–5 sentences: what the product looks like, its visual character, who it's for
4. **Key Design Decisions** — table of contestable choices (Decision / Choice / Rationale): typeface selection, color system approach, design system package if any, WCAG level target, dark mode status

Then add to the repo's `CLAUDE.md`, `AGENTS.md`, or equivalent:
```
## Style Guide
Read `docs/style-guide/00-index.md` before implementing any UI change. The style guide is the source of truth for visual decisions. Use semantic token names from `docs/style-guide/02-color-palette.md` and `docs/style-guide/03-typography.md` — never hardcode hex values or font names. Update `docs/style-guide/05-components.md` when adding design-primitive components.
```
If no agent-instructions file exists, create `AGENTS.md` with only that block. Don't overwrite existing content.

### Step 8 — Self-review

Read the set as a cold agent assigned "add a new settings page." Verify you can:
- Find the correct button variant in one hop from the index
- Know which color token to use for a disabled input
- Know the correct font size and weight for a page title
- Know where the error state color is defined and what it prohibits

Check:
- All cross-reference links resolve
- No token name appears twice with different values
- Every component's key states are documented
- Contrast ratios are stated for every text-on-background combination in `02-color-palette.md`
- Visually unconfirmed values are marked, not presented as fact
- `tokens.json` values match the prose in `02-color-palette.md` and `03-typography.md`
- No application code was modified (docs, tokens.json, and AGENTS.md are the only changes)

Summarize for the user: what was generated, what was inferred vs. confirmed from code, what needs screenshot verification before the guide should be considered complete, and what visual decisions should be reviewed or confirmed.

---

## What to run next

**To evaluate whether the live UI actually matches what the style guide documents:**
Run `/design-critique` — it will use the style guide as the reference canon and flag every place the implemented UI deviates from it. Style guide conformance and design-principle conformance are evaluated separately, so this also catches HIG, WCAG, and Gestalt violations beyond just spec drift. This is the natural next step after generating a guide for the first time.

**To implement visual corrections found during the audit:**
If the style guide documents how things *should* look but the code doesn't match, run `/task-plan-architect` to build a fix plan from the deviations, then `/planrunner` to execute it. Point the planner at the style guide's index and the relevant component files.

**To run a deeper visual audit with the style guide as the reference:**
`/design-critique` can be re-run after corrections land to verify the fixes held and catch anything new — it uses the style guide as canon, so each pass is anchored to the same standard. Pair with `/fusion-reasoning` when you want multiple independent reviewers to pressure-test a specific design decision before committing to it.
