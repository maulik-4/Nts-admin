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
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  testWidgets(
    'LoginScreen contains Vidhanta login options matching login.png mockup',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith((ref) => _MockAuthNotifier()),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Vidhanta Login features matching login.png ARE present
      expect(find.text('Firm Login'), findsOneWidget);
      expect(find.text('Client Login'), findsOneWidget);
      expect(find.text('Sign In as Firm'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.text('Have an invitation code?'), findsNothing);
      expect(find.text('Accept your invite to join'), findsNothing);
      expect(find.textContaining('New User?'), findsOneWidget);
      expect(
        find.textContaining('Get in Touch / Request Access'),
        findsOneWidget,
      );

      // Verify old raw text buttons are NOT present
      expect(find.text('Register Firm'), findsNothing);
      expect(find.text('Add Firm'), findsNothing);
      expect(find.text('Create Firm'), findsNothing);
      expect(find.text('New law firm? '), findsNothing);
    },
  );
}
