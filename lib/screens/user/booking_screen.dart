import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/transportation.dart';
import '../../models/ticket.dart';
import '../../services/app_state.dart';


class BookingScreen extends StatefulWidget {
  final Transportation transportation;
  final int quantityAdult;
  final int quantityBaby;
  final DateTime departureDate;
  final DateTime? returnDate;

  const BookingScreen({
    super.key,
    required this.transportation,
    required this.quantityAdult,
    required this.quantityBaby,
    required this.departureDate,
    this.returnDate,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
  
  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }
  
  double get _totalPrice {
    double adultPrice = widget.transportation.price * widget.quantityAdult;
    double babyPrice = widget.transportation.price * 0.5 * widget.quantityBaby; // Assume baby 50% price
    double basePrice = adultPrice + babyPrice;
    
    // If round trip, multiply by 2
    return widget.returnDate != null ? basePrice * 2 : basePrice;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
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
              // Transportation Details Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detail Transportasi',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(_getTransportationIcon()),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.transportation.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rute: ${widget.transportation.route}',
                        style: const TextStyle(fontSize: 16),
                      ),
                     Text('Jam: ${widget.transportation.departureTime} - ${widget.transportation.arrivalTime}'),

                      Text(
                        'Harga: ${_formatCurrency(widget.transportation.price)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Travel Dates Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanggal Perjalanan',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.flight_takeoff),
                          const SizedBox(width: 8),
                          Text(
                            'Pergi: ${_formatDate(widget.departureDate)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      if (widget.returnDate != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.flight_land),
                            const SizedBox(width: 8),
                            Text(
                              'Pulang: ${_formatDate(widget.returnDate!)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Passengers Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Penumpang',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      if (widget.quantityAdult > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Dewasa: ${widget.quantityAdult} orang'),
                            Text(_formatCurrency(widget.transportation.price * widget.quantityAdult)),
                          ],
                        ),
                      if (widget.quantityBaby > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Bayi: ${widget.quantityBaby} orang'),
                            Text(_formatCurrency(widget.transportation.price * 0.5 * widget.quantityBaby)),
                          ],
                        ),
                      ],
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatCurrency(_totalPrice),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Contact Information Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Kontak',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Telepon',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nomor telepon tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Book Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _processBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Konfirmasi Booking - ${_formatCurrency(_totalPrice)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
  
  IconData _getTransportationIcon() {
    switch (widget.transportation.type) {
      case 'train':
        return Icons.train;
      case 'plane':
        return Icons.flight;
      case 'car':
        return Icons.directions_bus;
      default:
        return Icons.directions;
    }
  }
  
  void _processBooking() {
    if (_formKey.currentState!.validate()) {
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi Booking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nama: ${_nameController.text}'),
              Text('Email: ${_emailController.text}'),
              Text('Telepon: ${_phoneController.text}'),
              const SizedBox(height: 8),
              Text('Total Pembayaran: ${_formatCurrency(_totalPrice)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
           ElevatedButton(
  onPressed: () async {
    final currentUser = AppState.currentUser;

    if (currentUser == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User belum login')),
      );
      return;
    }

    final ticket = Ticket(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser.id,
      transportation: widget.transportation,
      quantity: widget.quantityAdult + widget.quantityBaby,
      totalPrice: _totalPrice,
      status: 'Berhasil',
      bookingDate: DateTime.now(),
    );

    await AppState.addTicket(ticket);

    if (mounted) {
      Navigator.pop(context); // Close dialog
      Navigator.pop(context); // Back to previous screen

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking berhasil! Tiket disimpan ke riwayat.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  },
  child: const Text('Konfirmasi'),
),

          ],
        ),
      );
    }
  }
}
