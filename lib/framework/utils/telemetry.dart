import 'package:flutter/foundation.dart';

class Telemetry {
  static void trackView(
    String tag,
    String event, {
    Map<String, dynamic>? metadata,
  }) {
    if (!kDebugMode) return;
    final meta = metadata == null ? '' : ' $metadata';
    debugPrint('[view] $tag :: $event$meta');
  }

  static void trackError(
    String tag,
    String scope,
    Object error,
    StackTrace stack,
  ) {
    if (!kDebugMode) return;
    debugPrint('[error] $tag :: $scope :: $error');
    debugPrintStack(stackTrace: stack);
  }
}
