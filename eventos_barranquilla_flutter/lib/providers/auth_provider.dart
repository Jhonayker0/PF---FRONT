import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;
  final UserService _userService = UserService();

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;
  String? get token => _token;

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _userService.login(email: email, password: password);
      final userId = await _userService.verifyToken(token);
      final fetchedUser = await _userService.fetchUser(userId);
      _token = token;
      _user = fetchedUser;

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
      final token = await _userService.signup(
        name: name,
        email: email,
        password: password,
      );
      final userId = await _userService.verifyToken(token);
      final fetchedUser = await _userService.fetchUser(userId);
      _token = token;
      _user = User(
        id: fetchedUser.id,
        name: fetchedUser.name,
        email: fetchedUser.email,
        role: role.isNotEmpty ? role : fetchedUser.role,
        profilePicture: fetchedUser.profilePicture,
        favorites: fetchedUser.favorites,
        attendedEvents: fetchedUser.attendedEvents,
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
    _token = null;
    notifyListeners();
  }
}
