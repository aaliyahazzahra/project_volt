# Phase 1: Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the app's theme, navigation, and entry flow with the new design, delete the SQF (local SQLite) code, and keep the app running on Firebase.

**Architecture:** A `SessionController` (Provider) holds the signed-in user. `go_router` redirects signed-out users to login and sends signed-in users to a 4-tab shell (Beranda, Kelas, Simulasi, Profil). The Kelas, Simulasi, and Profil tabs reuse the existing Firebase screens, and Beranda is a placeholder until phase 3.

**Tech Stack:** Flutter (SDK at `D:\Code\flutter`), Dart 3.9+, `provider`, `go_router` (added in this phase), `firebase_auth`, `cloud_firestore`.

**Spec:** `docs/superpowers/specs/2026-10-05-volt-redesign-design.md` (sections 2, 3, 4 for the screen structure, 8 for phase 1).

## Global Constraints

- Seed color `#6750A4` (`Color(0xFF6750A4)`) is the only color source for the light theme.
- Dark theme is built but not used: `themeMode: ThemeMode.light`.
- Tab labels, in order: `Beranda`, `Kelas`, `Simulasi`, `Profil`.
- Route paths: `/splash`, `/login`, `/beranda`, `/kelas`, `/simulasi`, `/profil`.
- Login success goes to `/beranda`. A signed-out user is redirected to `/login`.
- No Supabase changes in this phase. Login stays on Firebase Auth.
- All UI text stays in Indonesian.
- Run `flutter analyze` and `flutter test --dart-define-from-file=config/supabase.json` before each commit.

## Review Focus

1. A signed-out user who opens `/kelas` directly is sent to `/login`, not to an error screen. (Task 3)
2. After an app restart with a valid saved login, the app opens the role's home without asking for login again. (Task 5, manual)
3. A saved user whose role is unknown ends up on login, not on an empty tab. (Task 5, manual)
4. A phone set to dark mode still shows the light theme, because `themeMode` is fixed to light. (Task 1 test, Task 5 manual)
5. The Android back button on any tab goes to Beranda before it leaves the app. (Task 4, manual)

---

## File Structure

- Create `lib/core/theme/app_theme.dart`: light and dark `ThemeData`, one seed color.
- Create `lib/app/session_controller.dart`: current user and sign-in state.
- Create `lib/app/app_router.dart`: `appRedirect` function and `buildAppRouter`.
- Create `lib/app/app_shell.dart`: the 4-tab bottom bar.
- Create `lib/features/home/beranda_page.dart`: placeholder Beranda with a greeting.
- Modify `lib/main.dart`: `MaterialApp.router`, theme, and session provider.
- Modify `lib/features/0_splash/Firebase/splash_screen_firebase.dart`: set the session and navigate with the router.
- Modify `lib/features/1_auth/Firebase/login_form_firebase.dart`: set the session and navigate with the router.
- Modify `lib/features/3_profile/Firebase/profile_page_firebase.dart`: logout clears the session.
- Delete the SQF-era files and the two old bottom nav files (Task 6 and Task 5).
- Modify `pubspec.yaml`: add `go_router`, remove unused packages (Task 7).

---

### Task 1: Light and dark theme

**Files:**
- Create: `lib/core/theme/app_theme.dart`
- Test: `test/core/theme/app_theme_test.dart`

**Interfaces:**
- Produces: `const Color kVoltSeed`, `ThemeData buildLightTheme()`, `ThemeData buildDarkTheme()`. Used by Task 5.

- [ ] **Step 1: Write the failing test**

```dart
test('light theme uses the Volt seed color', () {
  final theme = buildLightTheme();
  expect(theme.brightness, Brightness.light);
  expect(theme.colorScheme.primary,
      ColorScheme.fromSeed(seedColor: kVoltSeed).primary);
});

test('dark theme is built from the same seed', () {
  final theme = buildDarkTheme();
  expect(theme.brightness, Brightness.dark);
  expect(theme.colorScheme.primary,
      ColorScheme.fromSeed(seedColor: kVoltSeed, brightness: Brightness.dark).primary);
});
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/theme/app_theme_test.dart`
Expected: FAIL, `buildLightTheme` is not defined.

- [ ] **Step 3: Implement the theme**

