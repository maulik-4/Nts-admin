class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? fieldErrors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.fieldErrors,
  });

  factory ApiException.fromResponse(int? statusCode, dynamic data) {
    if (data is Map<String, dynamic>) {
      // Check for direct "error" key (e.g. {"error": "Invalid credentials"})
      if (data.containsKey('error') && data['error'] != null) {
        return ApiException(
          message: data['error'].toString(),
          statusCode: statusCode,
        );
      }

      // Check for standard DRF "detail" key (e.g. {"detail": "Authentication credentials were not provided."})
      if (data.containsKey('detail') && data['detail'] != null) {
        return ApiException(
          message: data['detail'].toString(),
          statusCode: statusCode,
        );
      }

      // Check for "non_field_errors"
      if (data.containsKey('non_field_errors') &&
          data['non_field_errors'] is List &&
          (data['non_field_errors'] as List).isNotEmpty) {
        return ApiException(
          message: (data['non_field_errors'] as List).first.toString(),
          statusCode: statusCode,
        );
      }

      // Check for field-specific validation errors (e.g. {"username": ["This field is required."]})
      final Map<String, dynamic> fields = {};
      final List<String> errorMessages = [];

      data.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          final errorStr = value.map((e) => e.toString()).join(' ');
          fields[key] = errorStr;
          errorMessages.add('$key: $errorStr');
        } else if (value is String) {
          fields[key] = value;
          errorMessages.add('$key: $value');
        }
      });

      if (errorMessages.isNotEmpty) {
        return ApiException(
          message: errorMessages.first,
          statusCode: statusCode,
          fieldErrors: fields,
        );
      }
    }

    // Default messages based on status codes
    String defaultMessage = 'An unexpected error occurred. Please try again.';
    if (statusCode == 400) {
      defaultMessage = 'Invalid request. Please check your inputs.';
    } else if (statusCode == 401) {
      defaultMessage = 'Invalid credentials or session expired.';
    } else if (statusCode == 403) {
      defaultMessage = 'You do not have permission to perform this action.';
    } else if (statusCode == 404) {
      defaultMessage = 'Requested resource was not found.';
    } else if (statusCode != null && statusCode >= 500) {
      defaultMessage =
          'Server error. Our team has been notified. Please try again later.';
    }

    return ApiException(message: defaultMessage, statusCode: statusCode);
  }

  factory ApiException.network({String? message}) {
    return ApiException(
      message: message ?? 'Unable to connect to the server. Please check your internet connection.',
      statusCode: null,
    );
  }

  @override
  String toString() => message;
}
