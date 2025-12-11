import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pass1Ctrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  final ApiService _api = ApiService();

  void _doRegister() async {
    print("Intentando registrar..."); // 1. Ver si entra a la función
    
    if (_pass1Ctrl.text != _pass2Ctrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Las contraseñas no coinciden")));
      return;
    }

    try {
      print("Enviando datos a la API..."); // 2. Ver si intenta conectar
      await _api.register(_nombreCtrl.text, _emailCtrl.text, _pass1Ctrl.text);
      
      print("Registro exitoso"); // 3. Éxito
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cuenta creada. Inicia sesión.")));
      Navigator.pop(context); 

    } catch (e) {
      print("ERROR: $e"); // 4. Ver el error en la consola de abajo
      // Muestra el error técnico en la pantalla para que sepamos qué es
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fallo: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Crear Cuenta")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nombreCtrl, decoration: InputDecoration(labelText: "Nombre")),
            TextField(controller: _emailCtrl, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: _pass1Ctrl, decoration: InputDecoration(labelText: "Contraseña"), obscureText: true),
            TextField(controller: _pass2Ctrl, decoration: InputDecoration(labelText: "Confirmar Contraseña"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _doRegister, child: Text("Registrar")),
          ],
        ),
      ),
    );
  }
}