Create `app_theme.dart` with `kVoltSeed = Color(0xFF6750A4)`. Each builder returns `ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: kVoltSeed, brightness: ...), scaffoldBackgroundColor: ...)`. Use an off-white background (`#FAFAFB`) for light and the default dark surface for dark. Set card theme to 16px radius and no elevation.

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/core/theme/app_theme_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/theme/app_theme.dart test/core/theme/app_theme_test.dart
git commit -m "feat(theme): add light and dark Material 3 themes"
```

---

### Task 2: Session controller

**Files:**
- Create: `lib/app/session_controller.dart`
- Test: `test/app/session_controller_test.dart`

**Interfaces:**
- Produces: `class SessionController extends ChangeNotifier` with `UserFirebaseModel? get user`, `bool get isSignedIn`, `void signIn(UserFirebaseModel user)`, `void signOut()`. Used by Tasks 3, 5.

- [ ] **Step 1: Write the failing test**

```dart
test('signIn stores the user and notifies listeners', () {
  final session = SessionController();
  var notified = 0;
  session.addListener(() => notified++);
  session.signIn(testUser);
  expect(session.isSignedIn, isTrue);
  expect(session.user, testUser);
  expect(notified, 1);
});

test('signOut clears the user', () {
  final session = SessionController()..signIn(testUser);
  session.signOut();
  expect(session.isSignedIn, isFalse);
  expect(session.user, isNull);
});
```

`testUser` is `UserFirebaseModel(uid: 'u1', namaLengkap: 'Aaliyah', email: 'a@x.id', role: 'mahasiswa')`.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/app/session_controller_test.dart`
Expected: FAIL, `SessionController` is not defined.

- [ ] **Step 3: Implement the controller**

Hold a nullable `UserFirebaseModel` in a private field. `signIn` sets it and calls `notifyListeners()`. `signOut` clears it and notifies.

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/app/session_controller_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/app/session_controller.dart test/app/session_controller_test.dart
git commit -m "feat(app): add session controller for the signed-in user"
```

---

### Task 3: Router and redirect rules

**Files:**
- Create: `lib/app/app_router.dart`
- Modify: `pubspec.yaml` (add `go_router` with `flutter pub add go_router`)
- Test: `test/app/app_router_test.dart`

**Interfaces:**
- Consumes: `SessionController` (Task 2).
- Produces: `String? appRedirect(String location, SessionController session)` and `GoRouter buildAppRouter(SessionController session)`. `buildAppRouter` is used by Task 5 and its routes use the page builders from Tasks 4 and 5.

- [ ] **Step 1: Write the failing test**

```dart
test('signed-out user going to /kelas is sent to /login', () {
  final session = SessionController();
  expect(appRedirect('/kelas', session), '/login');
});

test('signed-out user on /splash stays on /splash', () {
  final session = SessionController();
  expect(appRedirect('/splash', session), isNull);
});

test('signed-in user on /login is sent to /beranda', () {
  final session = SessionController()..signIn(testUser);
  expect(appRedirect('/login', session), '/beranda');
});

test('signed-in user on /kelas stays put', () {
  final session = SessionController()..signIn(testUser);
  expect(appRedirect('/kelas', session), isNull);
});
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/app/app_router_test.dart`
Expected: FAIL, `appRedirect` is not defined.

- [ ] **Step 3: Implement the redirect and router**

`appRedirect` implements the four cases above. `buildAppRouter(session)` returns a `GoRouter` with `initialLocation: '/splash'`, `refreshListenable: session`, and `redirect: (context, state) => appRedirect(state.matchedLocation, session)`. Declare `/splash` and `/login` as plain routes, and the four tab paths under a `StatefulShellRoute.indexedStack` whose builder is `AppShell` (Task 4). Leave the tab page builders as `Placeholder()` until Tasks 4 and 5 fill them in.

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/app/app_router_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/app/app_router.dart test/app/app_router_test.dart pubspec.yaml pubspec.lock
git commit -m "feat(app): add go_router with login redirect"
```

---

### Task 4: Bottom bar shell and Beranda placeholder

**Files:**
- Create: `lib/app/app_shell.dart`
- Create: `lib/features/home/beranda_page.dart`
- Test: `test/features/home/beranda_page_test.dart`

**Interfaces:**
- Consumes: `UserFirebaseModel` (existing).
- Produces: `class AppShell extends StatelessWidget` with `StatefulNavigationShell navigationShell` (used by Task 3). `class BerandaPage extends StatelessWidget` with `UserFirebaseModel user` (used by Task 5).

- [ ] **Step 1: Write the failing test**

```dart
testWidgets('Beranda greets the user by name', (tester) async {
  await tester.pumpWidget(MaterialApp(home: BerandaPage(user: testUser)));
  expect(find.text('Halo, Aaliyah'), findsOneWidget);
});
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/home/beranda_page_test.dart`
Expected: FAIL, `BerandaPage` is not defined.

- [ ] **Step 3: Implement the shell and Beranda**

`BerandaPage`: a `Scaffold` with a greeting `Halo, {namaLengkap}` and a card with the text "Beranda segera hadir", which phase 3 replaces. `AppShell`: a `Scaffold` with `NavigationBar` and four `NavigationDestination`s with the labels from Global Constraints. Its `body` is `navigationShell`. Tapping a destination calls `navigationShell.goBranch(index)`.

