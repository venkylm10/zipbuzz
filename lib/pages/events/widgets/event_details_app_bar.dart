import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';

class EventDetailsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EventDetailsAppBar(
      {super.key, required this.isPreview, required this.rePublish, required this.pickImage});
  final bool isPreview;
  final bool rePublish;
  final VoidCallback pickImage;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      shadowColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      leadingWidth: 0,
      leading: const SizedBox(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: InkWell(
            onTap: () => navigatorKey.currentState!.pop(),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Expanded(child: SizedBox()),
        if (isPreview || rePublish)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: pickImage,
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: const Center(
                      child: Icon(
                        Icons.edit,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);
}
