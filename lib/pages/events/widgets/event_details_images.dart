import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class EventDetailsImages extends StatelessWidget {
  final bool isPreview;
  final bool rePublish;
  final WidgetRef ref;
  final List<File> imageFiles;
  final List<String> imageUrls;
  final int maxImages;
  final bool clone;
  const EventDetailsImages({
    super.key,
    required this.isPreview,
    required this.rePublish,
    required this.ref,
    required this.imageFiles,
    required this.imageUrls,
    required this.maxImages,
    required this.clone,
  });

  @override
  Widget build(BuildContext context) {
    return isPreview || rePublish ? buildPreviewOrRepublishImages() : buildDetailsImages();
  }

  Column buildDetailsImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrls.isNotEmpty)
          Text(
            "Photos",
            style: AppStyles.h5.copyWith(
              color: AppColors.lightGreyColor,
            ),
          ),
        if (imageUrls.isNotEmpty) const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: StaggeredGrid.count(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: List.generate(
              imageUrls.length,
              (index) => StaggeredGridTile.count(
                crossAxisCellCount: index % (maxImages - 1) == 0 ? 2 : 1,
                mainAxisCellCount: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrls[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Column buildPreviewOrRepublishImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageFiles.isNotEmpty || imageUrls.isNotEmpty)
          Text(
            "Photos",
            style: AppStyles.h5.copyWith(
              color: AppColors.lightGreyColor,
            ),
          ),
        if (imageFiles.isNotEmpty || imageUrls.isNotEmpty) const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: StaggeredGrid.count(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: List.generate(
              imageUrls.length + imageFiles.length,
              (index) => StaggeredGridTile.count(
                crossAxisCellCount: index % (maxImages - 1) == 0
                    ? 2
                    : 1, // change this maxImages in newEventProvider
                mainAxisCellCount: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: index < imageUrls.length
                      ? CachedNetworkImage(
                          imageUrl: imageUrls[index],
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          imageFiles[index - imageUrls.length],
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
