import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';

class AddEventPhotos extends StatefulWidget {
  const AddEventPhotos({super.key});

  @override
  State<AddEventPhotos> createState() => _AddEventPhotosState();
}

class _AddEventPhotosState extends State<AddEventPhotos> {
  var defaultImagePaths = <String>[];

  @override
  void initState() {
    defaultImagePaths = [
      "assets/images/about/Image-0.png",
      "assets/images/about/Image-1.png",
      "assets/images/about/Image-2.png",
      "assets/images/about/Image-3.png",
      "assets/images/about/Image-4.png",
      "assets/images/about/Image-5.png",
      "assets/images/about/Image-6.png",
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 16),
        Container(
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
              defaultImagePaths.length,
              (index) => StaggeredGridTile.count(
                crossAxisCellCount: index % 6 == 0 ? 2 : 1,
                mainAxisCellCount: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          defaultImagePaths[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          height: 36,
                          width: 36,
                          child: Stack(
                            children: [
                              ClipRRect(
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
      ],
    );
  }
}
