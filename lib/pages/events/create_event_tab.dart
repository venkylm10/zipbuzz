import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/controllers/new_event_controller.dart';
import 'package:zipbuzz/main.dart';
import 'package:zipbuzz/pages/event_details/event_details_page.dart';
import 'package:zipbuzz/pages/events/create_event_form.dart';
import 'package:zipbuzz/widgets/common/broad_divider.dart';
import 'package:zipbuzz/widgets/create_event/add_hosts.dart';
import 'package:zipbuzz/widgets/create_event/event_banner_selector.dart';
import 'package:zipbuzz/widgets/create_event/event_type_and_capacity.dart';
import 'package:zipbuzz/widgets/create_event/guest_list.dart';
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

  void updateCoHosts() async {
    await ref.read(newEventProvider.notifier).updateCoHosts();
  }

  @override
  void initState() {
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    updateCoHosts();
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
          const CreateEventGuestList(),
          broadDivider(),
          const AddEventPhotos(),
          broadDivider(),
          InkWell(
            onTap: () {
              navigatorKey.currentState!.pushNamed(EventDetailsPage.id,
                  arguments: {
                    'event': ref.read(newEventProvider),
                    'isPreview': true
                  });
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
}
