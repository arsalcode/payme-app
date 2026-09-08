import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:payme/blocs/auth/auth_bloc.dart';
import 'package:payme/shared/theme.dart';

class WalletSettingsPage extends StatefulWidget {
  const WalletSettingsPage({super.key});

  @override
  State<WalletSettingsPage> createState() => _WalletSettingsPageState();
}

class _WalletSettingsPageState extends State<WalletSettingsPage> {
  bool isShowCardNumber = true;
  bool isCardFrozen = false;
  bool isOnlineTxActive = true;
  bool isContactlessActive = true;
  double dailyLimit = 10000000; // Rp 10.000.000

  String formatCurrency(double val) {
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
    final rawCardNumber = user?.cardNumber ?? '5399882208191280';

    // Format 16 digits into 4 chunks
    final chunk1 = rawCardNumber.length >= 4 ? rawCardNumber.substring(0, 4) : '5399';
    final chunk2 = rawCardNumber.length >= 8 ? rawCardNumber.substring(4, 8) : '8822';
    final chunk3 = rawCardNumber.length >= 12 ? rawCardNumber.substring(8, 12) : '0819';
    final chunk4 = rawCardNumber.length >= 16 ? rawCardNumber.substring(12, 16) : '1280';

    final displayNumber = isShowCardNumber
        ? '$chunk1 $chunk2 $chunk3 $chunk4'
        : '$chunk1 •••• •••• $chunk4';

    return Scaffold(
      backgroundColor: lightkBackgroundColor,
      appBar: AppBar(
        title: const Text('Wallet & Card Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          // 1. KARTU DEBIT VIRTUAL INTERAKTIF
          Container(
            height: 220,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isCardFrozen
                    ? [const Color(0xFF475569), const Color(0xFF1E293B)]
                    : [const Color(0xFF3B82F6), purpleColor, const Color(0xFF1E1B4B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (isCardFrozen ? Colors.black : purpleColor).withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payme Virtual Debit',
                      style: whiteTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: semiBold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      children: [
                        if (isCardFrozen)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'TERKUNCI',
                              style: whiteTextStyle.copyWith(fontSize: 10, fontWeight: bold),
                            ),
                          ),
                        Image.asset(
                          'assets/images/img_bank_bca.png',
                          width: 48,
                          height: 24,
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        ),
                      ],
                    ),
                  ],
                ),

                // CHIP & CONTACTLESS ICON
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.wifi_rounded,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 22,
                    ),
                  ],
                ),

                // NOMOR KARTU & TOGGLE EYE & COPY
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          displayNumber,
                          style: whiteTextStyle.copyWith(
                            fontSize: 18,
                            fontWeight: semiBold,
                            letterSpacing: 2,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isShowCardNumber ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              isShowCardNumber = !isShowCardNumber;
                            });
                          },
                          tooltip: isShowCardNumber ? 'Sembunyikan' : 'Tampilkan',
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.copy_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: rawCardNumber));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: greenColor,
                                duration: const Duration(seconds: 2),
                                content: Text(
                                  'Nomor Kartu disalin: $rawCardNumber',
                                  style: whiteTextStyle,
                                ),
                              ),
                            );
                          },
                          tooltip: 'Salin nomor kartu',
                        ),
                      ],
                    ),
                  ],
                ),

                // NAMA & EXPIRED
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PEMILIK KARTU',
                          style: whiteTextStyle.copyWith(
                            fontSize: 9,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          (user?.name ?? 'USER').toUpperCase(),
                          style: whiteTextStyle.copyWith(
                            fontSize: 13,
                            fontWeight: semiBold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'BERLAKU',
                          style: whiteTextStyle.copyWith(
                            fontSize: 9,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          '12/28',
                          style: whiteTextStyle.copyWith(
                            fontSize: 13,
                            fontWeight: semiBold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'CVV',
                          style: whiteTextStyle.copyWith(
                            fontSize: 9,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          isShowCardNumber ? '824' : '•••',
                          style: whiteTextStyle.copyWith(
                            fontSize: 13,
                            fontWeight: semiBold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // 2. KONTROL KEAMANAN KARTU
          Text(
            'Kontrol Keamanan Kartu',
            style: blackTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isCardFrozen
                          ? Colors.red.withValues(alpha: 0.1)
                          : blueColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isCardFrozen ? Icons.lock_rounded : Icons.lock_open_rounded,
                      color: isCardFrozen ? Colors.red : blueColor,
                    ),
                  ),
                  title: Text(
                    'Kunci / Bekukan Kartu',
                    style: blackTextStyle.copyWith(fontWeight: semiBold, fontSize: 14),
                  ),
                  subtitle: Text(
                    'Nonaktifkan sementara seluruh transaksi kartu virtual',
                    style: greyTextStyle.copyWith(fontSize: 12),
                  ),
                  value: isCardFrozen,
                  activeThumbColor: Colors.red,
                  onChanged: (val) {
                    setState(() {
                      isCardFrozen = val;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: val ? Colors.red : Colors.green,
                        content: Text(val
                            ? 'Kartu berhasil dibekukan sementara.'
                            : 'Kartu telah diaktifkan kembali.'),
                      ),
                    );
                  },
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: greenColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.language_rounded, color: greenColor),
                  ),
                  title: Text(
                    'Transaksi Online & E-Commerce',
                    style: blackTextStyle.copyWith(fontWeight: semiBold, fontSize: 14),
                  ),
                  subtitle: Text(
                    'Izinkan pembayaran merchant online via kartu',
                    style: greyTextStyle.copyWith(fontSize: 12),
                  ),
                  value: isOnlineTxActive,
                  activeThumbColor: blueColor,
                  onChanged: (val) => setState(() => isOnlineTxActive = val),
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: purpleColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.nfc_rounded, color: purpleColor),
                  ),
                  title: Text(
                    'Pembayaran Contactless (NFC)',
                    style: blackTextStyle.copyWith(fontWeight: semiBold, fontSize: 14),
                  ),
                  subtitle: Text(
                    'Tap to pay di mesin EDC tanpa kontak',
                    style: greyTextStyle.copyWith(fontSize: 12),
                  ),
                  value: isContactlessActive,
                  activeThumbColor: blueColor,
                  onChanged: (val) => setState(() => isContactlessActive = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. LIMIT TRANSAKSI HARIAN
          Text(
            'Batas Limit Harian',
            style: blackTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
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
                      'Batas Pengeluaran Per Hari:',
                      style: greyTextStyle.copyWith(fontSize: 13),
                    ),
                    Text(
                      formatCurrency(dailyLimit),
                      style: blueTextStyle.copyWith(fontSize: 15, fontWeight: semiBold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Slider(
                  value: dailyLimit,
                  min: 1000000,
                  max: 25000000,
                  divisions: 24,
                  activeColor: blueColor,
                  onChanged: (val) {
                    setState(() {
                      dailyLimit = val;
                    });
                  },
                ),
                Text(
                  '*Limit dapat disesuaikan sewaktu-waktu sesuai kebutuhan transaksi Anda.',
                  style: greyTextStyle.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }
}
