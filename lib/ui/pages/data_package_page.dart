import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payme/blocs/auth/auth_bloc.dart';
import 'package:payme/blocs/transaction/transaction_bloc.dart';
import 'package:payme/shared/theme.dart';
import 'package:payme/ui/widgets/buttons.dart';
import 'package:payme/ui/widgets/forms.dart';
import 'package:payme/ui/widgets/package_item.dart';

class DataPackagePage extends StatefulWidget {
  final String providerName;

  const DataPackagePage({
    super.key,
    this.providerName = 'Telkomsel',
  });

  @override
  State<DataPackagePage> createState() => _DataPackagePageState();
}

class _DataPackagePageState extends State<DataPackagePage> {
  final TextEditingController phoneController =
      TextEditingController(text: '081298765432');

  int selectedAmount = 10;
  int selectedPrice = 100000;

  final List<Map<String, int>> packages = [
    {'amount': 10, 'price': 100000},
    {'amount': 25, 'price': 200000},
    {'amount': 40, 'price': 300000},
    {'amount': 99, 'price': 500000},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paket Data ${widget.providerName}'),
      ),
      body: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(state.e),
              ),
            );
          }

          if (state is TransactionSuccess) {
            // Segarkan saldo dan riwayat mutasi
            context.read<AuthBloc>().add(AuthGetCurrentUser());
            context.read<TransactionBloc>().add(TransactionGetLatestEvent());

            Navigator.pushNamedAndRemoveUntil(
              context,
              '/data-succes',
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            children: [
              const SizedBox(
                height: 30,
              ),
              Text(
                'Phone Number',
                style: blackTextStyle.copyWith(
                  fontWeight: semiBold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              CustomFormFailed(
                title: 'Phone Number',
                controller: phoneController,
                keyboardType: TextInputType.phone,
                isShowTitle: false,
              ),
              const SizedBox(
                height: 40,
              ),
              Text(
                'Select Package',
                style: blackTextStyle.copyWith(
                  fontWeight: semiBold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              Wrap(
                spacing: 17,
                runSpacing: 17,
                children: packages.map((pkg) {
                  final isSelected = selectedAmount == pkg['amount'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedAmount = pkg['amount']!;
                        selectedPrice = pkg['price']!;
                      });
                    },
                    child: PackageItem(
                      amount: pkg['amount']!,
                      price: pkg['price']!,
                      isSelected: isSelected,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(
                height: 60,
              ),
              CustomFilledButtons(
                title: 'Continue',
                onPressed: () async {
                  if (phoneController.text.trim().length < 8) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('Nomor ponsel minimal 8 digit angka'),
                      ),
                    );
                    return;
                  }

                  // Verifikasi PIN sebelum transaksi diproses
                  final pinVerified =
                      await Navigator.pushNamed(context, '/pin');

                  if (pinVerified == true) {
                    if (context.mounted) {
                      context.read<TransactionBloc>().add(
                            TransactionBuyDataEvent(
                              amount: selectedPrice,
                              providerName: widget.providerName,
                              packageName: '${selectedAmount}GB',
                            ),
                          );
                    }
                  }
                },
              ),
              const SizedBox(
                height: 57,
              ),
            ],
          );
        },
      ),
    );
  }
}
