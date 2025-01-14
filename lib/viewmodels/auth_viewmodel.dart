import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthViewModel with ChangeNotifier {
  final AuthService _authService;
  AppUser? _user;
  bool _isLoading = false;

  AuthViewModel(this._authService) {
    _authService.user.listen(_onAuthStateChanged);
  }

  AppUser? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> register(String nombre, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    AppUser? user =
        await _authService.registerWithEmail(nombre, email, password);
    _user = user;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    AppUser? user = await _authService.loginWithEmail(email, password);
    _user = user;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
    } else {
      _user = await _authService.getUserData(firebaseUser.uid);
    }
    notifyListeners();
  }
}
