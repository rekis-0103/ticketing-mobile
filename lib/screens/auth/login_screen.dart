import 'package:flutter/material.dart';
import '../../services/data_repository.dart';
import '../../models/user.dart';
import '../../services/app_state.dart';

bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}

bool isValidPassword(String password) {
  return password.length >= 6;
}
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); // Tambah key

  @override
  LoginScreenState createState() => LoginScreenState(); // Hapus underscore
}

class LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;


 void _login() async {
  setState(() => _isLoading = true);

  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  // Validasi awal
  if (email.isEmpty || password.isEmpty) {
    _showSnackBar('Email dan password wajib diisi');
    setState(() => _isLoading = false);
    return;
  }

  if (!isValidEmail(email)) {
    _showSnackBar('Format email tidak valid');
    setState(() => _isLoading = false);
    return;
  }

  if (!isValidPassword(password)) {
    _showSnackBar('Password minimal 6 karakter');
    setState(() => _isLoading = false);
    return;
  }

  try {
    final users = await DataRepository.getUsers();
    User? user;
    final matchedUsers = users.where((u) => u.email == email).toList();

if (matchedUsers.isEmpty) {
  _showSnackBar('Akun belum terdaftar. Silakan daftar terlebih dahulu.');
  setState(() => _isLoading = false);
  return;
}

user = matchedUsers.first;

// ➕ Validasi password
if (user.password != password) {
  _showSnackBar('Password salah');
  setState(() => _isLoading = false);
  return;
}


    // Jika admin
  if (email == 'admin@ticketing.com') {
  user = User(
    id: user.id,
    name: user.name,
    email: user.email,
    password: password, // ⬅️ tambahkan ini
    isAdmin: true,
  );
}


    await AppState.setCurrentUser(user);

    if (!mounted) return;

    if (user.isAdmin) {
      Navigator.pushReplacementNamed(context, '/admin-dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/user-dashboard');
    }
  } catch (e) {
    _showSnackBar('Login gagal: ${e.toString()}');
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade600, Colors.blue.shade900],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : SingleChildScrollView(
                    padding: EdgeInsets.all(32),
                    child: Card(
                      elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                            Icon(
                              Icons.confirmation_number,
                              size: 64,
                              color: Colors.blue.shade600,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Ticketing App',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            const SizedBox(height: 32),
                            TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Tombol Lupa Password dan Daftar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Belum Punya Akun?'),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/register');
                                  },
                                  child: const Text('Daftar Disini'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Login',
                                    style: TextStyle(fontSize: 16)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Demo: admin@ticketing.com (Admin)\nGunakan email yang sudah terdaftar',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
