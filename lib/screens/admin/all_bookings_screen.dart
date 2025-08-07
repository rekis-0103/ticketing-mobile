import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../../services/app_state.dart';
import '../../models/ticket.dart';
import '../../models/transportation.dart';
import '../../widgets/stat_card.dart';

class AllBookingsScreen extends StatefulWidget {
  const AllBookingsScreen({super.key});

  @override
  State<AllBookingsScreen> createState() => _AllBookingsScreenState();
}

class _AllBookingsScreenState extends State<AllBookingsScreen> {
  late Future<List<Ticket>> _ticketsFuture;
  late Future<List<Transportation>> _transportationsFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _ticketsFuture = AppState.tickets;
      _transportationsFuture = AppState.transportations;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Ticket>>(
      future: _ticketsFuture,
      builder: (context, ticketsSnapshot) {
        return FutureBuilder<List<Transportation>>(
          future: _transportationsFuture,
          builder: (context, transportationsSnapshot) {
            if (ticketsSnapshot.connectionState == ConnectionState.waiting ||
                transportationsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (ticketsSnapshot.hasError || transportationsSnapshot.hasError) {
              return const Center(child: Text('Error loading data'));
            }

            final tickets = ticketsSnapshot.data ?? [];
            final transportations = transportationsSnapshot.data ?? [];

            return _buildContent(tickets, transportations);
          },
        );
      },
    );
  }

