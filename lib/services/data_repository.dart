import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ticket.dart';
import '../models/transportation.dart';
import '../models/user.dart';

class DataRepository {
  static const String _transportationsKey = 'transportations';
  static const String _ticketsKey = 'tickets';
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'currentUser';

  static Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // Transportation CRUD operations
  static Future<List<Transportation>> getTransportations() async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(_transportationsKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((json) => Transportation.fromJson(json)).toList();
  }

  static Future<void> saveTransportations(List<Transportation> transportations) async {
    final prefs = await _prefs;
    final jsonData = transportations.map((t) => t.toJson()).toList();
    await prefs.setString(_transportationsKey, json.encode(jsonData));
  }

  static Future<void> addTransportation(Transportation transportation) async {
    final transportations = await getTransportations();
    transportations.add(transportation);
    await saveTransportations(transportations);
  }

  static Future<void> updateTransportation(Transportation updatedTransportation) async {
    final transportations = await getTransportations();
    final index = transportations.indexWhere((t) => t.id == updatedTransportation.id);
    if (index != -1) {
      transportations[index] = updatedTransportation;
      await saveTransportations(transportations);
    }
  }

  static Future<void> deleteTransportation(String id) async {
    final transportations = await getTransportations();
    transportations.removeWhere((t) => t.id == id);
    await saveTransportations(transportations);
  }

  // Ticket CRUD operations
  static Future<List<Ticket>> getTickets() async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(_ticketsKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((json) => Ticket.fromJson(json)).toList();
  }

  static Future<void> saveTickets(List<Ticket> tickets) async {
    final prefs = await _prefs;
    final jsonData = tickets.map((t) => t.toJson()).toList();
    await prefs.setString(_ticketsKey, json.encode(jsonData));
  }

  static Future<void> addTicket(Ticket ticket) async {
    final tickets = await getTickets();
    tickets.add(ticket);
    await saveTickets(tickets);
  }

  // User CRUD operations
  static Future<List<User>> getUsers() async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(_usersKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((json) => User.fromJson(json)).toList();
  }

  static Future<void> saveUsers(List<User> users) async {
    final prefs = await _prefs;
    final jsonData = users.map((u) => u.toJson()).toList();
    await prefs.setString(_usersKey, json.encode(jsonData));
  }

  static Future<void> addUser(User user) async {
    final users = await getUsers();
    users.add(user);
    await saveUsers(users);
  }

  // Current user operations
  static Future<User?> getCurrentUser() async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(_currentUserKey);
    if (jsonString == null) return null;
    return User.fromJson(json.decode(jsonString));
  }

  static Future<void> setCurrentUser(User? user) async {
    final prefs = await _prefs;
    if (user == null) {
      await prefs.remove(_currentUserKey);
    } else {
      await prefs.setString(_currentUserKey, json.encode(user.toJson()));
    }
  }
static Future<void> resetAll() async {
  final prefs = await _prefs;
  await prefs.remove(_transportationsKey);
  await prefs.remove(_ticketsKey);
  await prefs.remove(_usersKey);
  await prefs.remove(_currentUserKey);
  debugPrint("All data cleared");
}

  // Initialize with sample data if empty
  static Future<void> initializeData() async {
  final transportations = await getTransportations();
  if (transportations.isEmpty) {
    final List<Transportation> dummyList = [];
    int idCounter = 1;

    final Map<String, List<String>> data = {
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

    final iconMap = {
      'train': Icons.train,
      'plane': Icons.flight,
      'car': Icons.directions_bus,
    };

    data.forEach((type, locations) {
      for (int i = 0; i < locations.length; i++) {
        for (int j = 0; j < locations.length; j++) {
          if (i == j) continue;

          final from = locations[i];
          final to = locations[j];

          dummyList.add(Transportation(
            id: '${idCounter++}',
            type: type,
            name: '${type.toUpperCase()} Express $i-$j',
            route: '$from - $to',
           price: (100000 + (10000 * i) + (5000 * j)).toDouble(),
            departureTime: '${8 + (i % 5)}:00',
            arrivalTime: '${11 + (j % 4)}:00',
            icon: iconMap[type]!,
          ));
        }
      }
    });

    await saveTransportations(dummyList);
    debugPrint('Dummy transportations saved: ${dummyList.length}');
  }

  final users = await getUsers();
  if (users.isEmpty) {
    await saveUsers([
      User(
        id: '1',
        name: 'Admin',
        email: 'admin@ticketing.com',
        password: 'admin123',
        isAdmin: true,
      ),
      User(
        id: '2',
        name: 'User',
        email: 'user@example.com',
        password: 'user123',
        isAdmin: false,
      ),
    ]);
    debugPrint('Dummy users created');
  }
}
}