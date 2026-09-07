import 'dart:async';

import 'package:payme/shared/theme.dart';
// import 'package:payme/ui/pages/oneboarding_page.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Timer(Duration(seconds: 1), () {
      //  Navigator.pushNamed(context, '/oneboarding');
      // Navigator.pushAndRemoveUntil(context, '/oneboarding', (r))
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/oneboarding', // Ganti dengan rute tujuan Anda
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackgroundColor,
      body: Center(
        child: Container(
          height: 50,
          width: 155,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/img_logo_dark.png'),
              // image: DecorationImage(image: AssetImage(Ass),),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