  Widget _buildContent(List<Ticket> tickets, List<Transportation> transportations) {
    final totalBookings = tickets.length;
    final totalRevenue = tickets.fold<double>(0, (sum, ticket) => sum + ticket.totalPrice);
    final carBookings = tickets.where((t) => t.transportation.type == 'car').length;
    final trainBookings = tickets.where((t) => t.transportation.type == 'train').length;
    final planeBookings = tickets.where((t) => t.transportation.type == 'plane').length;

    return RefreshIndicator(
      onRefresh: () async {
        _refreshData();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.purple.shade600],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Ticketing System Management',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('System Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Total Pesanan',
                    value: totalBookings.toString(),
                    icon: Icons.confirmation_number,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Total Pendapatan',
                    value: 'Rp ${totalRevenue.toStringAsFixed(0)}',
                    icon: Icons.monetization_on,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Rute Tersedia',
                    value: transportations.length.toString(),
                    icon: Icons.route,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'User Aktif',
                    value: '1',
                    icon: Icons.people,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Bookings by Transportation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildTransportationStat('Car', carBookings, Icons.directions_car, Colors.blue),
                    const SizedBox(height: 16),
                    _buildTransportationStat('Train', trainBookings, Icons.train, Colors.green),
                    const SizedBox(height: 16),
                    _buildTransportationStat('Plane', planeBookings, Icons.flight, Colors.orange),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Recent Bookings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final tickets = await _ticketsFuture;
                  final transportations = await _transportationsFuture;
                  await generateReportPdf(tickets, transportations);
                },
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text("Download Report", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (tickets.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      const Icon(Icons.inbox, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('No bookings yet', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              )
            else
              ...tickets.take(5).map((ticket) => _buildAdminTicketCard(ticket)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportationStat(String type, int count, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            type,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          '$count bookings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildAdminTicketCard(Ticket ticket) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(ticket.transportation.icon, color: Colors.blue.shade600, size: 32),
        title: Text(ticket.transportation.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ticket.transportation.route),
            Text('User ID: ${ticket.userId} | Qty: ${ticket.quantity}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Rp ${ticket.totalPrice.toStringAsFixed(0)}',
                style: TextStyle(color: Colors.green.shade600, fontWeight: FontWeight.w600)),
            Text('${ticket.bookingDate.day}/${ticket.bookingDate.month}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Future<void> generateReportPdf(List<Ticket> tickets, List<Transportation> transportations) async {
    final pdf = pw.Document();
    final totalBookings = tickets.length;
    final totalRevenue = tickets.fold<double>(0, (sum, ticket) => sum + ticket.totalPrice);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final now = DateTime.now();

    // Create a separate footer widget that doesn't depend on context
    pw.Widget footer(pw.Context context) {
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated on: ${dateFormat.format(now)}',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginTop: 1.5 * PdfPageFormat.cm,
          marginLeft: 1.5 * PdfPageFormat.cm,
          marginRight: 1.5 * PdfPageFormat.cm,
          marginBottom: 1.5 * PdfPageFormat.cm,
        ),
        build: (pw.Context context) => [
          // Header Section
          pw.Header(
            level: 0,
            child: pw.Text(
              'Admin Ticketing Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
          ),
          pw.SizedBox(height: 16),

          // Report Summary Section
          pw.Header(
            level: 1,
            child: pw.Text(
              'System Overview',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Bullet(
            text: 'Total Pemesanan: $totalBookings',
            style: pw.TextStyle(fontSize: 14),
            bulletColor: PdfColors.blue700,
          ),
          pw.Bullet(
            text: 'Total Pendapatan: Rp ${totalRevenue.toStringAsFixed(0)}',
            style: pw.TextStyle(fontSize: 14),
            bulletColor: PdfColors.blue700,
          ),
          pw.Bullet(
            text: 'Rute Tersedia: ${transportations.length}',
            style: pw.TextStyle(fontSize: 14),
            bulletColor: PdfColors.blue700,
          ),
          pw.SizedBox(height: 24),

          // Booking Details Section
          pw.Header(
            level: 1,
            child: pw.Text(
              'Booking Details',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
          ),
          pw.SizedBox(height: 12),

          if (tickets.isEmpty)
            pw.Padding(
              child: pw.Text(
                'No bookings available.',
                style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
              ),
              padding: pw.EdgeInsets.only(left: 10),
            )
          else
            pw.Table.fromTextArray(
              border: pw.TableBorder.all(
                width: 0.5,
                color: PdfColors.grey300,
              ),
              cellPadding: pw.EdgeInsets.all(8),
              headerDecoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
                fontSize: 12,
              ),
              cellStyle: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey800,
              ),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.centerRight,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
              },
              headers: [
                'Transportasi',
                'Rute',
                'Tipe',
                'Qty',
                'Harga',
                'Status',
                'Tanggal',
              ],
              data: tickets.map((t) {
  // Konversi nama transportasi
  String localizedTransportName = t.transportation.name;
  if (localizedTransportName.toLowerCase().contains('train')) {
    localizedTransportName = localizedTransportName.replaceAll(RegExp(r'train', caseSensitive: false), 'Kereta');
  } else if (localizedTransportName.toLowerCase().contains('plane')) {
    localizedTransportName = localizedTransportName.replaceAll(RegExp(r'plane', caseSensitive: false), 'Pesawat');
  } else if (localizedTransportName.toLowerCase().contains('car')) {
    localizedTransportName = localizedTransportName.replaceAll(RegExp(r'car', caseSensitive: false), 'Bis');
  }

  // Konversi tipe transportasi
  String localizedType = t.transportation.type;
  switch (localizedType) {
    case 'train':
      localizedType = 'Kereta';
      break;
    case 'plane':
      localizedType = 'Pesawat';
      break;
    case 'car':
      localizedType = 'Bis';
      break;
  }

  return [
    localizedTransportName,
    t.transportation.route,
    localizedType,
    t.quantity.toString(),
    'Rp ${t.totalPrice.toStringAsFixed(0)}',
    t.status,
    '${t.bookingDate.day.toString().padLeft(2, '0')}/${t.bookingDate.month.toString().padLeft(2, '0')}/${t.bookingDate.year}',
  ];
}).toList(),

            ),
        ],
        footer: footer,
      ),
    );

    try {
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/ticketing_report.pdf');
      await file.writeAsBytes(await pdf.save());
      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate PDF: ${e.toString()}')),
      );
    }
  }
}