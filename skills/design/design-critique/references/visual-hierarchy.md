# Lane E — Visual Hierarchy & Grouping

**Sub-agent brief:** Evaluate whether the layout guides the eye correctly — what's emphasized, how elements group, and whether spacing/weight do the work. Combines *Refactoring UI* practices with Gestalt grouping principles. **[GUIDELINE]** — principle-level, no hard thresholds (except where it overlaps Lane A contrast). Report hierarchy/grouping findings only.

Sources: Adam Wathan & Steve Schoger, *Refactoring UI* (2018); Gestalt principles of perception.

---

## Part 1 — Refactoring UI practices

### E1 — Hierarchy through weight and size, not color **[GUIDELINE]**

**What it means:** Establish importance primarily with **font weight, size, and color *value* (light/dark gray)** — not by coloring text. Reserve color for things that are genuinely interactive or semantic.

**What to check:**
- Secondary/tertiary text created by *coloring* it (e.g., brand-blue subtitles) instead of using a lighter gray or smaller/lighter weight.
- Everything at the same weight, so nothing leads.
- Using pure black `#000` for all text — Refactoring UI recommends a softened near-black for primary and grays for secondary/tertiary, building a value hierarchy. (Also a HIG color note, Lane D.)
- Emphasis attempted with ALL CAPS or color where weight/size would read cleaner.

**Good vs. bad:**
- ✗ Card title `#111`, subtitle in brand blue, body `#111` — no clear order, blue misread as a link.
- ✓ Title bold/dark, subtitle medium gray, body regular dark-gray — three tiers, no color needed.

### E2 — Spacing and the grouping power of whitespace **[GUIDELINE]**

**What it means:** Whitespace groups more cleanly than borders. Generous, *consistent* spacing creates structure; tight or uneven spacing creates confusion.

**What to check:**
- A spacing system (multiples of 4 or an 8pt grid). Flag off-grid one-offs (`7px`, `13px`, `19px`).
- Equal spacing between *related* and *unrelated* elements (kills grouping — see Gestalt Proximity, E5).
- Labels equidistant between two inputs, so they read as belonging to either.
- Cramped touch/whitespace where breathing room would clarify (also Lane A A7).
- Reaching for borders/dividers to separate things that spacing alone would group.

### E3 — Semantic color restraint **[GUIDELINE]**

**What it means:** Limit how many colors carry meaning. A small, purposeful palette where each color *means something* beats a rainbow. (Bridges to Lane F.)

**What to check:** more than a few accent/semantic colors competing; brand color sprinkled decoratively so it stops signaling "interactive"; semantic colors (success/warning/error) used outside their meaning.

### E4 — Designing the states, not just the happy path **[GUIDELINE]**

**What it means:** A component isn't done until empty, loading, error, and "too much data" states are designed. Missing states are a top source of real-world breakage.

**What to check (per key component):**
- **Empty state** — first-run / no-data: is it designed, or a blank void?
- **Loading state** — skeleton/spinner, not a frozen UI (ties to Nielsen H1).
- **Error state** — inline, recoverable (ties to Nielsen H9, Lane B).
- **Overflow** — long names, huge numbers, many rows: truncation/wrap/pagination handled?
- **Interactive states** — hover, focus, active, disabled present and distinct (focus also Lane A A4).

---

## Part 2 — Gestalt principles (how the eye groups)

The squint test: blur the layout in your mind. What clusters? What's figure vs. ground? Where does the eye go first?

| Principle | What it means | Violation pattern to flag |
|-----------|---------------|---------------------------|
| **E5 Proximity** | Things close together are read as related | Form label >~8px from its input; CTA not adjacent to what it acts on; related items scattered with equal whitespace |
| **E6 Similarity** | Things that look alike are read as the same kind | Two button styles for the same action class; static text styled like interactive text; mixed icon fill-styles in one bar |
| **E7 Continuity** | The eye follows aligned/continuous paths | Misaligned fields on the vertical axis; CTA that jumps position between wizard steps; nav that reorders between pages |
| **E8 Figure/ground** | We separate foreground from background | Text over a busy photo/gradient with no scrim (also Lane A contrast); background pattern competing with content; insufficient surface separation |
| **E9 Common region** | A shared boundary groups items | Unrelated content inside one card; related settings split across separate containers |
| **E10 Prägnanz (simplicity)** | The eye prefers the simplest reading | Dashboard with many simultaneous metrics and no hierarchy; "busy" layouts; icons needing a legend (also Lane C C4) |
| **E11 Common fate** | Things moving together are read as a group | Unrelated elements animate together; related elements animate independently when they should move as one |

---

## Reporting notes for this lane

- Hierarchy/grouping findings are typically **P2–P3**: P2 when a broken hierarchy genuinely impedes the primary task (user can't find the primary action), P3 for polish.
- **Figure/ground findings frequently *are* Lane A contrast failures** — when text-over-background is the issue, compute the ratio and cite SC 1.4.3 so it carries hard severity.
- Missing-states findings (E4) are high-value and concrete — enumerate which states are absent for which component.
- Be concrete: "subtitle uses brand blue, reads as a link" beats "weak hierarchy."
