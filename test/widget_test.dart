import 'package:flutter_test/flutter_test.dart';
import 'package:pair_iq/app.dart';

void main() {
  testWidgets('App loads home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PairIQApp());
    expect(find.text('Pair IQ'), findsOneWidget);
  });
}
