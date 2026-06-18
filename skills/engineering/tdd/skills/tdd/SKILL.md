---
description: Enforce the red → green → refactor TDD cycle. Invoke automatically whenever: implementing a new feature, function, method, or component; fixing a bug or regression; adding or modifying a test file; writing any code that introduces new behavior; changing an API contract or data shape; adding a new route, endpoint, or handler; refactoring logic that currently lacks test coverage. The rule is simple — no new behavior ships without a test written first. Skip only for pure mechanical refactors where full test coverage already exists and no behavior changes, or for changes limited to config files, documentation, or build scripts with no logic.
---

Follow the **red → green → refactor** (TDD) cycle for every new behavior or bug fix:

1. **Write the failing test first** — express the desired contract before writing any implementation. The test must fail for the right reason (e.g. `ReferenceError`, assertion mismatch), not because of a test setup error.
2. **Run it and watch it fail** — confirm the failure is meaningful before writing code.
3. **Write the minimum code to make it pass** — do not over-engineer; just satisfy the test.
4. **Run it and watch it pass** — confirm the new code actually fixes the failure.
5. **Refactor** — clean up duplication, naming, and structure without breaking the green test.
