import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payme/blocs/auth/auth_bloc.dart';
import 'package:payme/shared/theme.dart';
import 'package:payme/ui/widgets/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RewardPage extends StatefulWidget {
  final bool isTab;

  const RewardPage({
    super.key,
    this.isTab = false,
  });

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  int userPoints = 450;
  bool isClaimedToday = false;
  bool isRedeeming = false;
  List<Map<String, dynamic>> myClaimedVouchers = [];

  final List<Map<String, dynamic>> vouchers = [
    {
      'title': 'Cashback Saldo Rp 15.000',
      'cost': 150,
      'code': 'CASHBACK15K',
      'icon': Icons.account_balance_wallet_rounded,
      'color': const Color(0xFFB55FE6),
      'bgColor': const Color(0xFFF7E8FF),
      'isCashback': true,
      'cashbackValue': 15000,
    },
    {
      'title': 'Diskon Paket Data Rp 10.000',
      'cost': 100,
      'code': 'DATAHEMAT10',
      'icon': Icons.wifi_rounded,
      'color': const Color(0xFF51A0FF),
      'bgColor': const Color(0xFFE8F2FF),
      'isCashback': false,
    },
    {
      'title': 'Bebas Biaya Transfer',
      'cost': 65,
      'code': 'FREETRANSFER',
      'icon': Icons.send_rounded,
      'color': const Color(0xFF22B07D),
      'bgColor': const Color(0xFFE5F9EE),
      'isCashback': false,
    },
    {
      'title': 'Voucher Belanja Rp 25.000',
      'cost': 250,
      'code': 'SHOPPING25',
      'icon': Icons.shopping_bag_rounded,
      'color': const Color(0xFFFF8B3E),
      'bgColor': const Color(0xFFFFEFE5),
      'isCashback': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadRewardState();
  }

  String _getUserKey(String prefix) {
    final userId = _supabase.auth.currentUser?.id ?? 'guest';
    return '${prefix}_$userId';
  }

  Future<void> _loadRewardState() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);

    final pointsKey = _getUserKey('user_reward_points');
    final claimKey = _getUserKey('last_claimed_date');
    final vouchersKey = _getUserKey('claimed_vouchers');

    final savedPoints = prefs.getInt(pointsKey) ?? 450;
    final lastClaimed = prefs.getString(claimKey);
    final savedVouchersJson = prefs.getStringList(vouchersKey) ?? [];

    setState(() {
      userPoints = savedPoints;
      isClaimedToday = (lastClaimed == todayStr);
      myClaimedVouchers = savedVouchersJson
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> _savePoints(int newPoints) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_getUserKey('user_reward_points'), newPoints);
    setState(() {
      userPoints = newPoints;
    });
  }

  Future<void> _claimDailyPoints() async {
    if (isClaimedToday) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: blueColor,
          content: const Text('Anda sudah mengambil bonus harian hari ini.'),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString(_getUserKey('last_claimed_date'), todayStr);

    final updatedPoints = userPoints + 25;
    await _savePoints(updatedPoints);

    setState(() {
      isClaimedToday = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: greenColor,
          content: const Text('🎉 Selamat! +25 Poin bonus harian berhasil ditambahkan.'),
        ),
      );
    }
  }

  Future<void> _redeemVoucher(Map<String, dynamic> voucher) async {
    final cost = voucher['cost'] as int;
    if (userPoints < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Poin Anda belum mencukupi untuk voucher ini.'),
        ),
      );
      return;
    }

    final isCashback = voucher['isCashback'] == true;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Penukaran'),
        content: Text(
          isCashback
              ? 'Tukarkan $cost Pts langsung menjadi Saldo Asli Dompet Payme senilai Rp 15.000?'
              : 'Tukarkan $cost Pts dengan voucher "${voucher['title']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: greyTextStyle),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: purpleColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => isRedeeming = true);

              try {
                final user = _supabase.auth.currentUser;

                // Jika voucher Cashback: Tambah saldo riil di Supabase!
                if (isCashback && user != null) {
                  final wallet = await _supabase
                      .from('wallets')
                      .select()
                      .eq('user_id', user.id)
                      .single();

                  final currentBalance = (wallet['balance'] as num).toInt();
                  final cashbackVal = voucher['cashbackValue'] as int;

                  await _supabase.from('wallets').update({
                    'balance': currentBalance + cashbackVal,
                  }).eq('user_id', user.id);

                  await _supabase.from('transactions').insert({
                    'user_id': user.id,
                    'transaction_type': 'topup',
                    'title': 'Cashback Reward Poin (+Rp 15.000)',
                    'amount': cashbackVal,
                    'status': 'success',
                  });

                  if (mounted) {
                    context.read<AuthBloc>().add(AuthGetCurrentUser());
                  }
                }

                // Potong Poin
                final updatedPoints = userPoints - cost;
                await _savePoints(updatedPoints);

                // Simpan ke daftar voucher aktif pengguna
                final newVoucherRecord = {
                  'title': voucher['title'],
                  'code': voucher['code'],
                  'date': DateTime.now().toIso8601String().substring(0, 10),
                  'isCashback': isCashback,
                };

                final prefs = await SharedPreferences.getInstance();
                final vouchersKey = _getUserKey('claimed_vouchers');
                final currentList = prefs.getStringList(vouchersKey) ?? [];
                currentList.insert(0, jsonEncode(newVoucherRecord));
                await prefs.setStringList(vouchersKey, currentList);

                setState(() {
                  myClaimedVouchers.insert(0, newVoucherRecord);
                  isRedeeming = false;
                });

                if (mounted) {
                  _showSuccessDialog(voucher, isCashback);
                }
              } catch (e) {
                setState(() => isRedeeming = false);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('Gagal menukarkan: $e'),
                    ),
                  );
                }
              }
            },
            child: const Text('Tukarkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(Map<String, dynamic> voucher, bool isCashback) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: greenColor.withValues(alpha: 0.15),
              ),
              child: Center(
                child: Icon(Icons.check_circle_rounded,
                    color: greenColor, size: 48),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isCashback
                  ? 'Saldo Berhasil Ditambahkan!'
                  : 'Voucher Berhasil Diklaim!',
              style: blackTextStyle.copyWith(
                fontSize: 17,
                fontWeight: semiBold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isCashback
                  ? 'Bonus saldo Rp 15.000 sudah masuk langsung ke dompet digital Payme Anda.'
                  : 'Gunakan kode promo berikut saat bertransaksi:',
              style: greyTextStyle.copyWith(fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: lightkBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: blueColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    voucher['code'] as String,
                    style: blueTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: semiBold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: voucher['code'] as String));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kode voucher disalin ke clipboard!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Icon(Icons.copy_rounded, size: 18, color: blueColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomFilledButtons(
              title: 'Selesai',
              width: 150,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (userPoints / 1000).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: lightkBackgroundColor,
      appBar: AppBar(
        title: const Text('Rewards & Loyalty'),
        automaticallyImplyLeading: !widget.isTab,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help_outline_rounded,
              color: Color(0xFF14193F),
              size: 22,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: blueColor,
                  content: const Text(
                      'Kumpulkan poin dari transaksi harian dan tukarkan dengan saldo asli atau voucher!'),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isRedeeming
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              children: [
                // 1. BANNER POIN & PROGRESS LEVEL
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5311EC), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5311EC).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
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
                            'Payme Points',
                            style: whiteTextStyle.copyWith(
                              fontSize: 14,
                              fontWeight: medium,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              userPoints >= 1000 ? '👑 Level 2 Gold' : '⭐ Level 1 Member',
                              style: whiteTextStyle.copyWith(
                                fontSize: 11,
                                fontWeight: semiBold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$userPoints',
                            style: whiteTextStyle.copyWith(
                              fontSize: 36,
                              fontWeight: semiBold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Pts',
                            style: whiteTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: medium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Target Menuju Level 2',
                            style: whiteTextStyle.copyWith(fontSize: 12),
                          ),
                          Text(
                            '$userPoints / 1000 Pts',
                            style: whiteTextStyle.copyWith(
                              fontSize: 12,
                              fontWeight: semiBold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 7,
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. CHECK-IN HARIAN (DAILY STREAK)
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
                            'Daily Check-in',
                            style: blackTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: semiBold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: isClaimedToday
                                  ? greykColor.withValues(alpha: 0.2)
                                  : greenColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isClaimedToday ? 'Sudah Diambil' : '+25 Pts Hari Ini',
                              style: isClaimedToday
                                  ? greyTextStyle.copyWith(
                                      fontSize: 11, fontWeight: semiBold)
                                  : greenTextStyle.copyWith(
                                      fontSize: 11, fontWeight: semiBold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (index) {
                          final isToday = index == 2;
                          final isPassed = index < 2 || (isToday && isClaimedToday);

                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isPassed
                                    ? purpleColor.withValues(alpha: 0.12)
                                    : lightkBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isToday
                                      ? purpleColor
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'D${index + 1}',
                                    style: greyTextStyle.copyWith(fontSize: 10),
                                  ),
                                  const SizedBox(height: 4),
                                  Icon(
                                    isPassed
                                        ? Icons.check_circle_rounded
                                        : Icons.stars_rounded,
                                    color: isPassed
                                        ? purpleColor
                                        : const Color(0xFFF59E0B),
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: isClaimedToday ? null : _claimDailyPoints,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: purpleColor,
                            disabledBackgroundColor:
                                greykColor.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isClaimedToday
                                ? 'Bonus Hari Ini Sudah Diklaim'
                                : 'Ambil Bonus Harian (+25 Poin)',
                            style: whiteTextStyle.copyWith(
                              fontSize: 13,
                              fontWeight: semiBold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. VOUCHER AKTIF SAYA (JIKA ADA)
                if (myClaimedVouchers.isNotEmpty) ...[
                  Text(
                    'Voucher Aktif Saya (${myClaimedVouchers.length})',
                    style: blackTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: semiBold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...myClaimedVouchers.take(3).map((v) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: greenColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.confirmation_number_rounded,
                                    color: greenColor, size: 22),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      v['title'] ?? 'Voucher',
                                      style: blackTextStyle.copyWith(
                                        fontSize: 13,
                                        fontWeight: semiBold,
                                      ),
                                    ),
                                    Text(
                                      'Kode: ${v['code']} • ${v['date']}',
                                      style: greyTextStyle.copyWith(
                                          fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: v['code'] ?? ''));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Kode voucher disalin!'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Text('Salin', style: blueTextStyle),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 20),
                ],

                // 4. DAFTAR TUKAR VOUCHER & CASHBACK
                Text(
                  'Tukar Poin Hadiah',
                  style: blackTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: semiBold,
                  ),
                ),
                const SizedBox(height: 14),

                ...vouchers.map((voucher) {
                  final canRedeem = userPoints >= (voucher['cost'] as int);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: voucher['bgColor'] as Color,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            voucher['icon'] as IconData,
                            color: voucher['color'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                voucher['title'] as String,
                                style: blackTextStyle.copyWith(
                                  fontSize: 14,
                                  fontWeight: semiBold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.stars_rounded,
                                    color: Color(0xFFF59E0B),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${voucher['cost']} Pts',
                                    style: blackTextStyle.copyWith(
                                      fontSize: 12,
                                      fontWeight: medium,
                                      color: const Color(0xFFF59E0B),
                                    ),
                                  ),
                                  if (voucher['isCashback'] == true) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: greenColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Saldo Asli',
                                        style: greenTextStyle.copyWith(
                                          fontSize: 10,
                                          fontWeight: semiBold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: canRedeem
                              ? () => _redeemVoucher(voucher)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: purpleColor,
                            disabledBackgroundColor:
                                greykColor.withValues(alpha: 0.3),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            canRedeem ? 'Tukar' : 'Poin Kurang',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: canRedeem ? Colors.white : greykColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 40),
              ],
            ),
    );
  }
}
