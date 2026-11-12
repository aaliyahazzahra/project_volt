# Volt: splitting the next work between collaborators

Written 2026-11-12, updated after phase 1 was merged. Read `docs/HANDOFF.md` first (state, rules, how to verify). This file only says WHO does WHAT next, in which order, and how the two lines avoid stepping on each other in one repository. Verify the state with git before trusting any line.

## 1. State in one screen (updated at `project_volt` `develop` `e145b1b`, last tag `v1.0.2`)

- Phase 1 (theme, `go_router`, 4-tab shell, SQF code removed) is merged into `develop` (`e145b1b`, rebase-merge). The app still runs on Firebase.
- `flutter analyze`: 82 issues, all `info`. `flutter test`: 19 pass, 1 fail (the untracked simulator reproduction test). Measured before the last cleanup; a re-run on `develop` crashed with a Windows memory error and is not done.
- NOT proven: dark mode and unknown-role login on an emulator, any Supabase project or schema, whether the exposed Supabase key was rotated. The Simulasi tab cannot save a circuit (existing behavior, until phase 5).
- Package O0 is done, so the lines can start from `develop` once O1 is done and decision 14 is settled.

## 2. Work packages

Lines: **BE** = backend line (Supabase SQL, RLS, RPC, storage, repositories, simulator engine). **UI** = UI line (theme use, shared widgets, screens, router, simulator canvas). Phases come from spec section 8.

| ID | Package | Line | Needs | Size | Conflicts with |
|---|---|---|---|---|---|
| O0 | Phase 1: emulator checklist, push, PR into `develop`, merge | owner | none | S | DONE 2026-11-12 |
| O1 | Rotate Supabase keys or create a new project; give BE the project, put values in `config/supabase.json` | owner | none | S | none (no code) |
| O2 | Android toolchain upgrade on `chore/android-toolchain`: Gradle 8.14 or newer, AGP 8.11.1 or newer, Kotlin, with JDK 21; test on an emulator | owner (BE if asked: `android/` is a shared file) | O0 | M | none; UI1's emulator review needs it, or the local recipe in `HANDOFF.md` section 3 |
| BE1 | Phase 2 backend: `tb_profil`, signup trigger, RLS, `AuthRepository` (interface plus Supabase implementation), `SessionController` on the Supabase user | BE | O0, O1 | M | UI1 (interface agreed first) |
| UI1 | Phase 2 screens: splash session check, login, register, against `AuthRepository` with a fake in tests | UI | O0, BE1 step 1 (interface) | M | BE1 on `lib/app/session_controller.dart` |
| BE2 | Phase 3 backend: `tb_kelas`, `tb_anggota_kelas`, RLS, join RPCs, `KelasRepository` | BE | BE1 | M | UI2 (interface) |
| UI2 | Phase 3 screens: Beranda, Kelas list, create and join forms, class page tabs, shared widgets (`SummaryCard`, `ClassCard`, `DeadlineTile`, `StatusChip`, `PrimaryButton`) | UI | UI1, BE2 step 1 | L | none |
| BE3 | Phase 4 backend: `tb_materi`, `tb_tugas`, `tb_submisi`, buckets `app-materi` and `app-submisi`, signed URLs, two-step upload with cleanup, repositories | BE | BE2 | L | UI3 (interface) |
| UI3 | Phase 4 screens: materials, assignments, submission, grading (layout not designed) | UI | UI2, BE3 step 1, owner design of grading | L | none |
| BE4 | Phase 5 engine: pure Dart simulator engine (settle loop with cap, snapshot in and results out, truth table in an isolate), coordinate parsing fix, `tb_simulasi` repository, commit the reproduction test | BE | BE3 (for `tb_simulasi` only; engine can start after O0) | L | UI4 on `lib/data/simulation_models.dart` |
| UI4 | Phase 5 canvas: per-circuit state, queued reruns, tap-to-connect, truth table UI, full-screen canvas without bottom bar | UI | UI3, BE4 engine API | XL | BE4 |
| P6 | Phase 6 cleanup: remove Firebase, README status table | owner and BE | all above | M | everything; run alone |

Dependencies: UI work in a phase calls repositories through an interface, so UI starts once the BE line has written and the owner has approved that interface (step 1 of each BE package), not when the SQL is finished. Real wiring of a UI package waits for the matching BE package to merge. Phase N packages merge before phase N+1 starts (spec section 8).

## 3. The split

- **Collaborator BE (backend line, owns the Supabase dev project and any RLS or SQL check run):** BE1, BE2, BE3, BE4 in that order. BE4's engine part may start earlier if BE is waiting.
- **Collaborator UI (UI line):** UI1, UI2, UI3, UI4 in that order.
- **Owner:** O0 (done), O1, O2, P6, runs every commit and tag, reviews and approves every package, grading screen design, answers section 7.

Both lines work in `project_volt`. They avoid overlap by folder (section 4, rule 2).

## 4. Rules that keep the lines from colliding

