import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/services/image_picker.dart';

class EditEventBannerSelector extends ConsumerStatefulWidget {
  const EditEventBannerSelector({
    super.key,
  });

  @override
  ConsumerState<EditEventBannerSelector> createState() => _EventBannerSelectorState();
}

class _EventBannerSelectorState extends ConsumerState<EditEventBannerSelector> {
  File? image;

  void pickImage() async {
    final pickedImage = await ImageServices().pickImage();
    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
        ref.read(editEventControllerProvider.notifier).updateBannerImage(image!);
      });
    }
  }

  @override
  void initState() {
    ref.read(editEventControllerProvider.notifier).bannerImage = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => pickImage(),
      child: image == null
          ? SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        ref.read(editEventControllerProvider).bannerPath,
                        fit: BoxFit.cover,
                      ),
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
