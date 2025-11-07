import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/firestore_service.dart';
import 'package:flutter_application_1/src/features/auth/presentation/blocs/auth_cubit.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/categories/bloc/CategoriesBloc.dart';

import 'package:flutter_application_1/src/features/auth/presentation/screens/historial/bloc/HistorialBloc.dart';

import 'package:flutter_application_1/src/features/auth/presentation/screens/registrar_gasto/bloc/RegistarGastoBloc.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/wallet/wallet/bloc/WalletBloc.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/wallet/wallet/bloc/WalletEvent.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/profile/bloc/ProfileBloc.dart';

import 'package:flutter_application_1/src/features/auth/presentation/screens/category_detail/bloc/TransactionBloc.dart';
import 'package:flutter_application_1/src/color_theme/theme_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/login/bloc/LoginBloc.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/register/bloc/RegisterBloc.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/register/bloc/RegisterEvent.dart';

// Función que crea providers frescos cada vez que se llama
List<BlocProvider> get blocProviders {
  // Crear instancias frescas de los servicios cada vez
  final AuthService authService = AuthService();
  final FirestoreService firestoreService = FirestoreService();

  return [
    BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(authService: authService),
      lazy: false,
    ),
    BlocProvider<ThemeBloc>(create: (context) => ThemeBloc()),
    BlocProvider<LoginBloc>(
      create: (context) => LoginBloc(authService: authService),
    ),
    BlocProvider<RegisterBloc>(
      create: (context) =>
          RegisterBloc(authService: authService)..add(const RegisterInit()),
    ),
    BlocProvider<RegistrarGastoBloc>(
      create: (context) =>
          RegistrarGastoBloc(firestoreService: firestoreService),
    ),
    BlocProvider<CategoriesBloc>(
      create: (context) => CategoriesBloc(firestoreService: firestoreService),
    ),
    BlocProvider<HistorialBloc>(
      create: (context) => HistorialBloc(firestoreService: firestoreService),
    ),
    BlocProvider<WalletBloc>(
      create: (context) => WalletBloc()..add(LoadWalletData()),
    ),
    BlocProvider<ProfileBloc>(
      create: (context) => ProfileBloc(firestoreService: firestoreService),
    ),
    BlocProvider<TransactionBloc>(
      create: (context) => TransactionBloc(firestoreService),
    ),
  ];
}
