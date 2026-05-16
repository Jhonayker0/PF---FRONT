import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;

  // Demo credentials
  static const _demoCreds = {
    'cliente@example.com': {'password': '123456', 'name': 'Cliente Demo', 'role': 'client'},
    'admin@example.com': {'password': '123456', 'name': 'Admin Demo', 'role': 'admin'},
  };

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate API call

      if (!_demoCreds.containsKey(email)) {
        _errorMessage = 'Correo no encontrado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final creds = _demoCreds[email]!;
      if (creds['password'] != password) {
        _errorMessage = 'Contraseña incorrecta';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _user = User(
        id: email.hashCode.toString(),
        name: creds['name'] as String,
        email: email,
        role: creds['role'] as String,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al iniciar sesión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate API call

      _user = User(
        id: email.hashCode.toString(),
        name: name,
        email: email,
        role: role,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al registrarse: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }
}
