abstract class BaseErrorModel implements Exception {
  final String? message;
  final int? code;

  const BaseErrorModel({this.message, this.code});

  @override
  String toString() => 'Error: $message (code: $code)';
}

class FirebaseErrorModel extends BaseErrorModel {
  const FirebaseErrorModel({super.message, super.code});
}

class GenericErrorModel extends BaseErrorModel {
  const GenericErrorModel({super.message, super.code});
}
