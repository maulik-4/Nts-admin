import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Vidhanta application boots and displays splash brand', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: NTSLegalProApp()));

    // Initial pump shows splash screen with app title
    expect(find.text('VIDHANTA'), findsOneWidget);
    expect(find.text('Legal Management System'), findsOneWidget);
  });
}
