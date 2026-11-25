import 'package:flutter/material.dart';

import '../database/tareas_db.dart';
import '../services/preferencias_service.dart';

class TareasPage extends StatefulWidget {
  const TareasPage({super.key});

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();

  List<Map<String, dynamic>> _tareas = [];

  String _filtro = 'Todas';
  int? _idSeleccionado;
  bool _ocupado = false;

  final List<String> _filtros = ['Todas', 'Pendientes', 'Completadas'];

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  // Cargar tareas y filtro almacenado
  Future<void> _inicializar() async {
    await _ejecutar(() async {
      final filtro = await PreferenciasService.leerFiltro();
      final tareas = await TareasDB.listar();

      if (!mounted) return;

      setState(() {
        _filtro = _filtros.contains(filtro) ? filtro : 'Todas';
        _tareas = tareas;
      });
    });
  }

  // Consultar las tareas
  Future<void> _cargarTareas() async {
    final tareas = await TareasDB.listar();

    if (!mounted) return;

    setState(() {
      _tareas = tareas;
    });
  }

  // Control de operaciones y errores
  Future<void> _ejecutar(Future<void> Function() operacion) async {
    if (_ocupado || !mounted) return;

    setState(() => _ocupado = true);

    try {
      await operacion();
    } catch (e) {
      _mostrarMensaje('Error al realizar la operación: $e');
    } finally {
      if (mounted) {
        setState(() => _ocupado = false);
      }
    }
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // Filtrar las tareas
  List<Map<String, dynamic>> get _tareasFiltradas {
    if (_filtro == 'Pendientes') {
      return _tareas.where((tarea) => tarea['completada'] == 0).toList();
    }

    if (_filtro == 'Completadas') {
      return _tareas.where((tarea) => tarea['completada'] == 1).toList();
    }

    return _tareas;
  }

  // Guardar el filtro seleccionado
  Future<void> _cambiarFiltro(String filtro) async {
    await _ejecutar(() async {
      await PreferenciasService.guardarFiltro(filtro);

      if (!mounted) return;

      setState(() {
        _filtro = filtro;
      });
    });
  }

  // Crear o actualizar una tarea
  Future<void> _guardarTarea() async {
    final titulo = _tituloController.text.trim();
    final descripcion = _descripcionController.text.trim();
    final id = _idSeleccionado;

    if (titulo.isEmpty || descripcion.isEmpty) {
      _mostrarMensaje('Completa todos los campos');
      return;
    }

    await _ejecutar(() async {
      if (id == null) {
        await TareasDB.insertar(titulo, descripcion);
      } else {
        await TareasDB.actualizar(id, titulo, descripcion);
      }

      if (!mounted) return;

      _limpiarCampos();
      await _cargarTareas();

      _mostrarMensaje(
        id == null
            ? 'Tarea registrada correctamente'
            : 'Tarea actualizada correctamente',
      );
    });
  }

  // Seleccionar una tarea para editar
  void _seleccionarTarea(Map<String, dynamic> tarea) {
    if (_ocupado) return;

    setState(() {
      _idSeleccionado = tarea['id'] as int;
      _tituloController.text = tarea['titulo'] as String;
      _descripcionController.text = tarea['descripcion'] as String;
    });
  }

  // Cambiar el estado de una tarea
  Future<void> _cambiarEstado(int id, bool completada) async {
    await _ejecutar(() async {
      await TareasDB.cambiarEstado(id, completada);
      await _cargarTareas();

      _mostrarMensaje(
        completada ? 'Tarea completada' : 'Tarea marcada como pendiente',
      );
    });
  }

  // Eliminar una tarea
  Future<void> _eliminarTarea(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: const Text('¿Deseas eliminar esta tarea?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    await _ejecutar(() async {
      await TareasDB.eliminar(id);

      if (!mounted) return;

      if (_idSeleccionado == id) {
        _limpiarCampos();
      }

      await _cargarTareas();
      _mostrarMensaje('Tarea eliminada correctamente');
    });
  }

  void _limpiarCampos() {
    setState(() {
      _idSeleccionado = null;
      _tituloController.clear();
      _descripcionController.clear();
    });
  }

  // Contadores de tareas
  Widget _contador(String titulo, int cantidad) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Text(
                '$cantidad',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completadas = _tareas
        .where((tarea) => tarea['completada'] == 1)
        .length;

    final pendientes = _tareas.length - completadas;

    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de tareas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.storage),
            title: Text('Almacenamiento local'),
            subtitle: Text('Disponible sin Internet'),
          ),

          if (_ocupado) const LinearProgressIndicator(),

          Row(
            children: [
              _contador('Total', _tareas.length),
              _contador('Pendientes', pendientes),
              _contador('Completadas', completadas),
            ],
          ),

          const Divider(height: 32),

          Text(
            _idSeleccionado == null ? 'Nueva tarea' : 'Editar tarea',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _tituloController,
            enabled: !_ocupado,
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _descripcionController,
            enabled: !_ocupado,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _ocupado ? null : _guardarTarea,
                icon: Icon(_idSeleccionado == null ? Icons.add : Icons.save),
                label: Text(
                  _idSeleccionado == null ? 'Agregar tarea' : 'Guardar cambios',
                ),
              ),

              OutlinedButton(
                onPressed: _ocupado ? null : _limpiarCampos,
                child: const Text('Limpiar'),
              ),
            ],
          ),

          const Divider(height: 32),

          Text('Mis tareas', style: Theme.of(context).textTheme.titleLarge),

          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            children: _filtros.map((filtro) {
              return ChoiceChip(
                label: Text(filtro),
                selected: _filtro == filtro,
                onSelected: _ocupado ? null : (_) => _cambiarFiltro(filtro),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          if (_tareasFiltradas.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No hay tareas para mostrar'),
            ),

          ..._tareasFiltradas.map((tarea) {
            final id = tarea['id'] as int;
            final completada = tarea['completada'] == 1;

            return Card(
              child: ListTile(
                leading: Checkbox(
                  value: completada,
                  onChanged: _ocupado
                      ? null
                      : (valor) {
                          _cambiarEstado(id, valor ?? false);
                        },
                ),

                title: Text(
                  tarea['titulo'] as String,
                  style: TextStyle(
                    decoration: completada
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),

                subtitle: Text(
                  '${tarea['descripcion']}\n'
                  '${completada ? 'Completada' : 'Pendiente'}',
                ),

                onTap: _ocupado ? null : () => _seleccionarTarea(tarea),

                trailing: PopupMenuButton<String>(
                  enabled: !_ocupado,
                  onSelected: (opcion) {
                    if (opcion == 'editar') {
                      _seleccionarTarea(tarea);
                    } else if (opcion == 'eliminar') {
                      _eliminarTarea(id);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'editar', child: Text('Editar')),
                    PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
