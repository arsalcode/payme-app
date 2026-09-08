import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:payme/blocs/auth/auth_bloc.dart';
import 'package:payme/blocs/transaction/transaction_bloc.dart';
import 'package:payme/shared/theme.dart';
import 'package:payme/ui/pages/withdraw_succes_page.dart';
import 'package:payme/ui/widgets/buttons.dart';

class WithdrawPage extends StatefulWidget {
  const WithdrawPage({super.key});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  String selectedMethod = 'ATM BCA';
  int selectedAmount = 100000;
  final TextEditingController customAmountController = TextEditingController();

  final List<Map<String, String>> methods = [
    {
      'title': 'ATM BCA',
      'subtitle': 'Tarik tunai tanpa kartu di ATM BCA',
      'imageUrl': 'assets/images/img_bank_bca.png',
    },
    {
      'title': 'ATM Mandiri',
      'subtitle': 'Tarik tunai tanpa kartu di ATM Mandiri',
      'imageUrl': 'assets/images/img_bank_bni.png',
    },
    {
      'title': 'Indomaret / Alfamart',
      'subtitle': 'Tarik tunai lewat kasir terdekat',
      'imageUrl': 'assets/images/img_bank_ocbc.png',
    },
  ];

  final List<int> nominalPresets = [
    50000,
    100000,
    200000,
    300000,
    500000,
    1000000,
  ];

  @override
  void dispose() {
    customAmountController.dispose();
    super.dispose();
  }

  String formatCurrency(int number) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthSuccess ? authState.user : null;
    final userBalance = user?.balance ?? 0;

    return Scaffold(
      backgroundColor: lightkBackgroundColor,
      appBar: AppBar(
        title: const Text('Tarik Tunai (Withdraw)'),
      ),
      body: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionSuccess) {
            // Perbarui data saldo terkini di AuthBloc
            context.read<AuthBloc>().add(AuthGetCurrentUser());

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => WithdrawSuccesPage(
                  token: state.message,
                  amount: selectedAmount,
                  method: selectedMethod,
                ),
              ),
              (route) => false,
            );
          }

          if (state is TransactionFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(state.e),
              ),
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            children: [
              // 1. KARTU SALDO SAAT INI
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      purpleColor,
                      const Color(0xFF8B5CF6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: purpleColor.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Saldo Dompet Tersedia',
                          style: whiteTextStyle.copyWith(
                            fontSize: 13,
                            fontWeight: medium,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user?.cardNumber != null
                                ? '•••• ${user!.cardNumber!.substring(user.cardNumber!.length - 4)}'
                                : '•••• 1280',
                            style: whiteTextStyle.copyWith(
                              fontSize: 12,
                              fontWeight: semiBold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      formatCurrency(userBalance),
                      style: whiteTextStyle.copyWith(
                        fontSize: 26,
                        fontWeight: semiBold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 2. PILIH METODE PENARIKAN
              Text(
                'Pilih Lokasi Penarikan',
                style: blackTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semiBold,
                ),
              ),
              const SizedBox(height: 14),

              ...methods.map((method) {
                final isSelected = selectedMethod == method['title'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMethod = method['title']!;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? blueColor : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          method['imageUrl']!,
                          width: 50,
                          height: 30,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.account_balance,
                            color: blueColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method['title']!,
                                style: blackTextStyle.copyWith(
                                  fontSize: 15,
                                  fontWeight: semiBold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                method['subtitle']!,
                                style: greyTextStyle.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: blueColor,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // 3. PILIH NOMINAL PENARIKAN
              Text(
                'Pilih Nominal Tarik Tunai',
                style: blackTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semiBold,
                ),
              ),
              const SizedBox(height: 14),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: nominalPresets.map((nominal) {
                  final isSelected = selectedAmount == nominal;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedAmount = nominal;
                      });
                    },
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 60) / 2,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: isSelected ? blueColor : whiteColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? blueColor : greykColor.withValues(alpha: 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? blueColor.withValues(alpha: 0.25)
                                : Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          formatCurrency(nominal),
                          style: isSelected
                              ? whiteTextStyle.copyWith(
                                  fontSize: 15,
                                  fontWeight: semiBold,
                                )
                              : blackTextStyle.copyWith(
                                  fontSize: 15,
                                  fontWeight: semiBold,
                                ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 36),

              // 4. TOMBOL SUBMIT
              CustomFilledButtons(
                title: 'Tarik Tunai ${formatCurrency(selectedAmount)}',
                onPressed: () async {
                  if (selectedAmount < 50000) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('Minimal penarikan tunai adalah Rp 50.000'),
                      ),
                    );
                    return;
                  }

                  if (userBalance < selectedAmount) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('Saldo dompet tidak mencukupi untuk penarikan ini!'),
                      ),
                    );
                    return;
                  }

                  // Verifikasi PIN Keamanan sebelum penarikan
                  final pinVerified =
                      await Navigator.pushNamed(context, '/pin');

                  if (pinVerified == true) {
                    if (context.mounted) {
                      context.read<TransactionBloc>().add(
                            TransactionWithdrawEvent(
                              amount: selectedAmount,
                              method: selectedMethod,
                            ),
                          );
                    }
                  }
                },
              ),

              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}
