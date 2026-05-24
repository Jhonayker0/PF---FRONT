import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/profile_stats.dart';
import '../services/fcm_service.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;
  final UserService _userService = UserService();
  final FcmService _fcmService = FcmService();

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  bool isFavorite(String eventId) => _user?.favorites.contains(eventId) ?? false;

  ProfileStats get profileStats {
    final eventsCount = _user?.attendedEvents.length ?? 0;
    return ProfileStats(events: eventsCount, reviews: 0, monthsOnCumbe: 0);
  }

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
      await _syncFcmToken(fetchedUser.id);

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

  Future<bool> signUp(String email, String password, String name, String role, {String? profileImagePath}) async {
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
      var fetchedUser = await _userService.fetchUser(userId);
      // If the user supplied a profile image during registration, upload it
      // and update the user record with the returned URL.
      if (profileImagePath != null && profileImagePath.isNotEmpty) {
        try {
          final uploadedUrl = await _userService.uploadProfilePicture(
            userId: userId,
            filePath: profileImagePath,
            token: token,
          );
          // Merge with the fetched user's full JSON to satisfy backend required fields
          final merged = fetchedUser.toJson();
          merged['profile_picture_url'] = uploadedUrl;
          await _userService.updateUser(userId: userId, body: merged, token: token);
          fetchedUser = await _userService.fetchUser(userId);
        } catch (_) {
          // ignore upload errors during signup; continue with fetchedUser
        }
      }
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
      await _syncFcmToken(fetchedUser.id);

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

  Future<bool> updateProfile({String? name, String? profileImagePath}) async {
    final currentUser = _user;
    if (currentUser == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? uploadedUrl;
      if (profileImagePath != null && profileImagePath.isNotEmpty) {
        uploadedUrl = await _userService.uploadProfilePicture(
          userId: currentUser.id,
          filePath: profileImagePath,
          token: _token,
        );
      }

      final updates = <String, dynamic>{};
      if (name != null && name.isNotEmpty) updates['name'] = name;
      if (uploadedUrl != null && uploadedUrl.isNotEmpty) updates['profile_picture_url'] = uploadedUrl;
      if (updates.isNotEmpty) {
        final full = currentUser.toJson();
        full.addAll(updates);
        await _userService.updateUser(userId: currentUser.id, body: full, token: _token);
      }

      final refreshed = await _userService.fetchUser(currentUser.id);
      _user = refreshed;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'No se pudo actualizar perfil: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProfilePicture() async {
    final currentUser = _user;
    if (currentUser == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userService.deleteProfilePicture(
        userId: currentUser.id,
        token: _token,
      );
      final refreshed = await _userService.fetchUser(currentUser.id);
      _user = refreshed;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'No se pudo eliminar la foto de perfil: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    final token = _token;
    if (token != null && token.isNotEmpty) {
      try {
        await _userService.logout(token: token);
      } catch (_) {
        // Clear local auth state even if the backend logout request fails.
      }
    }

    _user = null;
    _errorMessage = null;
    _token = null;
    notifyListeners();
  }

  Future<bool> toggleFavorite(String eventId) async {
    final currentUser = _user;
    final currentToken = _token;

    if (currentUser == null || currentToken == null || currentToken.isEmpty) {
      _errorMessage = 'Debes iniciar sesión para guardar eventos.';
      notifyListeners();
      return false;
    }

    final currentlyFavorite = currentUser.favorites.contains(eventId);

    try {
      if (currentlyFavorite) {
        await _userService.removeFavorite(
          userId: currentUser.id,
          eventId: eventId,
          token: currentToken,
        );
        currentUser.favorites.remove(eventId);
      } else {
        await _userService.addFavorite(
          userId: currentUser.id,
          eventId: eventId,
          token: currentToken,
        );
        currentUser.favorites.add(eventId);
      }

      notifyListeners();
      return !currentlyFavorite;
    } catch (e) {
      _errorMessage = 'No se pudo actualizar favoritos: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _syncFcmToken(String userId) async {
    try {
      final token = await _fcmService.obtenerFcmToken();
      if (token == null || token.isEmpty) {
        return;
      }
      await _userService.updateFcmToken(userId: userId, fcmToken: token);
    } catch (_) {
      // Ignore token sync errors for now.
    }
  }
}
