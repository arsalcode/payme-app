import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:payme/blocs/auth/auth_bloc.dart';
import 'package:payme/blocs/transaction/transaction_bloc.dart';
import 'package:payme/shared/theme.dart';
import 'package:payme/ui/widgets/buttons.dart';
import 'package:payme/ui/widgets/forms.dart';

class DigitalServicePage extends StatefulWidget {
  final String serviceType; // 'water', 'stream', 'movie', 'food', 'travel'
  final String title;

  const DigitalServicePage({
    super.key,
    required this.serviceType,
    required this.title,
  });

  @override
  State<DigitalServicePage> createState() => _DigitalServicePageState();
}

class _DigitalServicePageState extends State<DigitalServicePage> {
  final TextEditingController customerNumberController =
      TextEditingController();
  int selectedPrice = 0;
  String selectedItemName = '';
  String selectedRegion = 'PAM Jaya (DKI Jakarta)';

  final List<String> pdamRegions = [
    'PAM Jaya (DKI Jakarta)',
    'PDAM Tirta Pakuan (Kota Bogor)',
    'PDAM Tirtawening (Bandung)',
    'PDAM Surya Sembada (Surabaya)',
  ];

  // List of packages based on service type
  late final List<Map<String, dynamic>> items;

  @override
  void initState() {
    super.initState();
    _initItems();
  }

  void _initItems() {
    switch (widget.serviceType) {
      case 'water':
        items = [
          {'name': 'Tagihan Bulan Ini', 'price': 85000, 'desc': 'Pemakaian: 18 m³'},
          {'name': 'Tagihan + Denda', 'price': 105000, 'desc': 'Pemakaian: 22 m³'},
        ];
        selectedPrice = 85000;
        selectedItemName = 'Tagihan PDAM';
        customerNumberController.text = '1092837482';
        break;

      case 'stream':
        items = [
          {'name': 'Netflix 1 Bulan', 'price': 54000, 'desc': 'Paket Ponsel HD'},
          {'name': 'Spotify Premium', 'price': 54990, 'desc': '1 Bulan Individual'},
          {'name': 'YouTube Premium', 'price': 59000, 'desc': '1 Bulan Bebas Iklan'},
          {'name': 'Vidio Platinum', 'price': 39000, 'desc': '30 Hari All Access'},
        ];
        selectedPrice = items[0]['price'];
        selectedItemName = items[0]['name'];
        break;

      case 'movie':
        items = [
          {'name': 'M-Tix XXI Rp 50.000', 'price': 50000, 'desc': 'Saldo Tiket Bioskop'},
          {'name': 'M-Tix XXI Rp 100.000', 'price': 100000, 'desc': 'Saldo Tiket Bioskop'},
          {'name': 'CGV Pay Rp 50.000', 'price': 50000, 'desc': 'Saldo Tiket CGV'},
          {'name': 'CGV Pay Rp 100.000', 'price': 100000, 'desc': 'Saldo Tiket CGV'},
        ];
        selectedPrice = items[0]['price'];
        selectedItemName = items[0]['name'];
        break;

      case 'food':
        items = [
          {'name': 'Voucher GrabFood Rp 50.000', 'price': 50000, 'desc': 'Berlaku 30 hari'},
          {'name': 'Voucher GoFood Rp 50.000', 'price': 50000, 'desc': 'Berlaku 30 hari'},
          {'name': 'Voucher ShopeeFood Rp 35.000', 'price': 35000, 'desc': 'Berlaku 14 hari'},
        ];
        selectedPrice = items[0]['price'];
        selectedItemName = items[0]['name'];
        break;

      case 'travel':
        items = [
          {'name': 'KAI Commuter Saldo', 'price': 50000, 'desc': 'Multi Trip Card'},
          {'name': 'Tiket Kereta Antarkota', 'price': 150000, 'desc': 'Voucher KAI Access'},
          {'name': 'Voucher Traveloka Rp 200.000', 'price': 200000, 'desc': 'Hotel & Tiket'},
        ];
        selectedPrice = items[0]['price'];
        selectedItemName = items[0]['name'];
        break;

      default:
        items = [
          {'name': 'Paket Layanan', 'price': 50000, 'desc': 'Standar'}
        ];
        selectedPrice = 50000;
        selectedItemName = 'Paket Layanan';
    }
  }

