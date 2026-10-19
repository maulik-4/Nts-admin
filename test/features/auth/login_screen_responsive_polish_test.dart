import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/auth/presentation/providers/auth_notifier.dart';
import 'package:flutter_application_1/features/auth/presentation/providers/auth_state.dart';
import 'package:flutter_application_1/features/auth/presentation/screens/login_screen.dart';

class _MockAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  _MockAuthNotifier() : super(const AuthState.initial());

  @override
  void clearError() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  Widget buildTestApp({Size size = const Size(390, 844)}) {
    return ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith((ref) => _MockAuthNotifier()),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: const LoginScreen(),
        ),
      ),
    );
  }

  group('Vidhanta Login Screen Visual Polish & Responsive Layout Tests', () {
    testWidgets(
      'Header elements render correctly matching login.png with floating badge',
      (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Eyebrow and heading verification
        expect(find.text('LEGAL MANAGEMENT SYSTEM'), findsOneWidget);
        expect(find.textContaining('Welcome to'), findsOneWidget);
        expect(find.textContaining('Vidhanta'), findsOneWidget);
        expect(find.textContaining('Streamline your legal'), findsOneWidget);

        // Verify exactly two login segmented options
        expect(find.text('Firm Login'), findsOneWidget);
        expect(find.text('Client Login'), findsOneWidget);
        expect(find.byIcon(Icons.apartment_rounded), findsOneWidget);
        expect(find.byIcon(Icons.groups_rounded), findsOneWidget);

        // Verify floating logo badge with icon.png
        final imageWidgets = tester.widgetList<Image>(find.byType(Image));
        final iconAssets = imageWidgets.where((img) {
          if (img.image is AssetImage) {
            return (img.image as AssetImage).assetName == 'icon.png';
          }
          return false;
        });
        expect(iconAssets.length, 1);

        // Verify decorative background asset loginback.png is present
        final backgroundAssets = imageWidgets.where((img) {
          if (img.image is AssetImage) {
            return (img.image as AssetImage).assetName == 'loginback.png';
          }
          return false;
        });
        expect(backgroundAssets.length, 1);
      },
    );

    testWidgets(
      'Switching between Firm Login and Client Login updates state, hints, and button label',
      (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Default state: Firm Login
        expect(find.text('Sign In as Firm'), findsOneWidget);
        expect(find.text('Enter your firm username'), findsOneWidget);

        // Switch to Client Login
        await tester.tap(find.text('Client Login'));
        await tester.pumpAndSettle();

        expect(find.text('Sign In as Client'), findsOneWidget);
        expect(find.text('Enter your client username'), findsOneWidget);

        // Switch back to Firm Login
        await tester.tap(find.text('Firm Login'));
        await tester.pumpAndSettle();

        expect(find.text('Sign In as Firm'), findsOneWidget);
        expect(find.text('Enter your firm username'), findsOneWidget);
      },
    );

    testWidgets('Password visibility toggles between obscured and visible', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Initially password is obscured
      final textFields = tester.widgetList<TextField>(find.byType(TextField));
      expect(textFields.last.obscureText, isTrue);

      // Tap toggle eye icon
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();

      final updatedFields = tester.widgetList<TextField>(
        find.byType(TextField),
      );
      expect(updatedFields.last.obscureText, isFalse);
    });

    testWidgets('Mockup elements from login.png are rendered cleanly', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.text('Have an invitation code?'), findsNothing);
      expect(find.text('Accept your invite to join'), findsNothing);
      expect(find.text('OR'), findsNothing);
      expect(find.textContaining('New User?'), findsOneWidget);
      expect(
        find.textContaining('Get in Touch / Request Access'),
        findsOneWidget,
      );
      expect(find.text('Register Firm'), findsNothing);

      // Verify single-page fit: fits completely without needing to scroll on 390x844
      final scrollable = tester.stateList<ScrollableState>(find.byType(Scrollable)).first;
      expect(scrollable.position.maxScrollExtent, 0.0);
    });

    // Responsive checks on various screen widths and heights
    final responsiveSizes = [
      const Size(320, 568), // iPhone SE / small narrow device
      const Size(360, 640), // Android compact
      const Size(390, 844), // Standard iPhone
      const Size(430, 932), // iPhone Pro Max / large mobile
      const Size(768, 1024), // Tablet
      const Size(844, 390), // Landscape mobile
    ];

    for (final size in responsiveSizes) {
      testWidgets(
        'Renders cleanly without overflow on ${size.width}x${size.height}',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          FlutterErrorDetails? caughtDetails;
          final oldHandler = FlutterError.onError;
          FlutterError.onError = (details) {
            caughtDetails = details;
          };

          await tester.pumpWidget(buildTestApp(size: size));
          await tester.pumpAndSettle();

          FlutterError.onError = oldHandler;

          // Verify key widgets exist and no RenderFlex error was thrown
          expect(find.text('LEGAL MANAGEMENT SYSTEM'), findsOneWidget);
          expect(find.text('Firm Login'), findsOneWidget);
          expect(find.text('Client Login'), findsOneWidget);
          expect(find.text('Sign In as Firm'), findsOneWidget);
          expect(caughtDetails, isNull);
        },
      );
    }
  });
}
