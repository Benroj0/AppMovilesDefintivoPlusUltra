import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_1/src/domain/utils/Resource.dart';
import 'package:flutter_application_1/src/features/utils/BlocFormItem.dart';

class RegisterState extends Equatable {
  final BlocFormItem name;
  final BlocFormItem lastname;
  final BlocFormItem email;
  final BlocFormItem password;
  final BlocFormItem confirmPassword;
  final Resource? response;
  final GlobalKey<FormState>? formKey;

  const RegisterState({
    this.name = const BlocFormItem(error: 'Ingrese su nombre'),
    this.lastname = const BlocFormItem(error: 'Ingrese su apellido'),
    this.email = const BlocFormItem(error: 'Ingrese su email'),
    this.password = const BlocFormItem(error: 'Ingrese su contraseña'),
    this.confirmPassword = const BlocFormItem(error: 'Confirme su contraseña'),
    this.response,
    this.formKey,
  });

  RegisterState copyWith({
    BlocFormItem? name,
    BlocFormItem? lastname,
    BlocFormItem? email,
    BlocFormItem? password,
    BlocFormItem? confirmPassword,
    Resource? response,
    GlobalKey<FormState>? formKey,
  }) {
    return RegisterState(
      name: name ?? this.name,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      response: response ?? this.response,
      formKey: formKey ?? this.formKey,
    );
  }

  @override
  List<Object?> get props => [
    name,
    lastname,
    email,
    password,
    confirmPassword,
    response,
  ];
}
