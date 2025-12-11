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
  bool _isLoading = false;

  void _doRegister() async {
    if (_pass1Ctrl.text != _pass2Ctrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Las contraseñas no coinciden"), backgroundColor: Colors.orange));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _api.register(_nombreCtrl.text, _emailCtrl.text, _pass1Ctrl.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cuenta creada. Inicia sesión."), backgroundColor: Colors.green));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fallo: $e"), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.indigo.shade800, Colors.blue.shade400]),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Align(alignment: Alignment.centerLeft, child: BackButton(color: Colors.white)),
                Icon(Icons.person_add, size: 80, color: Colors.white),
                SizedBox(height: 20),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Text("Crear Cuenta", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(height: 20),
                        TextField(controller: _nombreCtrl, decoration: InputDecoration(labelText: "Nombre", prefixIcon: Icon(Icons.person))),
                        SizedBox(height: 15),
                        TextField(controller: _emailCtrl, decoration: InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email))),
                        SizedBox(height: 15),
                        TextField(controller: _pass1Ctrl, decoration: InputDecoration(labelText: "Contraseña", prefixIcon: Icon(Icons.lock)), obscureText: true),
                        SizedBox(height: 15),
                        TextField(controller: _pass2Ctrl, decoration: InputDecoration(labelText: "Confirmar", prefixIcon: Icon(Icons.lock_outline)), obscureText: true),
                        SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: _isLoading 
                            ? Center(child: CircularProgressIndicator()) 
                            : ElevatedButton(onPressed: _doRegister, child: Text("REGISTRAR")),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}