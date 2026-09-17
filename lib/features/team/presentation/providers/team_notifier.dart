import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/team_member.dart';
import '../../data/repositories/team_repository.dart';

enum TeamFilter { all, advocates, staff }

final teamFilterProvider = StateProvider<TeamFilter>((ref) => TeamFilter.all);

final teamNotifierProvider =
    StateNotifierProvider<TeamNotifier, AsyncValue<List<TeamMember>>>((ref) {
      final repository = ref.watch(teamRepositoryProvider);
      return TeamNotifier(repository);
    });

final filteredTeamMembersProvider = Provider<AsyncValue<List<TeamMember>>>((
  ref,
) {
  final teamAsync = ref.watch(teamNotifierProvider);
  final filter = ref.watch(teamFilterProvider);

  return teamAsync.whenData((members) {
    switch (filter) {
      case TeamFilter.advocates:
        return members.where((m) => m.isLawyer).toList();
      case TeamFilter.staff:
        return members.where((m) => m.isStaff).toList();
      case TeamFilter.all:
        return members;
    }
  });
});

class TeamNotifier extends StateNotifier<AsyncValue<List<TeamMember>>> {
  final TeamRepository _repository;

  TeamNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTeamMembers();
  }

  Future<void> loadTeamMembers() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getTeamMembers());
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
      firmId: firmId,
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