Wire the four branches in `app_router.dart` with these page builders: `/beranda` → `BerandaPage(user: session.user!)`, `/kelas` → `HomepageMhsFirebase` for `mahasiswa` and `HomepageDosenFirebase` for `dosen`, `/simulasi` → `CreateSimulasiFirebasePage(user: ...)`, `/profil` → `ProfilePageFirebase(user: ...)`. Each builder reads the user from the session. The `!` is safe because the redirect blocks signed-out users.

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/home/beranda_page_test.dart`
Expected: PASS

- [ ] **Step 5: Manual check of the tabs (covers Review Focus 5)**

Run the app and sign in. Expected: four tabs appear, the back button on a non-Beranda tab goes to Beranda, and a second back press leaves the app.

- [ ] **Step 6: Commit**

```bash
git add lib/app/app_shell.dart lib/app/app_router.dart lib/features/home/beranda_page.dart test/features/home/beranda_page_test.dart
git commit -m "feat(app): add 4-tab bottom bar and Beranda placeholder"
```

---

### Task 5: Connect the entry flow to the router

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/features/0_splash/Firebase/splash_screen_firebase.dart`
- Modify: `lib/features/1_auth/Firebase/login_form_firebase.dart`
- Modify: `lib/features/3_profile/Firebase/profile_page_firebase.dart`
- Delete: `lib/features/2_dashboard/Firebase/bottom_nav_mhs_firebase.dart`, `lib/features/2_dashboard/Firebase/bottom_nav_dosen_firebase.dart`

**Interfaces:**
- Consumes: `buildLightTheme`, `buildDarkTheme` (Task 1), `SessionController` (Task 2), `buildAppRouter` (Task 3).

- [ ] **Step 1: Wire `main.dart`**

Keep the existing Firebase and Supabase initialization. Replace `MaterialApp(home: SplashScreenFirebase())` with `ChangeNotifierProvider(create: (_) => SessionController(), child: Builder(...))`, where the builder builds `MaterialApp.router(routerConfig: buildAppRouter(session), theme: buildLightTheme(), darkTheme: buildDarkTheme(), themeMode: ThemeMode.light, debugShowCheckedModeBanner: false)`. Create the router once, not on each build.

- [ ] **Step 2: Update the splash flow**

In `splash_screen_firebase.dart`, replace the branch that chose `BottomNavMhsFirebase` or `BottomNavDosenFirebase` with: if the saved session is valid and the role is `mahasiswa` or `dosen`, call `session.signIn(savedUser)`. Then call `context.go(session.isSignedIn ? '/beranda' : '/login')`. Remove `_navigateAndRemove`, the `Navigator.pushAndRemoveUntil` call, and the `dynamic` `nextPage` variable. Check `mounted` before using `context`.

(Covers Review Focus 2 and 3.)

- [ ] **Step 3: Update the login flow**

In `login_form_firebase.dart`, replace the `nextScreen` and `Navigator.pushReplacement` block with `context.read<SessionController>().signIn(user)` followed by `context.go('/beranda')`. Remove the imports of the two old bottom nav files. Keep the `else { return; }` case for unknown roles.

- [ ] **Step 4: Update logout**

In `profile_page_firebase.dart` around line 66, replace the `Navigator.push` to `AuthenticatorFirebase` with `context.read<SessionController>().signOut()` followed by `context.go('/login')`. Keep the existing Firebase sign-out call.

- [ ] **Step 5: Create the login route**

Point `/login` in `app_router.dart` at `AuthenticatorFirebase()`. The file already exists.

- [ ] **Step 6: Delete the old bottom nav files**

Run: `git rm lib/features/2_dashboard/Firebase/bottom_nav_mhs_firebase.dart lib/features/2_dashboard/Firebase/bottom_nav_dosen_firebase.dart`

- [ ] **Step 7: Verify**

Run: `flutter analyze`
Expected: 0 errors. Warnings may appear only if they already existed before this task.

Run: `flutter run --dart-define-from-file=config/supabase.json` and check the manual list below. Each item covers a Review Focus line.

- [ ] Sign in as a student: four tabs appear, Beranda shows the greeting. (Focus 2)
- [ ] Sign in as a lecturer: four tabs appear. (Focus 2)
- [ ] Close and reopen the app while still signed in: it opens the role's home. (Focus 2)
- [ ] Open the app with a saved user whose role isn't `mahasiswa` or `dosen`: it opens login. (Focus 3)
- [ ] Set the phone to dark mode: the app stays light. (Focus 4)
- [ ] Log out from Profil: it returns to login, and a second back press doesn't return to the app. (Focus 1)

- [ ] **Step 8: Commit**

