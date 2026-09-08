import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:payme/blocs/auth/auth_bloc.dart';
import 'package:payme/shared/theme.dart';
import 'package:payme/ui/pages/data_package_page.dart';
import 'package:payme/ui/widgets/buttons.dart';
import 'package:payme/ui/widgets/data_provider_item.dart';

class DataProviderPage extends StatefulWidget {
  const DataProviderPage({super.key});

  @override
  State<DataProviderPage> createState() => _DataProviderPageState();
}

class _DataProviderPageState extends State<DataProviderPage> {
  String selectedProvider = 'Telkomsel';

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthSuccess ? authState.user : null;

    final rawCard = user?.cardNumber ?? '5399882208191280';
    final cardNumber = rawCard.length >= 16
        ? '${rawCard.substring(0, 4)} ${rawCard.substring(4, 8)} ${rawCard.substring(8, 12)} ${rawCard.substring(12, 16)}'
        : rawCard;
    final balanceFormatted = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(user?.balance ?? 100000);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beli Data'),
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
            'From Wallet',
            style: blackTextStyle.copyWith(
              fontWeight: semiBold,
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            children: [
              Image.asset(
                'assets/images/img_wallet.png',
                width: 70,
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
                      fontWeight: medium,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    'Balance: $balanceFormatted',
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
            'Select Provider',
            style: blackTextStyle.copyWith(
              fontWeight: semiBold,
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedProvider = 'Telkomsel';
              });
            },
            child: DataProviderItem(
              name: 'Telkomsel',
              imageUrl: 'assets/images/img_provider_telkomsel.png',
              isSelected: selectedProvider == 'Telkomsel',
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedProvider = 'Indosat Ooredoo';
              });
            },
            child: DataProviderItem(
              name: 'Indosat Ooredoo',
              imageUrl: 'assets/images/img_provider_indosat.png',
              isSelected: selectedProvider == 'Indosat Ooredoo',
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedProvider = 'Singtel ID';
              });
            },
            child: DataProviderItem(
              name: 'Singtel ID',
              imageUrl: 'assets/images/img_provider_singtel.png',
              isSelected: selectedProvider == 'Singtel ID',
            ),
          ),
          const SizedBox(
            height: 80,
          ),
          CustomFilledButtons(
            title: 'Continue',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DataPackagePage(
                    providerName: selectedProvider,
                  ),
                ),
              );
            },
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}
