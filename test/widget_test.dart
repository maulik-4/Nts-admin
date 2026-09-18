import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/features/auth/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('Vidhanta application boots and displays splash brand image', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: NTSLegalProApp()));

    // Initial pump shows splash screen with splashScreen.png image asset
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/image/splashScreen.png',
      ),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Advance past splash timer and settle navigation transition
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 350));
  });
}
