// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:payme/shared/theme.dart';
import 'package:flutter/material.dart';

class PackageItem extends StatelessWidget {

  final int amount;
  final int price;
  final bool isSelected;


  const PackageItem({
    Key? key,
    required this.amount,
    required this.price,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
   return Container(
      width: 155,
      height: 171,
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? blueColor : whiteColor,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
          SizedBox(
            height: 13,
          ),
          Text(
            '${amount}GB',
            style: blackTextStyle.copyWith(
              fontSize: 16,
              fontWeight: medium,
            ),
          ),
          SizedBox(
            height: 2,
          ),
          Text(
            'Rp $price',
            style: greyTextStyle.copyWith(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