1. **One live gate at a time, owned by BE.** The shared state is the Supabase dev project (and, until phase 6, the Firebase project the app still uses). Row totals, class codes and RLS results break if another writer touches it during a check. BE runs SQL, RLS checks and migrations. UI never changes schema and never runs SQL; UI checks through the app with `zz-test-` accounts and removes them by exact id after a SELECT review, and not while BE announces a gate. Tests use fake repositories, never the live project.
2. **Folder ownership.** BE owns `supabase/` (SQL migrations), `lib/features/<feature>/data/**`, `lib/data/**`, `lib/app/session_controller.dart` and `test/**/data/**`. UI owns everything else under `lib/features/<feature>/` (screens, widgets), `lib/core/**`, `lib/widgets/**`, `lib/app/app_router.dart`, `lib/app/app_shell.dart` and the widget tests. The repository interface in `data/` is the contract between the lines; a change to it needs the other line's agreement through the owner.
3. **Shared files belong to BE only, changes by request:** `pubspec.yaml`, `pubspec.lock`, `lib/main.dart`, `analysis_options.yaml`, `config/**`, `.gitignore`, `README.md`, `CHANGELOG.md`. UI reports a gap to the owner and does not patch it. Each collaborator gives the owner a ready `CHANGELOG.md` snippet in the package report; the owner or BE pastes it.
4. **Specs and plans** live in `docs/superpowers/specs/` and `docs/superpowers/plans/` with names `<date>-<line>-<topic>` (example `2026-11-20-backend-phase-2-auth.md`), committed by explicit path in their own docs commit.
5. **Commits: explicit paths only.** Never `git add -A` or `git add .`. The untracked `test/features/simulation_logic_test.dart` stays out of every commit until BE4. Agents and collaborators never commit, tag or push; the owner is the only one who commits (rule 6 says what is handed over).
6. **After each finished package** the collaborator gives the owner a **commit package**: the files to stage (explicit paths), one Conventional Commits message (subject, plus a body when needed) and the exact CLI block to paste (`git add <paths>` then `git commit -m "..."`, plus `git tag` or `git push` lines when relevant) before starting the next package, and stops for review after the first deliverable of a new package.
7. **Branches:** one branch per line per phase, cut from the latest `develop`: `feature/phase-<n>-<topic>-backend` and `feature/phase-<n>-<topic>-ui`. BE merges first. See section 7, decision 3.
8. **HANDOFF.md edits:** BE edits sections 1, 3 and 4; UI adds rows to the done table and one bullet under section 4, in a separate small docs commit.
9. All other rules of `docs/HANDOFF.md` section 5 apply to both.
10. **Review (owner decision 2026-11-12, before the commit):** the other line's collaborator is the reviewer: the UI collaborator reviews Backend code, the Backend collaborator reviews UI code. The reviewer works on the same machine and reads the local working tree, not a pushed branch. Order: the author finishes the package and self-reviews (`/code-review`); the owner tells the reviewer to start; the reviewer reads `git status --short`, `git diff HEAD` and any untracked files, and reports findings as a list (file:line, what is wrong, blocking or not) without editing the author's folders; the author fixes and the reviewer re-checks until no blocking finding is left; only then the author hands the owner the commit package, with the review result in it. The author changes nothing while a review runs. The reviewer checks correctness, the repository interface contract, tests and the rules of this file. The owner stays the final approver and the only one who commits and merges.

## 5. Package details

### O0: Phase 1 release (owner)
**Status: DONE 2026-11-12.** Merged into `develop` (rebase-merge, `e145b1b`). Emulator results are in `docs/HANDOFF.md` section 3. The steps below are kept as the record.
Steps:
1. Run the manual list from plan Task 5 Step 7 on an emulator; record each result in the PR description.
2. Push the branch and open the PR into `develop` with the title from plan Task 8.
3. After merge, tell both collaborators to cut their branches from the new `develop`.

