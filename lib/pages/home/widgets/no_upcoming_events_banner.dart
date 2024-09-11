import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class NoUpcomingEventsBanner extends ConsumerWidget {
  final String title;
  final String subtitle;
  final Function(WidgetRef) onTap;
  final String buttonLabel;
  const NoUpcomingEventsBanner({
    super.key,
    this.title = "No events lined up",
    this.subtitle = "Your registered events will show up here",
    required this.onTap,
    this.buttonLabel = "Create Event",
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Image.asset(Assets.images.no_events_image),
        Positioned(
          left: 0,
          right: 0,
          top: 220,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    title,
                    style: AppStyles.h3.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: AppStyles.h4.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => onTap(ref),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xffFF9635),
                            const Color(0xffFF0099).withOpacity(0.65),
                          ],
                        ),
                      ),
                      child: Text(
                        buttonLabel,
                        style: AppStyles.h4.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