```bash
git add lib/main.dart lib/features/0_splash/Firebase/splash_screen_firebase.dart lib/features/1_auth/Firebase/login_form_firebase.dart lib/features/3_profile/Firebase/profile_page_firebase.dart lib/features/2_dashboard/Firebase/
git commit -m "feat(app): route entry, login and logout through go_router"
```

---

### Task 6: Delete the SQF-era code

**Files:**
- Delete the folders `lib/data/SQF/`, `lib/core/utils/SQF/`, `lib/features/0_splash/SQF/`, `lib/features/1_auth/SQF/`, `lib/features/2_dashboard/SQF/`, `lib/features/3_profile/SQF/`, `lib/features/4_kelas/view/SQF/`, `lib/features/4_kelas/widgets/SQF/`
- Delete these top-level files, which only SQF-era code imports (checked by grep before writing this plan):
  - `lib/data/auth_data_source.dart`
  - `lib/data/kelas_data_source.dart`
  - `lib/features/4_kelas/view/class_detail_page.dart`, `create_class_page.dart`, `create_materi_page.dart`, `create_tugas_page.dart`, `edit_class_page.dart`, `edit_tugas_page.dart`, `tugas_detail_dosen.dart`, `tugas_detail_mhs.dart`
  - `lib/features/3_profile/widgets/profile_header_card.dart`
  - `lib/widgets/rolebutton.dart`

**Interfaces:** none. This task only removes code.

- [ ] **Step 1: Check each candidate is unused**

For each file in the list above, run `grep -rln "<file name>" lib`. Expected: the only hits are the file itself or other files in the delete list. Keep any file that a Firebase-named file imports, and note it for the report.

- [ ] **Step 2: Delete the files**

Use `git rm -r` for the folders and `git rm` for the files.

- [ ] **Step 3: Verify no broken imports**

Run: `flutter analyze`
Expected: 0 errors. Any "Target of URI doesn't exist" error means a deleted file is still imported. Restore that file and note it.

Run: `grep -rn "SQF\|sqflite" lib`
Expected: no hits.

- [ ] **Step 4: Commit**

```bash
git commit -m "refactor: remove SQF (local SQLite) screens and data code"
```

Commit message body: list the removed folders and say SQLite will return in the offline-downloads phase.

---

### Task 7: Remove unused packages

**Files:**
- Modify: `pubspec.yaml`, `pubspec.lock`

**Interfaces:** none.

Verified before this plan was written: `circle_nav_bar`, `persistent_bottom_nav_bar_v2`, `animated_gradient`, and `animated_gradient_box` have no imports. `sqflite` was used only by the SQF code removed in Task 6. `bottom_bar_matu` was used by the two bottom nav files removed in Task 5.

- [ ] **Step 1: Confirm each package has no imports**

For each package below, run `grep -rln "package:<name>/" lib`. Expected: no output.
`circle_nav_bar`, `persistent_bottom_nav_bar_v2`, `animated_gradient`, `animated_gradient_box`, `sqflite`, `bottom_bar_matu`

- [ ] **Step 2: Remove them**

Run `flutter pub remove <name>` for each package that passed step 1.

- [ ] **Step 3: Verify**

Run: `flutter pub get` then `flutter analyze`
Expected: 0 errors.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "build: remove packages no longer used after the redesign"
```

---

### Task 8: Final verification and PR

- [ ] **Step 1: Run every check**

Run: `flutter analyze` → expected 0 errors, 0 warnings from new code.
Run: `flutter test --dart-define-from-file=config/supabase.json` → expected all tests pass.
Run the manual list from Task 5, Step 7 → every item passes.

- [ ] **Step 2: Update the CHANGELOG**

Under `[Unreleased]`, add to `Changed`: the new theme and the 4-tab navigation. Under `Removed`: the SQF screens and the unused packages.

- [ ] **Step 3: Commit the changelog**

```bash
git add CHANGELOG.md
git commit -m "docs: changelog for phase 1 foundation"
```

- [ ] **Step 4: Open the PR (after the user approves)**

Branch: `feature/redesign-phase-1-foundation` from `develop`. PR title: `[FEAT] Fondasi redesign: tema baru, navigasi 4 tab, hapus kode SQF`. Description: summary of Tasks 1 to 7, plus the manual checklist results.

---

## Self-Review Notes

- Spec coverage: section 2 (architecture) → Tasks 2, 3. Section 3 (visual system) → Task 1. Section 4 (screens, Beranda placeholder, shell) → Tasks 4, 5. Section 8 phase 1 (theme, router, bottom bar, delete SQF, stay on Firebase) → all tasks.
- Deviation from the spec: the spec's phase 1 lists "shared widget stubs". They are not in this plan, because no screen uses them until phases 3 and 4. Adding them now would be unused code.
- Deviation: the SQF deletion is verified by grep and `flutter analyze`, not by `flutter test`, because `flutter test` can be blocked on some machines (Device Guard). Task 5 has a manual check for that reason.
