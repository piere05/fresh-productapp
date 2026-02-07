import 'package:flutter_test/flutter_test.dart';
import 'package:project/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const FreshProductsApp());
    expect(find.text('Fresh Products App'), findsOneWidget);
  });
}
