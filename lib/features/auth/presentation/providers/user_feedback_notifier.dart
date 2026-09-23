import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_exception.dart';
import '../../data/models/user_feedback_request.dart';
import '../../data/repositories/auth_repository.dart';

class UserFeedbackState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final Map<String, dynamic>? fieldErrors;

  const UserFeedbackState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.fieldErrors,
  });

  UserFeedbackState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    Map<String, dynamic>? fieldErrors,
  }) {
    return UserFeedbackState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors,
    );
  }
}

final userFeedbackNotifierProvider =
    StateNotifierProvider.autoDispose<UserFeedbackNotifier, UserFeedbackState>((
  ref,
) {
  final repository = ref.watch(authRepositoryProvider);
  return UserFeedbackNotifier(repository);
});

class UserFeedbackNotifier extends StateNotifier<UserFeedbackState> {
  final AuthRepository _repository;

  UserFeedbackNotifier(this._repository) : super(const UserFeedbackState());

  Future<bool> submitFeedback(UserFeedbackRequest request) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      fieldErrors: null,
      isSuccess: false,
    );

    try {
      await _repository.submitUserFeedback(request);
      if (!mounted) return false;
      state = const UserFeedbackState(isLoading: false, isSuccess: true);
      return true;
    } on ApiException catch (e) {
      if (!mounted) return false;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
        fieldErrors: e.fieldErrors,
        isSuccess: false,
      );
      return false;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to submit your inquiry. Please check your connection and try again.',
        isSuccess: false,
      );
      return false;
    }
  }

  void reset() {
    if (!mounted) return;
    state = const UserFeedbackState();
  }
}
