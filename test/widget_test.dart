import 'package:flutter_test/flutter_test.dart';

import 'package:finanzas_personales/main.dart';

void main() {
  testWidgets('La app arranca y muestra la pantalla de inicio', (WidgetTester tester) async {
    await tester.pumpWidget(const FinanzasApp());
    await tester.pump();

    expect(find.text('MiFinanzas'), findsOneWidget);
  });
}
