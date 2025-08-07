import 'package:flutter_application_1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App starts with login screen', (WidgetTester tester) async {
    await tester.pumpWidget(TicketingApp());

    // Pastikan text "Login" atau komponen login ada
    expect(find.text('Login'), findsOneWidget); // sesuaikan dengan isi login screen
  });
}
