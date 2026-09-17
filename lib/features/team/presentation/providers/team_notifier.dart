import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/models/team_member.dart';
import '../../data/repositories/team_repository.dart';

enum TeamFilter { all, advocates, staff }

final teamFilterProvider = StateProvider<TeamFilter>((ref) => TeamFilter.all);

final teamSearchQueryProvider = StateProvider<String>((ref) => '');

final teamNotifierProvider =
    StateNotifierProvider<TeamNotifier, AsyncValue<List<TeamMember>>>((ref) {
      final repository = ref.watch(teamRepositoryProvider);
      final currentUser = ref.watch(authNotifierProvider).user;
      final firmId = (currentUser != null && !currentUser.isSuperAdmin)
          ? currentUser.firm
          : null;
      return TeamNotifier(repository, firmId);
    });

final filteredTeamMembersProvider = Provider<AsyncValue<List<TeamMember>>>((
  ref,
) {
  final teamAsync = ref.watch(teamNotifierProvider);
  final filter = ref.watch(teamFilterProvider);
  final query = ref.watch(teamSearchQueryProvider).trim().toLowerCase();
  final currentUser = ref.watch(authNotifierProvider).user;

  return teamAsync.whenData((members) {
    // 1. Filter out platform-level users (super_admin, platform_admin, is_superuser)
    // and isolate users to the authenticated user's firm.
    final firmScoped = members.where((m) {
      final isPlatformUser =
          m.isSuperAdmin ||
          m.role.toLowerCase() == 'super_admin' ||
          m.role.toLowerCase() == 'platform_admin' ||
          m.isSuperuser;

      if (isPlatformUser) {
        return false;
      }

      // If viewing user is a firm member, restrict strictly to members belonging to that firm
      if (currentUser != null && !currentUser.isSuperAdmin) {
        final currentFirmId = currentUser.firm;
        final currentFirmName = currentUser.firmName?.trim().toLowerCase();

        final memberFirmId = m.firmId;
        final memberFirmName = m.firm.trim().toLowerCase();

        final matchesId =
            currentFirmId != null &&
            memberFirmId != null &&
            memberFirmId == currentFirmId;
        final matchesName =
            currentFirmName != null &&
            currentFirmName.isNotEmpty &&
            memberFirmName == currentFirmName;
        final matchesIdString =
            currentFirmId != null && memberFirmName == currentFirmId.toString();

        if (!matchesId && !matchesName && !matchesIdString) {
          return false;
        }
      }

      return true;
    }).toList();

    // 2. Role tab filtering (advocates vs staff vs all)
    List<TeamMember> roleFiltered;
    switch (filter) {
      case TeamFilter.advocates:
        roleFiltered = firmScoped.where((m) => m.isLawyer).toList();
        break;
      case TeamFilter.staff:
        roleFiltered = firmScoped.where((m) => m.isStaff).toList();
        break;
      case TeamFilter.all:
        roleFiltered = firmScoped;
        break;
    }

    // 3. Search query filtering
    if (query.isNotEmpty) {
      return roleFiltered.where((m) {
        return m.username.toLowerCase().contains(query) ||
            m.email.toLowerCase().contains(query) ||
            m.displayRole.toLowerCase().contains(query);
      }).toList();
    }

    return roleFiltered;
  });
});

class TeamNotifier extends StateNotifier<AsyncValue<List<TeamMember>>> {
  final TeamRepository _repository;
  final int? _firmId;

  TeamNotifier(this._repository, [this._firmId])
    : super(const AsyncValue.loading()) {
    loadTeamMembers();
  }

  Future<void> loadTeamMembers() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.getTeamMembers(firmId: _firmId),
    );
  }

  Future<void> addUser({
    required String username,
    required String email,
    required String password,
    required String role,
    int? firmId,
  }) async {
    await _repository.addUser(
      username: username,
      email: email,
      password: password,
      role: role,
      firmId: firmId ?? _firmId,
    );
    await loadTeamMembers();
  }

  Future<void> inviteMember({
    required String email,
    required String role,
  }) async {
    await _repository.inviteMember(email: email, role: role);
    await loadTeamMembers();
  }

  Future<void> invitePlatformUser({
    required String email,
    required String role,
  }) async {
    await _repository.invitePlatformUser(email: email, role: role);
    await loadTeamMembers();
  }
}
