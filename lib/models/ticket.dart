import 'transportation.dart';

class Ticket {
  final String id;
  final String userId;
  final Transportation transportation;
  final DateTime bookingDate;
  final int quantity;
  final double totalPrice;
  final String status;

  Ticket({
    required this.id,
    required this.userId,
    required this.transportation,
    required this.bookingDate,
    required this.quantity,
    required this.totalPrice,
    this.status = 'Confirmed',
  });

  // Add toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'transportation': transportation.toJson(),
      'bookingDate': bookingDate.toIso8601String(),
      'quantity': quantity,
      'totalPrice': totalPrice,
      'status': status,
    };
  }

  // Add fromJson factory
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      userId: json['userId'],
      transportation: Transportation.fromJson(json['transportation']),
      bookingDate: DateTime.parse(json['bookingDate']),
      quantity: json['quantity'],
      totalPrice: json['totalPrice'].toDouble(),
      status: json['status'],
    );
  }
}