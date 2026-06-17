# Cursor Task JSON Shapes

The JSON Cursor hands you varies, but most packages contain a familiar set of fields. This is a quick map from common field names to how the orchestrator should use them. Treat this as a guide, not a contract — if a task omits a field, work with what you have.

---

## Common fields

| Field | What it is | How the orchestrator uses it |
|---|---|---|
| `task` | One-line summary of the work | Restate in your own plan; surface in the final report's Summary |
| `goal` | What "done" looks like | This is your north star — every slice should serve it |
| `scope.in` | What's in bounds | Use to decide which files/areas slices can touch |
| `scope.out` | What's out of bounds | Sacred — never violate, pass down to every worker |
| `important_context` | Background — current state, key files, plan path | Read first, then read the plan file if one is referenced |
| `important_context.plan_file` | Path to a detailed plan doc | Read it. Plans contain the design intent |
| `key_files` (or `important_context.key_files`) | Files most relevant to the work | Use to seed each worker's "files to read first" |
| `implementation_requirements` | The actual checklist | Map each item to a slice; pass the relevant items down to each worker |
| `test_requirements` | Test files + expectations | Decide which slice owns each test; pass down accordingly |
| `verification_commands` | Repo-wide commands to run at the end | YOU (orchestrator) run these as final gate. Not workers. |
| `quality_constraints` | Repo-wide rules and don'ts | Apply to all slices; bake into review checklist |
| `response_contract` | The exact shape of the final report | Honor exactly. `required_sections`, `must_include`, etc. |

## Less common but worth handling

| Field | What it is | How to handle |
|---|---|---|
| `priority` / `priority_level` | Urgency hint | Doesn't change correctness; can change how much investigation/research you do before slicing |
| `context_window_files` | Files to load into context up front | Read them in the orchestrator before planning |
| `forbidden_files` / `do_not_touch` | Explicit no-touch list | Treat as `scope.out` |
| `acceptance_criteria` | Alternate name for goal/requirements | Treat same as `implementation_requirements` |
| `deliverables` | List of artifacts expected | Make sure each is produced; reference in final report |

---

## Mapping example (using the home-active-chat-polish task you've seen)

Given a JSON like:

```json
{
  "task": "Implement the plan in /Users/.../home-active-chat-polish.plan.md",
  "goal": "Make the active/past chat view visually match the newer landing composer experience",
  "scope": { "in": [...], "out": [...] },
  "important_context": {
    "plan_file": "/Users/.../home-active-chat-polish.plan.md",
    "key_files": [...]
  },
  "implementation_requirements": [...],
  "test_requirements": [...],
  "verification_commands": ["pnpm type-check", "pnpm lint", "pnpm vibecheck:all:run"],
  "quality_constraints": [...],
  "response_contract": {
    "return_format": "markdown",
    "required_sections": ["Summary", "Files Changed", "Behavior Notes", "Tests Run", "Open Issues Or Follow-Ups"],
    "must_include": [...]
  }
}
```

The orchestrator's plan would look something like:

1. Read `.cursor/rules`.
2. Read the plan file at `important_context.plan_file`.
3. Read the key files to understand current state.
4. Decompose into slices, for example:
   - **Slice A**: Refactor `ComposerCard` to support controlled submit mode (`onSendMessage`, `pending`, `onMessageSent`). Touches `composer-card.tsx` + `composer-card.test.tsx`. Maps to implementation_requirements about ComposerCard reuse.
   - **Slice B**: Add `surface="chat-home"` mode to `BasisChat`. Touches `basis-chat.tsx` + `basis-chat.test.tsx`. Maps to requirements about the home presentation mode and removing old chrome.
   - **Slice C**: Wire the home mode in `ChatHomeClient`'s active-thread branch. Touches `chat-home-client.tsx` + `chat-home-client.test.tsx`.
   - Slice A must finish before Slice C (C consumes A's new API). B and A are independent.
5. Dispatch A and B in parallel. When A returns and passes review, dispatch C.
6. Adversarially review each return; dispatch fixes as needed.
7. Run `pnpm type-check`, `pnpm lint`, `pnpm vibecheck:all:run`. Fix failures.
8. Return a report in the exact 5-section shape the contract specified, addressing each `must_include` item explicitly.

---

## When the JSON is partial or malformed

If the user pastes something that looks like a task package but is missing key fields:

- Don't refuse. Work with what's there.
- Note the missing fields in the final report under "Open Issues Or Follow-Ups" or equivalent.
- If `response_contract` is missing, default to the standard 5-section report (Summary, Files Changed, Behavior Notes, Tests Run, Open Issues Or Follow-Ups).
- If `verification_commands` is missing, do your best to infer them from the repo (look for `package.json` scripts, Makefile targets, etc.) and report what you ran.
- If `scope` is missing, infer scope from `key_files` and the task description, and be conservative — don't sprawl.

When in doubt, ask the user one targeted clarifying question before kicking off the work. Better one round-trip than a wasted hour of subagent runs.
