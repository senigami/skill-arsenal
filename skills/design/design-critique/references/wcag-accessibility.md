# Lane A — Accessibility (WCAG 2.2)

**Sub-agent brief:** Evaluate the UI against WCAG 2.2 success criteria that are testable from CSS, DOM, and screenshots. Report only accessibility findings. Every numeric threshold below is **[VERIFIED]** against the W3C normative spec and Understanding documents unless marked otherwise. Cite the SC number and exact measured value in every finding (`3.1:1 — fails SC 1.4.3 by 1.4:1`).

Sources: [WCAG 2.2 spec](https://www.w3.org/TR/WCAG22/), [Understanding: Contrast (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html), [Understanding: Non-text Contrast](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html), [Understanding: Use of Color](https://www.w3.org/WAI/WCAG21/Understanding/use-of-color.html), [WebAIM Contrast](https://webaim.org/articles/contrast/).

---

## A1 — Text contrast (SC 1.4.3, Level AA) **[VERIFIED]**

**What it means:** Text and images of text must have enough luminance contrast against their background to be readable by users with moderately low vision.

**Thresholds (hard cutoffs — never round up; 4.499:1 fails 4.5:1):**
- **Normal text:** ≥ **4.5:1**
- **Large text:** ≥ **3:1**. "Large" = **≥ 24px** (18pt) regular, **or ≥ 18.67px** (14pt) **bold**.

**How to test:** For every text/background color pair, compute the WCAG contrast ratio. Resolve the *actual rendered* background (including any semi-transparent layers and the color beneath them). Check the smallest/lightest text first — that's where failures cluster.

**Common violations to spot in CSS:**
- Placeholder text at `rgba(0,0,0,0.38)` on white (~2.6:1) — and worse, real hint text reusing the placeholder token.
- Light-gray body copy: `#999` on `#fff` = 2.85:1 (fails), `#767676` on `#fff` = 4.54:1 (passes — the common "lightest passing gray").
- White text on a mid-tone brand button (`#fff` on `#4A90D9` = ~2.5:1).
- Text over a photo/gradient hero with no scrim.

**Exemptions:** Logotypes, incidental/decorative text, disabled controls.

**Good vs. bad:**
- ✗ `color:#9CA3AF` (gray-400) for a form's helper text on white → 2.5:1.
- ✓ `color:#6B7280` (gray-500) → 4.6:1, or pair the lighter gray with ≥24px size.

---

## A2 — Non-text contrast (SC 1.4.11, Level AA) **[VERIFIED]**

**What it means:** The visual boundaries of UI components and meaningful graphics must be perceivable. Applies to the parts you need to *see to operate or understand*.

**Threshold:** ≥ **3:1** against adjacent color(s). No rounding (2.999:1 fails).

**Applies to:**
- Form-field borders (the edge that tells you where to type)
- Checkbox / radio / toggle outlines and their checked indicator
- Button outlines on ghost/outline-style buttons
- Focus rings (the ring's color vs. what's behind it)
- Icon strokes when the icon conveys meaning or state
- Chart/graph elements required to read the data (axes, series boundaries)

**How to test:** Read the border/stroke color token and compare to the surface it sits on. Inputs are the highest-yield check.

**Common violations:**
- `border:1px solid #ccc` on white = 1.6:1 — the single most common failure.
- Ghost buttons with a hairline low-contrast outline.
- Toggle "off" state where the track is barely distinguishable from the page.

**Exemptions:** Inactive/disabled components, and elements whose appearance is the browser default (user-agent styled).

---

## A3 — Use of color is not sole indicator (SC 1.4.1, **Level A**) **[VERIFIED]**

> **Correction:** This is **Level A**, not AA. It is in scope precisely because Level A is the most foundational tier — a failure here is more serious, not less.

**What it means:** Color may reinforce meaning but must never be the *only* way to convey it. This holds **even when the contrast ratio passes** — the issue is color-blind and low-vision users who can't distinguish the hue at all.

**How to test:** For every state or distinction expressed by color, ask "is there a second cue?" (text label, icon, shape, pattern, underline, position).

**Common violations:**
- Form error shown only by a red border — no icon, no message, no `aria-invalid`.
- Required fields marked only by red label text (no asterisk/"required").
- Status badges distinguished only by background hue (green/yellow/red with identical text).
- Chart series separated only by color with no legend, direct labels, or patterns.
- Links in body text colored but not underlined and with no other cue.

**Good vs. bad:**
- ✗ Error = `border-color:red`.
- ✓ Error = red border **+** error icon **+** message text **+** `aria-invalid="true"`.

---

## A4 — Focus visible (SC 2.4.7, Level AA) **[VERIFIED]**

**What it means:** Every keyboard-operable element must show a visible focus indicator when focused. **SC 2.4.7 sets no numeric size or contrast threshold** — it only requires that *something visible* appears.

**How to test:** Grep for `outline:none` / `outline:0`. Each occurrence is a violation **unless** a replacement focus style (`:focus-visible` box-shadow, border, outline, or background change) is defined on the same element.

**Common violations:**
- `*:focus{outline:none}` global reset with no replacement.
- `:focus` styled but `:focus-visible` not — or a CSS reset removing the default without restoring.
- Custom controls (divs with `role="button"`, `tabindex`) that never style focus.

**Good vs. bad:**
- ✗ `button:focus{outline:none}`
- ✓ `button:focus-visible{outline:2px solid currentColor; outline-offset:2px}`

---

## A5 — Focus not obscured (SC 2.4.11, Level AA) **[VERIFIED]**

> **Correction:** In WCAG 2.2, **SC 2.4.11 is "Focus Not Obscured (Minimum)"** — *not* Focus Appearance.

**What it means:** When an element receives focus, it must not be **entirely** hidden by author-created content (sticky headers, footers, cookie bars, floating widgets).

**How to test:** Tab through the page mentally/programmatically with any `position:sticky`/`fixed` overlay present. Flag any focusable element that would scroll fully behind it.

**Common violations:** A sticky header covers the focused field as the page auto-scrolls; a cookie banner overlaps the focused control beneath it.

---

## A6 — Focus appearance (SC 2.4.13, **Level AAA**) **[VERIFIED — but AAA, aspirational]**

> **Correction & scope flag:** The measurable focus rules are **SC 2.4.13 at Level AAA**, not an AA requirement. Treat findings here as **best-practice / P3**, not AA blockers, and label them `(SC 2.4.13 AAA — best practice)`.

**What it means (the parts that are verified):**
- The focus indicator's contrast is measured **between the same pixels in the focused vs. unfocused state** (a 3:1 *state change*), **not** the ring against its adjacent background. This is the most-misquoted rule on the web.
- When only part of an indicator achieves the 3:1 state change, **only that qualifying portion** counts toward the area.

**Do NOT cite:** any "minimum focus area = 2px perimeter (e.g., 480px² for a 90×30 button)" formula. That specific claim was **refuted** in verification — it is not reliably supported.

**Practical, defensible check:** a focus ring of ≥2px thickness with `outline-offset` that clearly changes the element's appearance comfortably satisfies the spirit of 2.4.13. Recommend it as polish, not as an AA gate.

---

## A7 — Target size (SC 2.5.8, Level AA) **[VERIFIED]**

**What it means:** Pointer targets must be large enough to hit reliably.

**Threshold:** ≥ **24×24 CSS px**, **or** ≥24px of spacing between adjacent small targets.

**Exceptions:** inline targets (links in a sentence), targets sized by the user agent, or where a particular size is essential.

**How to test:** Measure rendered width/height (content + padding) of icon buttons, close (×) buttons, dense link lists, pagination dots, table-row action icons.

> **HIG note (Lane D overlaps):** Apple HIG recommends a more generous **44×44pt**. Use 24px as the AA floor (P1/P2 when failed on critical path) and 44px as the HIG-aligned target (P3 polish). [GUIDELINE]

---

## A8 — Reflow (SC 1.4.10, Level AA) **[VERIFIED]**

**What it means:** Content must reflow into a single column without loss of information or **horizontal scrolling** at a viewport width of **320 CSS px** (equivalent to 400% zoom on a 1280px screen).

**How to test:** Look for fixed-width containers wider than 320px, `width:100vw` on content (scrollbar-width overflow bug), large `min-width` values, wide tables/grids without an overflow strategy, horizontal-scroll layouts.

---

## A9 — Text spacing (SC 1.4.12, Level AA) **[VERIFIED]**

**What it means:** No loss of content when the user overrides spacing to: line-height **1.5×** font size, paragraph spacing **2×**, letter-spacing **0.12em**, word-spacing **0.16em**.

**How to test:** Flag hard-coded **pixel** `line-height` (e.g. `line-height:18px`) and fixed-height text containers that would clip when spacing increases. Prefer unitless line-height.

---

## A10 — Resize text (SC 1.4.4, Level AA) **[VERIFIED]**

**What it means:** Text must scale to **200%** without loss of content or function.

**How to test:** Look for fixed-height containers around text, `overflow:hidden` on text blocks, and viewport units (`vw`/`vh`) used for font sizing that defeat user zoom.

---

## Reporting notes for this lane

- Lead with the SC number, level, and exact measured value.
- Severity guide: failures on **critical-path** elements (primary CTA, form submit, checkout) → **P1**. Off-path AA failures → **P2**. AAA / HIG-stretch items (A6, 44px target) → **P3**.
- Contrast ratios: report to two decimals and state the gap (`2.8:1 — fails 4.5:1`). Never round to claim a pass.
- If working from screenshots only, mark contrast findings `[visual — exact ratio needs CSS values]` and estimate conservatively.
