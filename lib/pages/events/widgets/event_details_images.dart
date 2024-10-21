import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/pages/events/event_upload_new_images.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/image_picker.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class EventDetailsImages extends StatelessWidget {
  final bool isPreview;
  final bool rePublish;
  final WidgetRef ref;
  final List<File> imageFiles;
  final List<String> imageUrls;
  final int maxImages;
  final bool clone;
  final String status;
  final int eventId;
  final Function(EventModel) updateEvent;
  const EventDetailsImages({
    super.key,
    required this.isPreview,
    required this.rePublish,
    required this.ref,
    required this.imageFiles,
    required this.imageUrls,
    required this.maxImages,
    required this.clone,
    required this.status,
    required this.eventId,
    required this.updateEvent,
  });

  @override
  Widget build(BuildContext context) {
    return isPreview || rePublish ? buildPreviewOrRepublishImages() : buildDetailsImages(context);
  }

  Column buildDetailsImages(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrls.isNotEmpty || status == 'confirmed' || status == 'hosted')
          Text(
            "Photos",
            style: AppStyles.h5.copyWith(
              color: AppColors.lightGreyColor,
            ),
          ),
        if (imageUrls.isNotEmpty || status == 'confirmed' || status == 'hosted')
          const SizedBox(height: 16),
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
        if (status == 'confirmed' || status == 'hosted')
          InkWell(
            onTap: () async {
              final images = await ref.read(imageServicesProvider).pickMultipleImages();
              if (images.isEmpty) return;
              bool? res = await Navigator.of(navigatorKey.currentContext!).push(MaterialPageRoute(
                  builder: (_) => EventUploadNewImages(eventId: eventId, images: images)));
              if (res == true) {
                final event = await ref.read(dbServicesProvider).getEventDetails(eventId);
                updateEvent(event);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(top: 8),
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
          )
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
