/// Route Configuration untuk Ticket Feature
import 'package:flutter/material.dart';
import '../presentation/screens/ticket_list_screen.dart';
import '../presentation/screens/create_ticket_screen.dart';
import '../presentation/screens/ticket_detail_screen.dart';
import '../presentation/screens/dashboard_screen.dart';

class TicketRoutes {
  static const String listRoute = '/ticket/list';
  static const String createRoute = '/ticket/create';
  static const String detailRoute = '/ticket/detail';
  static const String dashboardRoute = '/ticket/dashboard';

  static Map<String, WidgetBuilder> getRoutes(BuildContext context) {
    return {
      dashboardRoute: (context) => const DashboardScreen(),
      listRoute: (context) => const TicketListScreen(),
      createRoute: (context) => const CreateTicketScreen(),
      detailRoute: (context) {
        final ticketId = ModalRoute.of(context)?.settings.arguments as String?;
        if (ticketId == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Ticket ID tidak ditemukan')),
          );
        }
        return TicketDetailScreen(ticketId: ticketId);
      },
    };
  }

  static String? onGenerateRoute(RouteSettings settings) {
    if (settings.name?.startsWith('/ticket/detail') ?? false) {
      final ticketId = settings.arguments as String?;
      if (ticketId != null) {
        return detailRoute;
      }
    }
    return null;
  }
}
