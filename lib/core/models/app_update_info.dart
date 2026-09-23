enum AppUpdateStatus {
  upToDate,
  optionalUpdate,
  forceUpdate,
}

class AppUpdateInfo {
  final AppUpdateStatus status;
  final String currentVersion;
  final int currentBuildNumber;
  final String latestVersion;
  final int latestBuildNumber;
  final String minRequiredVersion;
  final int minRequiredBuildNumber;
  final String updateUrl;
  final String title;
  final String message;
  final List<String> releaseNotes;

  const AppUpdateInfo({
    this.status = AppUpdateStatus.upToDate,
    this.currentVersion = '1.0.1',
    this.currentBuildNumber = 2,
    this.latestVersion = '1.0.1',
    this.latestBuildNumber = 2,
    this.minRequiredVersion = '1.0.1',
    this.minRequiredBuildNumber = 2,
    this.updateUrl = 'https://play.google.com/store/apps/details?id=com.legalpro.vidhanta',
    this.title = 'App Update Required',
    this.message = 'A newer version of Vidhanta is required to continue. Please update your application to access the latest features and improvements.',
    this.releaseNotes = const [],
  });

  bool get isForceUpdate => status == AppUpdateStatus.forceUpdate;
  bool get hasUpdate => status != AppUpdateStatus.upToDate;

  factory AppUpdateInfo.fromJson({
    required Map<String, dynamic> json,
    required String currentVersion,
    required int currentBuildNumber,
  }) {
    final latestVer = (json['latest_version'] ?? json['latestVersion'] ?? currentVersion) as String;
    final latestBuild = (json['latest_build'] ?? json['latestBuild'] ?? currentBuildNumber) as int;
    final minVer = (json['min_required_version'] ?? json['minRequiredVersion'] ?? '1.0.0') as String;
    final minBuild = (json['min_required_build'] ?? json['minRequiredBuild'] ?? 1) as int;
    final isForced = (json['is_force_update'] ?? json['forceUpdate'] ?? false) as bool;
    final url = (json['update_url'] ?? json['updateUrl'] ?? 'https://play.google.com/store/apps/details?id=com.legalpro.vidhanta') as String;
    final title = (json['title'] ?? 'App Update Required') as String;
    final msg = (json['message'] ?? 'A newer version of Vidhanta is available. Please update to proceed.') as String;

    List<String> notes = [];
    if (json['release_notes'] is List) {
      notes = (json['release_notes'] as List).map((e) => e.toString()).toList();
    }

    AppUpdateStatus updateStatus = AppUpdateStatus.upToDate;
    if (isForced || currentBuildNumber < minBuild || _compareSemver(currentVersion, minVer) < 0) {
      updateStatus = AppUpdateStatus.forceUpdate;
    } else if (currentBuildNumber < latestBuild || _compareSemver(currentVersion, latestVer) < 0) {
      updateStatus = AppUpdateStatus.optionalUpdate;
    }

    return AppUpdateInfo(
      status: updateStatus,
      currentVersion: currentVersion,
      currentBuildNumber: currentBuildNumber,
      latestVersion: latestVer,
      latestBuildNumber: latestBuild,
      minRequiredVersion: minVer,
      minRequiredBuildNumber: minBuild,
      updateUrl: url,
      title: title,
      message: msg,
      releaseNotes: notes,
    );
  }

  static int _compareSemver(String v1, String v2) {
    try {
      final p1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final p2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      for (int i = 0; i < 3; i++) {
        final val1 = i < p1.length ? p1[i] : 0;
        final val2 = i < p2.length ? p2[i] : 0;
        if (val1 < val2) return -1;
        if (val1 > val2) return 1;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }
}
