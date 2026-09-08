// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:payme/shared/theme.dart';
import 'package:flutter/material.dart';

class ProfileMenuItem extends StatelessWidget {
  final String? iconUrl;
  final IconData? iconData;
  final String title;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    super.key,
    this.iconUrl,
    this.iconData,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 26),
        child: Row(
          children: [
            if (iconUrl != null)
              Image.asset(
                iconUrl!,
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.circle,
                  size: 20,
                  color: blueColor,
                ),
              )
            else if (iconData != null)
              Icon(
                iconData,
                size: 24,
                color: blackColor,
              ),
            const SizedBox(
              width: 18,
            ),
            Expanded(
              child: Text(
                title,
                style: blackTextStyle.copyWith(
                  fontWeight: medium,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: Color(0xffA4A8AE),
            ),
          ],
        ),
      ),
    );
  }
}
