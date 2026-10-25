import 'package:flutter_test/flutter_test.dart';
import 'package:alce_yatri_passenger/main.dart';

void main() {
  testWidgets('Mostra tela de passageiro', (tester) async {
    await tester.pumpWidget(const PassengerApp());
    expect(find.text('Alce Yatri • Passageiro'), findsOneWidget);
    expect(find.text('Solicitar corrida de teste'), findsOneWidget);
  });
}
