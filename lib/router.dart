@JS('document')
library;

import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';

import 'views/contribution_tracking_page.dart';
import 'views/loan_management_page.dart';
import 'views/login_page.dart';
import 'views/member_management_page.dart';
import 'views/not_found_page.dart';
import 'views/reports_page.dart';

@JS('title')
external set documentTitle(String title);

final GoRouter router = GoRouter(
  initialLocation: '/login',
  refreshListenable: AuthChangeNotifier(),
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = Hive.box('auth').containsKey('status');
    final bool loggingIn = state.uri.path == '/login';
    if (!loggedIn) return loggingIn ? null : '/login';
    if (loggingIn) return '/member-management';
    return null;
  },
  routes: <RouteBase>[
    GoRoute(path: '/login', builder: (BuildContext context, GoRouterState state) {
      documentTitle = 'Sinking Fund Manager';
      return const LoginPage();
    }),
    GoRoute(
      path: '/member-management',
      builder: (BuildContext context, GoRouterState state) {
        documentTitle = 'Member Management';
        return const MemberManagementPage();
      },
    ),
    GoRoute(
      path: '/contribution-tracking',
      builder: (BuildContext context, GoRouterState state) {
        documentTitle = 'Contribution Tracking';
        return const ContributionTrackingPage();
      },
    ),
    GoRoute(
      path: '/loan-management',
      builder: (BuildContext context, GoRouterState state) {
        documentTitle = 'Loan Management';
        return const LoanManagementPage();
      },
    ),
    GoRoute(
      path: '/reports',
      builder: (BuildContext context, GoRouterState state) {
        documentTitle = 'Reports';
        return const ReportsPage();
      },
    ),
  ],
  errorBuilder: (BuildContext context, GoRouterState state) {
    documentTitle = 'Not Found';
    return const NotFoundPage();
  },
);

/// [AuthChangeNotifier] is a simple ChangeNotifier that notifies the router when auth status changes.
class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier() {
    Hive.box('auth').listenable().addListener(notifyListeners);
  }
}
