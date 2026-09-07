import 'package:payme/shared/theme.dart';
import 'package:payme/ui/widgets/buttons.dart';
import 'package:payme/ui/widgets/forms.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        children: [
          Container(
            width: 155,
            height: 50,
            margin: const EdgeInsets.only(
              top: 100,
              bottom: 100,
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/img_logo_light.png',
                ),
              ),
            ),
          ),
          Text(
            'Sign in &\n Grow Your Finance',
            style: blackTextStyle.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email
               CustomFormFailed(title: 'Email Address'),

                SizedBox(height: 16),

                CustomFormFailed(title: 'Password',obscureText: true,),

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
                  title: 'Sign in',
                  onPressed: () {
                    // CarouselController.nextPage();
                    // Navigator.pushNamed(context, '/sign-up-upload-profile');
                    Navigator.pushNamedAndRemoveUntil(context, '/home-page', (route)=>false,);
                  },
                ),

       
                SizedBox(height: 50),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                ),
                SizedBox(height: 20),
              //  CustomTextdButton(title: 'Create new  Account',width: 150,onPressed: (){},),
              CustomTextButton(title: 'Create New Account',onPressed: () {
                Navigator.pushNamed(context, '/sign-up' );
                
              },),
              ],
            ),
          )
        ],
      ),
    );
  }
}
