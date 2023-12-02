import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/controllers/home_tab_controller.dart';

class MapTab extends ConsumerWidget {
  const MapTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvoked: (value) =>
          ref.read(homeTabControllerProvider.notifier).backToHomeTab(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: Text(
            "Map",
            style: AppStyles.h2.copyWith(color: Colors.white),
          ),
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: SvgPicture.asset(
              Assets.icons.map,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
          titleSpacing: 0,
          centerTitle: false,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
        ),
        body: Center(
          child: Text(
            "Map tab",
            style: AppStyles.h2,
          ),
        ),
      ),
    );
  }
}
