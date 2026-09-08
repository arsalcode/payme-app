// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:payme/shared/theme.dart';
import 'package:flutter/material.dart';

class TransferResultUserItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String username;
  final bool isVerified;
  final bool isSelected;

  const TransferResultUserItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.username,
    this.isVerified = false,
    this.isSelected = false,
  });

  // Alias getter for backwards compatibility
  String get Username => username;

  @override
  Widget build(BuildContext context) {
    final isNetwork = imageUrl.startsWith('http');

    return Container(
      width: 155,
      height: 175,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(20),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: isNetwork
                    ? NetworkImage(imageUrl) as ImageProvider
                    : AssetImage(imageUrl),
              ),
            ),
            child: isVerified
                ? Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: whiteColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check_circle,
                          color: greenColor,
                          size: 18,
                        ),
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: blackTextStyle.copyWith(
              fontSize: 15,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            '@$username',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: greyTextStyle.copyWith(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
