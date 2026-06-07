import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isAuthenticated = false;
  bool _isLoading = true;

  String? _token;
  Map<String, dynamic>? _user;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;
  
  // ---> A SOLUÇÃO AQUI <---
  // Expondo o token publicamente para que o LeituraProvider possa usá-lo na requisição
  String? get token => _token;

  AuthProvider() {
    checkLogin();
  }

  Future<void> checkLogin() async {
    final token = await _storage.read(key: 'token');

    if (token != null) {
      _token = token;
      _isAuthenticated = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  // A MUDANÇA ESTÁ AQUI: Adicionamos o bool manterConectado
  Future<bool> login(String email, String senha, bool manterConectado) async {
    try {
      final response = await _authService.login(
        email: email,
        senha: senha,
      );

      if (response != null) {
        _token = response['token'];
        _user = response['user'];

        // Se o usuário marcou a caixa, salva fisicamente no navegador (persiste no F5)
        if (manterConectado) {
          await _storage.write(key: 'token', value: _token);
        }

        _isAuthenticated = true;
        notifyListeners();

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');

    _token = null;
    _user = null;
    _isAuthenticated = false;

    notifyListeners();
  }
}