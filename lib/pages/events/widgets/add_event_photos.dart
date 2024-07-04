import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/services/image_picker.dart';

class AddEventPhotos extends ConsumerStatefulWidget {
  const AddEventPhotos({super.key});

  @override
  ConsumerState<AddEventPhotos> createState() => _AddEventPhotosState();
}

class _AddEventPhotosState extends ConsumerState<AddEventPhotos> {
  List<File> selectedImages = [];
  var imageUrls = <String>[];

  @override
  void initState() {
    super.initState();
    selectedImages.clear();
    ref.read(newEventProvider.notifier).selectedImages.clear();
    setState(() {});
  }

  void removeFileImage({required File image}) {
    ref.read(newEventProvider.notifier).selectedImages.remove(image);
    setState(() {});
  }

  void removeNetworkImage({required String url}) {
    imageUrls.remove(url);
    ref.read(newEventProvider).imageUrls.remove(url);
    setState(() {});
  }

  void addImages() async {
    File? image;
    var pickedImages = await ref.read(imageServicesProvider).pickMultipleImages();
    if (pickedImages.isNotEmpty) {
      pickedImages.map((pickedImage) {
        image = File(pickedImage!.path);
        ref.read(newEventProvider.notifier).selectedImages.add(image!);
      }).toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    selectedImages = ref.watch(newEventProvider.notifier).selectedImages;
    imageUrls = ref.watch(newEventProvider).imageUrls;
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
        if (selectedImages.isEmpty && imageUrls.isEmpty) const SizedBox(height: 16),
        if (selectedImages.isEmpty && imageUrls.isEmpty)
          InkWell(
            onTap: () {
              addImages();
            },
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
              imageUrls.length + selectedImages.length,
              (index) => StaggeredGridTile.count(
                crossAxisCellCount: index % 6 == 0 ? 2 : 1,
                mainAxisCellCount: 1,
                child: index < imageUrls.length
                    ? buildNetworkImage(imageUrls[index])
                    : buildFileImage(
                        selectedImages[index - imageUrls.length],
                      ),
              ),
            ),
          ),
        ),
        if (selectedImages.isNotEmpty || imageUrls.isNotEmpty) const SizedBox(height: 16),
        if (selectedImages.isNotEmpty || imageUrls.isNotEmpty)
          InkWell(
            onTap: () {
              addImages();
            },
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

  Widget buildNetworkImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              url,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: InkWell(
              onTap: () => removeNetworkImage(url: url),
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
                        child: const SizedBox(height: 36, width: 36),
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
    );
  }

  ClipRRect buildFileImage(File image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.file(
              image,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: InkWell(
              onTap: () => removeFileImage(image: image),
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
                        child: const SizedBox(height: 36, width: 36),
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
    );
  }
}
