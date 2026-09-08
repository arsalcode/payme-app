import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:payme/blocs/transaction/transaction_bloc.dart';
import 'package:payme/models/transaction_model.dart';
import 'package:payme/shared/theme.dart';

class HistoryPage extends StatefulWidget {
  final bool isTab;

  const HistoryPage({
    super.key,
    this.isTab = false,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedFilter = 'all'; // 'all', 'income', 'expense'

  // Mock data fallback matching the design screenshot exactly
  final List<Map<String, dynamic>> mockToday = [
    {
      'title': 'Top Up',
      'subtitle': 'Yesterday',
      'amount': '+ 450.000',
      'isIncome': true,
      'bgColor': const Color(0xFFE8F2FF),
      'iconColor': const Color(0xFF51A0FF),
      'icon': Icons.download_rounded,
    },
    {
      'title': 'Cashback',
      'subtitle': 'Sep 11',
      'amount': '+ 22.000',
      'isIncome': true,
      'bgColor': const Color(0xFFF7E8FF),
      'iconColor': const Color(0xFFB55FE6),
      'icon': Icons.card_giftcard_rounded,
    },
    {
      'title': 'Withdraw',
      'subtitle': 'Sep 2',
      'amount': '- 5.000',
      'isIncome': false,
      'bgColor': const Color(0xFFE5F9EE),
      'iconColor': const Color(0xFF22B07D),
      'icon': Icons.upload_rounded,
    },
  ];

  final List<Map<String, dynamic>> mockEarlier = [
    {
      'title': 'Electric',
      'subtitle': 'Feb 18',
      'amount': '- 12.300.000',
      'isIncome': false,
      'bgColor': const Color(0xFFFFEFE5),
      'iconColor': const Color(0xFFFF8B3E),
      'icon': Icons.shopping_cart_outlined,
    },
    {
      'title': 'Food',
      'subtitle': 'Feb 18',
      'amount': '- 12.300.000',
      'isIncome': false,
      'bgColor': const Color(0xFFFFEBF0),
      'iconColor': const Color(0xFFFF5678),
      'icon': Icons.local_cafe_outlined,
    },
  ];

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Riwayat',
                style: blackTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: semiBold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Semua Transaksi'),
                leading: const Icon(Icons.all_inclusive),
                trailing: selectedFilter == 'all'
                    ? Icon(Icons.check, color: blueColor)
                    : null,
                onTap: () {
                  setState(() => selectedFilter = 'all');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Uang Masuk (+)'),
                leading: const Icon(Icons.arrow_downward, color: Colors.green),
                trailing: selectedFilter == 'income'
                    ? Icon(Icons.check, color: blueColor)
                    : null,
                onTap: () {
                  setState(() => selectedFilter = 'income');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Uang Keluar (-)'),
                leading: const Icon(Icons.arrow_upward, color: Colors.red),
                trailing: selectedFilter == 'expense'
                    ? Icon(Icons.check, color: blueColor)
                    : null,
                onTap: () {
                  setState(() => selectedFilter = 'expense');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

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
          'History',
          style: blackTextStyle.copyWith(
            fontSize: 18,
            fontWeight: semiBold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.tune_rounded,
              color: Color(0xFF14193F),
              size: 24,
            ),
            onPressed: _showFilterSheet,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          List<TransactionModel> realList = [];
          if (state is TransactionLatestLoaded) {
            realList = state.transactions;
          }

          if (realList.isNotEmpty) {
            return _buildRealTransactionsView(realList);
          }

          // Fallback ke tampilan persis mockup screenshot
          return _buildMockTransactionsView();
        },
      ),
    );
  }

  Widget _buildRealTransactionsView(List<TransactionModel> transactions) {
    // Filter transaksi berdasarkan selectedFilter
    final filtered = transactions.where((tx) {
      final isIncome =
          tx.transactionType == 'topup' || tx.transactionType == 'transfer_in';
      if (selectedFilter == 'income') return isIncome;
      if (selectedFilter == 'expense') return !isIncome;
      return true;
    }).toList();

    // Pisahkan data terbaru (hari ini / kemarin) dan data sebelumnya
    final now = DateTime.now();
    final todayList = filtered.where((tx) {
      if (tx.createdAt == null) return true;
      final diff = now.difference(tx.createdAt!).inDays;
      return diff <= 1;
    }).toList();

    final earlierList = filtered.where((tx) {
      if (tx.createdAt == null) return false;
      final diff = now.difference(tx.createdAt!).inDays;
      return diff > 1;
    }).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      children: [
        if (todayList.isNotEmpty) ...[
          _buildSectionHeader('Today'),
          _buildTransactionCard(
            todayList.map((tx) => _mapRealToItem(tx)).toList(),
          ),
        ],
        if (earlierList.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionHeader('Earlier'),
          _buildTransactionCard(
            earlierList.map((tx) => _mapRealToItem(tx)).toList(),
          ),
        ],
        if (todayList.isEmpty && earlierList.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Center(
              child: Text(
                'Tidak ada transaksi pada filter ini',
                style: greyTextStyle,
              ),
            ),
          ),
        const SizedBox(height: 50),
      ],
    );
  }

