import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isSuperAdmin => _currentUser?.isSuperAdmin ?? false;
  bool get isLoading => _isLoading;

  // ===== COMPTES ADMINISTRATEURS EVENT'S AL =====
  // Identifiants des comptes administrateurs:
  static const List<Map<String, dynamic>> _adminAccounts = [
    {
      'id': 'admin_000',
      'name': 'Super Administrateur',
      'email': 'superadmin@eventalapp.dz',
      'password': 'Super@2025',
      'role': UserRole.superAdmin,
      'phone': '+213 21 00 00 00',
    },
    {
      'id': 'admin_001',
      'name': 'Administrateur Principal',
      'email': 'admin@eventalapp.dz',
      'password': 'Admin@2025',
      'role': UserRole.admin,
      'phone': '+213 21 73 00 02',
    },
    {
      'id': 'admin_002',
      'name': 'Admin Alger Culture',
      'email': 'admin@algerculture.dz',
      'password': 'Admin@2025',
      'role': UserRole.admin,
      'phone': '+213 21 71 57 57',
    },
  ];

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        _currentUser = UserModel.fromJson(userMap);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Auth init error: $e');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network

    try {
      // Check admin accounts first
      for (final account in _adminAccounts) {
        if (account['email'] == email && account['password'] == password) {
          _currentUser = UserModel(
            id: account['id'],
            name: account['name'],
            email: account['email'],
            phone: account['phone'] ?? '',
            role: account['role'],
          );
          await _saveUser();
          _isLoading = false;
          notifyListeners();
          return {'success': true, 'message': 'Connexion réussie'};
        }
      }

      // Check regular users in storage
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('registered_users');
      if (usersJson != null) {
        final List<dynamic> users = jsonDecode(usersJson);
        for (final userMap in users) {
          if (userMap['email'] == email && userMap['password'] == password) {
            _currentUser = UserModel.fromJson(userMap);
            await _saveUser();
            _isLoading = false;
            notifyListeners();
            return {'success': true, 'message': 'Connexion réussie'};
          }
        }
      }

      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Email ou mot de passe incorrect.'};
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // Check if email already exists
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('registered_users');
      List<dynamic> users = usersJson != null ? jsonDecode(usersJson) : [];

      // Check admin emails
      for (final admin in _adminAccounts) {
        if (admin['email'] == email) {
          _isLoading = false;
          notifyListeners();
          return {'success': false, 'message': 'Cet email est déjà utilisé.'};
        }
      }

      // Check existing users
      for (final user in users) {
        if (user['email'] == email) {
          _isLoading = false;
          notifyListeners();
          return {'success': false, 'message': 'Cet email est déjà utilisé.'};
        }
      }

      // Create new user
      final newUser = {
        'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'role': UserRole.user.index,
        'createdAt': DateTime.now().toIso8601String(),
        'favoriteEventIds': <String>[],
        'bookingIds': <String>[],
        'isActive': true,
      };

      users.add(newUser);
      await prefs.setString('registered_users', jsonEncode(users));

      _currentUser = UserModel.fromJson(newUser);
      await _saveUser();

      _isLoading = false;
      notifyListeners();
      return {'success': true, 'message': 'Compte créé avec succès'};
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Erreur lors de l\'inscription: $e'};
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    notifyListeners();
  }

  Future<void> _saveUser() async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', jsonEncode(_currentUser!.toJson()));
  }

  // Get admin accounts info (for display in admin section)
  List<Map<String, String>> getAdminAccountsInfo() {
    return _adminAccounts.map((a) => {
      'name': a['name'] as String,
      'email': a['email'] as String,
      'role': (a['role'] as UserRole).name,
    }).toList();
  }
}
