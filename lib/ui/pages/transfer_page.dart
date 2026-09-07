import 'package:payme/shared/theme.dart';
import 'package:payme/ui/widgets/buttons.dart';
import 'package:payme/ui/widgets/forms.dart';
import 'package:payme/ui/widgets/transfer_recent_user_item.dart';
import 'package:payme/ui/widgets/transfer_result_user_item.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';

class TransferPage extends StatelessWidget {
  const TransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transfer',
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 24,
        ),
        children: [
          SizedBox(
            height: 30,
          ),
          Text(
            'Seacrch',
            style: blackTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semiBold,
            ),
          ),
          SizedBox(
            height: 14,
          ),
          CustomFormFailed(
            title: 'by Username',
            isShowTitle: false,
          ),
          // buildRecentUsers(),
          buildResult(),

          SizedBox(
            height: 274,
          ),
          CustomFilledButtons(
            title: 'Continue',
            onPressed: () {
              Navigator.pushNamed(context, '/transfer-amount' );
            },
          ),

          SizedBox(height: 50,),
        ],
      ),
    );
  }
}

Widget buildRecentUsers() {
  return Container(
    margin: const EdgeInsets.only(
      top: 40,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Users',
          style: blackTextStyle.copyWith(
            fontSize: 16,
            fontWeight: semiBold,
          ),
        ),
        SizedBox(
          height: 14,
        ),
        const TransferRecentUserItem(
          imageUrl: 'assets/images/img_frend1.png',
          name: 'Yonna Jie',
          Username: 'yoenna',
          isVerified: true,
        ),
        const TransferRecentUserItem(
          imageUrl: 'assets/images/img_frend2.png',
          name: 'Jonnn ni',
          Username: 'jonnhi',
          isVerified: false,
        ),
        const TransferRecentUserItem(
          imageUrl: 'assets/images/img_frend3.png',
          name: 'Eke Emba',
          Username: 'ekake',
          isVerified: false,
        ),
      ],
    ),
  );
}

Widget buildResult() {
  return Container(
    margin: EdgeInsets.only(
      top: 40,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Result',
          style: blackTextStyle.copyWith(
            fontSize: 16,
            fontWeight: semiBold,
          ),
        ),
        const SizedBox(
          height: 14,
        ),
        Wrap(
          spacing: 17,
          runSpacing: 17,
          children: [
            const TransferResultUserItem(
              imageUrl: 'assets/images/img_frend1.png',
              name: 'Yonna Jie',
              Username: 'yoenna',
              isVerified: true,
            ),
            const TransferResultUserItem(
              imageUrl: 'assets/images/img_frend1.png',
              name: 'Yonna Jie',
              Username: 'yoenna',
              isVerified: true,
              isSelected: true,
            ),
          ],
        ),
      ],
    ),
  );
}
