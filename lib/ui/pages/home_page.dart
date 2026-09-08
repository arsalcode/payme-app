import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:payme/blocs/auth/auth_bloc.dart';
import 'package:payme/blocs/transaction/transaction_bloc.dart';
import 'package:payme/models/transaction_model.dart';
import 'package:payme/models/user_model.dart';
import 'package:payme/shared/theme.dart';
import 'package:payme/ui/widgets/home_lates_trasaction_item.dart';
import 'package:payme/ui/widgets/home_services_item.dart';
import 'package:payme/ui/widgets/home_tips_item.dart';
import 'package:payme/ui/widgets/home_user_item.dart';

import 'package:payme/ui/pages/transfer_amount_page.dart';
import 'package:payme/ui/pages/history_page.dart';
import 'package:payme/ui/pages/statistic_page.dart';
import 'package:payme/ui/pages/reward_page.dart';
import 'package:payme/ui/pages/digital_service_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTab = 0;
  bool _isCardNumberVisible = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Segarkan data pengguna & dompet langsung dari Supabase saat masuk ke Home
    context.read<AuthBloc>().add(AuthGetCurrentUser());
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedTab = index;
    });

    if (index == 0) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } else if (index == 1 || index == 2) {
      // Segarkan data mutasi riwayat & statistik
      context.read<TransactionBloc>().add(TransactionGetLatestEvent());
    }
  }

  Widget _buildNavItem(int index, String iconPath, String label) {
    final isSelected = _selectedTab == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTabTapped(index),
          splashColor: blueColor.withValues(alpha: 0.12),
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  width: isSelected ? 58 : 36,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? blueColor.withValues(alpha: 0.16)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: AnimatedScale(
                    scale: isSelected ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    child: Image.asset(
                      iconPath,
                      width: 21,
                      height: 21,
                      color: isSelected ? blueColor : greykColor,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: isSelected
                      ? blueTextStyle.copyWith(
                          fontSize: 10,
                          fontWeight: semiBold,
                          letterSpacing: 0.1,
                        )
                      : greyTextStyle.copyWith(
                          fontSize: 10,
                          fontWeight: medium,
                        ),
                ),
                const SizedBox(height: 2),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  width: isSelected ? 20 : 0,
                  height: 3,
                  decoration: BoxDecoration(
                    color: isSelected ? blueColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: whiteColor,
        shape: const CircularNotchedRectangle(),
        clipBehavior: Clip.antiAlias,
        notchMargin: 6,
        elevation: 0,
        padding: EdgeInsets.zero,
        height: 78,
        child: Row(
          children: [
            _buildNavItem(0, 'assets/images/ic_overiview.png', 'OverView'),
            _buildNavItem(1, 'assets/images/ic_history.png', 'History'),
            const SizedBox(width: 48),
            _buildNavItem(2, 'assets/images/ic_statistic.png', 'Statistic'),
            _buildNavItem(3, 'assets/images/ic_reward.png', 'Reward'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const MoreDialog(),
          );
        },
        backgroundColor: purpleColor,
        child: Image.asset(
          'assets/images/ic_plus_cirle.png',
          width: 24,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state is AuthSuccess ? state.user : null;

          if (_selectedTab == 1) {
            return const HistoryPage(isTab: true);
          }
          if (_selectedTab == 2) {
            return const StatisticPage(isTab: true);
          }
          if (_selectedTab == 3) {
            return const RewardPage(isTab: true);
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AuthBloc>().add(AuthGetCurrentUser());
              context.read<TransactionBloc>().add(TransactionGetLatestEvent());
            },
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              children: [
                buildProfile(context, user),
                buildWalentCart(user),
                buildLevel(),
                buildServices(context),
                buildLatesTransction(),
                buildSendAgain(context),
                buildFrienLyTips(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildProfile(BuildContext context, UserModel? user) {
    return Container(
      margin: const EdgeInsets.only(
        top: 48,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Howdy,',
                style: greenTextStyle.copyWith(
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                user?.name ?? 'User',
                style: blackTextStyle.copyWith(
                  fontSize: 20,
                  fontWeight: semiBold,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: user?.profilePicture != null &&
                        user!.profilePicture!.isNotEmpty
                    ? DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(user.profilePicture!),
                      )
                    : const DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/images/img_profile.png'),
                      ),
              ),
              child: user?.isVerified == true
                  ? Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: whiteColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.check_circle,
                            color: greenColor,
                            size: 20,
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWalentCart(UserModel? user) {
    final rawCardNumber = (user?.cardNumber != null && user!.cardNumber!.isNotEmpty)
        ? user.cardNumber!
        : '5399882208191280';

    // Format 16 digit menjadi 4 kelompok angka (misal: 5399 8822 0819 1280)
    String displayCardNumber;
    if (rawCardNumber.length >= 16) {
      final c1 = rawCardNumber.substring(0, 4);
      final c2 = rawCardNumber.substring(4, 8);
      final c3 = rawCardNumber.substring(8, 12);
      final c4 = rawCardNumber.substring(12, 16);
      displayCardNumber = _isCardNumberVisible
          ? '$c1 $c2 $c3 $c4'
          : '$c1 •••• •••• $c4';
    } else {
      displayCardNumber = rawCardNumber;
    }

    final balanceFormatted = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(user?.balance ?? 100000);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/wallet-settings');
      },
      child: Container(
        width: double.infinity,
        height: 236,
        margin: const EdgeInsets.only(
          top: 32,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          image: const DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/img_bg_card.png'),
          ),
          boxShadow: [
            BoxShadow(
              color: purpleColor.withValues(alpha: 0.3),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Baris Atas: Kotak Nomor Kartu Virtual (Tinggi 72px, sangat lega & mantap)
            Container(
              height: 90,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.20),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
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
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          displayCardNumber,
                          style: whiteTextStyle.copyWith(
                            fontSize: 21,
                            fontWeight: semiBold,
                            letterSpacing: 2.8,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Tombol Toggle Tampilkan / Sembunyikan Nomor Kartu
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isCardNumberVisible = !_isCardNumberVisible;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isCardNumberVisible
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Tombol Salin Nomor Kartu (Tinggi, lega, & jelas)
                  GestureDetector(
                    onTap: () {
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.copy_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Salin',
                            style: whiteTextStyle.copyWith(
                              fontSize: 14,
                              fontWeight: semiBold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Baris Bawah: Saldo & Pintasan Pengaturan Kartu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo Dompet',
                      style: whiteTextStyle.copyWith(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      balanceFormatted,
                      style: whiteTextStyle.copyWith(
                        fontSize: 24,
                        fontWeight: semiBold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Kelola Kartu',
                        style: whiteTextStyle.copyWith(
                          fontSize: 12,
                          fontWeight: medium,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 11,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLevel() {
    return Container(
      margin: EdgeInsets.only(
        top: 20,
      ),
      padding: EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: whiteColor,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Level 1',
                style: blackTextStyle.copyWith(fontWeight: medium),
              ),
              const Spacer(),
              Text(
                '55%',
                style: greenTextStyle.copyWith(
                  fontWeight: semiBold,
                ),
              ),
              Text(
                ' of Rp. 20.000',
                style: blackTextStyle.copyWith(
                  fontWeight: semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(55),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: 0.55,
              valueColor: AlwaysStoppedAnimation(greenColor),
              backgroundColor: lightkBackgroundColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildServices(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Do Somthing',
            style: blackTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semiBold,
            ),
          ),
          SizedBox(
            height: 14,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HomeServicesItem(
                iconUrl: 'assets/images/ic_top.png',
                title: 'Top Up',
                onTap: () {
                  Navigator.pushNamed(context, '/topup');
                },
              ),
              HomeServicesItem(
                iconUrl: 'assets/images/ic_send.png',
                title: 'Send',
                onTap: () {
                  Navigator.pushNamed(context, '/transfer-page');
                },
              ),
              HomeServicesItem(
                iconUrl: 'assets/images/ic_withrow.png',
                title: 'Withdraw',
                onTap: () {
                  Navigator.pushNamed(context, '/withdraw');
                },
              ),
              HomeServicesItem(
                iconUrl: 'assets/images/ic_more.png',
                title: 'More',
                onTap: () {
                  showDialog(
                      context: context, builder: (context) => const MoreDialog());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildLatesTransction() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest Transactions',
            style: blackTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          Container(
            padding: const EdgeInsets.all(22),
            margin: const EdgeInsets.only(top: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: whiteColor,
            ),
            child: BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state is TransactionLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state is TransactionLatestLoaded) {
                  if (state.transactions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Belum ada transaksi',
                          style: greyTextStyle,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: state.transactions.map((tx) {
                      String icon = 'assets/images/ic_transaction.png';
                      final isIncome = tx.transactionType == 'topup' ||
                          tx.transactionType == 'transfer_in';

                      if (tx.transactionType == 'topup') {
                        icon = 'assets/images/ic_transaction.png';
                      } else if (tx.transactionType == 'transfer_in') {
                        icon = 'assets/images/ic_casback.png';
                      } else if (tx.transactionType == 'transfer_out') {
                        icon = 'assets/images/ic_transfer.png';
                      } else {
                        icon = 'assets/images/ic_product_data.png';
                      }

                      final timeString = tx.createdAt != null
                          ? DateFormat('MMM dd, HH:mm')
                              .format(tx.createdAt!.toLocal())
                          : 'Baru saja';

                      final amountFormatted = NumberFormat.currency(
                        locale: 'id',
                        symbol: '',
                        decimalDigits: 0,
                      ).format(tx.amount ?? 0);

                      final valueString = isIncome
                          ? '+ $amountFormatted'
                          : '- $amountFormatted';

                      return HomeLatesTrasactionItem(
                        iconUrl: icon,
                        title: tx.title ?? 'Transaksi',
                        time: timeString,
                        value: valueString,
                      );
                    }).toList(),
                  );
                }

                // Fallback awal jika belum terambil
                return const Column(
                  children: [
                    HomeLatesTrasactionItem(
                      iconUrl: 'assets/images/ic_transaction.png',
                      title: 'Welcome Bonus',
                      time: 'Hari ini',
                      value: '+ 100.000',
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSendAgain(BuildContext context) {
    void navigateToTransfer(String targetUsername) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TransferAmmountPage(
            recipientUsername: targetUsername,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(
        top: 30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Send Again',
            style: blackTextStyle.copyWith(
              fontWeight: semiBold,
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                HomeUserItem(
                  imageUrl: 'assets/images/img_frend1.png',
                  username: 'yoenna',
                  onTap: () => navigateToTransfer('yoenna'),
                ),
                HomeUserItem(
                  imageUrl: 'assets/images/img_frend2.png',
                  username: 'jonnhi',
                  onTap: () => navigateToTransfer('jonnhi'),
                ),
                HomeUserItem(
                  imageUrl: 'assets/images/img_frend3.png',
                  username: 'urip',
                  onTap: () => navigateToTransfer('urip'),
                ),
                HomeUserItem(
                  imageUrl: 'assets/images/img_profile.png',
                  username: 'arsal',
                  onTap: () => navigateToTransfer('arsal'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFrienLyTips() {
    return Container(
      margin: const EdgeInsets.only(
        top: 30,
        bottom: 50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Friendly Tips',
            style: blackTextStyle.copyWith(
              fontWeight: semiBold,
              fontSize: 17,
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          Wrap(
            spacing: 17,
            runSpacing: 10,
            children: const [
              HomeTipsItem(
                imageUrl: 'assets/images/img_tips1.png',
                title: 'Best tips for using\n a credit card',
                url:
                    'https://buildwithangga.com/tips/belajar-entity-relationship-diagram-studi-kasus-platform-media-sosial',
              ),
              HomeTipsItem(
                imageUrl: 'assets/images/img_tips2.png',
                title: 'Spot the good pie\n of finance modeld',
                url: 'https://www.google.com',
              ),
              HomeTipsItem(
                imageUrl: 'assets/images/img_tips3.png',
                title: 'Great hack to get\n better advices',
                url: 'https://www.google.com',
              ),
              HomeTipsItem(
                imageUrl: 'assets/images/img_tips4.png',
                title: 'Save more penny\n buy this instead ',
                url: 'https://www.google.com',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MoreDialog extends StatelessWidget {
  const MoreDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      alignment: Alignment.bottomCenter,
      content: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
          color: lightkBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: greykColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    'Do More With Us',
                    style: blackTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: semiBold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Center(
                  child: Wrap(
                    runSpacing: 16,
                    spacing: 24,
                    alignment: WrapAlignment.center,
                    children: [
                      HomeServicesItem(
                        iconUrl: 'assets/images/ic_product_data.png',
                        title: 'Data',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/data-provider');
                        },
                      ),
                      HomeServicesItem(
                        iconUrl: 'assets/images/ic_product_food.png',
                        title: 'Food',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DigitalServicePage(
                                serviceType: 'food',
                                title: 'Voucher Kuliner (Food)',
                              ),
                            ),
                          );
                        },
                      ),
                      HomeServicesItem(
                        iconUrl: 'assets/images/ic_product_movie.png',
                        title: 'Movie',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DigitalServicePage(
                                serviceType: 'movie',
                                title: 'Tiket Bioskop (Movie)',
                              ),
                            ),
                          );
                        },
                      ),
                      HomeServicesItem(
                        iconUrl: 'assets/images/ic_product_stream.png',
                        title: 'Stream',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DigitalServicePage(
                                serviceType: 'stream',
                                title: 'Voucher Streaming',
                              ),
                            ),
                          );
                        },
                      ),
                      HomeServicesItem(
                        iconUrl: 'assets/images/ic_product_travel.png',
                        title: 'Travel',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DigitalServicePage(
                                serviceType: 'travel',
                                title: 'Tiket & Transportasi',
                              ),
                            ),
                          );
                        },
                      ),
                      HomeServicesItem(
                        iconUrl: 'assets/images/ic_product_water.png',
                        title: 'Water',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DigitalServicePage(
                                serviceType: 'water',
                                title: 'Tagihan Air PDAM',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
