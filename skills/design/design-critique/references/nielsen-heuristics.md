# Lane B — Usability Heuristics (Nielsen Norman Group)

**Sub-agent brief:** Walk the interface against all ten heuristics. For each, name at least one pass and one concern — a clean heuristic is still worth recording. Report usability findings only. The H4 and H5 structure below is **[VERIFIED]** against NN/g primary sources; the rest is the standard NN/g framing.

Sources: [10 Usability Heuristics](https://www.nngroup.com/articles/ten-usability-heuristics/), [Consistency and Standards](https://www.nngroup.com/articles/consistency-and-standards/), [Error-Message Guidelines](https://www.nngroup.com/articles/error-message-guidelines/).

---

## The ten heuristics

| H# | Heuristic | What to check in the UI |
|----|-----------|-------------------------|
| **H1** | Visibility of system status | Loading/spinner on every async action; success/error confirmation after submit; progress for multi-step or long operations; no silent failures |
| **H2** | Match between system and the real world | Labels in the user's language, not internal jargon (`Archive`, not `Soft-delete`); natural reading/information order; icons whose metaphor matches real meaning |
| **H3** | User control and freedom | Visible "emergency exit": Cancel/Close in every flow; Undo for destructive actions; back button works; modals dismissible |
| **H4** | Consistency and standards | See H4 detail below — **[VERIFIED]** |
| **H5** | Error prevention | See H5 detail below — **[VERIFIED]** |
| **H6** | Recognition rather than recall | Options visible rather than memorized; breadcrumbs; autocomplete; recently-used; contextual help; don't force users to remember data across steps |
| **H7** | Flexibility and efficiency of use | Accelerators for experts (keyboard shortcuts, bulk actions, saved filters/presets) that don't burden novices |
| **H8** | Aesthetic and minimalist design | One primary action per view; every element earns its place; clear hierarchy at the squint test; no competing focal points |
| **H9** | Help users recognize, diagnose, recover from errors | See H9 detail below — **[VERIFIED correction]** |
| **H10** | Help and documentation | In-context help (tooltips, inline guidance, empty-state coaching) over a remote knowledge base; searchable, task-focused docs when needed |

---

## H4 — Consistency and standards (detail) **[VERIFIED]**

**Two kinds of consistency, both required:**
- **Internal:** the same words, layouts, and interactions mean the same thing throughout *this* product. ("Users should not have to wonder whether different words, situations, or actions mean the same thing.")
- **External:** the design follows **platform and industry conventions** — it behaves like the other products users already know. (This is the bridge to Jakob's Law in Lane D.)

**Four layers to audit consistency across:**
1. **Visual** — icons, imagery, color usage, component styling
2. **Layout** — page structure and the placement of buttons/controls
3. **Data-entry formats** — date formats, phone/number formats, units, casing
4. **Content & tone** — terminology and voice across onboarding, UI labels, and errors

**Common violations to spot:**
- Same action labeled `Save` in one place and `Submit`/`Apply` in another.
- Primary button on the left in one dialog, right in another.
- Two visual styles for the same class of action.
- Mixed date formats (`06/22/2026` vs `22 Jun 2026`) across screens.
- A nonstandard icon for a standard action (e.g., a heart used for "bookmark").
- Tone whiplash: playful onboarding, robotic error copy.

---

## H5 — Error prevention (detail) **[VERIFIED]**

The best error message is one that never appears. Two error classes need **different** prevention strategies:

- **Slips** — *unconscious* errors of inattention (right intention, wrong action). Prevent with **constraints and good defaults**: input masks, disabling impossible options, sensible pre-selections, format enforcement, spacing destructive actions away from common ones.
- **Mistakes** — *conscious* errors from a wrong mental model. Prevent by **reducing memory burden, supporting undo, and warning before irreversible actions**: confirmation for consequential/irreversible operations, plus a recovery path.

**Common violations:**
- `Delete account` placed adjacent to `Save settings`, no separation, no confirmation, no undo (a classic slip trap).
- Required field with no inline format hint until after a failed submit (mistake risk).
- Free-text entry where a constrained picker (date, country) would prevent invalid input.
- Irreversible action with neither confirmation nor undo.

---

## H9 — Error messages (detail) **[VERIFIED correction]**

> **Correction:** A widely-repeated claim says H9 mandates **bold red** error text. That is **not** in the guideline and was refuted in verification. Worse, color-only signaling violates SC 1.4.1 (Lane A).

**What H9 actually requires** — error messages must:
1. Be in **plain language** (no raw error codes or stack traces as the primary message).
2. **Precisely identify the problem** ("Card declined: expired" beats "Transaction failed").
3. **Constructively suggest a fix** ("Use a card expiring after today").

**Placement & form (NN/g error-message guidance):** put the message **next to the field** it concerns, keep it visible (don't auto-dismiss critical errors), and pair any color with text + icon so meaning survives without color.

**Common violations:** `Error 0x80004005`; a single top-of-form "Something went wrong" with no field attribution; toast errors that vanish before they can be read.

---

## Reporting notes for this lane

- Tie each finding to its H#. Issues spanning multiple heuristics (e.g., a color-only error fails H9 *and* Lane A SC 1.4.1) should be noted as cross-lane — the orchestrator will cross-promote severity.
- Most usability findings land **P2–P3**. Escalate to **P1** only when the issue blocks task completion or causes data loss (e.g., no confirmation before irreversible delete on the primary flow).
- Be specific about location and the exact label/term at fault — "inconsistent terminology" is not actionable; "`Save` on the profile page vs. `Update` on settings for the same action" is.
