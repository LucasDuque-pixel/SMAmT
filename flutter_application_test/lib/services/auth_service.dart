import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "https://smamt-82zk.onrender.com";

  Future<bool> register({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'senha': senha,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print('Erro register: ${response.body}');
      return false;
    }
  }

  Future<Map<String, dynamic>?> login({
    required String email,
    required String senha,
    }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'senha': senha,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
     print('Erro login: ${response.body}');
     return null;
   } 
  }
}