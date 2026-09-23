import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/models/app_update_info.dart';

void main() {
  group('AppUpdateInfo Tests', () {
    test('detects up to date version when versions match', () {
      final info = AppUpdateInfo.fromJson(
        json: {
          'latest_version': '1.0.1',
          'latest_build': 2,
          'min_required_version': '1.0.0',
          'min_required_build': 1,
          'is_force_update': false,
        },
        currentVersion: '1.0.1',
        currentBuildNumber: 2,
      );

      expect(info.status, AppUpdateStatus.upToDate);
      expect(info.isForceUpdate, false);
      expect(info.hasUpdate, false);
    });

    test('detects optional update when higher version available but above min version', () {
      final info = AppUpdateInfo.fromJson(
        json: {
          'latest_version': '1.1.0',
          'latest_build': 3,
          'min_required_version': '1.0.0',
          'min_required_build': 1,
          'is_force_update': false,
        },
        currentVersion: '1.0.1',
        currentBuildNumber: 2,
      );

      expect(info.status, AppUpdateStatus.optionalUpdate);
      expect(info.isForceUpdate, false);
      expect(info.hasUpdate, true);
    });

    test('detects force update when current version is below minimum required version', () {
      final info = AppUpdateInfo.fromJson(
        json: {
          'latest_version': '2.0.0',
          'latest_build': 10,
          'min_required_version': '2.0.0',
          'min_required_build': 10,
          'is_force_update': false,
        },
        currentVersion: '1.0.1',
        currentBuildNumber: 2,
      );

      expect(info.status, AppUpdateStatus.forceUpdate);
      expect(info.isForceUpdate, true);
      expect(info.hasUpdate, true);
    });

    test('detects force update when is_force_update flag is explicitly true', () {
      final info = AppUpdateInfo.fromJson(
        json: {
          'latest_version': '1.0.2',
          'latest_build': 3,
          'min_required_version': '1.0.1',
          'min_required_build': 2,
          'is_force_update': true,
        },
        currentVersion: '1.0.1',
        currentBuildNumber: 2,
      );

      expect(info.status, AppUpdateStatus.forceUpdate);
      expect(info.isForceUpdate, true);
    });
  });
}
