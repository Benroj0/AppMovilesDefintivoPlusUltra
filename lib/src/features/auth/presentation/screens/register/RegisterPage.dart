import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/domain/utils/Resource.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/register/RegisterContent.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/register/bloc/RegisterBloc.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/register/bloc/RegisterState.dart';
import 'package:flutter_application_1/src/routing/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  RegisterBloc? _bloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of<RegisterBloc>(context);
    return Scaffold(
      body: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          final responseState = state.response;
          if (responseState is Error) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Limpia anteriores
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseState.message),
              backgroundColor: Colors.red,
            ),
          );
          } else if (responseState is Success) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Limpia anteriores
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseState.data.toString()),
              backgroundColor: Colors.green,
            ),
          );
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login, // Siguiente paso: el cuestionario
              (route) => false, // Elimina el stack de autenticación
            );
          }
        },
        child: BlocBuilder<RegisterBloc, RegisterState>(
          builder: (context, state) {
            if (state.response is Loading) {
              return Stack(
                children: [
                  RegisterContent(_bloc, state),
                  const Center(child: CircularProgressIndicator()),
                ],
              );
            }
            return RegisterContent(_bloc, state);
          },
        ),
      ),
    );
  }
}
