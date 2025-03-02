import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Modelo de tarea
class Tarea {
  final String id;
  String titulo;
  bool completada;

  Tarea({required this.id, required this.titulo, this.completada = false});

  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      id: json['id'],
      titulo: json['titulo'],
      completada: json['completada'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'completada': completada,
    };
  }
}

// Provider para la gestión de tareas y persistencia
class TareasProvider extends ChangeNotifier {
  List<Tarea> _tareas = [];

  List<Tarea> get tareas => _tareas;

  TareasProvider() {
    cargarTareas();
  }

  // Crear tarea
  void agregarTarea(String titulo) {
    final nuevaTarea = Tarea(
      id: DateTime.now().toString(),
      titulo: titulo,
    );
    _tareas.add(nuevaTarea);
    guardarTareas();
    notifyListeners();
  }

  // Actualizar tarea (editar título)
  void actualizarTarea(String id, String nuevoTitulo) {
    final index = _tareas.indexWhere((tarea) => tarea.id == id);
    if (index != -1) {
      _tareas[index].titulo = nuevoTitulo;
      guardarTareas();
      notifyListeners();
    }
  }

  // Alternar estado completado
  void toggleCompletada(String id) {
    final index = _tareas.indexWhere((tarea) => tarea.id == id);
    if (index != -1) {
      _tareas[index].completada = !_tareas[index].completada;
      guardarTareas();
      notifyListeners();
    }
  }

  // Eliminar tarea
  void eliminarTarea(String id) {
    _tareas.removeWhere((tarea) => tarea.id == id);
    guardarTareas();
    notifyListeners();
  }

  // Estadísticas
  int get totalTareas => _tareas.length;
  int get tareasCompletadas => _tareas.where((tarea) => tarea.completada).length;
  double get progreso => totalTareas == 0 ? 0 : tareasCompletadas / totalTareas;

  // Persistencia: Guardar tareas en SharedPreferences
  Future<void> guardarTareas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tareasJson = _tareas.map((tarea) => jsonEncode(tarea.toJson())).toList();
    await prefs.setStringList('tareas', tareasJson);
  }

  // Persistencia: Cargar tareas
  Future<void> cargarTareas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? tareasJson = prefs.getStringList('tareas');
    if (tareasJson != null) {
      _tareas = tareasJson.map((jsonStr) => Tarea.fromJson(jsonDecode(jsonStr))).toList();
      notifyListeners();
    }
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TareasProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tareas - Kortex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(secondary: Colors.blueAccent),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TareasScreen(),
    );
  }
}

class TareasScreen extends StatelessWidget {
  const TareasScreen({Key? key}) : super(key: key);

  // Diálogo para agregar tarea
  void _mostrarDialogoAgregar(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar Tarea'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Ingresa el título de la tarea',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Colors.blueGrey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Agregar'),
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  Provider.of<TareasProvider>(context, listen: false)
                      .agregarTarea(_controller.text.trim());
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Diálogo para editar tarea
  void _mostrarDialogoEditar(BuildContext context, Tarea tarea) {
    final TextEditingController _controller = TextEditingController(text: tarea.titulo);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Tarea'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Editar título de la tarea',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Colors.blueGrey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Guardar'),
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  Provider.of<TareasProvider>(context, listen: false)
                      .actualizarTarea(tarea.id, _controller.text.trim());
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskCard(BuildContext context, Tarea tarea) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          tarea.titulo,
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87,
            decoration: tarea.completada ? TextDecoration.lineThrough : null,
          ),
        ),
        leading: Checkbox(
          value: tarea.completada,
          activeColor: Colors.blue,
          onChanged: (bool? value) {
            Provider.of<TareasProvider>(context, listen: false).toggleCompletada(tarea.id);
          },
        ),
        trailing: Wrap(
          spacing: 12,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blueAccent),
              onPressed: () => _mostrarDialogoEditar(context, tarea),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () {
                Provider.of<TareasProvider>(context, listen: false).eliminarTarea(tarea.id);
              },
            ),
          ],
        ),
        onTap: () => _mostrarDialogoEditar(context, tarea),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo general claro para contrastar con los tonos azules
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Lista de Tareas!',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade800, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Consumer<TareasProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Sección de estadísticas con diseño moderno
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.blue.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Estadísticas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text('Total', style: TextStyle(fontSize: 16, color: Colors.blue.shade700)),
                              SizedBox(height: 4),
                              Text(
                                '${provider.totalTareas}',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Completadas', style: TextStyle(fontSize: 16, color: Colors.blue.shade700)),
                              SizedBox(height: 4),
                              Text(
                                '${provider.tareasCompletadas}',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: provider.progreso,
                          minHeight: 8,
                          backgroundColor: Colors.blue.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Progreso: ${(provider.progreso * 100).toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 16, color: Colors.blue.shade700),
                      ),
                    ],
                  ),
                ),
              ),
              // Lista de tareas
              Expanded(
                child: provider.tareas.isEmpty
                    ? Center(
                        child: Text(
                          'No hay tareas. ¡Agrega una nueva tarea!',
                          style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.tareas.length,
                        itemBuilder: (context, index) {
                          final tarea = provider.tareas[index];
                          return _buildTaskCard(context, tarea);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
        onPressed: () => _mostrarDialogoAgregar(context),
      ),
      // Footer moderno
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            '© 2025 Keury Ramirez',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
