import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_7/main.dart'; // Asegúrate de que la ruta sea correcta

void main() {
  testWidgets('Prueba de la lista de tareas: agregar, completar y eliminar', (WidgetTester tester) async {
    // Inicia la aplicación.
    await tester.pumpWidget(MyApp());

    // Verificar que las estadísticas iniciales son 0.
    expect(find.text('Total Tareas: 0'), findsOneWidget);
    expect(find.text('Completadas: 0'), findsOneWidget);
    expect(find.text('Progreso: 0%'), findsOneWidget);

    // Ingresar una tarea nueva.
    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);
    await tester.enterText(textFieldFinder, 'Tarea de prueba');

    // Tocar el ícono de agregar (botón en el suffixIcon del TextField).
    final addIconFinder = find.byIcon(Icons.add);
    expect(addIconFinder, findsOneWidget);
    await tester.tap(addIconFinder);
    await tester.pump(); // Actualizar la UI

    // Verificar que la tarea se agregó y que las estadísticas se actualizan.
    expect(find.text('Tarea de prueba'), findsOneWidget);
    expect(find.text('Total Tareas: 1'), findsOneWidget);
    expect(find.text('Completadas: 0'), findsOneWidget);
    expect(find.text('Progreso: 0%'), findsOneWidget);

    // Marcar la tarea como completada (se muestra un Checkbox).
    final checkboxFinder = find.byType(Checkbox);
    expect(checkboxFinder, findsOneWidget);
    await tester.tap(checkboxFinder);
    await tester.pump(); // Actualizar la UI

    // Verificar que la tarea está marcada como completada y las estadísticas actualizan.
    expect(find.text('Completadas: 1'), findsOneWidget);
    expect(find.text('Progreso: 100%'), findsOneWidget);

    // Eliminar la tarea utilizando el botón con el ícono delete.
    final deleteIconFinder = find.byIcon(Icons.delete);
    expect(deleteIconFinder, findsOneWidget);
    await tester.tap(deleteIconFinder);
    await tester.pump(); // Actualizar la UI

    // Verificar que la tarea ha sido eliminada y las estadísticas vuelven a 0.
    expect(find.text('Tarea de prueba'), findsNothing);
    expect(find.text('Total Tareas: 0'), findsOneWidget);
    expect(find.text('Completadas: 0'), findsOneWidget);
    expect(find.text('Progreso: 0%'), findsOneWidget);
  });
}
