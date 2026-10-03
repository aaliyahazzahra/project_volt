# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project follows [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- `README.md` with setup, run, test, and branching instructions.
- `CHANGELOG.md`.
- `config/supabase.example.json` template. Supabase URL and anon key are read from `--dart-define-from-file=config/supabase.json`.
- Unit tests for `SimulationComponent` (`test/data/simulation_component_test.dart`).
- Unit tests for `TugasFirebaseModel.fromMap` (`test/data/tugas_firebase_model_test.dart`).

### Changed
- Supabase URL and anon key are no longer hardcoded in `lib/main.dart`. The app fails fast at startup if they are missing.
- `.gitignore` now ignores `config/supabase.json` and `.env` files.

### Removed
- The default counter test in `test/widget_test.dart`. It did not match the app and could not pass.

### Security
- Supabase keys were committed to git history before this change. Treat the old anon key as exposed and create a new Supabase project or rotate keys.

## [1.0.2]

Version from `pubspec.yaml` (`1.0.2+11`). Release date is not recorded in the repository.

### Added
- Splash, login, and register screens with Firebase Auth.
- Dashboards for lecturers and students, with bottom navigation.
- Class management: create, edit, class detail, members.
- Materials and assignments, with submission upload through Supabase Storage.
- Logic-gate simulation module (`5_simulasi`).
- Local SQLite version of the screens (`SQF/`), not used by the current entry point.
- Profile and about pages.

[Unreleased]: https://github.com/aaliyahazzahra/project_volt/compare/v1.0.2...HEAD
[1.0.2]: https://github.com/aaliyahazzahra/project_volt/releases/tag/v1.0.2
