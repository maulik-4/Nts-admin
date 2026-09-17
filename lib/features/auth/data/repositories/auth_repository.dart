import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_exception.dart';
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
  }) async {
    final tokenResponse = await remoteDataSource.login(
      LoginRequest(username: username, password: password),
    );

    if (tokenResponse.accessToken.isEmpty) {
      throw const ApiException(
        message: 'Invalid credentials or no access token returned.',
      );
    }

    // Save tokens securely
    await tokenStorage.saveTokens(
      accessToken: tokenResponse.accessToken,
      refreshToken: tokenResponse.refreshToken,
    );

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

    await tokenStorage.saveUserProfile(profile.toJsonString());
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
      return null;
    }

    // Attempt to load cached profile first for fast startup
    final cachedJson = await tokenStorage.getUserProfile();
    UserProfile? cachedProfile;
    if (cachedJson != null && cachedJson.isNotEmpty) {
      try {
        cachedProfile = UserProfile.fromJsonString(cachedJson);
      } catch (_) {}
    }

    // Attempt to verify session by fetching fresh profile
    try {
      final freshProfile = await remoteDataSource.getProfile();
      await tokenStorage.saveUserProfile(freshProfile.toJsonString());
      return freshProfile;
    } catch (e) {
      // If 401, session is invalid
      if (e is ApiException && e.statusCode == 401) {
        await tokenStorage.clearTokens();
        return null;
      }
      // On offline/network failure, fall back to cached session if available
      return cachedProfile;
    }
  }

  Future<void> logout() async {
    await tokenStorage.clearTokens();
  }
}
