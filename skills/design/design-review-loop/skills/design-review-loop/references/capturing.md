# Capturing screenshots for review

Reviewer subagents critique pixels, so the round's screenshots must be **files on disk** they can `Read` — inline previews from this conversation aren't visible to subagents. Delegate capture to a light agent (`runner` / Haiku); it's mechanical work.

## What to capture

For each target screen, per round:

| Viewport | Width | Why |
|----------|-------|-----|
| Mobile | ~390px | Where layout breaks first; touch targets, overflow, stacking |
| Tablet | ~768px | The awkward middle — reflow seams show here |
| Desktop | ~1280px | The primary design surface for most apps |

Add a **dark-mode** capture of each if the app themes — dark mode is where hardcoded color and contrast failures hide.

Save with stable, sortable names so before/after is trivial:
```
.design-review/round-<N>/<screen>-<viewport>[-dark].png
```
e.g. `.design-review/round-1/dashboard-mobile.png`, `.design-review/round-1/dashboard-desktop-dark.png`.

`.design-review/` is scratch — add it to `.gitignore` if it isn't already covered.

## How to capture

**Preferred — the preview tools.** If `preview_*` MCP tools are available:
1. `preview_start` (once, reuse across rounds).
2. `preview_resize` to each viewport width, navigate to the screen, then `preview_screenshot`.
3. The preview screenshot tool may return images inline rather than writing files — if so, use the headless fallback below to get durable PNGs the reviewers can read.

**Durable fallback — headless browser.** To guarantee PNGs on disk, drive the running dev server with a short `playwright-core` script (reuse the machine's cached browser; don't download one): for each (screen, viewport) set the viewport, `page.goto(url)`, wait for network idle, `page.screenshot({ path })`. Toggle the app's theme (class/attribute or the relevant control) for the dark captures.

## Capture-agent dispatch prompt (template)

> Mechanical capture task, no judgment. The dev server is running at `<base-url>` (start it with `<command>` if not). For each screen in `<list of routes>`, capture screenshots at widths 390, 768, and 1280px<, plus dark mode via <how to toggle>>. Save PNGs to `.design-review/round-<N>/<screen>-<viewport>[-dark].png`. Wait for the page to settle (network idle + any skeleton loaders gone) before each shot. Return only a JSON array of the saved file paths, grouped by screen.

## When a reviewer needs more than stills

- **Persona walkthrough & Flow/IA reviewers** critique a *journey*, not one screen — capture the full sequence of the core task (each step's screen) in order, so the reviewer can follow the path a user takes. Stills are fine; just give the whole flow.
- **Motion & interaction reviewer** can't judge transitions from stills. Either capture a short screen recording of the key interactions (playwright supports video), or capture before/mid/after state frames for each animated element and say what triggers the change. If neither is feasible this round, skip the motion reviewer rather than feed it stills it can't assess.

## Notes

- Capture **after** the page has settled — loading skeletons or un-hydrated states produce false findings.
- If a screen needs auth or specific data to render meaningfully, tell the capture agent how to reach that state (login, seed, route params). A review of an empty/error state is only useful if that state is what's under review.
- Keep each round's screenshots; the report's before/after comparison and the reviewers' "did the fix land?" check both depend on prior rounds still being on disk.
