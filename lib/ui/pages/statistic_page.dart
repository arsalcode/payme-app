import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:payme/blocs/transaction/transaction_bloc.dart';
import 'package:payme/models/transaction_model.dart';
import 'package:payme/shared/theme.dart';

class StatisticPage extends StatefulWidget {
  final bool isTab;

  const StatisticPage({
    super.key,
    this.isTab = false,
  });

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  String selectedPeriod = 'Bulan Ini'; // 'Minggu Ini', 'Bulan Ini', 'Tahun Ini'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightkBackgroundColor,
      appBar: AppBar(
        backgroundColor: lightkBackgroundColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: !widget.isTab,
        title: Text(
          'Statistic',
          style: blackTextStyle.copyWith(
            fontSize: 18,
            fontWeight: semiBold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.calendar_today_rounded,
              color: Color(0xFF14193F),
              size: 20,
            ),
            onSelected: (value) {
              setState(() {
                selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Minggu Ini',
                child: Text('Minggu Ini'),
              ),
              const PopupMenuItem(
                value: 'Bulan Ini',
                child: Text('Bulan Ini'),
              ),
              const PopupMenuItem(
                value: 'Tahun Ini',
                child: Text('Tahun Ini'),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          int income = 450000;
          int expense = 125000;

          if (state is TransactionLatestLoaded && state.transactions.isNotEmpty) {
            income = 0;
            expense = 0;
            for (var tx in state.transactions) {
              final isInc = tx.transactionType == 'topup' ||
                  tx.transactionType == 'transfer_in';
              if (isInc) {
                income += tx.amount ?? 0;
              } else {
                expense += tx.amount ?? 0;
              }
            }
            if (income == 0 && expense == 0) {
              income = 450000;
              expense = 125000;
            }
          }

          final incomeFormatted = NumberFormat.currency(
            locale: 'id',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format(income);

          final expenseFormatted = NumberFormat.currency(
            locale: 'id',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format(expense);

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            children: [
              // Period indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: blueColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.insights_rounded,
                      size: 16,
                      color: blueColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Periode: $selectedPeriod',
                      style: blueTextStyle.copyWith(
                        fontSize: 12,
                        fontWeight: semiBold,
                      ),
                    ),
                  ],
                ),
              ),

              // Income vs Expense Summary Cards
              Row(
                children: [
                  // Income Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE5F9EE),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.arrow_downward_rounded,
                                    size: 18,
                                    color: greenColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Income',
                                style: greyTextStyle.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            incomeFormatted,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: blackTextStyle.copyWith(
                              fontSize: 15,
                              fontWeight: semiBold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Expense Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFEBF0),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.arrow_upward_rounded,
                                    size: 18,
                                    color: Color(0xFFFF5678),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Expense',
                                style: greyTextStyle.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            expenseFormatted,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: blackTextStyle.copyWith(
                              fontSize: 15,
                              fontWeight: semiBold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Cashflow Activity Chart Card
              Text(
                'Arus Kas Mingguan',
                style: blackTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semiBold,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Aktivitas Finansial',
                          style: blackTextStyle.copyWith(
                            fontSize: 14,
                            fontWeight: medium,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: greenColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '+18% Lebih Hemat',
                            style: greenTextStyle.copyWith(
                              fontSize: 11,
                              fontWeight: semiBold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Custom Bar Chart
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBarItem('Sen', 0.4, false),
                        _buildBarItem('Sel', 0.7, false),
                        _buildBarItem('Rab', 0.5, false),
                        _buildBarItem('Kam', 0.9, true), // Highest day
                        _buildBarItem('Jum', 0.6, false),
                        _buildBarItem('Sab', 0.3, false),
                        _buildBarItem('Min', 0.45, false),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Breakdown Categories
              Text(
                'Kategori Pengeluaran',
                style: blackTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semiBold,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildCategoryRow(
                      title: 'Transfer & Kirim Saldo',
                      percentage: '45%',
                      progressValue: 0.45,
                      color: blueColor,
                      icon: Icons.send_rounded,
                      amount: 'Rp 56.250',
                    ),
                    const Divider(height: 24),
                    _buildCategoryRow(
                      title: 'Paket Data & Pulsa',
                      percentage: '30%',
                      progressValue: 0.30,
                      color: purpleColor,
                      icon: Icons.wifi_rounded,
                      amount: 'Rp 37.500',
                    ),
                    const Divider(height: 24),
                    _buildCategoryRow(
                      title: 'Tagihan & PPOB',
                      percentage: '15%',
                      progressValue: 0.15,
                      color: const Color(0xFFFF8B3E),
                      icon: Icons.electric_bolt_rounded,
                      amount: 'Rp 18.750',
                    ),
                    const Divider(height: 24),
                    _buildCategoryRow(
                      title: 'Makanan & Hiburan',
                      percentage: '10%',
                      progressValue: 0.10,
                      color: const Color(0xFFFF5678),
                      icon: Icons.fastfood_rounded,
                      amount: 'Rp 12.500',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBarItem(String label, double heightFraction, bool isHighlight) {
    return Column(
      children: [
        Container(
          width: 18,
          height: 110 * heightFraction,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: isHighlight
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [blueColor, const Color(0xFF6B8AFF)],
                  )
                : null,
            color: isHighlight ? null : const Color(0xFFE8EEF5),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: isHighlight
              ? blueTextStyle.copyWith(fontSize: 11, fontWeight: semiBold)
              : greyTextStyle.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildCategoryRow({
    required String title,
    required String percentage,
    required double progressValue,
    required Color color,
    required IconData icon,
    required String amount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: color, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: blackTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: medium,
                ),
              ),
            ),
            Text(
              amount,
              style: blackTextStyle.copyWith(
                fontSize: 13,
                fontWeight: semiBold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progressValue,
            minHeight: 6,
            valueColor: AlwaysStoppedAnimation(color),
            backgroundColor: const Color(0xFFF1F3F6),
          ),
        ),
      ],
    );
  }
}
