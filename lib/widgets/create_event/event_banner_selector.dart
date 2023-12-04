import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/controllers/new_event_controller.dart';
import 'package:zipbuzz/services/image_picker.dart';

class EventBannerSelector extends ConsumerStatefulWidget {
  const EventBannerSelector({
    super.key,
  });

  @override
  ConsumerState<EventBannerSelector> createState() =>
      _EventBannerSelectorState();
}

class _EventBannerSelectorState extends ConsumerState<EventBannerSelector> {
  File? image;

  void pickImage() async {
    final pickedImage = await ImageServices().pickImage();
    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
        ref.read(newEventProvider.notifier).updateBannerImage(image!);
      });
    }
  }

  @override
  void initState() {
    ref.read(newEventProvider.notifier).bannerImage = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => pickImage(),
      child: image == null
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
                  Divider(
                      color: AppColors.greyColor.withOpacity(0.2), height: 1),
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
          : SizedBox(
              height: 200,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.file(
                        image!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: SvgPicture.asset(
                        Assets.icons.gallery_add,
                        height: 40,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
