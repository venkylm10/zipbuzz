import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/models/host_model.dart';

class EventHosts extends StatelessWidget {
  const EventHosts({
    super.key,
    required this.hosts,
  });

  final List<Host> hosts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            if (hosts.first.imagePath == null)
              SvgPicture.asset(
                Assets.icons.person,
                height: 28,
              ),
            const SizedBox(width: 8),
            Text(
              hosts.first.name,
              style: AppStyles.h5,
            ),
            const Expanded(child: SizedBox()),
            Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  "Message",
                  style: AppStyles.h4.copyWith(color: AppColors.primaryColor),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (hosts.first.imagePath == null)
              SvgPicture.asset(
                Assets.icons.person,
                height: 28,
              ),
            const SizedBox(width: 8),
            Text(
              hosts.first.name,
              style: AppStyles.h5,
            ),
            const Expanded(child: SizedBox()),
            Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  "Message",
                  style: AppStyles.h4.copyWith(color: AppColors.primaryColor),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}