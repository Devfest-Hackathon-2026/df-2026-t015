/// API 仕様の error.code
enum ApiErrorCode {
  invalidArgument('INVALID_ARGUMENT'),
  unauthenticated('UNAUTHENTICATED'),
  notFound('NOT_FOUND'),
  versionConflict('VERSION_CONFLICT'),
  replanExpired('REPLAN_EXPIRED'),
  mustItemsInfeasible('MUST_ITEMS_INFEASIBLE'),

  /// 行き先を外しても、終わりの時刻までに終わる場所に着けない
  endInfeasible('END_INFEASIBLE'),

  /// 保存できる旅程の上限（1 人 20 件）を超える
  itineraryLimit('ITINERARY_LIMIT'),
  rateLimited('RATE_LIMITED'),
  upstreamError('UPSTREAM_ERROR'),

  /// 通信できなかった、または仕様にないコードが返った
  unknown('UNKNOWN');

  const ApiErrorCode(this.value);

  final String value;

  static ApiErrorCode fromValue(String? value) => ApiErrorCode.values
      .firstWhere((c) => c.value == value, orElse: () => ApiErrorCode.unknown);
}

/// サーバーが返したエラー（`{ "error": { code, message, details } }`）
class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.details = const {},
  });

  factory ApiException.fromResponse(int? statusCode, Object? body) {
    final error = body is Map<String, dynamic> ? body[_errorKey] : null;
    if (error is Map<String, dynamic>) {
      return ApiException(
        statusCode: statusCode,
        code: ApiErrorCode.fromValue(error[_codeKey] as String?),
        message: (error[_messageKey] as String?) ?? '',
        details: (error[_detailsKey] as Map<String, dynamic>?) ?? const {},
      );
    }
    return ApiException(
      statusCode: statusCode,
      code: ApiErrorCode.unknown,
      message: body?.toString() ?? '',
    );
  }

  static const _errorKey = 'error';
  static const _codeKey = 'code';
  static const _messageKey = 'message';
  static const _detailsKey = 'details';
  static const _placeIdsKey = 'placeIds';

  final int? statusCode;
  final ApiErrorCode code;
  final String message;
  final Map<String, dynamic> details;

  /// 422 MUST_ITEMS_INFEASIBLE で入りきらなかった行き先
  List<String> get infeasiblePlaceIds =>
      (details[_placeIdsKey] as List<dynamic>?)?.cast<String>() ?? const [];

  @override
  String toString() => 'ApiException($statusCode, ${code.value}): $message';
}
