import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'routes_screen.dart';
import 'login_screen.dart'; // <--- Importante para poder volver al Login

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  late Future<List<dynamic>> _pedidosFuture;

  @override
  void initState() {
    super.initState();
    _refreshPedidos();
  }

  void _refreshPedidos() {
    setState(() {
      _pedidosFuture = _api.getPedidos();
    });
  }

  void _logout() {
    // Navegar al Login y eliminar todo el historial de pantallas anteriores
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  // Formulario único para Crear y Editar
  void _mostrarFormulario({Map<String, dynamic>? pedido}) {
    final bool esEdicion = pedido != null;
    final _clienteCtrl = TextEditingController(text: esEdicion ? pedido['ClienteNombre'] : '');
    final _telCtrl = TextEditingController(text: esEdicion ? pedido['Telefono'] : '');
    final _dirCtrl = TextEditingController(text: esEdicion ? pedido['DireccionEntrega'] : '');
    final _vendedorCtrl = TextEditingController(text: esEdicion ? pedido['Vendedor'] : 'Juan');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(esEdicion ? "Editar Pedido" : "Nuevo Pedido"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _clienteCtrl, decoration: InputDecoration(labelText: "Cliente")),
              TextField(controller: _telCtrl, decoration: InputDecoration(labelText: "Teléfono")),
              TextField(controller: _dirCtrl, decoration: InputDecoration(labelText: "Dirección")),
              TextField(controller: _vendedorCtrl, decoration: InputDecoration(labelText: "Vendedor")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              try {
                if (esEdicion) {
                  await _api.updatePedido(
                    pedido['ID'],
                    _clienteCtrl.text,
                    _telCtrl.text,
                    _dirCtrl.text,
                    _vendedorCtrl.text
                  );
                } else {
                  await _api.createPedido(
                    _clienteCtrl.text,
                    _telCtrl.text,
                    _dirCtrl.text,
                    _vendedorCtrl.text
                  );
                }
                Navigator.pop(context);
                _refreshPedidos();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(esEdicion ? "Pedido actualizado" : "Pedido creado")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Eliminar Pedido"),
        content: Text("¿Estás seguro de eliminar este pedido?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
          TextButton(
            onPressed: () async {
              try {
                await _api.deletePedido(id);
                Navigator.pop(context);
                _refreshPedidos();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pedido eliminado")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Pedidos"),
        actions: [
          // Botón CRUD Rutas
          IconButton(
            icon: Icon(Icons.map),
            tooltip: "Gestionar Rutas",
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => RoutesScreen()));
            },
          ),
          // Botón Refrescar
          IconButton(
            icon: Icon(Icons.refresh), 
            tooltip: "Recargar",
            onPressed: _refreshPedidos
          ),
          // --- BOTÓN CERRAR SESIÓN ---
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.redAccent), // Icono de salida
            tooltip: "Cerrar Sesión",
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _pedidosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error de conexión"));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No hay pedidos."));

          final pedidos = snapshot.data!;
          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final p = pedidos[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(child: Text(p['ID'].toString())),
                  title: Text(p['ClienteNombre'] ?? 'Sin nombre'),
                  subtitle: Text("${p['DireccionEntrega']} - ${p['Telefono']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _mostrarFormulario(pedido: p),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmarEliminar(p['ID']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        child: Icon(Icons.add),
      ),
    );
  }
}