import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 120.0});

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/img/logo1.png', width: size, height: size);
  }
}
