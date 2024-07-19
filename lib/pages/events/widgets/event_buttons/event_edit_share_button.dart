import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class EventEditShareButton extends ConsumerWidget {
  final EventModel event;
  const EventEditShareButton({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        ref.read(eventsControllerProvider.notifier).shareEvent(event);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgGrey,
          border: Border.all(color: AppColors.borderGrey),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                Assets.icons.send_fill,
                height: 24,
                colorFilter: ColorFilter.mode(
                  Colors.grey.shade800,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Share",
                style: AppStyles.h3.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
