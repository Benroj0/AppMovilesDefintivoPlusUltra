import 'package:equatable/equatable.dart';
import 'package:flutter_application_1/src/features/utils/BlocFormItem.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object?> get props => [];
}

class LoginInit extends LoginEvent {
  const LoginInit();
}

class LoginEmailChanged extends LoginEvent {
  final BlocFormItem email;
  const LoginEmailChanged({required this.email});
  @override
  List<Object?> get props => [email];
}

class LoginPasswordChanged extends LoginEvent {
  final BlocFormItem password;
  const LoginPasswordChanged({required this.password});
  @override
  List<Object?> get props => [password];
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}
class LoginWithGoogleSubmitted extends LoginEvent { const LoginWithGoogleSubmitted(); }