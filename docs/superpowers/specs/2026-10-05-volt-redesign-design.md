# Volt Redesign: Design Spec

Date: 2026-10-05
Status: Approved in conversation, pending user review of this file
Repository: `aaliyahazzahra/project_volt` (GitHub)

## 1. Goal

Rebuild Volt, a Flutter learning app for lecturers (dosen) and students (mahasiswa), so it:

- looks modern instead of boring (clean light Material 3 now, dark tech style later),
- moves from Firebase to Supabase as its only backend, starting fresh with no user data migration,
- rebuilds the logic-gate simulator as a phone-first, full-screen canvas, and fixes its known bugs.

Out of scope for this spec: the dark theme itself, the grading screen layout (not mocked yet), and offline downloads with SQLite (planned later).

## 2. Architecture

Feature-first structure:

```
lib/
├── app/            app entry, router, role-based home
├── core/           theme (light now, dark later), shared widgets, constants
└── features/
    ├── auth/
    ├── home/       beranda for students and lecturers
    ├── kelas/      classes, members, class page tabs
    ├── tugas/      materials, assignments, submissions
    └── simulasi/   engine (pure Dart), canvas, toolbar
```

- **Navigation:** `go_router` with a bottom bar: Beranda, Kelas, Simulasi, Profil. The router sends each user to the home for their role.
- **State:** `Provider`, which the project already uses. No new state library.
- **Backend access:** only repository classes in each feature's `data/` folder call Supabase. Screens never call Supabase directly. This keeps the migration contained and lets screens be tested with fake repositories.
- **Simulator engine:** pure Dart, with no Flutter or Supabase imports, so it can be unit-tested directly.

## 3. Visual system

- **Colors:** Material 3 with seed `#6750a4`. Light and dark `ColorScheme`s are both built from the seed; only light is wired up now.
- **Surfaces:** soft off-white background, white cards with 16px radius, faint shadow, no hard borders.
- **Class colors:** each class stores a tint index, so its color is the same on every screen.
- **Typography:** default Flutter font for now. A custom font can be added later without a new dependency.
- **Spacing:** 16px side margins, 8px grid.
- **Shared widgets** in `core/widgets/`: `SummaryCard`, `ClassCard`, `DeadlineTile`, `StatusChip`, `PrimaryButton`.
- **Motion:** simple fades and page transitions only.

## 4. Screens and navigation

Start: splash → login or register → home for the user's role.

**Student**
- **Beranda:** deadlines ("Tenggat terdekat") at the top, then classes ("Kelas saya") as cards. Mockup: `home-layout-v2`.
- **Kelas:** class list with **+ Gabung kelas**, which opens a form to enter the lecturer's class code. Tapping a class opens the class page with tabs Info, Materi, Tugas, Anggota (option A, tabs at the top). Tapping a task opens the assignment screen (option A, status card with submit button at the bottom). Mockups: `class-detail`, `assignment-detail`.
- **Simulasi:** list of saved circuits with **+ Baru**. Tapping one opens the full-screen canvas.
- **Profil:** name, role, edit profile, about, logout.

**Lecturer**
- **Beranda:** a summary card with the number of submissions to grade, then classes in a two-column grid. Tapping the card opens the submission list (assumed from option B), and tapping a submission opens the grading screen.
- **Kelas:** class list with **+ Buat kelas**, which opens the create form (name, auto-generated code such as `LD-2026-C`, optional description). The class page has the same four tabs plus buttons to add materials and assignments. Mockup: `lecturer-kelas-tab`.
- **Simulasi** and **Profil:** same as the student's.

**Full-screen canvas:** opening a circuit hides the bottom bar. The canvas has a floating **+** button (option B) for adding components, and a back button returns to the list. Mockup: `simulator-layout` (option B).

**Assumption:** the grading screen shows the submitted work (including a student's circuit when it's a simulation), a score field, and feedback. Not mocked yet.

## 5. Simulator

**Engine (pure Dart):**
- Takes a circuit and returns new output values. It never edits the circuit it was given.
- Recalculates until outputs stop changing, with a cap so feedback loops can't hang the app. Replaces the current fixed 10 passes.
- Works on a snapshot and returns results keyed by component ID.

