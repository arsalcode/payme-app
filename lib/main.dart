import 'package:payme/shared/theme.dart';
import 'package:payme/ui/pages/data_package_page.dart';
import 'package:payme/ui/pages/data_provider_page.dart';
import 'package:payme/ui/pages/data_succes_page.dart';
import 'package:payme/ui/pages/home_page.dart';
import 'package:payme/ui/pages/oneboarding_page.dart';
import 'package:payme/ui/pages/pin_page.dart';
import 'package:payme/ui/pages/profile_edit_page.dart';
import 'package:payme/ui/pages/profile_edit_pin_page.dart';
import 'package:payme/ui/pages/profile_edit_succes_page.dart';
import 'package:payme/ui/pages/profile_page.dart';
import 'package:payme/ui/pages/sign_in_page.dart';
import 'package:payme/ui/pages/sign_up_page.dart';
import 'package:payme/ui/pages/sign_up_set_ktp_profile_page.dart';
import 'package:payme/ui/pages/sign_up_set_profile_page.dart';
import 'package:payme/ui/pages/sign_up_succes_page.dart';
import 'package:payme/ui/pages/splash_page.dart';
import 'package:payme/ui/pages/topup_ammount_page.dart';
import 'package:payme/ui/pages/topup_page.dart';
import 'package:payme/ui/pages/topup_succes_page.dart';
import 'package:payme/ui/pages/transfer_amount_page.dart';
import 'package:payme/ui/pages/transfer_page.dart';
import 'package:payme/ui/pages/transfer_secces_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // dialogBackgroundColor: lightkBackgroundColor,
        scaffoldBackgroundColor: lightkBackgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: lightkBackgroundColor,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: blackColor,
          ),
          titleTextStyle: blackTextStyle.copyWith(
            fontSize: 20,
            fontWeight: semiBold,
          ),
        ),
      ),

      // home: SplashPage(),
      routes: {
        '/': (context) => const SplashPage(),
        '/oneboarding': (context) => const OnboardingPage(),
        '/sign-in': (context) => const SignInPage(),
        '/sign-up': (context) => const SignUpPage(),
        // '/sign-up-set-profile': (context) => const SignUpSetProfilePage(),
        // '/sign-up-set-ktp-profile': (context) => const SignUpSetKtpProfilePage(),
        '/sign-up-succes': (context) => const SignUpSuccesPage(),
        '/home-page': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/pin': (context) => const PinPage(),
        '/profile-edit': (context) => const ProfileEditPage(),
        '/profile-edit-pin': (context) => const ProfileEditPinPage(),
        '/profile-edit-succes': (context) => const ProfileEditSuccesPage(),
        '/topup': (context) => const TopupPage(),
        '/topup-ammount': (context) => const TopupAmmountPage(),
        '/topup-succes': (context) => const TopupSuccesPage(),
        '/transfer-page': (context) => const TransferPage(),
        '/transfer-amount': (context) => const TransferAmmountPage(),
        '/transfer-succes': (context) => const TransferSuccesPage(),
        '/data-provider': (context) => const DataProviderPage(),
        '/data-package': (context) => const DataPackagePage(),
        '/data-succes': (context) => const DataSuccesPage(),




        


        

      },
    );
  }
}
