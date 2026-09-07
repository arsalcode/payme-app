import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payme/blocs/auth/auth_bloc.dart';
import 'package:payme/shared/theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home-page',
            (route) => false,
          );
        }

        if (state is AuthFailed || state is AuthInitial) {
          Timer(const Duration(seconds: 2), () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/oneboarding',
              (route) => false,
            );
          });
        }
      },
      child: Scaffold(
        backgroundColor: darkBackgroundColor,
        body: Center(
          child: Container(
            height: 50,
            width: 155,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/img_logo_dark.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
