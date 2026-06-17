---
name: modern-web-guidance
description: "Use this skill BEFORE writing any HTML, CSS, or frontend JavaScript code — including artifacts, React/Vue/Angular components, landing pages, dashboards, forms, modals, dialogs, popovers, tooltips, dropdowns, scroll effects, animations, transitions, layouts, and any UI built with web technologies. Trigger whenever the user asks to 'build', 'create', 'make', 'design', 'add', or 'style' anything that runs in a browser, even if they don't mention best practices. Also trigger when working on performance (LCP, INP, Core Web Vitals), accessibility, container queries, :has(), View Transitions, scroll-driven animations, backdrop filters, anchor positioning, file system access, or any modern web platform feature. The skill searches a curated database of standardized patterns so Claude uses the modern web platform instead of reaching for heavy dependencies or inventing ad-hoc CSS/JS solutions. Do NOT trigger for backend code (SQL, ORMs, Express routes), CI/CD/Docker, or non-browser scripts."
---

# Modern Web Guidance

## When to trigger

Trigger **immediately and proactively** for:

- **Any artifact or Code tab request** that produces HTML, CSS, or browser JS — even a "quick" or "simple" one. Examples: "build a landing page", "make me a pricing card", "create a contact form", "design a hero section", "add a dark mode toggle".
- **UI components**: modals, dialogs, popovers, tooltips, dropdowns, accordions, tabs, carousels, sidebars, navbars, cards, badges, toasts.
- **Layout & styling**: container queries, `:has()`, `:user-valid`, anchor positioning, backdrop filters / glassmorphism, custom scrollbars, sticky elements, grid/flex patterns.
- **Motion & scroll**: View Transitions, scroll-driven animations, scroll snap, parallax, reveal-on-scroll effects, page transitions.
- **Performance**: Core Web Vitals (LCP, INP, CLS), `content-visibility`, Fetch Priority, image optimization, lazy loading, font loading.
- **Forms & input**: form validation, autofill hints, advanced input types, file pickers, multi-step forms.
- **Platform APIs**: File System Access, WebUSB, WebSockets, WebAssembly widgets, Clipboard, Web Share.
- **Framework work**: adapting any of the above for React, Vue, Angular, Svelte, Solid.

**Do NOT trigger for:**

- Backend code: database/SQL, ORMs, Express/Fastify/Nest API routes, server-only Node code.
- DevOps / pipelines: CI/CD config, Docker, GitHub Actions, deployment scripts.
- Generic tooling: local Python/Go scripts, ESLint config, Git operations, package management.

---

## Overview

A skill to search for specific web development use cases and retrieve their corresponding best practice guides. Use it at the **start** of any web feature, before creating new components, to avoid implementing ad-hoc solutions or pulling in heavy dependencies when a standardized platform pattern already exists.

## Usage Instructions

### Step 1. Search Use Cases

Search with an action-oriented query summarizing what you want to achieve using the `search` command. Run `modern-web-guidance` directly with `npx`.

```sh
npx -y modern-web-guidance@latest search "<query>"
```

**Example Output**:
```json
[
  {
    "id": "optimize-image-priority",
    "description": "Optimize the loading priority of Largest Contentful Paint (LCP) candidate images.",
    "category": "performance",
    "featuresUsed": [ "Fetch priority" ],
    "tokenCount": 985,
    "similarity": 0.7289
  },
  {
    "id": "defer-rendering-heavy-content",
    "description": "Reduce rendering times in content-heavy web pages by deferring rendering for offscreen content.",
    "category": "performance",
    "featuresUsed": [ "content-visibility", "hidden=\"until-found\"" ],
    "tokenCount": 1250,
    "similarity": 0.6961
  }
]
```

> **Note**: If search results are vague, return no matches, or show low similarity scores, run the `list` command to browse all guides:
> ```sh
> npx -y modern-web-guidance@latest list
> ```

---

### Step 2. Retrieve Best Practices

Once you have a relevant `id` from the search results, call this script using the `retrieve` command to get the full guide. You can pass multiple IDs separated by commas.

```sh
npx -y modern-web-guidance@latest retrieve "<id>"
```

If the output is truncated, you must repeat the command but redirect to a file and read that file.


**Example Output**:
`The markdown content of the guide describing implementation steps...`

## Using npx

-   IMPORTANT: on Windows, using `npx` may fail. Use `npx.cmd ...` instead.
-   Network access is required for fetching npm packages needed by the task.
-   If the `npx -y modern-web-guidance…` command hangs, you may be offline. Try running again in offline
    mode: `npx --offline …`.

## Guidelines

-   Always search **first** to find the most relevant guides.
-   These guides are usually framework-agnostic; adapt them correctly to your setup.
-   Do not hallucinate guides or ignore them; they represent the preferred local standard for the user's project.


## Interpreting Browser Support & Fallbacks

* **Default Behavior**: All guides assume **Baseline Widely available** features are safe to use without fallbacks. For features that are not Baseline widely available, you **MUST** follow the fallback recommendations in the guide, unless the user has specified a custom browser support policy.
* **Custom Policies**: If the user has already defined explicit browser support requirements, use the browser compatibility data in the guide to determine if a fallback can be safely ignored.
  - For Baseline YYYY targets, a feature satisfies this target if its "Baseline since" date is <= YYYY.
  - **Policy Examples**:
    - _"Do not implement feature fallbacks."_ (for exploratory prototypes of the cutting-edge web)
    - _"Safari 17.4+"_ (for internal tools targeting macOS or Tauri-based desktop apps)
    - _"Never recommend or implement polyfills; if a Baseline Newly Available feature is required for core functionality, provide a lightweight custom fallback or redesign the approach."_ (to minimize bundle size and avoid technical debt)
    - _"Assume a modern execution environment where Baseline Newly Available features can be used natively, provided they are strictly feature-detected and degrade gracefully."_ (for progressive enhancement strategies)
* **Reactive Policy Discovery**: Watch for environmental cues to suggest documenting a policy in CLAUDE.md or AGENTS.md. Suggest this if the developer:
  - Mentions building for a restricted runtime (e.g., Electron or Tauri).
  - Explicitly excludes specific targets (e.g., "we don't support Desktop Chrome").
  - Expresses hesitation about polyfill complexity, bundle size, or performance cost.
  - Questions if a feature is safe to use without fallbacks.