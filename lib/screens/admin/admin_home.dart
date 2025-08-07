import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AdminHome extends StatelessWidget {
  AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _getTicketData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || (snapshot.data as List).isEmpty) {
            return const Center(child: Text('Tidak ada data pemesanan'));
          }

          final ticketData = snapshot.data as List<dynamic>;
          final bookingStats = _calculateBookingStats(ticketData);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat datang Admin',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildBookingChart(bookingStats),
                const SizedBox(height: 24),
                _buildRecentBookings(ticketData),
              ],
            ),
          );
        },
      ),
    );
  }

  

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingChart(Map<String, int> bookingStats) {
    final dates = bookingStats.keys.toList();
    final values = bookingStats.values.toList();

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grafik Pemesanan Harian',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final date = dates[group.x.toInt()];
                        return BarTooltipItem(
                          '$date\n${rod.toY.toInt()} pemesanan',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < dates.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                DateFormat('d MMM').format(DateTime.parse(dates[value.toInt()])),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 28,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: _calculateInterval(values),
                        getTitlesWidget: (value, meta) {
                          if (value == meta.max) {
                            return const Text('');
                          }
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    dates.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: values[index].toDouble(),
                          color: Colors.blueAccent,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBookings(List<dynamic> tickets) {
    final recentTickets = tickets.take(5).toList();

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pemesanan Terakhir',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...recentTickets.map((ticket) => ListTile(
                  leading: const Icon(Icons.confirmation_number, color: Colors.blue),
                  title: Text(ticket['transportation']['name']),
                  subtitle: Text(
                    '${DateFormat('dd MMM yyyy HH:mm').format(DateTime.parse(ticket['bookingDate']))} • Rp${NumberFormat('#,###').format(ticket['totalPrice'])}',
                  ),
                  trailing: Chip(
                    label: Text(ticket['status']),
                    backgroundColor: ticket['status'] == 'Berhasil'
                        ? Colors.green[100]
                        : Colors.orange[100],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  static Future<List<dynamic>> _getTicketData() async {
    final prefs = await SharedPreferences.getInstance();
    final ticketData = prefs.getString('tickets');
    if (ticketData != null) {
      return List<dynamic>.from(jsonDecode(ticketData));
    }
    return [];
  }

  static Map<String, int> _calculateBookingStats(List<dynamic> tickets) {
    final stats = <String, int>{};

    for (final ticket in tickets) {
      final date = DateTime.parse(ticket['bookingDate']).toIso8601String().split('T')[0];
      stats[date] = (stats[date] ?? 0) + 1;
    }

    final sortedKeys = stats.keys.toList()..sort();
    final sortedStats = <String, int>{};
    for (final key in sortedKeys) {
      sortedStats[key] = stats[key]!;
    }

    return sortedStats;
  }

  static double _calculateInterval(List<int> values) {
    if (values.isEmpty) return 1;
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    if (maxValue <= 5) return 1;
    if (maxValue <= 10) return 2;
    if (maxValue <= 20) return 5;
    return (maxValue / 5).ceilToDouble();
  }
}
