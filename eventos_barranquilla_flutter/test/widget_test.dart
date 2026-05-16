import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eventos_barranquilla_flutter/app.dart';

void main() {
  testWidgets('renders editorial home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const EventosBarranquillaApp());

    expect(find.text('Eventos Barranquilla'), findsOneWidget);
    expect(find.text('Planes curados para salir hoy sin perder tiempo'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pump();
  });
}
