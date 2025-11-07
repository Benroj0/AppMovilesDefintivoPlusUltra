import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/domain/utils/Resource.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/login/LoginContent.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/login/bloc/LoginBloc.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/login/bloc/LoginState.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginBloc? _bloc;

  @override
  void initState() {
    // EJECUTA UNA SOLA VEZ CUANDO CARGA LA PANTALLA
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('🔐 LoginPage: Construyendo LoginPage');
    _bloc = BlocProvider.of<LoginBloc>(context);
    print('🔐 LoginPage: LoginBloc obtenido: $_bloc');

    return Scaffold(
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          final responseState = state.response;
          if (responseState is Error) {
            // 1. Reemplazamos Fluttertoast con SnackBar
            ScaffoldMessenger.of(
              context,
            ).hideCurrentSnackBar(); // Limpia anteriores
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(responseState.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (responseState is Success) {
            // 👉 Navegar de vuelta al AuthWrapper eliminando todo el stack
            print('Login exitoso - Regresando al AuthWrapper');
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AuthWrapper()),
              (route) => false,
            );
          }
        },
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            if (state.response is Loading) {
              return Stack(
                children: [
                  LoginContent(_bloc, state),
                  const Center(child: CircularProgressIndicator()),
                ],
              );
            }
            return LoginContent(_bloc, state);
          },
        ),
      ),
    );
  }
}
