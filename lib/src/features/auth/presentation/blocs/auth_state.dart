import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState {
  const AuthState();
}

// Estado inicial, cuando la app recién carga
class AuthInitial extends AuthState {}

// Estado cuando el usuario SÍ está logueado
class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
}

// Estado cuando el usuario NO está logueado
class Unauthenticated extends AuthState {}