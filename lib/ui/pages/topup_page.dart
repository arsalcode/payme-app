import 'package:payme/shared/theme.dart';
import 'package:payme/ui/widgets/bank_item.dart';
import 'package:payme/ui/widgets/buttons.dart';
import 'package:flutter/material.dart';

class TopupPage extends StatelessWidget {
  const TopupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Top Up',
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
          Text(
            'Wallet',
            style: blackTextStyle.copyWith(
              fontSize: 15,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Image.asset('assets/images/img_wallet.png'),
              SizedBox(
                width: 16,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '8008 2208 1996',
                    style: blackTextStyle.copyWith(
                        fontSize: 16, fontWeight: medium),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    'Muhammad Arsal',
                    style: blackTextStyle.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 40,
          ),
          Text(
            'Select Bank',
            style: blackTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          const BankItem(
            title: 'BANK BCA',
            imageUrl: 'assets/images/img_bank_bca.png',
            isSelected: true,
          ),
          const SizedBox(
            height: 14,
          ),
          const BankItem(
            title: 'BANK BNI',
            imageUrl: 'assets/images/img_bank_bni.png',
          ),
          const SizedBox(
            height: 14,
          ),
          const BankItem(
            title: 'BANK MANDIRI',
            imageUrl: 'assets/images/img_bank_mandiri.png',
          ),
          const SizedBox(
            height: 14,
          ),
          const BankItem(
            title: 'BANK OC BC',
            imageUrl: 'assets/images/img_bank_ococ.png',
          ),
          const SizedBox(
            height: 12,
          ),
          CustomFilledButtons(
            title: 'Continue',
            onPressed: (){
              Navigator.pushNamed(context, '/topup-ammount');
            },
          ),

          SizedBox(height: 57,),
        ],
      ),
    );
  }
}
