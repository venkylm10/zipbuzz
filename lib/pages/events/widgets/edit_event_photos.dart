import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/services/image_picker.dart';

class EditEventPhotos extends ConsumerStatefulWidget {
  const EditEventPhotos({super.key});

  @override
  ConsumerState<EditEventPhotos> createState() => _EditEventPhotosState();
}

class _EditEventPhotosState extends ConsumerState<EditEventPhotos> {
  int maxImages = 0;

  @override
  void initState() {
    maxImages = ref.read(editEventControllerProvider.notifier).maxImages;
    ref.read(editEventControllerProvider.notifier).selectedImages.clear();
    super.initState();
  }

  void removeFileImage({required File image}) {
    ref.read(editEventControllerProvider.notifier).selectedImages.remove(image);
    setState(() {});
  }

  void removeImageUrl({required String imageUrl}) {
    ref.read(editEventControllerProvider.notifier).removeEventImageUrl(imageUrl);
    setState(() {});
  }

  void addImages() async {
    File? image;
    var pickedImages = await ref.read(imageServicesProvider).pickMultipleImages();
    if (pickedImages.isNotEmpty) {
      pickedImages.map((pickedImage) {
        image = File(pickedImage.path);
        ref.read(editEventControllerProvider.notifier).selectedImages.add(image!);
      }).toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final selectedImages = ref.watch(editEventControllerProvider.notifier).selectedImages;
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
        Consumer(builder: (context, ref, child) {
          final urls = ref.watch(editEventControllerProvider).imageUrls;
          if (urls.isEmpty && selectedImages.isEmpty) {
            return InkWell(
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
            );
          }
          return const SizedBox();
        }),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Consumer(builder: (context, ref, child) {
            final urls = ref.watch(editEventControllerProvider).imageUrls;
            return StaggeredGrid.count(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: List.generate(
                urls.length + selectedImages.length,
                (index) => StaggeredGridTile.count(
                  crossAxisCellCount: index % 6 == 0 ? 2 : 1,
                  mainAxisCellCount: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: index < urls.length
                              ? CachedNetworkImage(
                                  imageUrl: urls[index],
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  selectedImages[index - urls.length],
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: InkWell(
                            onTap: () {
                              if (index < urls.length) {
                                removeImageUrl(imageUrl: urls[index]);
                              } else {
                                removeFileImage(image: selectedImages[index - urls.length]);
                              }
                            },
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
                  ),
                ),
              ),
            );
          }),
        ),
        Consumer(builder: (context, ref, child) {
          final urls = ref.watch(editEventControllerProvider).imageUrls;
          if (urls.isEmpty) {
            return const SizedBox();
          }
          return Column(
            children: [
              const SizedBox(height: 16),
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
        })
      ],
    );
  }
}
