import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:payme/blocs/auth/auth_bloc.dart';
import 'package:payme/blocs/transaction/transaction_bloc.dart';
import 'package:payme/shared/theme.dart';
import 'package:payme/ui/widgets/buttons.dart';

class TransferAmmountPage extends StatefulWidget {
  final String? recipientUsername;

  const TransferAmmountPage({
    super.key,
    this.recipientUsername,
  });

  @override
  State<TransferAmmountPage> createState() => _TransferAmmountPageState();
}

class _TransferAmmountPageState extends State<TransferAmmountPage> {
  final TextEditingController amountController =
      TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();

    amountController.addListener(() {
      final text = amountController.text;
      if (text.isEmpty) return;

      final cleanNumber = int.tryParse(text.replaceAll('.', '')) ?? 0;
      final formatted = NumberFormat.currency(
        locale: 'id',
        decimalDigits: 0,
        symbol: '',
      ).format(cleanNumber);

      if (amountController.text != formatted) {
        amountController.value = amountController.value.copyWith(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    });
  }

  void addAmount(String number) {
    if (amountController.text == '0') {
      amountController.text = '';
    }
    setState(() {
      amountController.text = amountController.text + number;
    });
  }

  void deleteAmount() {
    if (amountController.text.isNotEmpty) {
      setState(() {
        amountController.text = amountController.text
            .substring(0, amountController.text.length - 1);

        if (amountController.text == '') {
          amountController.text = '0';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackgroundColor,
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
            // Segarkan data saldo user & riwayat transaksi
            context.read<AuthBloc>().add(AuthGetCurrentUser());
            context.read<TransactionBloc>().add(TransactionGetLatestEvent());

            Navigator.pushNamedAndRemoveUntil(
              context,
              '/transfer-succes',
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
            padding: const EdgeInsets.symmetric(horizontal: 60),
            children: [
              const SizedBox(
                height: 60,
              ),
              Center(
                child: Text(
                  'Total Amount',
                  style: whiteTextStyle.copyWith(
                    fontWeight: semiBold,
                    fontSize: 20,
                  ),
                ),
              ),
              if (widget.recipientUsername != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Center(
                    child: Text(
                      'to @${widget.recipientUsername}',
                      style: blueTextStyle.copyWith(
                        fontSize: 14,
                        fontWeight: medium,
                      ),
                    ),
                  ),
                ),
              const SizedBox(
                height: 50,
              ),
              Align(
                child: SizedBox(
                  width: 240,
                  child: TextFormField(
                    controller: amountController,
                    cursorColor: greykColor,
                    enabled: false,
                    textAlign: TextAlign.center,
                    style: whiteTextStyle.copyWith(
                      fontSize: 36,
                      fontWeight: medium,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Text(
                        'Rp ',
                        style: whiteTextStyle.copyWith(
                          fontSize: 36,
                          fontWeight: medium,
                        ),
                      ),
                      disabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xffA4A8AE),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 66,
              ),
              Wrap(
                spacing: 40,
                runSpacing: 40,
                children: [
                  CustomInputButton(
                    title: '1',
                    onTap: () => addAmount('1'),
                  ),
                  CustomInputButton(
                    title: '2',
                    onTap: () => addAmount('2'),
                  ),
                  CustomInputButton(
                    title: '3',
                    onTap: () => addAmount('3'),
                  ),
                  CustomInputButton(
                    title: '4',
                    onTap: () => addAmount('4'),
                  ),
                  CustomInputButton(
                    title: '5',
                    onTap: () => addAmount('5'),
                  ),
                  CustomInputButton(
                    title: '6',
                    onTap: () => addAmount('6'),
                  ),
                  CustomInputButton(
                    title: '7',
                    onTap: () => addAmount('7'),
                  ),
                  CustomInputButton(
                    title: '8',
                    onTap: () => addAmount('8'),
                  ),
                  CustomInputButton(
                    title: '9',
                    onTap: () => addAmount('9'),
                  ),
                  const SizedBox(
                    width: 60,
                    height: 60,
                  ),
                  CustomInputButton(
                    title: '0',
                    onTap: () => addAmount('0'),
                  ),
                  GestureDetector(
                    onTap: () => deleteAmount(),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: numberBackgroundColor,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back,
                          color: whiteColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              CustomFilledButtons(
                title: 'Continue',
                onPressed: () async {
                  final amount = int.tryParse(
                          amountController.text.replaceAll('.', '')) ??
                      0;

                  if (amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('Nominal transfer harus lebih dari Rp 0'),
                      ),
                    );
                    return;
                  }

                  // Verifikasi PIN sebelum transfer
                  final pinVerified =
                      await Navigator.pushNamed(context, '/pin');
                  if (pinVerified == true) {
                    if (context.mounted) {
                      context.read<TransactionBloc>().add(
                            TransactionTransferEvent(
                              amount: amount,
                              recipientUsername:
                                  widget.recipientUsername ?? 'user',
                            ),
                          );
                    }
                  }
                },
              ),
              const SizedBox(
                height: 15,
              ),
              CustomTextButton(
                title: 'Terms & Conditions',
                onPressed: () {},
              ),
              const SizedBox(
                height: 40,
              ),
            ],
          );
        },
      ),
    );
  }
}
