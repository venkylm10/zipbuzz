import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';

class EventBannerSelector extends StatefulWidget {
  const EventBannerSelector({
    super.key,
  });

  @override
  State<EventBannerSelector> createState() => _EventBannerSelectorState();
}

class _EventBannerSelectorState extends State<EventBannerSelector> {
  final File? image = null;
  @override
  Widget build(BuildContext context) {
    return image == null
        ? Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.borderGrey,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
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
                ),
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
          )
        : Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.borderGrey,
            ),
            
          );
  }
}
