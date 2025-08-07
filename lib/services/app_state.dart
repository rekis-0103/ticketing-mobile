// services/app_state.dart
import '../models/user.dart';
import '../models/transportation.dart';
import '../models/ticket.dart';
import 'data_repository.dart';


class AppState {
  static User? currentUser;
  
  static Future<List<Transportation>> get transportations async => 
      await DataRepository.getTransportations();
  
  static Future<List<Ticket>> get tickets async => 
      await DataRepository.getTickets();

  static Future<void> addTransportation(Transportation transportation) async =>
      await DataRepository.addTransportation(transportation);

  static Future<void> updateTransportation(Transportation transportation) async =>
      await DataRepository.updateTransportation(transportation);

  static Future<void> deleteTransportation(String id) async =>
      await DataRepository.deleteTransportation(id);

  static Future<void> addTicket(Ticket ticket) async =>
      await DataRepository.addTicket(ticket);

  static Future<void> setCurrentUser(User? user) async {
    currentUser = user;
    await DataRepository.setCurrentUser(user);
  }

  static Future<void> initialize() async {
    
    await DataRepository.initializeData();
    currentUser = await DataRepository.getCurrentUser();
  }
}