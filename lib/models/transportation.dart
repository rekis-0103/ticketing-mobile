import 'package:flutter/material.dart';

class Transportation {
  final String id;
  final String name;
  final String type; // train, plane, car
  final String route;
  final String departureTime;
  final String arrivalTime;
  final double price;
  final String? description;
  final int? availableSeats;
  final IconData? icon;

  Transportation({
    required this.id,
    required this.name,
    required this.type,
    required this.route,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    this.description,
    this.availableSeats,
    this.icon,
  });

  factory Transportation.fromJson(Map<String, dynamic> json) {
    return Transportation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      route: json['route'] ?? '',
      departureTime: json['departureTime'] ?? '',
      arrivalTime: json['arrivalTime'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'],
      availableSeats: json['availableSeats'],
      // Icon is not serializable directly — handle separately in UI if needed
      icon: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'route': route,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'price': price,
      'description': description,
      'availableSeats': availableSeats,
      // 'icon': icon, // skipped in JSON, use icon dynamically in UI
    };
  }
}
