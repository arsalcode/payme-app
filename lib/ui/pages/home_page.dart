import 'package:flutter/material.dart';
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  get iconUrl => null;

  @override
  Widget build(BuildContext context) {
    // return const Placeholder();
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: whiteColor,
        shape: const CircularNotchedRectangle(),
        clipBehavior: Clip.antiAlias,
        notchMargin: 6,
        elevation: 0,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: whiteColor,
          elevation: 0,
          selectedItemColor: blueColor,
          unselectedItemColor: blackColor,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: blueTextStyle.copyWith(
            fontSize: 10,
            fontWeight: medium,
          ),
          unselectedLabelStyle:
              blackTextStyle.copyWith(fontSize: 10, fontWeight: medium),
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/ic_overiview.png',
                width: 20,
                color: blueColor,
              ),
              label: 'OverView',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/ic_history.png',
                width: 20,
              ),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/ic_statistic.png',
                width: 20,
              ),
              label: 'Statistic',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/ic_reward.png',
                width: 20,
              ),
              label: 'Reward',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            children: [
              buildProfile(context, user),
              buildWalentCart(user),
              buildLevel(),
              buildServices(context),
              buildLatesTransction(),
              buildSendAgain(),
              buildFrienLyTips(),
            ],
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
    final cardNumber = user?.cardNumber ?? '1280';
    final maskedCard = cardNumber.length >= 4
        ? '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}'
        : '**** **** **** 1280';

    final balanceFormatted = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(user?.balance ?? 100000);

    return Container(
      width: double.infinity,
      height: 220,
      margin: const EdgeInsets.only(
        top: 38,
      ),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: const DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/images/img_bg_card.png'),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user?.name ?? 'User',
            style: whiteTextStyle.copyWith(
              fontSize: 18,
              fontWeight: medium,
            ),
          ),
          const SizedBox(
            height: 28,
          ),
          Text(
            maskedCard,
            style: whiteTextStyle.copyWith(
              fontSize: 18,
              fontWeight: medium,
              letterSpacing: 5,
            ),
          ),
          const SizedBox(
            height: 21,
          ),
          Text(
            'Balance',
            style: whiteTextStyle,
          ),
          Text(
            balanceFormatted,
            style: whiteTextStyle.copyWith(
              fontSize: 24,
              fontWeight: semiBold,
            ),
          ),
        ],
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
                onTap: () {},
              ),
              HomeServicesItem(
                iconUrl: 'assets/images/ic_more.png',
                title: 'More',
                onTap: () {
                  showDialog(
                      context: context, builder: (context) => MoreDialog());
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

  buildSendAgain() {
    return Container(
      margin: EdgeInsets.only(
        top: 30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Send Again',
            style: blackTextStyle.copyWith(
              fontWeight: semiBold,
              fontSize: 16,
            ),
          ),
          SizedBox(
            height: 14,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                HomeUserItem(
                  imageUrl: 'assets/images/img_frend1.png',
                  username: 'yuwanit',
                ),
                HomeUserItem(
                  imageUrl: 'assets/images/img_frend2.png',
                  username: 'jani',
                ),
                HomeUserItem(
                  imageUrl: 'assets/images/img_frend3.png',
                  username: 'urip',
                ),
                HomeUserItem(
                  imageUrl: 'assets/images/logo_unpak.png',
                  username: 'masssa',
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
      margin: EdgeInsets.only(
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
          SizedBox(
            height: 14,
          ),
          Wrap(
            spacing: 17,
            runSpacing: 10,
            children: [
              HomeTipsItem(
                imageUrl: 'assets/images/img_tips1.png',
                title: 'Best tips for using\n a credit card',
                url:
                    'https://buildwithangga.com/tips/belajar-entity-relationship-diagram-studi-kasus-platform-media-sosial',
              ),
              HomeTipsItem(
                imageUrl: 'assets/images/img_tips2.png',
                title: 'Spot the good pie\n of finance modeld',
                url: 'https://www.gooogle.com',
              ),
              HomeTipsItem(
                imageUrl: 'assets/images/img_tips3.png',
                title: 'Great hack to get\n better advices',
                url: 'https://www.gooogle.com',
              ),
              HomeTipsItem(
                imageUrl: 'assets/images/img_tips4.png',
                title: 'Save more penny\n buy this instead ',
                url: 'https://www.gooogle.com',
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
      alignment: Alignment.bottomCenter,
      content: Container(
        height: 326,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: lightkBackgroundColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Do More With Us',
              style: blackTextStyle.copyWith(
                fontSize: 16,
                fontWeight: semiBold,
              ),
            ),
            const SizedBox(
              height: 13,
            ),
            Wrap(
              runSpacing: 25,
              spacing: 29,
              children: [
                HomeServicesItem(
                  iconUrl: 'assets/images/ic_product_data.png',
                  title: 'Data',
                  onTap: () {
                    Navigator.pushNamed(context, '/data-provider');                  },
                ),
                HomeServicesItem(
                  iconUrl: 'assets/images/ic_product_food.png',
                  title: 'Food',
                  onTap: () {},
                ),
                HomeServicesItem(
                  iconUrl: 'assets/images/ic_product_movie.png',
                  title: 'Movie',
                  onTap: () {},
                ),
                 HomeServicesItem(
                  iconUrl: 'assets/images/ic_product_stream.png',
                  title: 'Stream',
                  onTap: () {},
                ),
                 HomeServicesItem(
                  iconUrl: 'assets/images/ic_product_travel.png',
                  title: 'Travel',
                  onTap: () {},
                ),
                 HomeServicesItem(
                  iconUrl: 'assets/images/ic_product_water.png',
                  title: 'Water',
                  onTap: () {},
                ),
               
              ],
            ),
          ],
        ),
      ),
    );
  }
}
