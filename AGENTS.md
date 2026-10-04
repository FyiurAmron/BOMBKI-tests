# AGENTS.md — AI working notes

ALWAYS ASK IF UNSURE!

`CONTRIBUTING.md` is the project rules — read it in full before starting and
comply. This file is the operational layer for non-human contributors: the
concrete checks and procedures, not a restatement of the rules.

## Check tiers

The host-native FPC build is the daily driver: compile, conformance,
unit-test, scenario, and coverage checks all run against it, and its
results are enough to keep working. Genuine-TP7 compilation and the
DOSEMU2 original-versus-TP7 runtime smoke checks are reserved for final
checks: run them before pushing a milestone or in CI, not as part of
every task.

## Language

Always use English for communication. Tolerate input in other languages, but
respond and contribute entirely in English.

In documentation and user-facing text or output, prefer plain ASCII whenever
possible. Never use an em dash; write a regular ASCII hyphen-minus (`-`)
instead, except when reproducing a direct quotation verbatim.

## Task-start sequence

1. Read `README.md` for the project overview and documented build/test commands.
2. Read `CONTRIBUTING.md` in full to learn the project conventions and scope.
3. Establish the working baseline by checking the branch and worktree status,
   then identify the files and behavior relevant to the task.
4. Read `TODO.md` for the active work queue.
5. Refresh your view of any in-scope document changed during the task before
   relying on its updated contents.

## End-of-task verification

- Run the applicable Pascal conformance/compile checks and `git diff --check`;
  report only checks that actually ran.
- On Linux, prefer running the required compiler and checks directly. Do not
  use Docker or Podman when the needed functionality is available locally.
- For actual behavior tests, prefer a host-native executable when available.
  Drive it through an interactive PTY with expect-style synchronization: wait
  for expected output before sending each response. For example, wait for
  startup `TICK` before sending the race, then wait for the player-name prompt
  before sending the name. This complete sequence is illustrative only, not a
  required scenario; tailor the steps and output markers to the behavior under
  test. Synchronize on expected output rather than using fixed sleeps, blind
  input batches, or repeated polling.
- For DOSBox-X or DOSEMU2 runtime tests, track each process started by the
  session and bound its runtime. Before yielding or finishing, close every such
  instance and verify it has exited. Never leave an emulator running for the
  user or kill unrelated pre-existing instances; orphaned/repeated instances
  can crash WSL.
- Leave game sound enabled when it is useful for runtime diagnosis, but do not
  leave a DOSEMU2 game on its intro screen for long.
- Update `TODO.md` and the dated log as work is completed or priorities change.
- Verify the worktree, then commit and push when the current task is complete.

## Running tests

- Test runners must explicitly emit the names of the
  failed tests (not only a failure count), so a single
  run shows exactly which tests broke and why.
- Always redirect a test run's full output to a file
  under `build/tmp/` and inspect that file (read or
  grep it) to see the results and failures. Never
  rerun a test suite merely to view its output; rerun
  only to reproduce a failure after changing code.

## Autonomy

Do not stop after completing an intermediate task. Continue autonomously with
the next useful step. Only stop when the entire requested objective is
complete or you genuinely require information that cannot be obtained
independently.

Temporary build and analysis files belong under the project-local
`build/tmp/` directory. Do not use a shared/global `/tmp` location.

`_reference/` must never appear in a staged change.

## Installing software

- On Windows, prefer portable / temp-only solutions (download-and-extract into
  a temp dir, then run from there) over system installs whenever possible.
- On Windows, always ask the human for approval before installing software on
  the machine (e.g. winget/choco installs).

## Branch workflow

- Always work on a branch; never commit directly to `main`.
- Commit coherent subject-sized work as it progresses, including incomplete
  TODO items. Keep these commits local until a significant milestone is done
  (for example, completing one TODO item), then push the branch.
- Amend a local, unpushed commit only to correct a faulty commit or to record
  whole or partial completion of work that the commit marked incomplete. Do
  not amend merely to accumulate more changes on the same subject; commit
  those changes separately. This standing instruction pre-approves the
  specified amendments; never amend a pushed commit.
- Before pushing a completed milestone, review the local commits and squash
  very closely related commits so the final history has a reasonable number
  of commits, ideally one per subject. Use the affected-file sets and commit
  messages as a practical guide. These milestone squashes are pre-approved for
  local, unpushed commits on this branch.
- Reviews happen on GitHub: push the branch and open the PR; `main` advances
  only through reviewed merges, never by direct push. This rule governs the
  automated contributor flow, which ends with a pushed branch and an open PR
  awaiting review. The maintainer's own manual actions override it, and the
  maintainer may review in-session (in the conversation) instead of via a PR.
  When the maintainer asks for a push to `main`, the review already happened:
  carry it out without relitigating the rule or re-flagging the change.

## Committing

- Subject: one line, one idea, concise, ≤ 60 chars,
  prefix from the CONTRIBUTING list, no body.
- Stage explicit paths only (`git add <files>`), never `git add -A`.
- Pre-commit checks: file is LF-only (no CR bytes), no trailing whitespace,
  `git diff --check` clean.
- Hook: enable `.githooks/pre-commit` with `git config core.hooksPath .githooks`
  — enforces newline at EOF, LF-only, no trailing whitespace, and never staging
  `_reference/`.

## History rewrites

1. Amendments and milestone squashes allowed under Branch workflow are
   pre-approved for local, unpushed commits. For other history rewrites,
   propose the amend/rebase to the human and wait for approval.
2. Reword only the intended commits (interactive rebase) or amend the tip.
3. Verify the rewrite is message-only: `git diff <old-tip> <new-tip>` is empty.
4. Push with `--force-with-lease`.
