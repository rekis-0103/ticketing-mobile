class User {
  final String id;
  final String name;
  final String email;
  final String password; // Tambahkan ini
  final bool isAdmin;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password, // Tambahkan ini
    required this.isAdmin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'] ?? '', // Ambil dari JSON
      isAdmin: json['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password, // Simpan ke JSON
      'isAdmin': isAdmin,
    };
  }
}
