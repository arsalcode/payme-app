import 'package:payme/shared/theme.dart';
import 'package:payme/ui/widgets/buttons.dart';
import 'package:payme/ui/widgets/forms.dart';
import 'package:flutter/material.dart';

class ProfileEditSuccesPage extends StatelessWidget {
  const ProfileEditSuccesPage({super.key});

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
              'Nice Update!',
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
              'Your data is safe with\n Our System',
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
              title: 'My Profile',
              onPressed: () {
                // Navigator.pushNamed(context, '/home-page');
                // Navigator.pushNamedAndRemoveUntil(context, '/home-page', predicate);
                // Navigator.pushNamedAndRemoveUntil(context, '/home-page',(route)=> false);
                // Navigator.pushNamedAndRemoveUntil(context, '', (ro));
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
