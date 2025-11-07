import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/wallet/wallet/bloc/WalletBloc.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/wallet/wallet/bloc/WalletState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletContent extends StatelessWidget {
  const WalletContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Billetera")),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _cardPresupuesto(context, state),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _miniCard(
                      "Gastado",
                      "S/ ${state.gastado}",
                      Icons.trending_up_outlined,
                    ),
                    _miniCard(
                      "Gastados",
                      "${state.cantidadGastos}",
                      Icons.event_note,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _cardTopCategoria(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _cardPresupuesto(BuildContext context, WalletState state) {
    final restante = state.presupuesto - state.gastado;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.account_balance_wallet, size: 20),
              SizedBox(width: 8),
              Text(
                "Presupuesto Mensual",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "S/ ${restante.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 20),
          ),
          Text(
            "Restante de S/ ${state.presupuesto.toStringAsFixed(2)}",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18), // 👈 icono dinámico
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _cardTopCategoria(BuildContext context, WalletState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.star, size: 20), // 👈 icono
              SizedBox(width: 8),
              Text(
                "Top Categorias",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.shopping_cart,
                    size: 20,
                  ), // 👈 icono de categoría
                  const SizedBox(width: 6),
                  Text(
                    state.topCategoria,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              Text(
                "S/ ${state.montoTopCategoria.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          Text(
            "${state.cantidadGastos} Gastos",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
