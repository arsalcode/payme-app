import 'package:payme/shared/theme.dart';
import 'package:payme/ui/widgets/buttons.dart';
import 'package:payme/ui/widgets/forms.dart';
import 'package:flutter/material.dart';

class ProfileEditPage extends StatelessWidget {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: 24,
        ),
        children: [
          SizedBox(
            height: 30,
          ),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomFormFailed(
                  title: 'Username',
                ),
                 SizedBox(
                  height: 16,
                ),
                 CustomFormFailed(
                  title: 'Full Name',
                ),
                 SizedBox(
                  height: 16,
                ),
                CustomFormFailed(
                  title: 'Email Address',
                ),
                SizedBox(
                  height: 16,
                ),
                CustomFormFailed(
                  title: 'Password',
                  obscureText: true,
                ),

                // Password

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Forget Password',
                    style: blueTextStyle,
                  ),
                ),

                SizedBox(height: 30),
                CustomFilledButtons(
                  title: 'Update Now',
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/profile-edit-succes', (Route) => false);
                  },
                ),

                // SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
