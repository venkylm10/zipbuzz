import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/utils/constants/assets.dart';

class EventDetailsBanner extends ConsumerWidget {
  const EventDetailsBanner(
      {super.key, required this.event, required this.isPreview, required this.dominantColor});
  final EventModel event;
  final bool isPreview;
  final Color dominantColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return isPreview ? buildPreviewBanner(context, ref) : buildNewBanner(context, ref);
  }

  Widget buildPreviewBanner(BuildContext context, WidgetRef ref) {
    final previewBanner = ref.read(newEventProvider.notifier).bannerImage;
    if (previewBanner != null) {
      return SizedBox(
        height: 300,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.file(
                previewBanner,
                fit: BoxFit.cover,
              ),
            ),
            buildBannerGradient(context),
          ],
        ),
      );
    }

    return SizedBox(
      height: 300,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              interestBanners[event.category]!,
              fit: BoxFit.cover,
            ),
          ),
          buildBannerGradient(context),
        ],
      ),
    );
  }

  Widget buildNewBanner(BuildContext context, WidgetRef ref) {
    final newBanner = ref.read(editEventControllerProvider.notifier).bannerImage;
    if (newBanner == null) {
      return SizedBox(
        height: 300,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                event.bannerPath,
                fit: BoxFit.cover,
              ),
            ),
            buildBannerGradient(context),
          ],
        ),
      );
    } else {
      return SizedBox(
        height: 300,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.file(
                newBanner,
                fit: BoxFit.cover,
              ),
            ),
            buildBannerGradient(context),
          ],
        ),
      );
    }
  }

  Positioned buildBannerGradient(BuildContext context) {
    return Positioned(
      bottom: -10,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 300,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, dominantColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.2, 1],
          ),
        ),
      ),
    );
  }
}
