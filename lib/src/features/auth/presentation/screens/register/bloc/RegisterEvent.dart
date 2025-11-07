import 'package:equatable/equatable.dart';
import 'package:flutter_application_1/src/features/utils/BlocFormItem.dart';

abstract class RegisterEvent extends Equatable {
    const RegisterEvent();

  @override
  List<Object?> get props => [];

}
class RegisterInit extends RegisterEvent {
  const RegisterInit();
}
class RegisterNameChanged extends RegisterEvent {
  final BlocFormItem name;
  const RegisterNameChanged({required this.name});
  @override
  List<Object?> get props => [name];
}
class RegisterLastNameChanged extends RegisterEvent {
  final BlocFormItem lastname;
  const RegisterLastNameChanged({required this.lastname});
  @override
  List<Object?> get props => [lastname];
}
class RegisterEmailChanged extends RegisterEvent {
  final BlocFormItem email;
  const RegisterEmailChanged({required this.email});
  @override
  List<Object?> get props => [email];
}
class RegisterPasswordChanged extends RegisterEvent {
  final BlocFormItem password;
  const RegisterPasswordChanged({required this.password});
  @override
  List<Object?> get props => [password];
}
class RegisterConfirmPasswordChanged extends RegisterEvent {
  final BlocFormItem confirmPassword;
  const RegisterConfirmPasswordChanged({required this.confirmPassword});
  @override
  List<Object?> get props => [confirmPassword];
}
class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted();
}
class RegisterFormReset extends RegisterEvent {
  const RegisterFormReset();
}
