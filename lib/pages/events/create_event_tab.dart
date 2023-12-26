import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/defaults.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/pages/event_details/event_details_page.dart';
import 'package:zipbuzz/pages/events/create_event_form.dart';
import 'package:zipbuzz/widgets/common/broad_divider.dart';
import 'package:zipbuzz/widgets/create_event/add_hosts.dart';
import 'package:zipbuzz/widgets/create_event/event_banner_selector.dart';
import 'package:zipbuzz/widgets/create_event/event_type_and_capacity.dart';
import 'package:zipbuzz/widgets/create_event/guest_list_type.dart';
import 'package:zipbuzz/widgets/create_event/photos.dart';

class CreateEvent extends ConsumerStatefulWidget {
  const CreateEvent({super.key});

  @override
  ConsumerState<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends ConsumerState<CreateEvent> {
  String category = allInterests.entries.first.key;
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  int randInt = 0;

  @override
  void initState() {
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EventBannerSelector(),
          const SizedBox(height: 16),
          const CreateEventForm(),
          broadDivider(),
          const AddHosts(),
          broadDivider(),
          const EventTypeAndCapacity(),
          broadDivider(),
          const CreateEventGuestListType(),
          broadDivider(),
          const AddEventPhotos(),
          broadDivider(),
          InkWell(
            onTap: () {
              showPreview();
            },
            child: Ink(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(Assets.icons.save_event),
                  const SizedBox(width: 8),
                  Text(
                    "Save & Preview",
                    style: AppStyles.h3.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<Color> getDominantColor() async {
    final previewBanner = ref.read(newEventProvider.notifier).bannerImage;
    final defaultBanners = ref.read(defaultsProvider).bannerPaths;
    randInt = Random().nextInt(defaultBanners.length);
    Color dominantColor = Colors.green;
    if (previewBanner != null) {
      final image = FileImage(previewBanner);
      final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
        image,
      );
      dominantColor = generator.dominantColor!.color;
    } else {
      final image = AssetImage(defaultBanners[randInt]);
      final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
        image,
      );
      dominantColor = generator.dominantColor!.color;
    }
    return dominantColor;
  }

  void showPreview() async {
    if (ref.read(newEventProvider.notifier).validateNewEvent()) {
      final dominantColor = await getDominantColor();
      navigatorKey.currentState!.pushNamed(
        EventDetailsPage.id,
        arguments: {
          'event': ref.read(newEventProvider),
          'isPreview': true,
          'dominantColor': dominantColor,
          'randInt': randInt,
        },
      );
    }
  }
}
