enum UserRole { user, admin, superAdmin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? profileImageUrl;
  final DateTime createdAt;
  final List<String> favoriteEventIds;
  final List<String> bookingIds;
  bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.role = UserRole.user,
    this.profileImageUrl,
    DateTime? createdAt,
    this.favoriteEventIds = const [],
    this.bookingIds = const [],
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isAdmin => role == UserRole.admin || role == UserRole.superAdmin;
  bool get isSuperAdmin => role == UserRole.superAdmin;

  String get roleLabel {
    switch (role) {
      case UserRole.superAdmin:
        return 'Super Administrateur';
      case UserRole.admin:
        return 'Administrateur';
      default:
        return 'Utilisateur';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.index,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'favoriteEventIds': favoriteEventIds,
      'bookingIds': bookingIds,
      'isActive': isActive,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: UserRole.values[json['role'] ?? 0],
      profileImageUrl: json['profileImageUrl'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      favoriteEventIds: List<String>.from(json['favoriteEventIds'] ?? []),
      bookingIds: List<String>.from(json['bookingIds'] ?? []),
      isActive: json['isActive'] ?? true,
    );
  }
}
