import 'package:equatable/equatable.dart';
import 'package:get/get.dart';

abstract class Failure extends Equatable {
  String get message;

  @override
  List<Object?> get props => [message];
}

class OfflineFailure extends Failure {
  @override
  String get message => 'offline_failure_message'.tr;
}

class ServerFailure extends Failure {
  @override
  String get message => 'server_failure_message'.tr;
}

class EmptyCacheFailure extends Failure {
  @override
  String get message => 'empty_cache_failure_message'.tr;
}

class ServerMessageFailure extends Failure {
  final String customMessage;

  ServerMessageFailure(this.customMessage);

  @override
  String get message => customMessage;
}

class UnauthorizedFailure extends Failure {
  @override
  String get message => 'unauthorized_failure_message'.tr;
}

class TimeoutFailure extends Failure {
  @override
  String get message => 'timeout_failure_message'.tr;
}

class AuthFailure extends Failure {
  final String? customMessage;

  AuthFailure([this.customMessage]);

  @override
  String get message => customMessage ?? 'auth_failure_message'.tr;
}

class UsedEmailOrPhoneNumberFailure extends Failure {
  final String? customMessage;

  UsedEmailOrPhoneNumberFailure([this.customMessage]);

  @override
  String get message => customMessage ?? 'email_or_phone_number_used'.tr;
}

class YouHaveToCreateAccountAgainFailure extends Failure {
  final String? customMessage;

  YouHaveToCreateAccountAgainFailure([this.customMessage]);

  @override
  String get message => customMessage ?? 'create_account_again'.tr;
}