### BE1: Phase 2 backend (Collaborator BE)
**Status: not started.** Needs O0 and O1.
Steps:
1. Brainstorm, then write the plan `docs/superpowers/plans/<date>-backend-phase-2-auth.md`: exact SQL for `tb_profil` and the signup trigger (role from the user's choice, never from client-editable metadata alone: ask the owner), RLS, and the `AuthRepository` interface. Stop for the owner's review; UI1 starts from the interface.
2. Create the migration under `supabase/migrations/`, apply it to the dev project, and verify RLS with two `zz-test-` users (a user reads only their own profile).
3. Implement the Supabase `AuthRepository`, a fake for tests, and repository mapping tests with a fake client.
4. Move `SessionController` to the Supabase user model without changing the router redirect rules (`appRedirect` tests must still pass).
Expected: `flutter analyze` 0 errors and 0 warnings from new code; `flutter test` passes; evidence recorded in the hand-over.

### UI1: Phase 2 screens (Collaborator UI)
Deliverable: splash session check, login and register screens that call `AuthRepository` and show Indonesian error messages with retry (spec section 7). Widget test for the login form against the fake. Reuse the phase 1 theme and router; unknown roles must still not enter the app. The owner reviews on an emulator before UI2 starts.

### BE2 to BE4, UI2 to UI4, P6
Not detailed yet: each starts with a plan written after the previous package merges (the spec leaves SQL and RPC to the plans, spec section 9).

## 6. Kickoff prompts (paste into each collaborator's Claude)

- Collaborator BE: "Read `docs/HANDOFF.md` and `docs/WORK-SPLIT.md` in `project_volt`. You are the backend line and own `supabase/`, `lib/features/*/data/`, `lib/data/` and `lib/app/session_controller.dart`. Phase 1 (package O0) is merged. Do not start until I have given you the Supabase dev project (O1) and told you to go. Then start with package BE1 step 1 (plan and `AuthRepository` interface) and stop for my review. Never edit screens, widgets, `lib/core/` or the router, never read `config/supabase.json` or any `.env`, never use the `service_role` key in the app, never commit, tag or push; when a package is ready, review your own diff first, then give me a commit package (files to stage by explicit path, a Conventional Commits message and the CLI to run: `git add <paths>` then `git commit -m "..."`) and I will commit myself, never use `git add -A`. You are also the reviewer of the UI line: when I tell you UI work is ready for review, read the local working tree (`git status --short`, `git diff HEAD`, and any untracked files) and report findings (file:line, what is wrong, blocking or not) without editing UI files."
- Collaborator UI: "Read `docs/HANDOFF.md` and `docs/WORK-SPLIT.md` in `project_volt`. You are the UI line and own screens, widgets, `lib/core/`, `lib/widgets/`, `lib/app/app_router.dart` and `lib/app/app_shell.dart`. Phase 1 (package O0) is merged. Do not start until the `AuthRepository` interface from BE1 step 1 is approved and I tell you to go. Then start with package UI1 against a fake repository and stop for my review after the first screen. Never edit `supabase/`, any `data/` folder or `lib/data/`, never write to or run SQL against the shared Supabase or Firebase project while BE runs a check, never read `config/supabase.json` or any `.env`, never commit, tag or push; when a package is ready, review your own diff first, then give me a commit package (files to stage by explicit path, a Conventional Commits message and the CLI to run: `git add <paths>` then `git commit -m "..."`) and I will commit myself, never use `git add -A`. You are also the reviewer of the BE line: when I tell you BE work is ready for review, read the local working tree (`git status --short`, `git diff HEAD`, and any untracked files) and report findings (file:line, what is wrong, blocking or not) without editing BE files."

## 7. Decisions the owner still has to make

1. Folder layout: the spec targets `lib/features/auth|home|kelas|tugas|simulasi`, but the code still has numbered folders (`0_splash` to `5_simulasi`) and `lib/data/firebase`. DEFAULT until answered: new code goes into the spec's folders; the old numbered folders stay untouched until the phase that replaces them, and the owner decides when to rename.
2. Supabase project: not answered whether a new project exists after the key exposure. DEFAULT: O1 happens before BE1; one dev project only; no staging or production Supabase is assumed.
3. Pull requests: the spec says one PR per phase into `develop`, but two lines work in each phase. DEFAULT: two PRs per phase (BE first, then UI), both into `develop`.
4. Ownership of the simulator: DEFAULT engine, models and `tb_simulasi` repository go to BE (BE4); canvas state and gestures go to UI (UI4). `lib/data/simulation_models.dart` is BE's; UI asks for changes through the owner.
5. Grading screen layout: not designed (spec section 9). The owner mocks it before UI3 starts the grading part.
6. Mockups in `.superpowers/` are git-ignored: the owner shares them with the UI collaborator, or commits copies under `docs/`.
7. Test data prefix `zz-test-`: DEFAULT, not confirmed. Dev sign-in accounts for emulator checks: the owner creates them.
8. Commit signing: not required (DEFAULT).
9. Whether the failing untracked reproduction test may be committed as failing before BE4: DEFAULT no, commit with the fix.
10. ~~How should the collaborators split the work?~~ ANSWERED 2026-11-12: backend line and UI line.
11. ~~Where do `MEMORY.md` and `FLOW.md` live?~~ ANSWERED 2026-11-12: in the repo root, git-ignored (private to each machine).
12. ~~Who commits and tags?~~ ANSWERED 2026-11-12: the owner commits and tags; branch model and Conventional Commits from `README.md`. REVISED 2026-11-12: collaborators only write the commit message and the CLI (a commit package); the owner runs it.
13. ~~Who reviews, and when?~~ ANSWERED 2026-11-12: the collaborators review each other across lines (UI reviews Backend, Backend reviews UI), on the owner's machine and before the owner commits (rule 10); the owner approves and commits.
14. One working directory or two? The reviewer reads the local working tree, but two lines on two branches cannot share one checkout at the same time. OPEN, suggested default: one `git worktree` per line next to the main folder (for example `D:\Code\project_volt-be` and `D:\Code\project_volt-ui`), and the reviewer reads the other line's worktree. Owner to confirm.
15. Android toolchain (package O2): DEFAULT yes, the owner does it before the first emulator review by the UI collaborator. Until then both collaborators use the uncommitted local recipe in `HANDOFF.md` section 3. Owner to confirm, or say who does it.
