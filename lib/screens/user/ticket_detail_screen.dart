import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/ticket.dart';

class TicketDetailScreen extends StatelessWidget {
  final Ticket ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  String _formatDate(DateTime date) =>
      DateFormat('dd MMM yyyy, HH:mm').format(date);

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final transportation = ticket.transportation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tiket'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(transportation.icon, size: 32, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          transportation.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Rute: ${transportation.route}'),
                  Text('Waktu: ${transportation.departureTime} - ${transportation.arrivalTime}'),
                  Text('Harga per kursi: ${_formatCurrency(transportation.price)}'),
                  const Divider(height: 32),
                  Text('Jumlah Kursi: ${ticket.quantity}'),
                  Text('Total Pembayaran: ${_formatCurrency(ticket.totalPrice)}'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Status: '),
                      Chip(
                        label: Text(
                          ticket.status,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green.shade600,
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Text('Tanggal Booking: ${_formatDate(ticket.bookingDate)}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Kembali'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
