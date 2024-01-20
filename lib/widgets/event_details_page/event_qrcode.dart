import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/services/deep_link_services.dart';
import 'package:zipbuzz/services/qr_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class EventQRCode extends StatelessWidget {
  final EventModel event;
  const EventQRCode({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context,ref,child) {
        return GestureDetector(
          onTap: () async {
            final uri = await ref.read(deepLinkServicesProvider).generateEventDynamicLink(event.id.toString());
            QrServices.shareEventQrCode(uri.toString(), event);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 1,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  Assets.icons.qr,
                  height: 20,
                ),
                const SizedBox(width: 5),
                Text(
                  "Invite",
                  style: AppStyles.h5.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
