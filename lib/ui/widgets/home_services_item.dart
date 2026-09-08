// ignore_for_file: public_member_api_docs, sort_constructors_first/
import 'package:payme/shared/theme.dart';
import 'package:flutter/material.dart';

class HomeServicesItem extends StatelessWidget {
  final String iconUrl;
  final String title;
  final VoidCallback? onTap;

  const HomeServicesItem({
    super.key,
    required this.iconUrl,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            margin: const EdgeInsets.only(
              bottom: 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: whiteColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                iconUrl,
                width: 26,
                height: 26,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.apps_rounded,
                  size: 26,
                  color: blueColor,
                ),
              ),
            ),
          ),
          Text(
            title,
            style: blackTextStyle.copyWith(
              fontSize: 14,
              fontWeight: medium,
            ),
          ),
        ],
      ),
    );
  }
}
