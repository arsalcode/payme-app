import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payme/blocs/auth/auth_bloc.dart';
import 'package:payme/shared/theme.dart';
import 'package:payme/ui/pages/topup_ammount_page.dart';
import 'package:payme/ui/widgets/bank_item.dart';
import 'package:payme/ui/widgets/buttons.dart';

class TopupPage extends StatefulWidget {
  const TopupPage({super.key});

  @override
  State<TopupPage> createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> {
  String selectedBank = 'BCA';

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthSuccess ? authState.user : null;

    final rawCard = user?.cardNumber ?? '5399882208191280';
    final cardNumber = rawCard.length >= 16
        ? '${rawCard.substring(0, 4)} ${rawCard.substring(4, 8)} ${rawCard.substring(8, 12)} ${rawCard.substring(12, 16)}'
        : rawCard;
    final userName = user?.name ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Up'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        children: [
          const SizedBox(
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
              Image.asset(
                'assets/images/img_wallet.png',
                width: 60,
              ),
              const SizedBox(
                width: 16,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cardNumber,
                    style: blackTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: medium,
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    userName,
                    style: greyTextStyle.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
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
          GestureDetector(
            onTap: () {
              setState(() {
                selectedBank = 'BCA';
              });
            },
            child: BankItem(
              title: 'BANK BCA',
              imageUrl: 'assets/images/img_bank_bca.png',
              isSelected: selectedBank == 'BCA',
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedBank = 'BNI';
              });
            },
            child: BankItem(
              title: 'BANK BNI',
              imageUrl: 'assets/images/img_bank_bni.png',
              isSelected: selectedBank == 'BNI',
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedBank = 'MANDIRI';
              });
            },
            child: BankItem(
              title: 'BANK MANDIRI',
              imageUrl: 'assets/images/img_bank_mandiri.png',
              isSelected: selectedBank == 'MANDIRI',
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedBank = 'OCBC';
              });
            },
            child: BankItem(
              title: 'BANK OCBC',
              imageUrl: 'assets/images/img_bank_ococ.png',
              isSelected: selectedBank == 'OCBC',
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          CustomFilledButtons(
            title: 'Continue',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TopupAmmountPage(bankName: selectedBank),
                ),
              );
            },
          ),
          const SizedBox(
            height: 57,
          ),
        ],
      ),
    );
  }
}
