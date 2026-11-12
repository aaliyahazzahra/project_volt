# Volt handoff: where the work stands and what is next

Written 2026-11-12 by the owner's AI assistant for the next collaborator. Covers `project_volt` (Flutter app, one repository, two work lines: backend and UI).
How a human starts: tell your AI assistant "read `docs/HANDOFF.md`", then say "whats next".
If you are an AI assistant and the user just said "whats next" (or asked you to read this file): read this whole file, run the checks in section 2, then answer with (a) the current state in 3-4 lines, (b) the open actions of section 4 with a recommendation, and (c) ask which one to start. Do not start building before the user picks. The owner keeps private notes (`MEMORY.md`, `FLOW.md` at the repo root, git-ignored) that you do NOT have; everything you need is in this file, `docs/WORK-SPLIT.md` and the committed docs named below.

## 1. What was done (summary)

Volt is a Flutter learning app for lecturers (dosen) and students (mahasiswa). It is being rebuilt in six phases: new look, Supabase instead of Firebase, and a rebuilt logic-gate simulator. Phase 1 (foundation) is finished on a feature branch and not yet merged. The app still runs on Firebase.

| Item | Repo | Version | Commit |
|---|---|---|---|
| Redesign design spec (approved in conversation) | project_volt | unreleased | `d2d6399`, [spec](superpowers/specs/2026-10-05-volt-redesign-design.md) |
| Phase 1 implementation plan | project_volt | unreleased | `b19757c`, [plan](superpowers/plans/2026-10-05-phase-1-foundation.md) |
| Phase 1 foundation: light and dark Material 3 themes (`a887f51`), `SessionController` (`990a744`), `go_router` with login redirect (`93f5878`), 4-tab shell and Beranda placeholder (`5a8a99c`), entry flow through the router (`922cc07`), SQF screens and data code removed (`36526a0`), unused packages removed (`fbe8291`), changelog (`ef14439`), simulasi pop fix (`fbb9df5`). Proven: analyzer and unit tests below. NOT proven: manual checklist on an emulator. | project_volt | unreleased (pubspec `1.0.2+11`) | `fbb9df5` on `feature/redesign-phase-1-foundation` |
| Config out of source: Supabase URL and anon key come from `--dart-define-from-file=config/supabase.json` | project_volt | unreleased | see `CHANGELOG.md` |

Read these before changing anything (all committed): the spec (sections 2 to 8 are the design, section 9 the open items), the phase 1 plan (shows the task style used), `README.md` (setup, branching, backend status table), `CHANGELOG.md`.

## 2. Verify the state first (do not trust this file blindly)

