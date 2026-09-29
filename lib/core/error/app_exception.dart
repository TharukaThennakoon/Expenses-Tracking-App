/// Base for errors the app knows how to explain to the user.
class AppException implements Exception {
  const AppException(this.code);

  /// Short machine-readable code shown under error screens.
  final String code;

  @override
  String toString() => '$runtimeType($code)';
}

/// The server could not be reached. Data sources throw this when a request
/// fails because the device is offline or the server is down.
class NetworkException extends AppException {
  const NetworkException() : super('unavailable');
}
