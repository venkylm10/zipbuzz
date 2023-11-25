import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';

class EventsTab extends StatelessWidget {
  const EventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          "Events",
          style: AppStyles.h2.copyWith(color: Colors.white),
        ),
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: SvgPicture.asset(
            Assets.icons.events,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        titleSpacing: 0,
        centerTitle: false,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
      ),
      body: Center(
        child: Text(
          "Events Tab",
          style: AppStyles.h2,
        ),
      ),
    );
  }
}
