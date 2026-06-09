import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/leitura.dart';
import 'auth_provider.dart'; // Importante: precisamos do AuthProvider aqui

class LeituraProvider with ChangeNotifier {
  List<Leitura> _historico = [];
  bool _isLoading = false;

  List<Leitura> get historico => _historico;
  bool get isLoading => _isLoading;

  final String _baseUrl = 'http://192.168.0.68:3000:3000/api/v1/leituras';

  // O context é necessário para buscar o token do AuthProvider
  Future<void> buscarHistorico(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Pega o token do seu AuthProvider
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      
      print("Token utilizado na requisição: $token"); // Debug para ver se o token existe

      final response = await http.get(
        Uri.parse('$_baseUrl/historico'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // 2. Autenticação obrigatória aqui
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> dadosJson = json.decode(response.body);
        _historico = dadosJson.map((json) => Leitura.fromJson(json)).toList();
        _historico.sort((a, b) => b.dataRegistro.compareTo(a.dataRegistro));
        print("Provider: Dados carregados! Total: ${_historico.length}");
      } else if (response.statusCode == 401) {
        print("Erro 401: Usuário não autorizado. Verifique seu token.");
      } else {
        print('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro de conexão no Provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}