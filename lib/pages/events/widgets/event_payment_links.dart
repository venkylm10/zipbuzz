import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/utils/constants/assets.dart';

class EventPaymentLinks extends StatelessWidget {
  final EventModel event;
  const EventPaymentLinks({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final paypal = event.paypalLink != 'zipbuzz-null';
    final venmo = event.venmoLink != 'zipbuzz-null';
    return Row(
      children: [
        if (paypal)
          Expanded(
            child: GestureDetector(
              onTap: () async {
                if (await canLaunchUrlString(event.paypalLink)) {
                  launchUrlString(event.paypalLink);
                }
              },
              child: Container(
                height: 42,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.yellow[600],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SvgPicture.asset(Assets.icons.paypal),
              ),
            ),
          ),
        if (paypal && venmo) const SizedBox(width: 16),
        if (venmo)
          Expanded(
            child: GestureDetector(
              onTap: () async {
                if (await canLaunchUrlString(event.venmoLink)) {
                  launchUrlString(event.venmoLink);
                }
              },
              child: Container(
                height: 42,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xff3d95ce),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SvgPicture.asset(
                  Assets.icons.venmo,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
