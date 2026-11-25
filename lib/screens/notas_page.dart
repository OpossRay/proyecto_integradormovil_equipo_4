import 'package:flutter/material.dart';

import '../database/db.dart';
import '../services/preferencias_service.dart';

class NotasPage extends StatefulWidget {
  const NotasPage({super.key});

  @override
  State<NotasPage> createState() => _NotasPageState();
}

class _NotasPageState extends State<NotasPage> {
  final _nombreController = TextEditingController();
  final _tituloController = TextEditingController();
  final _contenidoController = TextEditingController();

  List<Map<String, dynamic>> _notas = [];

  String _nombre = 'Invitado';
  int? _idSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Recuperar nombre y notas
  Future<void> _cargarDatos() async {
    final nombre = await PreferenciasService.leerNombre();
    final notas = await DB.listar();

    if (!mounted) return;

    setState(() {
      _nombre = nombre;
      _nombreController.text = nombre;
      _notas = notas;
    });
  }

  // Guardar nombre del usuario
  Future<void> _guardarNombre() async {
    final nombre = _nombreController.text.trim();

    if (nombre.isEmpty) {
      _mostrarMensaje('Ingresa un nombre');
      return;
    }

    await PreferenciasService.guardarNombre(nombre);

    if (!mounted) return;

    setState(() {
      _nombre = nombre;
    });

    _mostrarMensaje('Nombre guardado');
  }

  // Consultar las notas
  Future<void> _cargarNotas() async {
    final notas = await DB.listar();

    if (!mounted) return;

    setState(() {
      _notas = notas;
    });
  }

  // Registrar una nota
  Future<void> _guardarNota() async {
    final titulo = _tituloController.text.trim();
    final contenido = _contenidoController.text.trim();

    if (titulo.isEmpty || contenido.isEmpty) {
      _mostrarMensaje('Completa todos los campos');
      return;
    }

    await DB.insertar(titulo, contenido);

    if (!mounted) return;

    _limpiarCampos();
    await _cargarNotas();

    _mostrarMensaje('Nota guardada correctamente');
  }

  // Seleccionar una nota
  void _seleccionarNota(Map<String, dynamic> nota) {
    setState(() {
      _idSeleccionado = nota['id'] as int;
      _tituloController.text = nota['titulo'] as String;
      _contenidoController.text = nota['contenido'] as String;
    });
  }

  // Actualizar una nota
  Future<void> _actualizarNota() async {
    if (_idSeleccionado == null) {
      _mostrarMensaje('Selecciona una nota');
      return;
    }

    final titulo = _tituloController.text.trim();
    final contenido = _contenidoController.text.trim();

    if (titulo.isEmpty || contenido.isEmpty) {
      _mostrarMensaje('Completa todos los campos');
      return;
    }

    await DB.actualizar(_idSeleccionado!, titulo, contenido);

    if (!mounted) return;

    _limpiarCampos();
    await _cargarNotas();

    _mostrarMensaje('Nota actualizada correctamente');
  }

  // Eliminar con confirmación
  Future<void> _eliminarNota(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar nota'),
          content: const Text('¿Deseas eliminar esta nota?'),
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
        );
      },
    );

    if (confirmar != true || !mounted) return;

    await DB.eliminar(id);

    if (!mounted) return;

    if (_idSeleccionado == id) {
      _limpiarCampos();
    }

    await _cargarNotas();

    _mostrarMensaje('Nota eliminada');
  }

  // Limpiar el formulario
  void _limpiarCampos() {
    setState(() {
      _idSeleccionado = null;
      _tituloController.clear();
      _contenidoController.clear();
    });
  }

  // Mostrar mensajes
  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _tituloController.dispose();
    _contenidoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de notas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Hola, $_nombre',
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _nombreController,
            decoration: const InputDecoration(
              labelText: 'Nombre de usuario',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 8),

          OutlinedButton(
            onPressed: _guardarNombre,
            child: const Text('Guardar nombre'),
          ),

          const Divider(height: 32),

          Text(
            _idSeleccionado == null ? 'Nueva nota' : 'Editar nota',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _tituloController,
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _contenidoController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Contenido',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _idSeleccionado == null ? _guardarNota : null,
                child: const Text('Guardar'),
              ),
              FilledButton.tonal(
                onPressed: _idSeleccionado != null ? _actualizarNota : null,
                child: const Text('Actualizar'),
              ),
              OutlinedButton(
                onPressed: _limpiarCampos,
                child: const Text('Limpiar'),
              ),
            ],
          ),

          const Divider(height: 32),

          Text('Mis notas', style: Theme.of(context).textTheme.titleLarge),

          const SizedBox(height: 8),

          if (_notas.isEmpty) const Text('No hay notas registradas'),

          ..._notas.map(
            (nota) => Card(
              child: ListTile(
                title: Text(nota['titulo'] as String),
                subtitle: Text(
                  '${nota['contenido']}\n'
                  '${nota['pendiente_sincronizar'] == 1 ? 'Pendiente de sincronizar' : 'Sincronizada'}',
                ),
                onTap: () => _seleccionarNota(nota),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _eliminarNota(nota['id'] as int),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
