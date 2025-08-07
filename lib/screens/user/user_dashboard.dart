import 'package:flutter/material.dart';
import '../../services/app_state.dart';
import 'dashboard_home.dart';
import 'transportation_screen.dart';
import 'my_tickets_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardHome(onBookNowPressed: () {
        setState(() {
          _selectedIndex = 1;
        });
      }),
      const TransportationScreen(),
      const MyTicketsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final user = AppState.currentUser;
    final isGuest = user == null;

    return Scaffold(
     appBar: AppBar(
  title: Text(isGuest
      ? 'Selamat Datang, Guest'
      : 'Selamat Datang, ${user!.name}'),
  backgroundColor: Colors.blue, // pastikan warnanya tidak putih
  foregroundColor: Colors.white, // supaya teks & ikon tampak putih
  actions: [
    isGuest
        ? TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text(
              'Login/Daftar',
              style: TextStyle(
                color: Colors.white, // ini penting agar terlihat
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AppState.currentUser = null;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
  ],
),

      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Book Ticket',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'My Tickets',
          ),
        ],
      ),
    );
  }
}
