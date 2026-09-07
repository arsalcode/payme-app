// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:payme/models/sign_up_form_model.dart';
import 'package:payme/shared/theme.dart';
import 'package:payme/ui/widgets/buttons.dart';
import 'package:image_picker/image_picker.dart';

class SignUpSetKtpProfilePage extends StatefulWidget {
  final SignUpFormModel data;

  
  const SignUpSetKtpProfilePage({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<SignUpSetKtpProfilePage> createState() => _SignUpSetKtpProfilePageState();
}

class _SignUpSetKtpProfilePageState extends State<SignUpSetKtpProfilePage> {
    XFile? selectedImage;


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
            'Verify Your\nAccount',
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: lightkBackgroundColor,

                  ),
                  child: Center(child: Image.asset('assets/images/ic_upload.png',width: 32,),),
                ),

                // Container(
                //   height: 120,
                //   width: 120,
                //   decoration: const BoxDecoration(
                //     shape: BoxShape.circle,
                //     // color: lightkBackgroundColor,
                //     image: DecorationImage(
                //       fit: BoxFit.cover,
                //       image: AssetImage('assets/images/img_profile.png'),
                //     ),
                //   ),
                // ),
                SizedBox(
                  height: 16,
                ),

                Text(
                  'Passport/ID Card',
                  style:
                      blackTextStyle.copyWith(fontSize: 16, fontWeight: medium),
                ),
                //Full Name

                SizedBox(
                  height: 50,
                ),
                // CustomFormFailed(title: 'Set PIN (6 digit number)'),
                // Email

                SizedBox(height: 30),
                CustomFilledButtons(
                  title: 'Continue',
                  onPressed: () {
                    // CarouselController.nextPage();
                  },
                ),

                // SizedBox(height: 50),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                ),
                CustomTextButton(title: 'Skip for Now', onPressed: (){
                  Navigator.pushNamed(context, '/sign-up-succes');

                },),
              ],
            ),
          )
        ],
      ),
    );
  }
}
