import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:payme/blocs/auth/auth_bloc.dart';
import 'package:payme/models/sign_up_form_model.dart';
import 'package:payme/shared/theme.dart';
import 'package:payme/ui/widgets/buttons.dart';

class SignUpSetKtpProfilePage extends StatefulWidget {
  final SignUpFormModel data;

  const SignUpSetKtpProfilePage({
    super.key,
    required this.data,
  });

  @override
  State<SignUpSetKtpProfilePage> createState() =>
      _SignUpSetKtpProfilePageState();
}

class _SignUpSetKtpProfilePageState extends State<SignUpSetKtpProfilePage> {
  XFile? selectedImage;

  void showCustomSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailed) {
            showCustomSnackBar(context, state.e);
          }

          if (state is AuthSuccess) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/sign-up-succes',
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
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
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final image = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          setState(() {
                            selectedImage = image;
                          });
                        }
                      },
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: lightkBackgroundColor,
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
                                  'assets/images/ic_upload.png',
                                  width: 32,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Passport/ID Card',
                      style: blackTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: medium,
                      ),
                    ),
                    const SizedBox(height: 50),
                    CustomFilledButtons(
                      title: 'Continue',
                      onPressed: () {
                        if (selectedImage == null) {
                          showCustomSnackBar(
                            context,
                            'Silakan pilih foto KTP atau tekan Skip for Now',
                          );
                          return;
                        }

                        final imageBase64 = 'data:image/png;base64,' +
                            base64Encode(
                              File(selectedImage!.path).readAsBytesSync(),
                            );

                        final finalData = widget.data.copyWith(
                          ktp: imageBase64,
                        );

                        context.read<AuthBloc>().add(AuthRegister(finalData));
                      },
                    ),
                    const SizedBox(height: 30),
                    CustomTextButton(
                      title: 'Skip for Now',
                      onPressed: () {
                        context
                            .read<AuthBloc>()
                            .add(AuthRegister(widget.data));
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
