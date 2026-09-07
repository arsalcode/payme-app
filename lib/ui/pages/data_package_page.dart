import 'package:payme/shared/theme.dart';
import 'package:payme/ui/widgets/buttons.dart';
import 'package:payme/ui/widgets/forms.dart';
import 'package:payme/ui/widgets/package_item.dart';
import 'package:payme/ui/widgets/transfer_result_user_item.dart';
import 'package:flutter/material.dart';

class DataPackagePage extends StatelessWidget {
  const DataPackagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Paket Data',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        children: [
          SizedBox(
            height: 30,
          ),
          Text(
            'Phone Number',
            style: blackTextStyle.copyWith(
              fontWeight: semiBold,
              fontSize: 16,
            ),
          ),
          SizedBox(
            height: 14,
          ),
          CustomFormFailed(
            title: '+628',
            isShowTitle: false,
          ),
          SizedBox(
            height: 40,
          ),
          Text(
            'Select Package',
            style: blackTextStyle.copyWith(
              fontWeight: semiBold,
              fontSize: 16,
            ),
          ),
          SizedBox(
            height: 14,
          ),
          Wrap(
            spacing: 17,
            runSpacing: 17,
            children: [
              PackageItem(
                amount: 10,
                price: 100000,
                isSelected: true,
              ),
              PackageItem(
                amount: 10,
                price: 100000,
                isSelected: false,
              ),
              PackageItem(
                amount: 10,
                price: 100000,
                isSelected: false,
              ),
              PackageItem(
                amount: 10,
                price: 100000,
                isSelected: false,
              ),
            ],
          ),
          SizedBox(
            height: 85,
          ),
          CustomFilledButtons(
            title: 'continue',
            onPressed: () async {
              if (await Navigator.pushNamed(context, '/pin') == true) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/data-succes', (Route) => false);
              }
              ;
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