  @override
  void dispose() {
    customerNumberController.dispose();
    super.dispose();
  }

  String formatCurrency(int val) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(val);
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthSuccess ? authState.user : null;
    final userBalance = user?.balance ?? 0;

    return Scaffold(
      backgroundColor: lightkBackgroundColor,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionSuccess) {
            context.read<AuthBloc>().add(AuthGetCurrentUser());
            Navigator.pushNamedAndRemoveUntil(
                context, '/data-succes', (route) => false);
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
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            children: [
              // SALDO DOMPET
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: blueColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.account_balance_wallet_rounded,
                              color: blueColor),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Saldo Payme Anda',
                              style: greyTextStyle.copyWith(fontSize: 12),
                            ),
                            Text(
                              formatCurrency(userBalance),
                              style: blackTextStyle.copyWith(
                                fontSize: 16,
                                fontWeight: semiBold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/topup'),
                      child: Text('Top Up', style: blueTextStyle),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // KHUSUS PDAM: PILIH WILAYAH & INPUT NO METER
              if (widget.serviceType == 'water') ...[
                Text(
                  'Wilayah PDAM',
                  style: blackTextStyle.copyWith(
                    fontSize: 15,
                    fontWeight: semiBold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: greykColor.withValues(alpha: 0.2)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedRegion,
                      isExpanded: true,
                      items: pdamRegions
                          .map((r) => DropdownMenuItem(
                                value: r,
                                child: Text(r, style: blackTextStyle),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedRegion = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Nomor Sambungan / ID Pelanggan',
                  style: blackTextStyle.copyWith(
                    fontSize: 15,
                    fontWeight: semiBold,
                  ),
                ),
                const SizedBox(height: 10),
                CustomFormFailed(
                  title: 'ID Pelanggan',
                  controller: customerNumberController,
                  keyboardType: TextInputType.number,
                  isShowTitle: false,
                ),
                const SizedBox(height: 24),
              ],

              // DAFTAR PAKET / TAGIHAN
              Text(
                widget.serviceType == 'water'
                    ? 'Rincian Tagihan Air'
                    : 'Pilih Paket / Nominal',
                style: blackTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semiBold,
                ),
              ),
              const SizedBox(height: 14),

              ...items.map((item) {
                final isSelected = selectedPrice == item['price'] &&
                    selectedItemName == item['name'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPrice = item['price'];
                      selectedItemName = item['name'];
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? blueColor : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: blackTextStyle.copyWith(
                                fontSize: 15,
                                fontWeight: semiBold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['desc'],
                              style: greyTextStyle.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              formatCurrency(item['price']),
                              style: blueTextStyle.copyWith(
                                fontSize: 15,
                                fontWeight: semiBold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isSelected)
                              Icon(Icons.check_circle,
                                  color: blueColor, size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 36),

              CustomFilledButtons(
                title: 'Bayar Sekarang (${formatCurrency(selectedPrice)})',
                onPressed: () async {
                  if (userBalance < selectedPrice) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                            'Saldo Payme tidak mencukupi untuk transaksi ini!'),
                      ),
                    );
                    return;
                  }

                  // Verifikasi PIN sebelum bayar
                  final pinVerified =
                      await Navigator.pushNamed(context, '/pin');

                  if (pinVerified == true) {
                    if (context.mounted) {
                      final serviceTitle = widget.serviceType == 'water'
                          ? 'Tagihan $selectedRegion'
                          : selectedItemName;

                      context.read<TransactionBloc>().add(
                            TransactionPayServiceEvent(
                              amount: selectedPrice,
                              serviceTitle: serviceTitle,
                              serviceType: widget.serviceType,
                            ),
                          );
                    }
                  }
                },
              ),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }
}
