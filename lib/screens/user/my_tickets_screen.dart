import 'package:flutter/material.dart';
import '../../services/app_state.dart';
import '../../models/ticket.dart';
import '../../widgets/ticket_card.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  late Future<List<Ticket>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = AppState.tickets;
  }

  Future<void> _refreshData() async {
    setState(() {
      _ticketsFuture = AppState.tickets;
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

        final allTickets = snapshot.data ?? [];
        final userTickets = allTickets
            .where((ticket) => ticket.userId == AppState.currentUser?.id)
            .toList();

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: userTickets.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.confirmation_number_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tickets yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Book your first ticket from the Book Ticket tab',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: userTickets.length,
                  itemBuilder: (context, index) {
                    return TicketCard(ticket: userTickets[index]);
                  },
                ),
        );
      },
    );
  }
}
