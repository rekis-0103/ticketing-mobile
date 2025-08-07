import 'package:flutter/material.dart';
import 'package:flutter_application_1/core.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart'; // ⬅️ Tambahkan ini
import 'screens/user/user_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';
import 'services/app_state.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.initialize();
  runApp(const TicketingApp());
  await DataRepository.setCurrentUser(null);
}

class TicketingApp extends StatelessWidget {
  const TicketingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  title: 'Ticketing App',
  theme: ThemeData(
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  ),
  home: const UserDashboard(),
  routes: {
    '/login': (context) => const LoginScreen(),
    '/register': (context) => const RegisterScreen(), 
    '/user-dashboard': (context) => const UserDashboard(),
    '/admin-dashboard': (context) => const AdminDashboard(),
  },
);
  }
}