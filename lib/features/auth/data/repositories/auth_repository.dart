import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/accept_invite_request.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_profile.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final tokenStorage = ref.watch(secureTokenStorageProvider);
  return AuthRepository(
    remoteDataSource: remoteDataSource,
    tokenStorage: tokenStorage,
  );
});

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureTokenStorage tokenStorage;

  AuthRepository({required this.remoteDataSource, required this.tokenStorage});

  Future<UserProfile> login({
    required String username,
    required String password,
    String? fcmToken,
  }) async {
    debugPrint('[AUTH] Initiating user login for: $username');

    // Retrieve FCM device token if not explicitly provided
    String? resolvedFcmToken = fcmToken;
    if (resolvedFcmToken == null) {
      try {
        resolvedFcmToken = await NotificationService.instance.getDeviceToken();
        if (resolvedFcmToken != null && resolvedFcmToken.isNotEmpty) {
          debugPrint(
            '[AUTH] Attaching FCM token to login request: $resolvedFcmToken',
          );
        }
      } catch (e) {
        debugPrint('[AUTH] Note on FCM token retrieval: $e');
      }
    }

    final tokenResponse = await remoteDataSource.login(
      LoginRequest(
        username: username,
        password: password,
        fcmToken: resolvedFcmToken,
      ),
    );

    if (tokenResponse.accessToken.isEmpty) {
      throw const ApiException(
        message: 'Invalid credentials or no access token returned.',
      );
    }

    // Save tokens and credentials securely
    await tokenStorage.saveTokens(
      accessToken: tokenResponse.accessToken,
      refreshToken: tokenResponse.refreshToken,
    );
    await tokenStorage.saveCredentials(username: username, password: password);

    // Build user profile directly from the login response (source of truth)
    UserProfile profile;
    if (tokenResponse.user != null) {
      profile = UserProfile.fromUser(tokenResponse.user!);
    } else {
      try {
        profile = await remoteDataSource.getProfile();
      } catch (_) {
        // Fallback to token claims if profile endpoint fails or has restricted permissions
        profile = UserProfile(
          id: tokenResponse.userId,
          username: tokenResponse.username ?? username,
          email: '',
          role: tokenResponse.role,
        );
      }
    }

    // If user belongs to a firm and firmName is empty, fetch firm details
    if (profile.firm != null &&
        (profile.firmName == null || profile.firmName!.isEmpty)) {
      try {
        final firmData = await remoteDataSource.getFirmProfile();
        if (firmData != null && firmData['name'] != null) {
          profile = profile.copyWith(firmName: firmData['name'].toString());
        }
      } catch (_) {}
    }

    await tokenStorage.saveUserProfile(profile.toJsonString());
    debugPrint(
      '[AUTH] User successfully logged in: role=${profile.role}, firm=${profile.firmName ?? profile.firm}',
    );
    return profile;
  }

  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    return await remoteDataSource.register(request);
  }

  Future<Map<String, dynamic>> acceptInvite(AcceptInviteRequest request) async {
    return await remoteDataSource.acceptInvite(request);
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await remoteDataSource.forgotPassword(email);
  }

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String password,
  }) async {
    return await remoteDataSource.resetPassword(
      token: token,
      password: password,
    );
  }

  Future<UserProfile?> restoreSession() async {
    final hasToken = await tokenStorage.hasAccessToken();
    if (!hasToken) {
      debugPrint('[AUTH] No stored access token found. Presenting login.');
      return null;
    }

    // Attempt to load cached profile first for instant UI availability
    final cachedJson = await tokenStorage.getUserProfile();
    UserProfile? cachedProfile;
    if (cachedJson != null && cachedJson.isNotEmpty) {
      try {
        cachedProfile = UserProfile.fromJsonString(cachedJson);
      } catch (_) {}
    }

    // If cached profile is missing firmName, attempt firm profile resolution
    if (cachedProfile != null &&
        cachedProfile.firm != null &&
        (cachedProfile.firmName == null || cachedProfile.firmName!.isEmpty)) {
      try {
        final firmData = await remoteDataSource.getFirmProfile();
        if (firmData != null && firmData['name'] != null) {
          cachedProfile = cachedProfile.copyWith(
            firmName: firmData['name'].toString(),
          );
          await tokenStorage.saveUserProfile(cachedProfile.toJsonString());
        }
      } catch (_) {}
    }

    // Attempt to verify session by fetching fresh profile
    try {
      final freshProfile = await remoteDataSource.getProfile();
      final resolvedFirmName = freshProfile.firmName ?? cachedProfile?.firmName;
      final updatedProfile = freshProfile.copyWith(firmName: resolvedFirmName);
      await tokenStorage.saveUserProfile(updatedProfile.toJsonString());
      debugPrint(
        '[AUTH] Session restored and verified online: ${updatedProfile.username}',
      );
      return updatedProfile;
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        debugPrint(
          '[AUTH] Access token expired on session restore. Attempting silent renewal...',
        );
        final creds = await tokenStorage.getCredentials();
        if (creds != null &&
            creds['username'] != null &&
            creds['password'] != null) {
          try {
            final renewedProfile = await login(
              username: creds['username']!,
              password: creds['password']!,
            );
            debugPrint(
              '[AUTH] Silent session renewal succeeded on app launch.',
            );
            return renewedProfile;
          } catch (reAuthErr) {
            if (reAuthErr is ApiException &&
                (reAuthErr.statusCode == 400 ||
                    reAuthErr.statusCode == 401 ||
                    reAuthErr.statusCode == 403)) {
              debugPrint(
                '[AUTH] Stored credentials invalid or account disabled. Clearing session.',
              );
              await tokenStorage.clearTokens();
              return null;
            }
          }
        }
      }

      // On network errors or profile endpoint restrictions: PRESERVE SESSION!
      debugPrint(
        '[AUTH] Network or endpoint failure on session restore. Preserving cached session.',
      );
      return cachedProfile;
    }
  }

  Future<void> logout() async {
    debugPrint('[AUTH] User manually logged out.');
    await tokenStorage.clearTokens();
  }
}
