import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/overview_screen.dart'; // 1. Nova importação do Hub de Semáforos
import '../screens/splash_screen.dart';
import '../screens/register_screen.dart'; 

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const overview = '/overview'; // 2. Rota para a Central de Monitoramento
  static const home = '/home'; // 3. Rota para os Gráficos
  static const register = '/register'; 

  static final routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    overview: (context) => const OverviewScreen(), // 4. O destino macro
    home: (context) => const HomeScreen(), // 5. O destino detalhado
    register: (context) => const RegisterScreen(), 
  };
}