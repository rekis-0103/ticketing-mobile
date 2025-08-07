import 'package:flutter/material.dart';
import '../../services/app_state.dart';
import '../../models/transportation.dart';
import 'add_edit_transportation_screen.dart';
import '../../models/ticket.dart';

class TransportationManagementScreen extends StatefulWidget {
  const TransportationManagementScreen({super.key});

  @override
  TransportationManagementScreenState createState() => TransportationManagementScreenState();
}

class TransportationManagementScreenState extends State<TransportationManagementScreen> {
  late Future<List<Transportation>> _transportationsFuture;

  @override
  void initState() {
    super.initState();
    _transportationsFuture = AppState.transportations;
  }

  void _refreshData() {
    setState(() {
      _transportationsFuture = AppState.transportations;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditTransportationScreen(),
            ),
          );
          _refreshData();
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                Icon(Icons.settings, color: Colors.blue.shade600),
                SizedBox(width: 8),
                Text(
                  'Transportation Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded( 
            child: FutureBuilder<List<Transportation>>(
              future: _transportationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No transportations found'));
                }
                final transportations = snapshot.data!;
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: transportations.length,
                  itemBuilder: (context, index) {
                    final transportation = transportations[index];
                    return _buildManagementCard(context, transportation);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementCard(BuildContext context, Transportation transportation) {
    return FutureBuilder<List<Ticket>>(
      future: AppState.tickets,
      builder: (context, snapshot) {
        final tickets = snapshot.data ?? [];
        final bookingCount = tickets.where(
          (ticket) => ticket.transportation.id == transportation.id
        ).length;
        
        final totalRevenue = tickets
            .where((ticket) => ticket.transportation.id == transportation.id)
            .fold<double>(0, (sum, ticket) => sum + ticket.totalPrice);

        return Card(
          margin: EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        getIconFromName(transportation.name),
                        color: Colors.blue.shade600,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transportation.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            transportation.route,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditTransportationScreen(
                                transportation: transportation,
                              ),
                            ),
                          );
                          _refreshData();
                        } else if (value == 'delete') {
                          _showDeleteDialog(context, transportation);
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Schedule',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          Text(
                            '${transportation.departureTime} - ${transportation.arrivalTime}',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Bookings',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          Text(
                            '$bookingCount',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Revenue',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          Text(
                            'Rp ${totalRevenue.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, Transportation transportation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Transportation'),
        content: Text('Are you sure you want to delete ${transportation.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AppState.deleteTransportation(transportation.id);
              _refreshData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${transportation.name} deleted')),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  IconData getIconFromName(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('train')) return Icons.train;
  if (lower.contains('car')) return Icons.directions_bus;
  if (lower.contains('plane')) return Icons.flight;
  return Icons.directions_transit;
}

}