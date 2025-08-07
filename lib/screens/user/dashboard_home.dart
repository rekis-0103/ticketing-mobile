
import 'package:flutter/material.dart';
import '../../services/app_state.dart';
import '../../models/ticket.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/ticket_card.dart';

class DashboardHome extends StatefulWidget {
  final VoidCallback onBookNowPressed;

  const DashboardHome({super.key, required this.onBookNowPressed});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  late Future<List<Ticket>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = AppState.tickets;
  }

  Future<void> _refreshData() async {
    final newData = await AppState.tickets;
    setState(() {
      _ticketsFuture = Future.value(newData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Ticket>>(
      future: _ticketsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading tickets'));
        }

        final tickets = snapshot.data ?? [];
        final currentUserId = AppState.currentUser?.id;
        final userTickets = tickets.where((t) => t.userId == currentUserId).toList();
        final totalSpent = userTickets.fold<double>(0, (sum, t) => sum + t.totalPrice);

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back!',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          AppState.currentUser?.name ?? 'User',
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Quick Stats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Total Bookings',
                        value: '${userTickets.length}',
                        icon: Icons.confirmation_number,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: 'Total Spent',
                        value: 'Rp ${totalSpent.toStringAsFixed(0)}',
                        icon: Icons.monetization_on,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Recent Bookings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (userTickets.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.inbox, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No bookings yet',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: widget.onBookNowPressed,
                            child: const Text('Book Your First Ticket'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...userTickets.take(3).map((ticket) => TicketCard(ticket: ticket)),
              ],
            ),
          ),
        );
      },
    );
  }
}
