---
description: Enforce the red → green → refactor TDD cycle for every new behavior or bug fix. Use when writing new features, fixing bugs, or adding test coverage.
---

Follow the **red → green → refactor** (TDD) cycle for every new behavior or bug fix:

1. **Write the failing test first** — express the desired contract before writing any implementation. The test must fail for the right reason (e.g. `ReferenceError`, assertion mismatch), not because of a test setup error.
2. **Run it and watch it fail** — confirm the failure is meaningful before writing code.
3. **Write the minimum code to make it pass** — do not over-engineer; just satisfy the test.
4. **Run it and watch it pass** — confirm the new code actually fixes the failure.
5. **Refactor** — clean up duplication, naming, and structure without breaking the green test.
