import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RoutesScreen extends StatefulWidget {
  @override
  _RoutesScreenState createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  final ApiService _api = ApiService();
  late Future<List<dynamic>> _rutasFuture;

  @override
  void initState() {
    super.initState();
    _refreshRutas();
  }

  void _refreshRutas() {
    setState(() {
      _rutasFuture = _api.getRutas();
    });
  }

  // Formulario para Crear o Editar
  void _mostrarFormulario({Map<String, dynamic>? ruta}) {
    final bool esEdicion = ruta != null;
    final _nombreCtrl = TextEditingController(text: esEdicion ? ruta['NombreRuta'] : '');
    final _zonaCtrl = TextEditingController(text: esEdicion ? ruta['ZonaAsignada'] : '');
    final _numTiendasCtrl = TextEditingController(text: esEdicion ? ruta['NumTiendas'].toString() : '');
    final _descCtrl = TextEditingController(text: esEdicion ? ruta['Descripcion'] : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(esEdicion ? "Editar Ruta" : "Nueva Ruta"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nombreCtrl, decoration: InputDecoration(labelText: "Nombre Ruta")),
              TextField(controller: _zonaCtrl, decoration: InputDecoration(labelText: "Zona")),
              TextField(
                controller: _numTiendasCtrl, 
                decoration: InputDecoration(labelText: "N° Tiendas"),
                keyboardType: TextInputType.number,
              ),
              TextField(controller: _descCtrl, decoration: InputDecoration(labelText: "Descripción")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              try {
                if (esEdicion) {
                  await _api.updateRuta(
                    ruta['ID'],
                    _nombreCtrl.text,
                    _zonaCtrl.text,
                    int.parse(_numTiendasCtrl.text),
                    _descCtrl.text
                  );
                } else {
                  await _api.createRuta(
                    _nombreCtrl.text,
                    _zonaCtrl.text,
                    int.parse(_numTiendasCtrl.text),
                    _descCtrl.text
                  );
                }
                Navigator.pop(context);
                _refreshRutas();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(esEdicion ? "Ruta actualizada" : "Ruta creada")));
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
        title: Text("Eliminar Ruta"),
        content: Text("¿Estás seguro de que quieres eliminar esta ruta?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
          TextButton(
            onPressed: () async {
              try {
                await _api.deleteRuta(id);
                Navigator.pop(context);
                _refreshRutas();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ruta eliminada")));
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
      appBar: AppBar(title: Text("Gestión de Rutas")),
      body: FutureBuilder<List<dynamic>>(
        future: _rutasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No hay rutas registradas."));

          final rutas = snapshot.data!;
          return ListView.builder(
            itemCount: rutas.length,
            itemBuilder: (context, index) {
              final r = rutas[index];
              return Card(
                child: ListTile(
                  title: Text(r['NombreRuta'] ?? 'Sin nombre'),
                  subtitle: Text("Zona: ${r['ZonaAsignada']} | Tiendas: ${r['NumTiendas']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _mostrarFormulario(ruta: r),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmarEliminar(r['ID']),
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
        backgroundColor: Colors.green,
      ),
    );
  }
}