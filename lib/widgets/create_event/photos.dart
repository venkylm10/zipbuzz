import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/controllers/new_event_controller.dart';
import 'package:zipbuzz/services/image_picker.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

class AddEventPhotos extends ConsumerStatefulWidget {
  const AddEventPhotos({super.key});

  @override
  ConsumerState<AddEventPhotos> createState() => _AddEventPhotosState();
}

class _AddEventPhotosState extends ConsumerState<AddEventPhotos> {
  List<File> selectedImages = [];
  int maxImages = 0;

  @override
  void initState() {
    maxImages = ref.read(newEventProvider.notifier).maxImages;
    selectedImages.clear();
    ref.read(newEventProvider.notifier).selectedImages.clear();
    super.initState();
  }

  void removeImage({required File image}) {
    ref.read(newEventProvider.notifier).selectedImages.remove(image);
    setState(() {});
  }

  void addImages() async {
    if (selectedImages.length >= maxImages) {
      showSnackBar(message: "You can only add $maxImages images");
      return;
    }
    File? image;
    var pickedImages =
        await ref.read(imageServicesProvider).pickMultipleImages();
    if (pickedImages.isNotEmpty) {
      pickedImages.map((pickedImage) {
        if (selectedImages.length >= maxImages) {
          showSnackBar(message: "You can only add $maxImages images");
          setState(() {});
          return;
        }
        image = File(pickedImage!.path);
        ref.read(newEventProvider.notifier).selectedImages.add(image!);
      }).toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    selectedImages = ref.watch(newEventProvider.notifier).selectedImages;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Photos",
          style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
        ),
        const SizedBox(height: 16),
        Text(
          "You can add event photos to show user whats in store for them.",
          style: AppStyles.h4,
        ),
        if (selectedImages.isEmpty) const SizedBox(height: 16),
        if (selectedImages.isEmpty)
          GestureDetector(
            onTap: addImages,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(Assets.icons.add_circle),
                  const SizedBox(width: 8),
                  Text(
                    "Add",
                    style: AppStyles.h4.copyWith(
                      color: AppColors.greyColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: StaggeredGrid.count(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: List.generate(
              selectedImages.length,
              (index) => StaggeredGridTile.count(
                crossAxisCellCount: index % 6 == 0 ? 2 : 1,
                mainAxisCellCount: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.file(
                          selectedImages[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () =>
                              removeImage(image: selectedImages[index]),
                          child: SizedBox(
                            height: 36,
                            width: 36,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 4,
                                      sigmaY: 4,
                                    ),
                                    child:
                                        const SizedBox(height: 36, width: 36),
                                  ),
                                ),
                                SvgPicture.asset(
                                  Assets.icons.delete_fill,
                                  height: 36,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (selectedImages.isNotEmpty) const SizedBox(height: 16),
        if (selectedImages.isNotEmpty)
          GestureDetector(
            onTap: addImages,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(Assets.icons.add_circle),
                  const SizedBox(width: 8),
                  Text(
                    "Add more",
                    style: AppStyles.h4.copyWith(
                      color: AppColors.greyColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
