import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_volt/app/app_shell.dart';
import 'package:project_volt/app/session_controller.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/features/0_splash/Firebase/splash_screen_firebase.dart';
import 'package:project_volt/features/1_auth/Firebase/authenticator_firebase.dart';
import 'package:project_volt/features/2_dashboard/Firebase/homepage_dosen_firebase.dart';
import 'package:project_volt/features/2_dashboard/Firebase/homepage_mhs_firebase.dart';
import 'package:project_volt/features/3_profile/Firebase/profile_page_firebase.dart';
import 'package:project_volt/features/5_simulasi/create_simulasi_firebase_page.dart';
import 'package:project_volt/features/home/beranda_page.dart';
import 'package:provider/provider.dart';

/// The signed-in user. Only called below the redirect, so it is never null.
UserFirebaseModel _currentUser(BuildContext context) {
  return context.read<SessionController>().user!;
}

/// Dosen and mahasiswa share the Kelas tab but see different class lists.
Widget _kelasPage(BuildContext context) {
  final user = _currentUser(context);
  if (user.role == 'dosen') {
    return HomepageDosenFirebase(user: user);
  }
  return HomepageMhsFirebase(user: user);
}

/// Decides whether [location] must be redirected for the current session.
/// Returns the path to go to, or null to stay where we are.
String? appRedirect(String location, SessionController session) {
  final isPublic = location == '/splash' || location == '/login';
  if (!session.isSignedIn) {
    return isPublic ? null : '/login';
  }
  if (location == '/login') {
    return '/beranda';
  }
  return null;
}

GoRouter buildAppRouter(SessionController session) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: session,
    redirect: (context, state) => appRedirect(state.matchedLocation, session),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashScreenFirebase(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthenticatorFirebase(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/beranda',
                builder: (context, state) =>
                    BerandaPage(user: _currentUser(context)),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/kelas',
                builder: (context, state) => _kelasPage(context),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/simulasi',
                builder: (context, state) =>
                    CreateSimulasiFirebasePage(user: _currentUser(context)),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profil',
                builder: (context, state) =>
                    ProfilePageFirebase(user: _currentUser(context)),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