**Canvas state:**
- Each circuit has its own state, identified by its ID. A result always goes back to the circuit it was calculated for, never to whichever tab is open.
- A change made during a run is not dropped. The app queues one more run with the latest state.
- A result only updates output values. It never replaces the user's inputs or wires.

**Tap to connect:**
- Tap an output, then tap an input to draw a wire. Tapping an input that already has a wire replaces it.
- Tap empty space to cancel. Long-press a wire to delete it.

**Truth table:** generated for the INPUT components, up to 4 inputs (16 rows). Each row is an engine run in a background isolate.

**Saving:** each circuit is one JSON document in `tb_simulasi`, using the existing `toMap` format. Coordinates are read as numbers, so whole values like `100` don't crash.

**Bugs this design fixes** (found in the current code):
1. A run overwrites the canvas with a snapshot taken before the run, reverting input toggles and wire changes made during it.
2. A run finishing after a tab switch writes into the wrong circuit.
3. Requests made during a run are dropped, so a newly opened tab isn't simulated.
4. Fixed 10 passes give wrong outputs for longer circuits in unlucky component order.
5. Number parsing can crash on whole-number coordinates after the Supabase move.

## 6. Data layer (Supabase)

**Naming:** follows the company SOP (`tb_` prefix, snake_case), adapted for Postgres.

**Auth:** Supabase email and password. A trigger creates a `tb_profil` row on signup, using the role the user picked.

**Tables:**
- `tb_profil`: name, role (dosen or mahasiswa), NIM or NIDN, linked to the auth user
- `tb_kelas`: name, unique class code, description, color index, lecturer
- `tb_anggota_kelas`: which students are in which class
- `tb_materi`: materials per class, with file path
- `tb_tugas`: assignments per class, with deadline and optional circuit reference
- `tb_simulasi`: saved circuits as one JSON document
- `tb_submisi`: student submissions with grade and feedback

Every table has `created_at/by`, `updated_at/by`, and `deleted_at/by`.

**Row Level Security (on every table):**
- Students see only classes they've joined, and only their own submissions.
- Lecturers manage only classes they own, and see submissions for those classes.
- No user can read another student's submission.

**Storage:** two private buckets, `app-materi` and `app-submisi`. Files are shared through short-lived signed URLs only.

**Joins:** multi-table reads go through Postgres functions called via RPC, as the SOP asks for joins to live in stored procedures.

**Keys:** the app uses only the publishable key, supplied through `--dart-define-from-file`. The secret key never goes into the app or the repo.

## 7. Errors and testing

**Errors:**
- Network failures show a clear Indonesian message with a retry button. No silent failures.
- An expired session returns the user to login.
- Uploads run in two steps. If saving the row fails, the uploaded file is removed.
- Forms validate input before sending. A duplicate class code shows a specific message.
- A failing simulator run keeps the circuit as it was and shows "Simulasi gagal dijalankan".

**Testing:**
- Unit tests: simulator engine (gate chains in any order, feedback loops, truth table), models, and repository mapping with a fake client.
- Widget tests: login form, summary card, status chip.
- Canvas tests: a switch flipped during a run stays flipped; a tab switch during a run updates the correct circuit.
- Manual checklist on a phone emulator before each phase's PR is merged.
- Every PR passes `flutter analyze` (0 errors, 0 warnings) and `flutter test`.

## 8. Delivery

Six phases, one PR each into `develop`:

1. **Foundation:** theme, router, bottom bar. Delete the SQF folders. The app still runs on Firebase.
2. **Auth on Supabase:** login, register, splash session.
3. **Classes and membership:** create class (lecturer), join class (student), class page tabs.
4. **Materials, assignments, submissions:** uploads, deadlines, grading.
5. **Simulator rebuild:** engine, canvas with tap-to-connect, truth table, saving to Supabase.
6. **Cleanup:** remove Firebase completely, including `firebase_options.dart` and `google-services.json`, then polish.

## 9. Open items

- The grading screen layout is not designed yet.
- Dark theme is planned but not in scope.
- The exact SQL, RLS policies, and RPC functions will be written in the implementation plan, not here.
- `test/features/` (the simulator reproduction test) is untracked and will be committed with the bugfix work.
