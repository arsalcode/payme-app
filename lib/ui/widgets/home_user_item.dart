// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:payme/shared/theme.dart';
import 'package:flutter/material.dart';

class HomeUserItem extends StatelessWidget {
  final String imageUrl;
  final String username;
  final VoidCallback? onTap;

  const HomeUserItem({
    super.key,
    required this.imageUrl,
    required this.username,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isNetwork = imageUrl.startsWith('http');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 95,
        height: 125,
        margin: const EdgeInsets.only(right: 17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: whiteColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: isNetwork
                      ? NetworkImage(imageUrl) as ImageProvider
                      : AssetImage(imageUrl),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '@$username',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: blackTextStyle.copyWith(
                  fontSize: 13,
                  fontWeight: semiBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
