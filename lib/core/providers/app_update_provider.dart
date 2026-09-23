import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_update_info.dart';
import '../network/dio_client.dart';
import '../services/app_update_service.dart';

final appUpdateServiceProvider = Provider<AppUpdateService>((ref) {
  final dio = ref.watch(dioProvider);
  return AppUpdateService(dio);
});

final appUpdateNotifierProvider =
    StateNotifierProvider<AppUpdateNotifier, AppUpdateInfo>((ref) {
  final service = ref.watch(appUpdateServiceProvider);
  return AppUpdateNotifier(service);
});

class AppUpdateNotifier extends StateNotifier<AppUpdateInfo> {
  final AppUpdateService _service;

  AppUpdateNotifier(this._service) : super(const AppUpdateInfo());

  Future<AppUpdateInfo> checkAppVersion({
    String? currentVersion,
    int? currentBuildNumber,
  }) async {
    final info = await _service.checkForUpdate(
      currentVersion: currentVersion ?? AppUpdateService.currentAppVersion,
      currentBuildNumber: currentBuildNumber ?? AppUpdateService.currentAppBuildNumber,
    );
    if (mounted) {
      state = info;
    }
    return info;
  }

  void simulateUpdate({
    required bool isForceUpdate,
    String latestVersion = '1.1.0',
    String? message,
    List<String>? releaseNotes,
  }) {
    state = AppUpdateInfo(
      status: isForceUpdate ? AppUpdateStatus.forceUpdate : AppUpdateStatus.optionalUpdate,
      currentVersion: AppUpdateService.currentAppVersion,
      currentBuildNumber: AppUpdateService.currentAppBuildNumber,
      latestVersion: latestVersion,
      latestBuildNumber: AppUpdateService.currentAppBuildNumber + 1,
      minRequiredVersion: isForceUpdate ? latestVersion : AppUpdateService.currentAppVersion,
      minRequiredBuildNumber: isForceUpdate ? AppUpdateService.currentAppBuildNumber + 1 : 1,
      updateUrl: 'https://play.google.com/store/apps/details?id=com.legalpro.vidhanta',
      title: isForceUpdate ? 'Mandatory App Update' : 'New Update Available',
      message: message ??
          (isForceUpdate
              ? 'A critical update is required to continue using Vidhanta. This update includes essential security patches and database synchronization.'
              : 'A newer version of Vidhanta is available with performance enhancements.'),
      releaseNotes: releaseNotes ?? [
        'Enhanced legal case timeline tracking',
        'Direct document cloud synchronization',
        'Critical security and stability patches',
      ],
    );
  }

  void clearUpdate() {
    state = const AppUpdateInfo();
  }

  Future<bool> launchUpdateUrl() async {
    return await _service.launchUpdateUrl(state.updateUrl);
  }
}
