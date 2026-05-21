import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/splash_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';

  static final routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
  };
}