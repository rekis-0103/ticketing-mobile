class User {
  final String id;
  final String name;
  final String email;
  final bool isAdmin;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.isAdmin = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      isAdmin: json['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isAdmin': isAdmin,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    bool? isAdmin,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, isAdmin: $isAdmin)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          isAdmin == other.isAdmin;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ email.hashCode ^ isAdmin.hashCode;
}
