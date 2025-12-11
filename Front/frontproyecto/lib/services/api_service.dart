import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Asegúrate de que esta IP sea la correcta (tu IP local si usas celular físico)
  final String baseUrl = "http://10.0.2.2:8000"; 

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception("El usuario no existe");
      } else if (response.statusCode == 401) {
        throw Exception("Contraseña incorrecta");
      } else {
        throw Exception("Error del servidor: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error de conexión: $e");
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
      throw Exception("Error al registrar: ${response.body}");
    }
  }

  // --- NUEVA FUNCIÓN: Obtener Pedidos ---
  Future<List<dynamic>> getPedidos() async {
    final response = await http.get(Uri.parse('$baseUrl/pedidos'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error cargando pedidos');
    }
  }

  // --- NUEVA FUNCIÓN: Crear Pedido ---
  Future<void> createPedido(String cliente, String telefono, String direccion, String vendedor) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pedidos'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "cliente_nombre": cliente,
        "telefono": telefono,
        "fecha_entrega": DateTime.now().add(Duration(days: 1)).toIso8601String(), // Entrega mañana por defecto
        "vendedor": vendedor,
        "direccion": direccion
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Error al crear pedido: ${response.body}");
    }
  }

  // --- CRUD RUTAS ---

  // 1. Obtener todas las rutas
  Future<List<dynamic>> getRutas() async {
    final response = await http.get(Uri.parse('$baseUrl/rutas'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar rutas: ${response.statusCode}');
    }
  }

  // 2. Crear una nueva ruta
  Future<void> createRuta(String nombre, String zona, int numTiendas, String descripcion) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rutas'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nombre_ruta": nombre,
        "zona_asignada": zona,
        "num_tiendas": numTiendas,
        "descripcion": descripcion
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Error al crear ruta: ${response.body}");
    }
  }

  // 3. Actualizar una ruta existente
  Future<void> updateRuta(int id, String nombre, String zona, int numTiendas, String descripcion) async {
    final response = await http.put(
      Uri.parse('$baseUrl/rutas/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nombre_ruta": nombre,
        "zona_asignada": zona,
        "num_tiendas": numTiendas,
        "descripcion": descripcion
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Error al actualizar ruta: ${response.body}");
    }
  }

  // 4. Eliminar una ruta
  Future<void> deleteRuta(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/rutas/$id'));
    
    if (response.statusCode != 200) {
      throw Exception("Error al eliminar ruta: ${response.body}");
    }
  }

  // --- AGREGAR DENTRO DE LA CLASE ApiService ---

  // Actualizar pedido
  Future<void> updatePedido(int id, String cliente, String telefono, String direccion, String vendedor) async {
    final response = await http.put(
      Uri.parse('$baseUrl/pedidos/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "cliente_nombre": cliente,
        "telefono": telefono,
        "fecha_entrega": DateTime.now().add(Duration(days: 1)).toIso8601String(), // Mantiene fecha mañana
        "vendedor": vendedor,
        "direccion": direccion
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Error al actualizar pedido: ${response.body}");
    }
  }

  // Eliminar pedido
  Future<void> deletePedido(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/pedidos/$id'));
    
    if (response.statusCode != 200) {
      throw Exception("Error al eliminar pedido: ${response.body}");
    }
  }
}