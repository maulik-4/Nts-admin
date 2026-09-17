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
  testWidgets('LoginScreen does NOT contain Register Firm or Add Firm options', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith((ref) => _MockAuthNotifier()),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Verify appropriate auth features ARE present
    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Accept Invite'), findsOneWidget);

    // CRITICAL REQUIREMENT #4: Add Firm / Register Firm MUST NOT be on the Login page
    expect(find.text('Register Firm'), findsNothing);
    expect(find.text('Add Firm'), findsNothing);
    expect(find.text('Create Firm'), findsNothing);
    expect(find.text('New law firm? '), findsNothing);
  });
}
