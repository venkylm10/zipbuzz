import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';

class EventBannerSelector extends StatelessWidget {
  const EventBannerSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.borderGrey,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Column(
            children: [
              SvgPicture.asset(
                Assets.icons.gallery,
                height: 32,
              ),
              const SizedBox(height: 8),
              Text(
                "Tap to add image from gallery",
                style: AppStyles.h5.copyWith(
                  color: Colors.grey.shade500,
                ),
              )
            ],
          ),
          const SizedBox(height: 40),
          Divider(color: AppColors.greyColor.withOpacity(0.2), height: 1),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "Choose from template",
              style: AppStyles.h5.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}