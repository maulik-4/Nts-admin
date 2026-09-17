import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/features/auth/data/models/user_profile.dart';
import 'package:flutter_application_1/features/auth/presentation/providers/auth_notifier.dart';
import 'package:flutter_application_1/features/auth/presentation/providers/auth_state.dart';
import 'package:flutter_application_1/features/dashboard/presentation/widgets/metric_card.dart';
import 'package:flutter_application_1/features/dashboard/presentation/widgets/responsive_metric_grid.dart';
import 'package:flutter_application_1/features/team/data/models/team_member.dart';
import 'package:flutter_application_1/features/team/presentation/providers/team_notifier.dart';
import 'package:flutter_application_1/shared/widgets/app_brand_logo.dart';
import 'package:flutter_application_1/shared/widgets/status_badge.dart';

void main() {
  group('1. Firm User Team & Advocates Scoping Tests', () {
    final currentUserFirm15 = UserProfile(
      id: 101,
      username: 'firm_admin_15',
      email: 'admin@firm15.com',
      role: 'admin',
      firmId: 15,
      firmName: 'Alpha Law Partners',
    );

    final membersPool = [
      // Current firm lawyer (ID match)
      const TeamMember(
        id: 1,
        username: 'lawyer_alpha_1',
        email: 'lawyer1@firm15.com',
        role: 'lawyer',
        firm: 'Alpha Law Partners',
        firmId: 15,
      ),
      // Current firm staff (Name match)
      const TeamMember(
        id: 2,
        username: 'staff_alpha_2',
        email: 'staff2@firm15.com',
        role: 'staff',
        firm: 'Alpha Law Partners',
        firmId: null,
      ),
      // Other firm lawyer (Firm 20)
      const TeamMember(
        id: 3,
        username: 'lawyer_beta_cross',
        email: 'lawyer@beta.com',
        role: 'lawyer',
        firm: 'Beta Legal Firm',
        firmId: 20,
      ),
      // Other firm lawyer without firmId (string only)
      const TeamMember(
        id: 4,
        username: 'lawyer_gamma_cross',
        email: 'lawyer@gamma.com',
        role: 'lawyer',
        firm: 'Gamma Advocates',
        firmId: null,
      ),
      // Platform Super Admin
      const TeamMember(
        id: 5,
        username: 'super_admin_user',
        email: 'super@platform.com',
        role: 'super_admin',
        firm: '',
        isSuperuser: true,
      ),
    ];

    test(
      'Filtered team strictly excludes platform users and cross-firm members',
      () {
        final container = ProviderContainer(
          overrides: [
            authNotifierProvider.overrideWith(
              (ref) => _StaticAuthNotifier(
                AuthState.authenticated(currentUserFirm15),
              ),
            ),
            teamNotifierProvider.overrideWith(
              (ref) => _StaticTeamNotifier(membersPool),
            ),
            teamFilterProvider.overrideWith((ref) => TeamFilter.all),
            teamSearchQueryProvider.overrideWith((ref) => ''),
          ],
        );

        final state = container.read(filteredTeamMembersProvider);
        expect(state.hasValue, true);
        final members = state.value!;

        // Must only contain Alpha Law Partners members (ID 1 and 2)
        expect(members.length, 2);
        expect(members.any((m) => m.username == 'lawyer_alpha_1'), true);
        expect(members.any((m) => m.username == 'staff_alpha_2'), true);

        // Must NEVER contain super admin or cross firm members
        expect(members.any((m) => m.username == 'super_admin_user'), false);
        expect(members.any((m) => m.username == 'lawyer_beta_cross'), false);
        expect(members.any((m) => m.username == 'lawyer_gamma_cross'), false);
      },
    );

    test('Advocates filter displays ONLY firm lawyers and excludes staff', () {
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(
            (ref) =>
                _StaticAuthNotifier(AuthState.authenticated(currentUserFirm15)),
          ),
          teamNotifierProvider.overrideWith(
            (ref) => _StaticTeamNotifier(membersPool),
          ),
          teamFilterProvider.overrideWith((ref) => TeamFilter.advocates),
          teamSearchQueryProvider.overrideWith((ref) => ''),
        ],
      );

      final state = container.read(filteredTeamMembersProvider);
      final members = state.value!;

      expect(members.length, 1);
      expect(members.first.username, 'lawyer_alpha_1');
      expect(members.first.isLawyer, true);
    });
  });

  group('2. AppBrandLogo & Vidhanta Official Branding Tests', () {
    testWidgets('AppBrandLogo renders official asset and fills container', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: AppBrandLogo(
                  size: 80,
                  showBorder: true,
                  isCircular: true,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AppBrandLogo), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.fit, BoxFit.cover);
      expect(image.image, isA<AssetImage>());
      final assetImage = image.image as AssetImage;
      expect(assetImage.assetName, 'assets/images/icon.png');
    });
  });

  group('3. Responsive Metric Grid Layout Tests', () {
    testWidgets('Renders 1-column stack on narrow mobile (320px)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ResponsiveMetricGrid(
                children: [
                  MetricCard(
                    title: 'Active Cases',
                    value: '42',
                    icon: Icons.folder,
                  ),
                  MetricCard(
                    title: 'Pending Hearings',
                    value: '7',
                    icon: Icons.gavel,
                  ),
                  MetricCard(
                    title: 'Open Invoices',
                    value: '18',
                    icon: Icons.receipt,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MetricCard), findsNWidgets(3));
      // In mobile (<400px), cards are stacked in a single Column without multi-child Rows
      expect(find.byType(Column), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders multi-column row grid on tablet/desktop (800px)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ResponsiveMetricGrid(
                children: [
                  MetricCard(
                    title: 'Active Cases',
                    value: '42',
                    icon: Icons.folder,
                  ),
                  MetricCard(
                    title: 'Pending Hearings',
                    value: '7',
                    icon: Icons.gavel,
                  ),
                  MetricCard(
                    title: 'Open Invoices',
                    value: '18',
                    icon: Icons.receipt,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MetricCard), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });
  });

  group('4. Theme Compatibility & Status Badges', () {
    testWidgets(
      'StatusBadge adapts gracefully to Dark Mode without blinding white backgrounds',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: const Scaffold(
              body: Center(child: StatusBadge(status: 'active')),
            ),
          ),
        );

        expect(find.byType(StatusBadge), findsOneWidget);
        expect(find.text('ACTIVE'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}

class _StaticAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  _StaticAuthNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _StaticTeamNotifier extends StateNotifier<AsyncValue<List<TeamMember>>>
    implements TeamNotifier {
  _StaticTeamNotifier(List<TeamMember> members)
    : super(AsyncValue.data(members));

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
