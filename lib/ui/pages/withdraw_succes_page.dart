import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payme/shared/theme.dart';
import 'package:payme/ui/widgets/buttons.dart';

class WithdrawSuccesPage extends StatelessWidget {
  final String token;
  final int amount;
  final String method;

  const WithdrawSuccesPage({
    super.key,
    required this.token,
    required this.amount,
    required this.method,
  });

  String formatCurrency(int val) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(val);
  }

  @override
  Widget build(BuildContext context) {
    // Format token e.g. "839201" -> "839 201"
    final formattedToken = token.length == 6
        ? '${token.substring(0, 3)} ${token.substring(3)}'
        : token;

    return Scaffold(
      backgroundColor: lightkBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: greenColor.withValues(alpha: 0.15),
                ),
                child: Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: greenColor,
                    size: 56,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Tarik Tunai Disiapkan!',
                style: blackTextStyle.copyWith(
                  fontSize: 20,
                  fontWeight: semiBold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Tunjukkan kode penarikan berikut di $method\ntanpa perlu menggunakan kartu fisik.',
                style: greyTextStyle.copyWith(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // KARTU KODE TARIK TUNAI
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'KODE TRANSAKSI TARIK TUNAI',
                    style: greyTextStyle.copyWith(
                      fontSize: 11,
                      fontWeight: semiBold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: blueColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: blueColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      formattedToken,
                      style: blueTextStyle.copyWith(
                        fontSize: 32,
                        fontWeight: semiBold,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: greykColor,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Berlaku hingga 60 menit ke depan',
                        style: greyTextStyle.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(thickness: 1),
                  const SizedBox(height: 16),

                  // DETAIL PENARIKAN
                  _buildDetailRow('Metode Penarikan', method),
                  const SizedBox(height: 12),
                  _buildDetailRow('Nominal Uang', formatCurrency(amount)),
                  const SizedBox(height: 12),
                  _buildDetailRow('Biaya Transaksi', 'Gratis (Rp 0)'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Status Mutasi', 'Sukses Diproses',
                      valueColor: greenColor),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // PETUNJUK PENARIKAN
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: blueColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Langkah Pengambilan Uang:',
                        style: blackTextStyle.copyWith(
                          fontSize: 13,
                          fontWeight: semiBold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildStep('1', 'Kunjungi mesin $method terdekat.'),
                  _buildStep('2', 'Pilih menu "Tarik Tunai Tanpa Kartu / Cardless".'),
                  _buildStep('3', 'Masukkan nomor HP Anda & ketik 6 digit kode di atas.'),
                  _buildStep('4', 'Uang tunai akan keluar dari mesin ATM secara otomatis.'),
                ],
              ),
            ),

            const SizedBox(height: 36),

            CustomFilledButtons(
              title: 'Kembali ke Home',
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home-page',
                  (route) => false,
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: greyTextStyle.copyWith(fontSize: 13),
        ),
        Text(
          value,
          style: blackTextStyle.copyWith(
            fontSize: 13,
            fontWeight: semiBold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 2, right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: blueColor.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Text(
                number,
                style: blueTextStyle.copyWith(
                  fontSize: 10,
                  fontWeight: semiBold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: blackTextStyle.copyWith(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
