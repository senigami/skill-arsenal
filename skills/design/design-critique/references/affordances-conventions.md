# Lane D — Affordances & Conventions

**Sub-agent brief:** Evaluate whether elements *look like what they do* and *behave like users expect from other products*. Combines Don Norman's interaction principles, Jakob's Law, and Apple HIG's platform-convention guidance. Mostly **[GUIDELINE]** — frame as established design principle, not normative spec. Report affordance/convention findings only.

Sources: Don Norman, *The Design of Everyday Things*; [Jakob's Law](https://lawsofux.com/jakobs-law/); [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/).

---

## D1 — Signifiers and affordances (Norman) **[GUIDELINE]**

**What it means:**
- An **affordance** is what an element *can do*; a **signifier** is the perceptible cue that *tells the user* it can do it. Most UI problems are missing or false **signifiers** — the capability exists, but nothing signals it.

**What to check:**
- **Buttons that don't look clickable:** no fill, border, shadow, or hover affordance — flat text indistinguishable from a label.
- **Links with no signifier:** colored-only links in body text (no underline, no icon) — fails as a signifier *and* fails Lane A SC 1.4.1. Underline is the canonical link signifier.
- **Clickable cards/rows with no cue:** entire row is a link but nothing (cursor, hover, chevron) says so.
- **False affordances:** underlined text that *isn't* a link; something styled like a button that's static.
- **Icon-only controls** whose meaning isn't universal, with no label or tooltip.
- **Disabled controls** with no signifier for *why* they're disabled or how to enable them.

**Good vs. bad:**
- ✗ "Learn more" in brand color, no underline, same size as body.
- ✓ "Learn more" underlined (or with a trailing `→`), with a hover state.

---

## D2 — Mapping and feedback (Norman) **[GUIDELINE]**

**What it means:** Controls should map naturally to their effects, and every action should produce immediate, visible **feedback**.

**What to check:**
- Natural mapping: a control's position/direction matches its result (a "next" affordance points forward; volume up is up).
- Feedback on every interaction: press states, optimistic UI or spinners on async actions, confirmation after completion (ties to Nielsen H1, Lane B).
- Toggles/switches that show their current state unambiguously (and not by color alone — Lane A).

---

## D3 — Slips as a class of error (Norman → Nielsen H5) **[GUIDELINE]**

**What it means:** Slips are correct-intention/wrong-action errors caused by inattention. Design prevents them with **constraints, good defaults, and physical/visual separation** of dangerous actions. (This is the source of Nielsen H5 in Lane B — flag the link when both apply.)

**What to check:** destructive actions adjacent to routine ones; no confirmation/undo on consequential actions; easy-to-mis-tap targets next to each other (also Lane A SC 2.5.8).

---

## D4 — Jakob's Law: users expect your site to work like the others they use **[GUIDELINE]**

**What it means:** Users spend most of their time on *other* products. They transfer those expectations to yours. Meeting conventions lets them focus on your content instead of relearning patterns. Deviating from a strong convention has a real cost that must be justified.

**Conventions to check the UI against:**
- **Color semantics:** red = error/destructive/stop; green = success/go; yellow/amber = warning. (Violating this is both a Jakob's Law and a Von Restorff issue — Lane C/F.)
- **Layout:** logo top-left links home; primary nav along the top or left; cart/account top-right; search in the header.
- **Controls:** underlined or clearly-styled links; checkboxes for multi-select, radios for single-select; a recognizable submit affordance at the end of a form.
- **Icons:** hamburger = menu; magnifier = search; gear = settings; trash = delete; floppy = save. Don't repurpose a well-known icon for a different action.
- **Gestures/keys:** Esc closes a modal; Enter submits; browser back works.

**Common violations:** green used for a destructive button; a custom icon for a standard action; search hidden behind an unlabeled icon; nonstandard control for a standard choice (a dropdown where radio buttons are expected).

**Judgment note:** a deliberate, well-executed deviation can be a brand signature. Flag deviations as **P3** and explain the convention being broken and its cost — let the team decide if the trade is worth it. Escalate only when the deviation actively misleads (green delete button).

---

## D5 — Apple HIG: Clarity, Deference, Depth **[GUIDELINE]**

HIG was written for native Apple platforms; these translate to the web at the principle level. Do **not** assert HIG "requires" specific pixel values it doesn't publish.

**Clarity** — content is legible and the purpose of every element is obvious:
- Legible text, adequate contrast (defer hard thresholds to Lane A), purposeful negative space.
- Function communicated before decoration.

**Deference** — UI defers to content; chrome doesn't compete:
- Navigation, toolbars, and backgrounds should not out-shout the content they frame.
- Decorative elements (gradients, illustrations, textures) shouldn't overpower the primary action.
- On translucent/elevated surfaces (sidebars, sheets, dropdowns), HIG favors **layered translucency** (a blurred, semi-transparent material) over a flat opaque fill, so the layer beneath remains sensed. A solid `#000`/`#fff` fill on a floating surface flattens this. *(Recommend `backdrop-filter: blur()` + semi-transparent background; provide a `prefers-reduced-transparency` fallback.)*

**Depth** — distinct visual layers convey hierarchy and position:
- Elevation should be consistent: things "closer" (modals, popovers) sit visibly above the content.
- A z-axis that's broken (a tooltip rendered behind its trigger; a modal at the same apparent depth as the page) is a depth violation.

**HIG specifics worth checking (as guidance, not hard law):**
- **Single prominent action:** give one action per view the strongest visual weight; everything else is secondary/tertiary. (Reinforces Hick's Law and Nielsen H8.)
- **Color as an enhancement, not the sole carrier of meaning** (aligns with Lane A SC 1.4.1).
- **Destructive actions get distinct treatment** (typically red and/or a confirmation), and are never the default/most-prominent button.
- **Touch targets:** HIG recommends ~**44×44pt** — more generous than the WCAG 24px floor (Lane A A7). Use as a polish target.
- **Motion:** respect `prefers-reduced-motion`; offer an instant or opacity-only fallback. Treat a missing reduced-motion fallback as a real issue (it's an accessibility/comfort concern), not mere polish.

---

## Reporting notes for this lane

- Affordance failures that make a control unusable by keyboard or unreadable as interactive can rise to **P2**; most convention/HIG-stretch items are **P3**.
- Always name the convention or principle and the concrete element. "Violates convention" is not actionable; "the delete button is green, where users expect red for destructive (Jakob's Law)" is.
- Where a finding also implicates accessibility (color-only link, tiny target, no reduced-motion fallback), cite the Lane A SC so the orchestrator can cross-promote and the team sees the hard requirement behind the principle.
