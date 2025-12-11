import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Importamos tu pantalla de login

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Distribuidora App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Aquí le decimos que arranque directamente con el Login
      home: LoginScreen(), 
    );
  }
}