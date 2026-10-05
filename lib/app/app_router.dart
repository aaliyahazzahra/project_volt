import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_volt/app/session_controller.dart';
import 'package:project_volt/features/0_splash/Firebase/splash_screen_firebase.dart';
import 'package:project_volt/features/1_auth/Firebase/authenticator_firebase.dart';

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
      // Placeholder shell until Task 4 adds the bottom bar and real pages.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => navigationShell,
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/beranda',
                builder: (context, state) => const Placeholder(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/kelas',
                builder: (context, state) => const Placeholder(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/simulasi',
                builder: (context, state) => const Placeholder(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profil',
                builder: (context, state) => const Placeholder(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
