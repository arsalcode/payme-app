import 'package:payme/ui/widgets/buttons.dart';
import 'package:flutter/material.dart';

import 'package:payme/shared/theme.dart';
import 'package:payme/ui/widgets/profile_menu_item.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: 24,
        ),
        children: [
          SizedBox(
            height: 40,
          ),
          Container(
            padding: EdgeInsets.symmetric(
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
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/img_profile.png'),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: 28,
                        height: 24,
                        decoration: BoxDecoration(
                          color: whiteColor,
                          // color: blackColor,
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
                    ),
                  ),
                ),
                const SizedBox(
                  height: 18,
                ),
          
                SizedBox(
                  height: 40,
                ),
                ProfileMenuItem(
                  iconUrl: 'assets/images/ic_edit_profile.png',
                  title: 'Edit Profile',
                  onTap: ()async {
                    if(await Navigator.pushNamed(context, '/pin') == true){
                      Navigator.pushNamed(context, '/profile-edit');
                    }
                  },
                ),

                ProfileMenuItem(
                  iconUrl: 'assets/images/ic_edit_profile.png',
                  title: 'MY PIN',
                   onTap: ()async {
                    if(await Navigator.pushNamed(context, '/pin') == true){
                      Navigator.pushNamed(context, '/profile-edit-pin');
                    }
                  },
                ),

                ProfileMenuItem(
                  iconUrl: 'assets/images/ic_edit_profile.png',
                  title: 'Wallet Setting',
                     onTap: () {
                    // Navigator.pushNamed(context, '/pin');
                    // if( Navigator.pushNamed(context, '/pin') == true){
                    //   Navigator.pushNamed(context, 'profile-edit-pin');
                    // }
                  },
                ),

                ProfileMenuItem(
                  iconUrl: 'assets/images/ic_edit_profile.png',
                  title: 'My Rewards',
                    onTap: () {
                    // Navigator.pushNamed(context, '/pin');
                    // if( Navigator.pushNamed(context, '/pin') == true){
                    //   Navigator.pushNamed(context, 'profile-edit-pin');
                    // }
                  },
                ),

                ProfileMenuItem(
                  iconUrl: 'assets/images/ic_edit_profile.png',
                  title: 'Help Center',
                    onTap: () {
                    // Navigator.pushNamed(context, '/pin');
                    // if( Navigator.pushNamed(context, '/pin') == true){
                    //   Navigator.pushNamed(context, 'profile-edit-pin');
                    // }
                  },
                ),

                ProfileMenuItem(
                  iconUrl: 'assets/images/ic_edit_profile.png',
                  title: 'Log Out',
                     onTap: () {
                    // Navigator.pushNamed(context, '/pin');
                    // if( Navigator.pushNamed(context, '/pin') == true){
                    //   Navigator.pushNamed(context, 'profile-edit-pin');
                    // }
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 87,
          ),
          CustomTextButton(
            title: 'Report a Problem',
            onPressed: () {},
          ),
          SizedBox(
            height: 87,
          ),
        ],
      ),
    );
  }
}
