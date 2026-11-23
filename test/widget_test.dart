import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_integradormovil_equipo_4/main.dart';

void main() {
  testWidgets('La pantalla de geolocalización se muestra correctamente', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());

    expect(find.text('Mi ubicación GPS'), findsOneWidget);
    expect(find.text('Geolocalización'), findsOneWidget);
    expect(
      find.text('Obtén las coordenadas actuales de tu dispositivo.'),
      findsOneWidget,
    );
    expect(find.text('Obtener mi ubicación'), findsOneWidget);
    await tester.ensureVisible(find.text('Mis puntos de interés'));
    await tester.pumpAndSettle();

    expect(find.text('Mis puntos de interés'), findsOneWidget);
  });
}
