import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ProfileContent.dart';

class ProfilePage extends StatelessWidget {
  final User? usuario;
  final VoidCallback? onBackPressed;
  const ProfilePage({super.key, this.usuario, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return ProfileContent(onBackPressed: onBackPressed);
  }
}
