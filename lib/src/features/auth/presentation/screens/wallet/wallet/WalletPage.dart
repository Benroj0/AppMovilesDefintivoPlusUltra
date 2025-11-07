import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/wallet/wallet/WalletContent.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/wallet/wallet/bloc/WalletBloc.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/wallet/wallet/bloc/WalletEvent.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WalletBloc()..add(LoadWalletData()),
      child: const WalletContent(),
    );
  }
}
