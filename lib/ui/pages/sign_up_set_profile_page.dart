// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:payme/ui/pages/sign_up_page.dart';
import 'package:payme/ui/pages/sign_up_set_ktp_profile_page.dart';
import 'package:flutter/material.dart';

import 'package:payme/models/sign_up_form_model.dart';
import 'package:payme/shared/theme.dart';
import 'package:payme/ui/widgets/buttons.dart';
import 'package:payme/ui/widgets/forms.dart';
import 'package:image_picker/image_picker.dart';

class SignUpSetProfilePage extends StatefulWidget {
  final SignUpFormModel data;

  const SignUpSetProfilePage({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<SignUpSetProfilePage> createState() => _SignUpSetProfilePageState();
}

class _SignUpSetProfilePageState extends State<SignUpSetProfilePage> {
  final pinController = TextEditingController(text: '');
  XFile? selectedImage;

  bool validate() {
    if (pinController.text != 6) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    print(
      widget.data.toJson(),
    );
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
            'Join Us to Unlock\nYour Growth',
            style: blackTextStyle.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              final Image = await selectedImage;
              setState(() {
                selectedImage = Image;
              });
            },
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lightkBackgroundColor,
                      // image: selectedImage;
                      image: selectedImage == null
                          ? null
                          : DecorationImage(
                              fit: BoxFit.cover,
                              image: FileImage(
                                File(selectedImage!.path),
                              ),
                            ),
                    ),
                    child: selectedImage == null
                        ? Center(
                            child: Image.asset(
                              'assets/ic_upload.png',
                              width: 32,
                            ),
                          )
                        : Image.file(
                            File(selectedImage!.path),
                            fit: BoxFit.cover,
                          ),
                  ),
                  SizedBox(
                    height: 16,
                  ),

                  Text(
                    'Shayna Hanna',
                    style: blackTextStyle.copyWith(
                        fontSize: 16, fontWeight: medium),
                  ),
                  //Full Name

                  SizedBox(
                    height: 30,
                  ),
                  CustomFormFailed(
                    title: 'Set PIN (6 digit number)',
                    obscureText: true,
                    controller: pinController,
                    keyboardType: TextInputType.number,
                  ),

                  // Email

                  SizedBox(height: 30),
                  CustomFilledButtons(
                    title: 'Continue',
                    onPressed: () {
                      if (validate()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpSetKtpProfilePage(
                              data: widget.data.copyWith(
                                pin: pinController.text,
                                profilePicture: selectedImage == null
                                    ? null
                                    : 'data:image/png;base64,' +
                                        base64Encode(
                                          File(selectedImage!.path)
                                              .readAsBytesSync(),
                                        ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        showCustomSnackBar(
                          context,
                          'PIN harus 6 digit',
                        );
                      }
                      // CarouselController.nextPage();
                    },
                  ),

                  // SizedBox(height: 50),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
