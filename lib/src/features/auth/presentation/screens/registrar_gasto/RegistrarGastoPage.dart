import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/registrar_gasto/RegistrarGastoContent.dart';

class RegistrarGastoPage extends StatelessWidget {
  const RegistrarGastoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: RegistrarGastoContent(),
      ),
    );
  }
}