  Map<String, dynamic> _mapRealToItem(TransactionModel tx) {
    final isIncome =
        tx.transactionType == 'topup' || tx.transactionType == 'transfer_in';

    final amountFormatted = NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    ).format(tx.amount ?? 0);

    final timeString = tx.createdAt != null
        ? DateFormat('MMM dd').format(tx.createdAt!.toLocal())
        : 'Hari ini';

    Color bgColor;
    Color iconColor;
    IconData icon;

    if (tx.transactionType == 'topup') {
      bgColor = const Color(0xFFE8F2FF);
      iconColor = const Color(0xFF51A0FF);
      icon = Icons.download_rounded;
    } else if (tx.transactionType == 'transfer_in') {
      bgColor = const Color(0xFFF7E8FF);
      iconColor = const Color(0xFFB55FE6);
      icon = Icons.card_giftcard_rounded;
    } else if (tx.transactionType == 'transfer_out') {
      bgColor = const Color(0xFFE5F9EE);
      iconColor = const Color(0xFF22B07D);
      icon = Icons.upload_rounded;
    } else {
      bgColor = const Color(0xFFFFEFE5);
      iconColor = const Color(0xFFFF8B3E);
      icon = Icons.shopping_cart_outlined;
    }

    return {
      'title': tx.title ?? 'Transaksi',
      'subtitle': timeString,
      'amount': isIncome ? '+ $amountFormatted' : '- $amountFormatted',
      'isIncome': isIncome,
      'bgColor': bgColor,
      'iconColor': iconColor,
      'icon': icon,
    };
  }

  Widget _buildMockTransactionsView() {
    final filteredToday = mockToday.where((item) {
      if (selectedFilter == 'income') return item['isIncome'] == true;
      if (selectedFilter == 'expense') return item['isIncome'] == false;
      return true;
    }).toList();

    final filteredEarlier = mockEarlier.where((item) {
      if (selectedFilter == 'income') return item['isIncome'] == true;
      if (selectedFilter == 'expense') return item['isIncome'] == false;
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      children: [
        if (filteredToday.isNotEmpty) ...[
          _buildSectionHeader('Today'),
          _buildTransactionCard(filteredToday),
        ],
        if (filteredEarlier.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionHeader('Tue 12 Dec'),
          _buildTransactionCard(filteredEarlier),
        ],
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: blackTextStyle.copyWith(
          fontSize: 16,
          fontWeight: semiBold,
        ),
      ),
    );
  }

  Widget _buildTransactionCard(List<Map<String, dynamic>> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;

          return Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Row(
              children: [
                // Avatar pastel icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item['bgColor'] as Color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      item['icon'] as IconData,
                      color: item['iconColor'] as Color,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: blackTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: semiBold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item['subtitle'] as String,
                        style: greyTextStyle.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Amount
                Text(
                  item['amount'] as String,
                  style: blackTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: semiBold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
