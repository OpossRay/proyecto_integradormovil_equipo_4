import 'package:flutter_test/flutter_test.dart';

import 'package:proyecto_integradormovil_equipo_4/main.dart';

void main() {
  testWidgets('La aplicación muestra sus tres secciones', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // Comprobar las opciones de navegación.
    expect(find.text('Cámara'), findsOneWidget);
    expect(find.text('Sensores'), findsOneWidget);
    expect(find.text('Bitácora'), findsOneWidget);

    // Navegar a la bitácora.
    await tester.tap(find.text('Bitácora'));

    // Avanzar el reloj de la prueba sin esperar animaciones infinitas.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Comprobar que se abrió la pantalla.
    expect(find.text('Bitácora de inspecciones'), findsOneWidget);
  });
}
