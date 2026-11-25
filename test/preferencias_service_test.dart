import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto_integradormovil_equipo_4/services/preferencias_service.dart';

//import '../lib/services/preferencias_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Devuelve Invitado como nombre predeterminado', () async {
    final nombre = await PreferenciasService.leerNombre();

    expect(nombre, 'Invitado');
  });

  test('Guarda y recupera el nombre del usuario', () async {
    await PreferenciasService.guardarNombre('Charly');

    final nombre = await PreferenciasService.leerNombre();

    expect(nombre, 'Charly');
  });

  test('Devuelve Todas como filtro predeterminado', () async {
    final filtro = await PreferenciasService.leerFiltro();

    expect(filtro, 'Todas');
  });

  test('Guarda el filtro Pendientes', () async {
    await PreferenciasService.guardarFiltro('Pendientes');

    final filtro = await PreferenciasService.leerFiltro();

    expect(filtro, 'Pendientes');
  });

  test('Actualiza el filtro a Completadas', () async {
    await PreferenciasService.guardarFiltro('Pendientes');
    await PreferenciasService.guardarFiltro('Completadas');

    final filtro = await PreferenciasService.leerFiltro();

    expect(filtro, 'Completadas');
  });
}
