import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payme/blocs/auth/auth_bloc.dart';
import 'package:payme/shared/theme.dart';
import 'package:payme/ui/widgets/buttons.dart';
import 'package:payme/ui/widgets/profile_menu_item.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthSuccess ? authState.user : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        children: [
          const SizedBox(
            height: 40,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 22,
            ),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF1F3F6),
                      ),
                      child: ClipOval(
                        child: user?.profilePicture != null &&
                                user!.profilePicture!.isNotEmpty &&
                                user.profilePicture!.startsWith('http')
                            ? Image.network(
                                user.profilePicture!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                  'assets/images/img_profile.png',
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                'assets/images/img_profile.png',
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    if (user?.isVerified == true)
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: whiteColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.check_circle,
                            color: greenColor,
                            size: 24,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  user?.name ?? 'User',
                  style: blackTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: semiBold,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  '@${user?.username ?? "user"}',
                  style: greyTextStyle.copyWith(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                ProfileMenuItem(
                  iconUrl: 'assets/images/ic_edit_profile.png',
                  title: 'Edit Profile',
                  onTap: () async {
                    if (await Navigator.pushNamed(context, '/pin') == true) {
                      if (context.mounted) {
                        Navigator.pushNamed(context, '/profile-edit');
                      }
                    }
                  },
                ),
                ProfileMenuItem(
                  iconUrl: 'assets/images/ic_pin.png',
                  title: 'My PIN',
                  onTap: () async {
                    if (await Navigator.pushNamed(context, '/pin') == true) {
                      if (context.mounted) {
                        Navigator.pushNamed(context, '/profile-edit-pin');
                      }
                    }
                  },
                ),
                ProfileMenuItem(
                  iconUrl: 'assets/images/ic_wallet_setting.png',
                  title: 'Wallet Settings',
                  onTap: () {
                    Navigator.pushNamed(context, '/wallet-settings');
                  },
                ),
                ProfileMenuItem(
                  iconUrl: 'assets/images/ic_my_reward.png',
                  title: 'My Rewards',
                  onTap: () {
                    Navigator.pushNamed(context, '/reward');
                  },
                ),
                ProfileMenuItem(
                  iconUrl: 'assets/images/ic_logout_user.png',
                  title: 'Log Out',
                  onTap: () {
                    context.read<AuthBloc>().add(AuthLogout());
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/sign-in',
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          CustomTextButton(
            title: 'Report a Problem',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: blueColor,
                  content: const Text(
                      'Pusat Bantuan Payme: Hubungi support@payme.id jika mengalami kendala.'),
                ),
              );
            },
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}
