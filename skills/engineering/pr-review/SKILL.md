---
name: pr-review
description: >
  Reviews a GitHub pull request for real blocking problems that nobody has flagged yet:
  correctness bugs, security gaps, broken API or contract shapes, data races, and acceptance
  criteria the PR did not meet. It checks every concern against the actual code before
  reporting it, so it does not hand you false positives.

  Use this skill whenever: reviewing a PR by number ("review PR #NNN", "check PR 702", "is
  this safe to merge?", "what do you think of this PR?"), doing a blocker-only pass before
  approving, checking whether feedback someone else gave is correct ("is this reviewer comment
  real?", "is this Gemini, Copilot, or bugbot finding valid?", "double-check this review"), or
  asking whether a PR meets its ticket. It returns either a clear APPROVE, or a list of
  confirmed blockers, each with the file, the line number, a copy-paste GitHub comment, and a
  suggested fix. It only reports problems no one has raised yet, and it never posts to GitHub
  on its own. Trigger it even when the user just drops a PR number.
---

# PR Review

Your job is to find the real blocking problems in a pull request, and nothing else. Not style,
not theoretical risk, not things someone already flagged. Only problems that will break in
production, lose data, open a security hole, break a contract, or leave the linked ticket
unfinished.

Two habits make this skill worth more than a plain "review this PR":

1. **Check before you flag.** Reviewers, human and AI, often raise problems that are not in
   the actual code, especially about how a library, ORM, or type behaves. Confirm every
   concern against the real files first. A believable bug you did not verify is worse than
   saying nothing.
2. **Match the effort to the risk.** Most PRs need a quick, focused pass. Go deep only when
   the change is genuinely risky. Digging through a low-risk PR wastes the user's time and
   hides the real signal.

---

## Orchestrate efficiently

Load the `efficient-orchestration` skill and use it as the operating model for the review.
PR review splits up well, and the cost works in your favor:

- **You make the calls.** Deciding what counts as a real blocker, checking concerns against
  the code, checking ticket coverage, and writing the verdict need your judgment. Keep that
  work in the main loop.
- **Hand off the reading.** Reading the changed files and listing possible problems is
  routine work. On a PR that touches more than about 3 files, give each file (or group of
  related files) to a subagent that reads it and reports back a list of possible problems with
  exact line quotes. This keeps your context small and runs in parallel.
- **Keep the verdict yourself.** Treat what subagents return as leads, not findings. Re-read
  the lines they cite and run the verification step yourself before you report anything. A
  subagent saying "this looks wrong" is exactly the unchecked claim this skill is built to
  catch.

For a small PR (1 to 3 files) or a single-comment check, skip the hand-off and do it
yourself. Spinning up subagents would cost more than it saves. Match the tooling to the size
of the job.

### Never check out the branch. Read it by ref.

Read the PR files without changing the working tree. `git show origin/<branch>:<path>` and
`gh pr diff <number>` read files and diffs by ref. They do not move HEAD or change any file on
disk. `git fetch` (which only updates remote-tracking refs) is also safe.

**Do not `git checkout` the PR branch.** The review usually runs in a checkout the user is
working in, so a checkout would wipe out their state. And if you are reviewing two PRs at once,
or fanning out subagents, two checkouts in the same folder will clash and corrupt each other.
Reading by ref avoids all of this, so it is the default.

If a review really needs a live tree (to run tests or build), isolate it. Give each PR its own
`git worktree add`, or spawn the reviewer subagent with `isolation: "worktree"`, so nothing is
shared. Reviewing several PRs at once is only safe when each one reads by ref or sits in its
own worktree. Never a shared checkout.

---

## Workflow

### 1. Fetch the PR and its context

```bash
gh pr view <number> --json title,body,headRefName,baseRefName,state,labels,additions,deletions,changedFiles,closingIssuesReferences
git fetch origin <headRefName>
# Use GitHub's file list, not a local three-dot diff:
gh pr view <number> --json files -q '.files[] | "\(.additions)+ \(.deletions)-  \(.path)"'
```

Get the file list from `gh pr view --json files` (or `gh pr diff`), not from
`git diff main...origin/<branch>`. If your local `main` is behind, the three-dot merge base is
old and the diff fills up with unrelated files (one real 5-file PR showed 53). GitHub's file
list is always the true changeset.

Read the PR description and any conversation. It tells you the intent, the approach, and what
the author marked as out of scope, deferred, or a known limit. Do not re-raise those.

### 2. Collect what people already flagged, so you can leave it out

```bash
gh pr view <number> --comments
gh api repos/{owner}/{repo}/pulls/<number>/comments --jq '.[] | {user: .user.login, path, line, body}'
gh api repos/{owner}/{repo}/pulls/<number>/reviews --jq '.[] | {user: .user.login, state, body}'
```

Collect every existing inline comment, review, and bot finding (bugbot, Copilot, Gemini,
CodeRabbit, and so on). The point is to leave them out. The user wants only new problems. If
you later confirm a blocker that someone, human or bot, already raised, drop it from your new
findings. At the end, say in one line how many already-flagged items you skipped, but do not
describe them again.

**An unresolved known blocker still decides the verdict.** Leaving a prior finding off your
list is not the same as ignoring it for the verdict. For each prior finding, check the current
branch HEAD: is it actually fixed? If a blocker someone already flagged is still live,
especially a security one, the PR is not safe to approve. Say so plainly: "an
already-flagged high-severity issue at `file:line` looks unresolved. I am not repeating the
detail since it is already on the PR, but it blocks approval until it is fixed." Do not return
a clean APPROVE while a known blocker sits unfixed just because someone else found it first.

### 3. Find and read the linked ticket or issue

If `closingIssuesReferences` has an entry, or the body has `Closes #N`, `Fixes #N`, `Refs #N`,
or a `Ticket:` line, open the linked issue:

```bash
gh issue view <issue-number> --json title,body,labels
```

Pull out its acceptance criteria (a checklist, an "Acceptance Criteria" section, or the stated
requirements). You will check the PR against these in step 6. If the repo keeps tickets as
files (say a `tickets/` folder) and the PR points to one, read that file too.

If there is no linked ticket, note that and skip the AC check. Do not invent criteria.

### 4. Decide how deep to go

Default to a focused first pass: read the diff and the changed files, scan for clear blockers,
check AC coverage, confirm what you find, and report. This is the right depth for most PRs.

Go deeper only when there is a real risk signal:

- The PR marks its risk as **high** (in a risk or severity field in the body or template), or
- It carries a **security or deep-review label** (such as `deep-review` or `security`), or
- The diff **touches sensitive areas** no matter the stated risk: auth, secrets, audit,
  proxying, migrations, or paths that write or delete data.

A big diff alone does not require a deep dive. A large mechanical rename is still low risk. Use
your judgment, and say in one line which depth you picked and why.

A deep dive also means: read the nearby files (types, schemas, callers, tests), follow the
data and auth flow end to end, and run the optional spec check (step 6d) more carefully.

### 5. List the possible blockers

Scan the changed code for problems that really block a merge:

- **Logic errors:** a wrong condition, a missing null check at a real boundary, the wrong
  variable, an off-by-one that crashes or corrupts data.
- **Security:** an auth or permission bypass, user input reaching SQL, a shell, or a template
  without validation, a secret logged or returned in a response.
- **Broken contracts:** a function whose shape does not match its declared type or schema, a
  wrong HTTP status or error code on a path clients depend on.
- **Data integrity:** a write missing the transaction it needs, async work missing
  idempotency, a race that loses data without warning.
- **Unsafe types:** `as any`, `as unknown as T`, or a non-null `!` hiding a real error (not a
  narrow, justified cast).
- **No tests for new behavior:** a new endpoint, rule, or failure path with no test at all.

Do not flag: style, naming, formatting, "this could be cleaner," risks that depend on config
the repo does not have, small performance tweaks, or anything the PR description already marks
as deferred.

### 6. Check the rest of the obligations

**6a. Acceptance-criteria coverage.** For each criterion in the linked ticket, confirm the
diff actually meets it. A criterion the PR neither builds nor tests is a blocker, unless the
PR or ticket clearly defers it to a named follow-up ticket or a later phase. Put coverage in
its own section (see the output format) so the user sees the whole picture, not just a
pass or fail.

**6b. Stay in scope.** If the PR says some criteria belong to another ticket, respect that. Do
not mark the PR down for work that was handed to a different ticket.

**6c. Conflicts with other open PRs.** A review against `main` is blind to other open PRs, and
two PRs that each look fine alone can collide when both merge. Do one cheap scan, then look
closer only where it matters:

```bash
gh pr list --state open --json number,title,files
```

Intersect this PR's changed files with each other open PR's file list. Two kinds of conflict
to catch:

- **Number clashes.** When the PR adds a file whose number must be unique, like an ADR
  (`docs/decisions/NNNN-*.md`), a DB migration, or an RFC, another open PR may have taken the
  same number even though both are right against `main`. Whichever merges second creates a
  duplicate number and a merge conflict on the shared index (such as the ADR README table).
- **Contradictory edits to the same source of truth.** When this PR and another open PR both
  edit the same authoritative file, a spec or doc (`docs/**`), a schema or migration, a shared
  type, or a contract, they can describe the same thing two different ways. Whichever merges
  second either conflicts or lands a file that contradicts itself. This is the one a `main`-only
  review misses most, and it bit a real review: two open PRs both rewrote the same `docs/10`
  auth section, one removing a mechanism the other still described.

Only the overlaps on a real source-of-truth file are worth opening. For each, read the other
PR's diff of that file (`gh pr diff <other> -- <path>`) and check whether the two can both
land coherently. A genuine clash, a duplicate number or a contradiction an implementer would
have to obey, is a blocker. Name the other PR, say what conflicts, and suggest who rebases on
whom (usually the further-along or higher-risk PR lands first). Skip this for a PR that only
touches its own new files or code no other open PR is near.

**6d. Spec compliance (bonus, deep dive).** If the repo has authoritative spec or architecture
docs the change relates to, check that the code matches them (naming, error shapes,
conventions). Treat this as a bonus, not a gate. Flag a clear contradiction, but do not block
on a reading that could go either way.

### 7. Confirm every candidate before you flag it. This is the step that matters.

For each possible blocker and each AC gap, confirm it is real:

1. **Quote the exact lines** from the real file and confirm the code is shaped the way you
   think (`git show origin/<headRefName>:<path>`). Reviewers often describe code that is not
   there, like a "whitespace bug" in a string that is actually clean.
2. **Check what the concern rests on.** If it is about a library or ORM method, read its type
   or source in the installed version (`node_modules`, vendored source, or the equivalent for
   the language). If it is about a type, read the type. About a column being nullable, read
   the schema. About behavior that depends on config, check whether that config is actually
   set.
3. **Look for guards already in place:** a DB constraint, a validator upstream, a schema parse
   at the boundary, that already stops the bad state.
4. **Check the tests.** Does a test already cover the exact path you are worried about? If so,
   a bug there would be caught, and it is probably not real.

If you cannot confirm the problem is in the real code after these checks, it is not a blocker.
Drop it.

### 8. Report the verdict

Drop any confirmed blocker that someone already raised (step 2), then report. End the verdict
with the commit you reviewed (see "Recording what you reviewed"), so a later re-review has a
baseline.

---

## Re-review mode

Use this when you already reviewed the PR, asked for changes, and the author says they fixed
it ("re-review", "I addressed the comments", "check again"). Do not start over. Look only at
what changed since your last review.

1. **Find the baseline:** the commit you reviewed last time. Get it, in this order:
   - From this conversation, if the review is still in context (you stamped the commit in your
     last verdict).
   - From the commit timeline: `gh pr view <n> --json commits`. The commits after your review
     are the fixes, and there is usually one literally titled "address review" or similar.
   - If you cannot tell, ask the user for the prior review or the commit, rather than guessing.
2. **Read only the delta:** the new commits and any new comments since your review. The
   author's commit messages and replies usually say what they changed.
3. **Re-verify each prior finding** against the current code: resolved, still live, or partly
   done. Check by current content, not the old line numbers. A merge from the base branch
   shifts line numbers, so grep for the text instead of trusting the line you cited before.
4. **Re-run any check that was itself a finding.** If you flagged a number clash, re-run the
   clash check, because the renumber can collide with a different PR. If you flagged a missing
   doc, confirm the doc is now there and says the right thing.
5. **Scan only the changed files for new blockers.** A fix can introduce one.
6. **Report** each prior finding's status, any new blockers, the updated verdict, and the new
   commit you reviewed as the next baseline.

Never post a follow-up tag or "re-review please" comment on the PR. The record is the PR's own
thread (the comments the user already left and the author's replies and commits) plus the
commit stamp in your verdict. Keep handing back text only.

---

## Common false positives

These are the shapes that fool automated reviewers most. When a concern matches one, check it
hard against the installed code before you believe it:

- **ORM query builders.** Claims that a query builder makes "malformed SQL" or "returns
  objects instead of values" are usually wrong. The builder's subquery and expression handling
  is defined behavior. Read the function's signature in the installed version.
- **JSON and JSONB columns.** Most drivers turn JSON columns into native objects at the driver
  level, the same way for partial and full selects. A claim that a column "comes back as a
  string" is wrong unless the code actually registers a custom type parser. Grep for one.
- **Type narrowing in strict mode.** A cast on a value that was properly narrowed is fine.
  Only `as any`, `as unknown as T`, and an unjustified non-null `!` are real smells.
- **Policy-language rule merging (OPA or Rego).** Two definitions of the same rule are OR-ed
  when their bodies cannot both be true at once (the default plus override pattern). A real
  conflict only happens when both bodies can be true at the same time.

The general rule: a concern about how a framework, library, or language behaves is the number
one source of false positives. Confirm it against the real installed version, not from memory.

---

## Recording what you reviewed

End every verdict with the commit you reviewed: `Reviewed at commit <sha> (branch <name>)`.
That one line is the baseline a later re-review diffs from, whether the conversation continues
or a fresh session picks it up. Keep the chat going when you can, so the prior findings stay in
context.

Do not record state by posting to the PR or writing a file. The durable record is the PR's own
thread: the comments the user pastes from your review, the author's replies, and the commit
messages. That is enough to pick up a re-review later.

## Output format

**Every blocker must carry three things, with no exceptions:** the exact file, the exact line
number, and a ready-to-paste review comment with the literal text to drop on the PR. This is
the whole point of the skill. The user pastes your comment straight into GitHub. A finding
without a real `path:line` and a paste-ready comment is not done. Go get the line number
(`grep -n` against the file on the branch) before you report. Anchor the line on the most
relevant spot: the bad line of code or prose, or for a "something is missing" finding, the
nearest line where the fix belongs.

**Write the PR comment in plain language.** This is the text the user pastes onto GitHub, so
it matters more than anything else here. Apply the `humanizer` skill's rules to it: short
sentences, everyday words, no jargon, no filler, no buzzwords, no em dashes, no curly quotes.
Name the file and line, say what is wrong, say why it matters in one line, and give the fix.
Write the way you would explain it to a teammate in chat, not like a formal review.

Before you hand over a comment, reread it and cut anything that does not help the author fix
the problem.

Bad (stiff and jargon-heavy):
> This introduces a latent data-integrity regression: the mutation lacks transactional
> atomicity, so concurrent invocations may interleave and yield a partially-applied state,
> thereby violating the idempotency invariant.

Good (plain):
> `app-mutations.ts:255`: this update runs outside a transaction, so two requests at the same
> time can overwrite each other and leave the row half-updated. Wrap the read and write in one
> transaction so only one wins.

**No blockers:**

```
## PR #NNN: [title]

**Verdict: APPROVE.** Review depth: [first pass | deep dive | re-review] ([one line on why])
Reviewed at commit [sha] (branch [name]).

Reviewed N changed files. No new blockers.

**Acceptance criteria:** [N/N met | no linked ticket]
[If a ticket is linked, one line per criterion: met (where) / deferred to <ref>.]

[2 to 3 sentences on what the PR does and what makes it solid: the specific pattern,
constraint, or test that gives you confidence. Not just "looks good."]

[If it applies: "Left out M issue(s) already raised by others."]
```

**Blockers found:**

```
## PR #NNN: [title]

**Verdict: REQUEST CHANGES.** Review depth: [first pass | deep dive | re-review] ([one line on why])
Reviewed at commit [sha] (branch [name]).

N new blocker(s).

**Acceptance criteria:** [coverage summary. List any criterion that is not met and not
deferred as one of the blockers below.]

---

### 1. [Short plain title]

**File:** `path/to/file.ext:line`
**Problem:** [One plain sentence: the exact code and what is wrong.]
**Impact:** [What breaks: "500 on the restore path", "skips the audit write", "role bypass".]
**Confirmed by:** [What you actually read: the type signature, the missing constraint, the
missing test, the ticket criterion with no code behind it.]

**Fix:**
```
[corrected code]
```

**Comment to paste on the PR:**
> @author, [plain, specific, and useful: the file and line, what is wrong, why it matters in
> one sentence, and the fix. No lecture.]

---
[repeat per blocker]

[If it applies: "Left out M issue(s) already raised by others."]
```

You only ever hand back text. Never post, approve, or request changes on GitHub yourself. The
user does that.

---

## Checking someone else's feedback

When the user shares a reviewer's concern (a bot finding or a colleague's comment) and asks
whether it is real, go straight to checking it. This is the fast path:

1. Find the exact file and line they cite.
2. Read the real code (`git show origin/<branch>:<path>`). Is the problem there, the way the
   reviewer describes it? Often the code they quote is not in the file.
3. Check what the concern rests on (installed library version, driver config, DB schema, type
   signatures), the same way as the verification step.
4. Answer one of two ways:
   - **Real:** confirm what you found, and agree with or improve the fix.
   - **False positive:** say exactly why. What you read, how the code actually behaves, and why
     the reviewer's assumption does not hold here.

Then give the user a short, plain reply they can send back to the reviewer, citing what you
checked.

---

## Principles

- Saying nothing about a non-issue beats a confident wrong flag. If you are unsure after
  checking, say so instead of inventing a blocker.
- Prefer the smallest fix that solves the real problem. Do not redesign things in a review.
- Tell "this is a bug" apart from "I would do it differently." Only the first one blocks.
- Respect the author's stated scope and the ticket's boundaries. Work that was handed to
  another ticket is not a defect of this PR.
