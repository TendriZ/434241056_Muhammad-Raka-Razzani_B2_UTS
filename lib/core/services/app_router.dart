import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/helpdesk_home_page.dart';
import '../../features/home/presentation/pages/admin_home_page.dart';
import '../../features/ticket/presentation/pages/create_ticket_page.dart';
import '../../features/ticket/presentation/pages/ticket_detail_page.dart';
import '../../features/notification/presentation/pages/notification_page.dart';

// Provider untuk GoRouter
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/helpdesk',
        name: 'helpdesk_home',
        builder: (context, state) => const HelpdeskHomePage(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin_home',
        builder: (context, state) => const AdminHomePage(),
      ),
      GoRoute(
        path: '/ticket/create',
        name: 'create_ticket',
        builder: (context, state) => const CreateTicketPage(),
      ),
      GoRoute(
        path: '/ticket/detail/:id',
        name: 'detail_ticket',
        builder: (context, state) {
          final ticketId = state.pathParameters['id']!;
          return TicketDetailPage(ticketId: ticketId);
        },
      ),
      GoRoute(
        path: '/notification',
        name: 'notification',
        builder: (context, state) => const NotificationPage(),
      ),
    ],
  );
});


