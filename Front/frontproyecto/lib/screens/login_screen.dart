import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final ApiService _api = ApiService();

  void _doLogin() async {
    try {
      await _api.login(_emailCtrl.text, _passCtrl.text);
      // Si pasa, vamos al Home
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } catch (e) {
      // Aviso si el usuario no existe o error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login Distribuidora")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailCtrl, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: _passCtrl, decoration: InputDecoration(labelText: "Contraseña"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _doLogin, child: Text("Entrar")),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen())),
              child: Text("Crear cuenta"),
            )
          ],
        ),
      ),
    );
  }
}