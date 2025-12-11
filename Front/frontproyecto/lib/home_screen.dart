import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:frontproyecto/screens/routes_screen.dart';
import 'package:frontproyecto/screens/login_screen.dart';

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
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _mostrarFormulario({Map<String, dynamic>? pedido}) {
    final bool esEdicion = pedido != null;
    final _clienteCtrl = TextEditingController(text: esEdicion ? pedido['ClienteNombre'] : '');
    final _telCtrl = TextEditingController(text: esEdicion ? pedido['Telefono'] : '');
    final _dirCtrl = TextEditingController(text: esEdicion ? pedido['DireccionEntrega'] : '');
    final _vendedorCtrl = TextEditingController(text: esEdicion ? pedido['Vendedor'] : 'Juan');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Para que suba con el teclado
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(esEdicion ? "Editar Pedido" : "Nuevo Pedido", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
            SizedBox(height: 20),
            TextField(controller: _clienteCtrl, decoration: InputDecoration(labelText: "Cliente", prefixIcon: Icon(Icons.person_outline))),
            SizedBox(height: 15),
            TextField(controller: _telCtrl, decoration: InputDecoration(labelText: "Teléfono", prefixIcon: Icon(Icons.phone_android))),
            SizedBox(height: 15),
            TextField(controller: _dirCtrl, decoration: InputDecoration(labelText: "Dirección", prefixIcon: Icon(Icons.map_outlined))),
            SizedBox(height: 15),
            TextField(controller: _vendedorCtrl, decoration: InputDecoration(labelText: "Vendedor", prefixIcon: Icon(Icons.badge_outlined))),
            SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    Navigator.pop(context);
                    if (esEdicion) {
                      await _api.updatePedido(pedido['ID'], _clienteCtrl.text, _telCtrl.text, _dirCtrl.text, _vendedorCtrl.text);
                    } else {
                      await _api.createPedido(_clienteCtrl.text, _telCtrl.text, _dirCtrl.text, _vendedorCtrl.text);
                    }
                    _refreshPedidos();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Operación exitosa"), backgroundColor: Colors.green));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
                  }
                },
                child: Text("GUARDAR DATOS"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminar(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("¿Eliminar?"),
        content: Text("Esta acción no se puede deshacer."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
          TextButton(
            onPressed: () async {
              await _api.deletePedido(id);
              Navigator.pop(context);
              _refreshPedidos();
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Pedidos", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: Icon(Icons.local_shipping),
        actions: [
          IconButton(icon: Icon(Icons.map_rounded), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RoutesScreen()))),
          IconButton(icon: Icon(Icons.exit_to_app, color: Colors.redAccent), onPressed: _logout),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _pedidosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.inbox, size: 60, color: Colors.grey), Text("Sin pedidos")]));

          final pedidos = snapshot.data!;
          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: pedidos.length,
            separatorBuilder: (_, __) => SizedBox(height: 10),
            itemBuilder: (context, index) {
              final p = pedidos[index];
              return Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade50,
                      child: Text(p['ClienteNombre'][0].toUpperCase(), style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(p['ClienteNombre'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Row(children: [Icon(Icons.location_on, size: 14, color: Colors.grey), SizedBox(width: 4), Expanded(child: Text(p['DireccionEntrega']))]),
                        Row(children: [Icon(Icons.phone, size: 14, color: Colors.grey), SizedBox(width: 4), Text(p['Telefono'])]),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') _mostrarFormulario(pedido: p);
                        if (value == 'delete') _confirmarEliminar(p['ID']);
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Colors.blue), SizedBox(width: 10), Text("Editar")])),
                        PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 10), Text("Eliminar")])),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormulario(),
        label: Text("Nuevo Pedido"),
        icon: Icon(Icons.add),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }
}