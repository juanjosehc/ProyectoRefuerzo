import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://10.0.2.2:8000"; // Cambia a tu IP local si usas dispositivo físico

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception("El usuario no existe");
    } else {
      throw Exception("Credenciales incorrectas");
    }
  }

  Future<void> register(String nombre, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nombre": nombre,
        "email": email,
        "password": password,
        "rol": "Vendedor"
      }),
    );
    if (response.statusCode != 200) {
      throw Exception("Error al registrar");
    }
  }

  // Método para obtener pedidos (Ejemplo CRUD)
  Future<List<dynamic>> getPedidos() async {
    final response = await http.get(Uri.parse('$baseUrl/pedidos'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error cargando pedidos');
    }
  }
}