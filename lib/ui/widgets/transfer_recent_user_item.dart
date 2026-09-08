import 'package:payme/shared/theme.dart';
import 'package:flutter/material.dart';

class TransferRecentUserItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String username;
  final bool isVerified;
  final bool isSelected;
  final VoidCallback? onTap;

  const TransferRecentUserItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.username,
    required this.isVerified,
    this.isSelected = false,
    this.onTap,
  });

  // Alias getter for backwards compatibility
  String get Username => username;

  @override
  Widget build(BuildContext context) {
    final isNetwork = imageUrl.startsWith('http');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 18,
        ),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: whiteColor,
          border: Border.all(
            width: 2,
            color: isSelected ? blueColor : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.only(
                right: 14,
              ),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: blackTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: medium,
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    '@$username',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: greyTextStyle.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isVerified)
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: greenColor,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    'Verified',
                    style: greenTextStyle.copyWith(
                      fontSize: 12,
                      fontWeight: medium,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
