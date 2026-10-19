class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? fieldErrors;
  final String? code;
  final String? requestId;

  const ApiException({
    required this.message,
    this.statusCode,
    this.fieldErrors,
    this.code,
    this.requestId,
  });

  bool get isFirmBlocked => code == 'FIRM_BLOCKED';
  bool get isSubscriptionExpired => code == 'SUBSCRIPTION_EXPIRED';
  String? get errorCode => code;

  factory ApiException.fromResponse(
    int? statusCode,
    dynamic data, {
    String? requestIdHeader,
  }) {
    if (data is Map<String, dynamic>) {
      // 1. Standardized Error Envelope from fa64f95 Backend Exception Handler
      // format: { "success": false, "error": { "code": "...", "message": "...", "fieldErrors": {...}, "requestId": "..." } }
      if (data.containsKey('error') && data['error'] != null) {
        final errObj = data['error'];
        if (errObj is Map<String, dynamic>) {
          final String? code = errObj['code']?.toString();
          final String? msg = errObj['message']?.toString();
          final String? reqId =
              errObj['requestId']?.toString() ??
              errObj['request_id']?.toString() ??
              requestIdHeader;

          Map<String, dynamic>? parsedFields;
          final rawFields = errObj['fieldErrors'] ?? errObj['field_errors'];
          if (rawFields is Map<String, dynamic>) {
            parsedFields = Map<String, dynamic>.from(rawFields);
          }

          return ApiException(
            message: msg ?? 'An unexpected error occurred.',
            statusCode: statusCode,
            code: code,
            requestId: reqId,
            fieldErrors: parsedFields,
          );
        } else if (errObj is String) {
          // Direct error string: {"error": "Invalid credentials."}
          return ApiException(
            message: errObj,
            statusCode: statusCode,
            requestId: requestIdHeader,
          );
        }
      }

      // 1.1 Direct top-level code or error response
      if (data.containsKey('code') && data['code'] != null) {
        final String code = data['code'].toString();
        final String? msg = (data['message'] ?? data['detail'])?.toString();
        final String? reqId =
            data['requestId']?.toString() ??
            data['request_id']?.toString() ??
            requestIdHeader;
        return ApiException(
          message: msg ?? 'An unexpected error occurred.',
          statusCode: statusCode,
          code: code,
          requestId: reqId,
        );
      }

      // 2. Standard DRF "detail" key (e.g. {"detail": "Authentication credentials were not provided."})
      if (data.containsKey('detail') && data['detail'] != null) {
        return ApiException(
          message: data['detail'].toString(),
          statusCode: statusCode,
          requestId: requestIdHeader,
        );
      }

      // 3. "non_field_errors"
      if (data.containsKey('non_field_errors') &&
          data['non_field_errors'] is List &&
          (data['non_field_errors'] as List).isNotEmpty) {
        return ApiException(
          message: (data['non_field_errors'] as List).first.toString(),
          statusCode: statusCode,
          requestId: requestIdHeader,
        );
      }

      // 4. Field-specific validation errors (e.g. {"username": ["This field is required."]})
      final Map<String, dynamic> fields = {};
      final List<String> errorMessages = [];

      data.forEach((key, value) {
        if (key != 'success' && key != 'requestId') {
          if (value is List && value.isNotEmpty) {
            final errorStr = value.map((e) => e.toString()).join(' ');
            fields[key] = errorStr;
            errorMessages.add('$key: $errorStr');
          } else if (value is String) {
            fields[key] = value;
            errorMessages.add('$key: $value');
          }
        }
      });

      if (errorMessages.isNotEmpty) {
        return ApiException(
          message: errorMessages.first,
          statusCode: statusCode,
          fieldErrors: fields,
          requestId: requestIdHeader,
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

    return ApiException(
      message: defaultMessage,
      statusCode: statusCode,
      requestId: requestIdHeader,
    );
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
