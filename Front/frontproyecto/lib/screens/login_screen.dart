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
  bool _isLoading = false;

  void _doLogin() async {
    setState(() => _isLoading = true);
    try {
      await _api.login(_emailCtrl.text, _passCtrl.text);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade800, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_shipping_rounded, size: 100, color: Colors.white),
                SizedBox(height: 10),
                Text("Distribuidora", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                SizedBox(height: 40),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Text("Bienvenido", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                        SizedBox(height: 20),
                        TextField(
                          controller: _emailCtrl,
                          decoration: InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _passCtrl,
                          decoration: InputDecoration(labelText: "Contraseña", prefixIcon: Icon(Icons.lock)),
                          obscureText: true,
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: _isLoading 
                            ? Center(child: CircularProgressIndicator()) 
                            : ElevatedButton(onPressed: _doLogin, child: Text("INICIAR SESIÓN")),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen())),
                  child: Text("¿No tienes cuenta? Regístrate", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}