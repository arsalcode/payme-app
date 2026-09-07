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
                Container(
                  width: 120,
                  height: 120,
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
                            width: 28,
                            height: 24,
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
                      Navigator.pushNamed(context, '/profile-edit');
                    }
                  },
                ),
                ProfileMenuItem(
                  iconUrl: 'assets/images/ic_edit_profile.png',
                  title: 'My PIN',
                  onTap: () async {
                    if (await Navigator.pushNamed(context, '/pin') == true) {
                      Navigator.pushNamed(context, '/profile-edit-pin');
                    }
                  },
                ),
                ProfileMenuItem(
                  iconUrl: 'assets/images/ic_edit_profile.png',
                  title: 'Wallet Settings',
                  onTap: () {},
                ),
                ProfileMenuItem(
                  iconUrl: 'assets/images/ic_edit_profile.png',
                  title: 'My Rewards',
                  onTap: () {},
                ),
                ProfileMenuItem(
                  iconUrl: 'assets/images/ic_edit_profile.png',
                  title: 'Admin Back-Office',
                  onTap: () {
                    Navigator.pushNamed(context, '/admin');
                  },
                ),
                ProfileMenuItem(
                  iconUrl: 'assets/images/ic_edit_profile.png',
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
            height: 40,
          ),
          CustomTextButton(
            title: 'Report a Problem',
            onPressed: () {},
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}
