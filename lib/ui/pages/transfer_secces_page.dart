import 'package:payme/shared/theme.dart';
import 'package:payme/ui/widgets/buttons.dart';
import 'package:payme/ui/widgets/forms.dart';
import 'package:flutter/material.dart';

class TransferSuccesPage extends StatelessWidget {
  const TransferSuccesPage({super.key});

  get semibold => null;

  @override
  Widget build(BuildContext context) {
    // return const Placeholder();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Berhasil Transfer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 26,
            ),
            const Text(
              'Use the money wiselly and\n grow your finance',
              style: TextStyle(
                fontSize: 16,

                // fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 50,
            ),
            CustomFilledButtons(
              width: 183,
              title: 'Back to Home',
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home-page', // Ganti dengan rute tujuan Anda
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