```bash
git log --oneline -6 && git status --short && git tag --sort=-creatordate | head -3
git rev-parse --short develop main && git rev-list --count develop..HEAD
flutter analyze
flutter test
```
Expected at 2026-11-12: branch `feature/redesign-phase-1-foundation`, HEAD `fbb9df5`, last tag `v1.0.2`; `develop` at `7794c86`, `main` at `56f3b1c`; HEAD is 11 commits ahead of `develop`. One file shows as untracked and is NOT yours to touch or commit: `test/features/simulation_logic_test.dart` (the owner's reproduction test for the simulator, to be committed with the bugfix work, spec section 9).
Then run `flutter analyze` (expected: 82 issues, all `info` level, 0 errors, 0 warnings) and `flutter test` (expected: 19 pass, 1 fail). The one failure is the untracked `simulation_logic_test.dart` (a 12-NOT chain listed in reverse order does not settle). That fits spec section 5 bug 4 (fixed 10 passes); the owner has not confirmed it, so ask before treating it as expected.
Ask the owner what staging and production currently run: the release state of environments is not recorded in git. Ask whether the Supabase keys that were committed to history have been rotated.

## 3. Not verified (be honest about these)

- Phase 1 app behavior: unit tests pass, but the manual checklist (plan Task 5 Step 7: splash, login, logout, tabs, back behavior, Kelas, Simulasi, Profil on an emulator) has no recorded result. NOT verified: `flutter run` on a device or emulator.
- Phase 1 delivery: the branch is not on `origin` (the remote has only `main`, `develop` and `chore/project-setup`) and no PR exists. The plan's PR step waits for the owner's approval.
- Supabase: no Supabase-backed feature exists yet except the storage service for materials and submissions. No project, schema, RLS policy or RPC function is verified or recorded. Whether the exposed key was rotated is NOT verified (see `CHANGELOG.md`, Security).
- Firebase flows (register, class, materials, assignments, simulator saving): behavior comes from the 1.0.2 release and the code; no check was run in this setup.
- Test coverage: only data models, theme, router and session controller are unit-tested. Screens and services are not covered.
- Environments: no staging or production is recorded. Whether `v1.0.2` (build 11) was published to Google Play is not recorded.
- `flutter test` can be blocked by Device Guard on some machines (plan, Self-Review Notes). It ran fine on the owner's machine on 2026-11-12.
- Stale generated files at `fbb9df5`: running `flutter analyze` or `flutter test` triggers `flutter pub get`, which rewrites `pubspec.lock` (about 90 lines removed, the packages dropped in `fbe8291`) and the generated plugin registrants under `linux/`, `macos/` and `windows/`. Those changes were reverted on 2026-11-12 and are NOT committed. Ask the owner whether to commit the refreshed lock and registrants with the phase 1 PR; until then, never stage them by accident.

## 4. What is next (priority order; ask the user which)

**Work split:** two lines run in parallel after phase 1 merges: see `docs/WORK-SPLIT.md` (packages, owners, collision rules, kickoff prompts, open decisions).

### A. Release the finished work (owner, no new code)
1. Run the manual checklist of plan Task 5 Step 7 on an emulator, then push `feature/redesign-phase-1-foundation` and open the PR into `develop` (title in plan Task 8: `[FEAT] Fondasi redesign: tema baru, navigasi 4 tab, hapus kode SQF`). Merge it before any phase 2 branch is cut.
2. Rotate the Supabase keys, or create a new Supabase project, because the old anon key is in git history. Put the new values only in `config/supabase.json` (git-ignored).

### B. Build the next piece (each needs brainstorm, spec or plan, then execution)
- Phase 2, auth on Supabase: login, register and splash session. Needs a plan with the exact SQL (`tb_profil`, signup trigger) because the spec leaves SQL to the plan (spec section 9). Packages BE1 and UI1 in `WORK-SPLIT.md`.
- Phases 3 to 5 in spec order (classes, then materials and assignments and grading, then simulator rebuild), then phase 6 cleanup.
- Commit the simulator reproduction test together with the engine fix (BE4).

### C. Reminders for later
- Phase 6: remove Firebase completely (`lib/firebase_options.dart`, `android/app/google-services.json`, Firebase packages), update the backend status table in `README.md`.
- The release date of `1.0.2` is not recorded; add it to `CHANGELOG.md` when known.
- The `.superpowers/` folder holds brainstorm mockups (`home-layout-v2`, `class-detail`, `assignment-detail`, `lecturer-kelas-tab`, `simulator-layout`) and is git-ignored. Mockups are not in git; ask the owner for them before building those screens.

### D. Parked (owner decides; ask before starting)
- Dark theme wiring (the dark `ColorScheme` is built, not used).
- Offline downloads with SQLite (`sqflite` was removed in phase 1 and returns with that feature).
- A custom font.
- Grading screen layout (not mocked yet; needed before the grading part of phase 4).

## 5. How this project is worked (rules the owner set)

- Commits: the owner commits and tags. Agents and collaborators never commit, tag or push. After each finished unit they hand the owner a **commit package**: the files to stage (explicit paths), one Conventional Commits message (subject, plus a body when needed) and the exact CLI block to paste (`git add <paths>` then `git commit -m "..."`, plus `git tag` or `git push` lines when relevant). The owner reads it, runs it, and is the only one who commits. Never `git add -A` or `git add .`. Branch model from `README.md`: `main` released, `develop` integration, working branches `feature/<name>`, `refactor/<name>`, `fix/<name>`, `chore/<name>`, `docs/<name>`. Conventional Commits. No signing required (default; owner can change). The untracked `test/features/simulation_logic_test.dart` is excluded from every commit until BE4.
- Review (owner decision 2026-11-12): collaborators review each other across lines, before the owner commits; the UI collaborator reviews Backend code and the Backend collaborator reviews UI code. The reviewer works on the same machine and reads the local working tree (`git status --short`, `git diff HEAD`, untracked files), reports findings without editing the author's folders, and the author fixes until no blocking finding is left. The author self-reviews first (`/code-review`). Then the owner gets the commit package, with the review result in it. Details: `WORK-SPLIT.md` rule 10.
- Never read or print `.env*` or `config/supabase.json`, and never let a subagent do so. Never put the Supabase `service_role` or secret key in this project. Do not edit `android/key.properties`, `android/app/release-key.jks`, `lib/firebase_options.dart` or `android/app/google-services.json` (Firebase files stay until phase 6). No ports are reserved (Flutter app, no local server); the Flutter SDK is at `D:\Code\flutter`.
- Language: the app UI is Indonesian; code comments are mixed Indonesian and English; `CHANGELOG.md`, `README.md`, specs, plans and these documents are English. PR titles follow the plan style (`[FEAT] ...`, Indonesian).
- Database: Supabase Postgres from phase 2, none yet. Naming follows the company database SOP (`tb_` prefix, snake_case; spec section 6). Every table has `created_at/by`, `updated_at/by`, `deleted_at/by` and RLS. Multi-table reads go through Postgres functions called by RPC. The exact SQL lives in each phase plan.
- Test data: prefix `zz-test-` (example: `zz-test-mhs1@example.com`, class code `ZZ-TEST-01`); delete by exact id after a SELECT review; never a bulk delete without inspecting the matches first. This is a default the owner has not confirmed (see `WORK-SPLIT.md` section 7).
- Standards: the spec (`docs/superpowers/specs/`), `README.md`, and the company SOPs for git and database design. Every PR passes `flutter analyze` (0 errors, 0 warnings) and `flutter test`, plus the manual checklist on an emulator before merge (spec section 7).
- Dev sign-in for emulator checks: use accounts with the test prefix that the owner creates; never print or store a password in a document or chat.
- After each unit of work, record it in the owner's notes and, for committed knowledge, in the repo docs (this file, `CHANGELOG.md`, specs and plans). Update sections 1 and 4 of THIS file whenever you finish an item.
