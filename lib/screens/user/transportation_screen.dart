import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/transportation.dart';
import '../../widgets/transportation_card.dart';
import '../../services/app_state.dart';
import 'booking_screen.dart';

class TransportationScreen extends StatefulWidget {
  const TransportationScreen({super.key});

  @override
  State<TransportationScreen> createState() => _TransportationScreenState();
}

class _TransportationScreenState extends State<TransportationScreen> {
  String _selectedType = 'train';
  String? _origin;
  String? _destination;
  DateTime? _departureDate;
  bool _isRoundTrip = false;
  DateTime? _returnDate;
  int _adult = 0;
  int _baby = 0;

// Helper untuk ambil kode dari nama lokasi, misal "Gambir (GMR)" -> "gmr"
String _extractCode(String text) {
  final start = text.indexOf('(');
  final end = text.indexOf(')');
  if (start != -1 && end != -1 && end > start) {
    return text.substring(start + 1, end).toLowerCase();
  }
  return '';
}

  List<Transportation> _results = [];
  bool _searchPerformed = false;

  final Map<String, List<String>> _locationOptions = {
    'train': [
      'Gambir (GMR)',
      'Cirebon (CN)',
      'Bandung (BD)',
      'Solo Balapan (SLO)',
      'Yogyakarta (YK)',
      'Surabaya Gubeng (SGU)',
      'Malang (ML)',
      'Semarang Tawang (SMT)',
      'Tegal (TG)',
      'Purwokerto (PWT)',
    ],
    'plane': [
      'Soekarno-Hatta (CGK)',
      'Ngurah Rai (DPS)',
      'Juanda (SUB)',
      'Kualanamu (KNO)',
      'Sultan Hasanuddin (UPG)',
      'Adisutjipto (JOG)',
      'Sultan Syarif Kasim II (PKU)',
      'Minangkabau (PDG)',
      'Supadio (PNK)',
      'Halim Perdanakusuma (HLP)',
    ],
    'car': [
      'Pulogebang (PLG)',
      'Lebak Bulus (LBB)',
      'Kalideres (KLD)',
      'Giwangan (GWG)',
      'Tirtonadi (TTD)',
      'Arjosari (AJS)',
      'Bungurasih (BGS)',
      'Pasar Rebo (PRB)',
      'Terminal Bekasi (TBK)',
      'Kampung Rambutan (KPR)',
    ],
  };

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy').format(date);
  }

  Icon _getIcon(String type) {
    switch (type) {
      case 'train':
        return const Icon(Icons.train);
      case 'plane':
        return const Icon(Icons.flight);
      case 'car':
        return const Icon(Icons.directions_bus);
      default:
        return const Icon(Icons.directions);
    }
  }

 Future<void> _searchTickets() async {
  try {
    final data = await AppState.transportations;

    final originCode = _origin != null ? _extractCode(_origin!) : '';
    final destinationCode = _destination != null ? _extractCode(_destination!) : '';
    final routePattern = '$originCode - $destinationCode';

    final filtered = data.where((t) {
      final matchType = t.type == _selectedType;

      final routeParts = t.route.toLowerCase().split(' - ');
      if (routeParts.length != 2) return false;

      final dataOrigin = _extractCode(routeParts[0]);
      final dataDest = _extractCode(routeParts[1]);
      final dataPattern = '$dataOrigin - $dataDest';

      return matchType && routePattern == dataPattern;
    }).toList();

    setState(() {
      _results = filtered;
      _searchPerformed = true;
    });
  } catch (e) {
    print('Error in _searchTickets: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error mencari tiket: $e')),
      );
    }
  }
}




  Future<void> _selectDepartureDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _departureDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _departureDate = picked;
        if (_returnDate != null && _returnDate!.isBefore(picked)) {
          _returnDate = null;
        }
      });
    }
  }

  Future<void> _selectReturnDate() async {
    if (_departureDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal pergi terlebih dahulu')),
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: _returnDate ?? _departureDate!.add(const Duration(days: 1)),
      firstDate: _departureDate!,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _returnDate = picked;
      });
    }
  }

  bool _canSearch() {
    return _origin != null &&
        _destination != null &&
        _departureDate != null &&
        _origin != _destination;
  }

  bool _canProceedToBooking() {
    final filled = _origin != null &&
        _destination != null &&
        _departureDate != null &&
        (_adult > 0 || _baby > 0) &&
        _origin != _destination;

    return !_isRoundTrip ? filled : filled && _returnDate != null;
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIcon(_selectedType);
    final locations = _locationOptions[_selectedType]!;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSearchCard(icon, locations),
          const SizedBox(height: 20),
          if (_searchPerformed)
            _results.isEmpty
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text('Tidak ada tiket ditemukan')),
                    ),
                  )
                : Column(
                    children: _results.map((t) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TransportationCard(
                          transportation: t,
                          onTap: () {
                            if (!_canProceedToBooking()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Mohon isi semua data sebelum lanjut'),
                                ),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookingScreen(
                                  transportation: t,
                                  quantityAdult: _adult,
                                  quantityBaby: _baby,
                                  departureDate: _departureDate!,
                                  returnDate: _isRoundTrip ? _returnDate : null,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
        ],
      ),
    );
  }

  Widget _buildSearchCard(Icon icon, List<String> locations) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Pilih Jenis Transportasi', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTypeChip('train', 'Kereta'),
                _buildTypeChip('plane', 'Pesawat'),
                _buildTypeChip('car', 'Bus'),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _origin,
              decoration: InputDecoration(
                prefixIcon: icon,
                labelText: 'Dari',
                border: const OutlineInputBorder(),
              ),
              isExpanded: true,
              items: locations
                  .map((loc) => DropdownMenuItem(value: loc, child: Text(loc)))
                  .toList(),
              onChanged: (val) => setState(() => _origin = val),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _destination,
              decoration: InputDecoration(
                prefixIcon: icon,
                labelText: 'Tujuan',
                border: const OutlineInputBorder(),
              ),
              isExpanded: true,
              items: locations
                  .map((loc) => DropdownMenuItem(value: loc, child: Text(loc)))
                  .toList(),
              onChanged: (val) => setState(() => _destination = val),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectDepartureDate,
              child: _buildDateField(
                label: 'Tanggal Pergi',
                value: _departureDate != null ? _formatDate(_departureDate) : null,
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: _isRoundTrip,
                  onChanged: (val) {
                    setState(() {
                      _isRoundTrip = val ?? false;
                      if (!_isRoundTrip) _returnDate = null;
                    });
                  },
                ),
                const Text('Pulang Pergi'),
              ],
            ),
            if (_isRoundTrip)
              InkWell(
                onTap: _selectReturnDate,
                child: _buildDateField(
                  label: 'Tanggal Pulang',
                  value: _returnDate != null ? _formatDate(_returnDate) : null,
                ),
              ),
            const SizedBox(height: 12),
            _buildCounterRow('Dewasa', _adult, (val) => setState(() => _adult = val)),
            _buildCounterRow('Bayi', _baby, (val) => setState(() => _baby = val)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _canSearch() ? _searchTickets : null,
                icon: const Icon(Icons.search),
                label: const Text('Cari Tiket'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({required String label, String? value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today),
          const SizedBox(width: 12),
          Text(
            value ?? label,
            style: TextStyle(fontSize: 16, color: value == null ? Colors.grey : Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterRow(String label, int value, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Row(
          children: [
            IconButton(
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove),
            ),
            Text('$value', style: const TextStyle(fontSize: 16)),
            IconButton(
              onPressed: () => onChanged(value + 1),
              icon: const Icon(Icons.add),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTypeChip(String type, String label) {
    final isSelected = _selectedType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedType = type;
          _origin = null;
          _destination = null;
          _departureDate = null;
          _returnDate = null;
          _searchPerformed = false;
          _results.clear();
        });
      },
    );
  }
}
