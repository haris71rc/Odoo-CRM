sealed class Failure implements Exception {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection failed']);
}

class ApiFailure extends Failure {
  const ApiFailure(super.message, {this.statusCode});

  final int? statusCode;
}

class ParsingFailure extends Failure {
  const ParsingFailure([super.message = 'Failed to parse response']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred']);
}
