import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/pages/events/edit_event_form.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/pages/event_details/event_details_page.dart';
import 'package:zipbuzz/widgets/common/back_button.dart';
import 'package:zipbuzz/widgets/common/broad_divider.dart';
import 'package:zipbuzz/widgets/create_event/add_hosts.dart';
import 'package:zipbuzz/widgets/create_event/event_type_and_capacity.dart';
import 'package:zipbuzz/widgets/create_event/guest_list_type.dart';
import 'package:zipbuzz/widgets/create_event/photos.dart';
import 'package:zipbuzz/widgets/edit_event/event_banner.dart';
import 'package:zipbuzz/widgets/event_details_page/event_host_guest_list.dart';

class EditEventPage extends ConsumerStatefulWidget {
  static const id = '/edit_event_page';
  const EditEventPage({super.key});

  @override
  ConsumerState<EditEventPage> createState() => _CreateEventState();
}

class _CreateEventState extends ConsumerState<EditEventPage> {
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
    return Scaffold(
      appBar: AppBar(
        leading: backButton(),
        title: Text(
          "Editing Event",
          style: AppStyles.h2.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EditEventBannerSelector(),
              const SizedBox(height: 16),
              const EditEventForm(),
              broadDivider(),
              const AddHosts(),
              broadDivider(),
              const EventTypeAndCapacity(rePublish: true),
              broadDivider(),
              const AddEventPhotos(),
              broadDivider(),
              const CreateEventGuestListType(),
              const SizedBox(height: 32),
              EventHostGuestList(guests: ref.watch(editEventControllerProvider).eventMembers, eventId: ref.watch(editEventControllerProvider).id),
              broadDivider(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12).copyWith(top: 0),
        child: InkWell(
          onTap: () {
            showPreview();
          },
          child: Ink(
            height: 50,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                "Save",
                style: AppStyles.h3.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Color> getDominantColor() async {
    final previewBanner = ref.read(editEventControllerProvider.notifier).bannerImage;
    Color dominantColor = Colors.green;
    if (previewBanner != null) {
      final image = FileImage(previewBanner);
      final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
        image,
      );
      dominantColor = generator.dominantColor!.color;
    } else {
      final image = NetworkImage(ref.read(editEventControllerProvider).bannerPath);
      final generator = await PaletteGenerator.fromImageProvider(image);
      dominantColor = generator.dominantColor!.color;
    }

    return dominantColor;
  }

  void showPreview() async {
    final dominantColor = await getDominantColor();
    navigatorKey.currentState!.pushNamed(
      EventDetailsPage.id,
      arguments: {
        'event': ref.read(editEventControllerProvider),
        'rePublish': true,
        'dominantColor': dominantColor,
        'randInt': randInt,
      },
    );
  }
}
