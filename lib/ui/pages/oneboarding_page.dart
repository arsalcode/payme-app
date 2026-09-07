import 'package:payme/shared/theme.dart';
// import 'package:payme/ui/pages/sign_in_page.dart';
import 'package:payme/ui/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int currentIndex = 0;
  //  CarouselController carouselController = CarouselController();
  CarouselSliderController carouselController = CarouselSliderController();

  List<String> titles = [
    'Grow Your\nFinancial Today',
    'Build From\nZero to Freedom',
    'Start Together',
  ];

  List<String> subtitles = [
    'Our system is helping you to\nachieve a better goal',
    'We provide tips for you so that\nyou can adapt easier',
    'We will guide you to where\nyou wanted it too',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CarouselSlider(
              items: [
                Image.asset('assets/images/img_onbording1.png', height: 331),
                Image.asset('assets/images/img_onbording2.png', height: 331),
                Image.asset('assets/images/img_onbording3.png', height: 331),
              ],
              carouselController: carouselController,
              options: CarouselOptions(
                height: 331,
                viewportFraction: 1,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
            ),
            const SizedBox(height: 80),
            Container(
              width: 327,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 22),
              decoration: BoxDecoration(
                color: whiteColor,
                // color: ,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    titles[currentIndex],
                    style: blackTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: semiBold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 26),
                  Text(
                    subtitles[currentIndex],
                    style: greyTextStyle.copyWith(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: currentIndex == 2 ? 38 : 50),
                  // currentIndex ==2? Column(children: [
                  // c],)):
                  currentIndex == 2
                      ? Column(
                          children: [
                            CustomFilledButtons(
                              title: 'Get Started',
                              onPressed: () {
                                // Navigator.pushNamed(context, '/sign-up');
                                Navigator.pushNamedAndRemoveUntil(context, '/sign-up', (route)=>false);
                              },
                            ),
                            // SizedBox(
                            //   width: double.infinity,
                            //   height: 50,
                            //   child: TextButton(
                            //     onPressed: () {
                            //       // if (currentIndex < 2) {
                            //       carouselController.nextPage();
                            //       // }
                            //       currentIndex = 0;
                            //     },
                            //     style: TextButton.styleFrom(
                            //       backgroundColor: purpleColor,
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(56),
                            //       ),
                            //     ),
                            //     child: Text(
                            //       'Get Started',
                            //       style: whiteTextStyle.copyWith(
                            //         fontSize: 16,
                            //         fontWeight: semiBold,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 24,

                              // child: TextButton(
                              //   onPressed: () {
                              //     // if (currentIndex < 2) {
                              //     // carouselController.nextPage();
                              //     // }
                              //     // currentIndex = 0;
                              //     Navigator.pushNamed(context, '/sign-in');

                              //     // Navigator.push(
                              //     //   context,
                              //     //   MaterialPageRoute(
                              //     //     builder: (context) => SignInPage(),
                              //     //   ),
                              //     // );
                              //   },
                              //   style: TextButton.styleFrom(
                              //     padding: EdgeInsets.zero,
                              //   ),
                              //   child: Text(
                              //     'Sign In',
                              //     style: greyTextStyle.copyWith(
                              //       fontSize: 16,
                              //       fontWeight: semiBold,
                              //     ),
                              //   ),
                              // ),
                            ),

                            CustomTextButton(
                              title: 'sign-in',
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(context, '/sign-in', (route)=>false);
                                // Navigator.pushNamed(context, '/sign-in');
                              },
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            for (int i = 0; i < 3; i++)
                              Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: i == currentIndex
                                      ? blueColor
                                      : lightkBackgroundColor,
                                  // color: currentIndex ==0? blueColor:lightkBackgroundColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            const Spacer(),
                            CustomFilledButtons(
                              width: 150,
                              title: 'Continue',
                              onPressed: () {
                                carouselController.nextPage();
                              },
                            ),

                            // SizedBox(
                            //   width: 150,
                            //   height: 50,
                            //   child: TextButton(
                            //     onPressed: () {
                            //       // if (currentIndex < 2) {
                            //       carouselController.nextPage();
                            //       // }
                            //       currentIndex = 0;
                            //     },
                            //     style: TextButton.styleFrom(
                            //       backgroundColor: purpleColor,
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(56),
                            //       ),
                            //     ),
                            //     child: Text(
                            //       'Continue',
                            //       style: whiteTextStyle.copyWith(
                            //         fontSize: 16,
                            //         fontWeight: semiBold,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
