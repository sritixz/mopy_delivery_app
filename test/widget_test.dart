import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mopy_delivery_app/main.dart';
import 'package:mopy_delivery_app/providers/auth_provider.dart';
import 'package:mopy_delivery_app/providers/duty_provider.dart';

void main() {
  testWidgets('Delivery App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => DutyProvider()),
        ],
        child: const MopyDeliveryApp(),
      ),
    );

    expect(find.byType(MopyDeliveryApp), findsOneWidget);
  });
}
