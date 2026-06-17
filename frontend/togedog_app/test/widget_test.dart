import 'package:flutter_test/flutter_test.dart';
import 'package:togedog/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TogedogApp());
  });
}
