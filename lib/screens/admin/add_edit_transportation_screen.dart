import 'package:flutter/material.dart';
import '../../models/transportation.dart';
import '../../services/app_state.dart';

class AddEditTransportationScreen extends StatefulWidget {
  final Transportation? transportation;

  const AddEditTransportationScreen({super.key, this.transportation});

  @override
  State<AddEditTransportationScreen> createState() => _AddEditTransportationScreenState();
}

class _AddEditTransportationScreenState extends State<AddEditTransportationScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _id, _type, _name, _route, _departureTime, _arrivalTime;
  late double _price;
  late IconData _icon;

  final List<String> _types = ['car', 'train', 'plane'];
  final Map<String, IconData> _typeIcons = {
    'car': Icons.directions_bus,
    'train': Icons.train,
    'plane': Icons.flight,
  };

  final Map<String, String> _typeLabels = {
    'car': 'Bus',
    'train': 'Kereta',
    'plane': 'Pesawat',
  };

  @override
  void initState() {
    super.initState();
    final t = widget.transportation;
    _id = t?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    _type = t?.type ?? 'car';
    _name = t?.name ?? '';
    _route = t?.route ?? '';
    _price = t?.price ?? 0;
    _departureTime = t?.departureTime ?? '08:00';
    _arrivalTime = t?.arrivalTime ?? '12:00';
    _icon = t?.icon ?? Icons.directions_bus;
  }

  String _generateTimeString() {
    return '$_departureTime - $_arrivalTime';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transportation == null 
            ? 'Tambah Transportasi' 
            : 'Edit Transportasi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Transportasi',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _type,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Transportasi',
                          border: OutlineInputBorder(),
                        ),
                        items: _types.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Row(
                              children: [
                                Icon(_typeIcons[type]),
                                const SizedBox(width: 8),
                                Text(_typeLabels[type] ?? type),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _type = value!;
                            _icon = _typeIcons[value]!;
                          });
                        },
                        validator: (value) => value == null ? 'Pilih jenis transportasi' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _name,
                        decoration: const InputDecoration(
                          labelText: 'Nama Transportasi',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.label),
                        ),
                        validator: (value) => (value == null || value.isEmpty) 
                            ? 'Masukkan nama transportasi' 
                            : null,
                        onSaved: (value) => _name = value!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _route,
                        decoration: const InputDecoration(
                          labelText: 'Rute (contoh: Jakarta - Bandung)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.route),
                        ),
                        validator: (value) => (value == null || value.isEmpty) 
                            ? 'Masukkan rute perjalanan' 
                            : null,
                        onSaved: (value) => _route = value!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _price.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Harga (Rupiah)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan harga';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Masukkan angka yang valid';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Harga harus lebih dari 0';
                          }
                          return null;
                        },
                        onSaved: (value) => _price = double.parse(value!),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jadwal Perjalanan',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _departureTime,
                              decoration: const InputDecoration(
                                labelText: 'Waktu Keberangkatan',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.schedule),
                                hintText: '08:00',
                              ),
                              validator: (value) => (value == null || value.isEmpty) 
                                  ? 'Masukkan waktu keberangkatan' 
                                  : null,
                              onSaved: (value) => _departureTime = value!,
                              onTap: () async {
                                final TimeOfDay? picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _departureTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              initialValue: _arrivalTime,
                              decoration: const InputDecoration(
                                labelText: 'Waktu Tiba',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.schedule_rounded),
                                hintText: '12:00',
                              ),
                              validator: (value) => (value == null || value.isEmpty) 
                                  ? 'Masukkan waktu tiba' 
                                  : null,
                              onSaved: (value) => _arrivalTime = value!,
                              onTap: () async {
                                final TimeOfDay? picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _arrivalTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Jadwal yang akan ditampilkan: ${_generateTimeString()}',
                                style: TextStyle(color: Colors.blue.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.save),
                  label: Text(widget.transportation == null 
                      ? 'Tambah Transportasi' 
                      : 'Update Transportasi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final transportation = Transportation(
        id: _id,
        type: _type,
        name: _name,
        route: _route,
        price: _price,
        departureTime: _departureTime,
        arrivalTime: _arrivalTime,
        icon: _icon,
      );

      try {
        if (widget.transportation == null) {
          await AppState.addTransportation(transportation);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transportasi berhasil ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          await AppState.updateTransportation(transportation);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transportasi berhasil diupdate'),
              backgroundColor: Colors.green,
            ),
          );
        }

        if (!mounted) return;
        Navigator.pop(context, true); // Return true to indicate success
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}