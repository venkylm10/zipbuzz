import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/utils.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/requests/event_members_request_model.dart';
import 'package:zipbuzz/pages/events/widgets/event_details_app_bar.dart';
import 'package:zipbuzz/pages/events/widgets/event_details_attendee_numbers.dart';
import 'package:zipbuzz/pages/events/widgets/event_details_banner.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/services/image_picker.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/widgets/custom_bezel.dart';
import 'package:zipbuzz/utils/widgets/custom_hyper_linked_textspan.dart';
import 'package:zipbuzz/utils/widgets/loader.dart';
import 'package:zipbuzz/pages/events/widgets/event_host_guest_list.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/user/user_model.dart';
import 'package:zipbuzz/pages/events/widgets/event_chip.dart';
import 'package:zipbuzz/pages/events/widgets/event_buttons.dart';
import 'package:zipbuzz/pages/events/widgets/event_details.dart';
import 'package:zipbuzz/pages/events/widgets/event_hosts.dart';
import 'package:zipbuzz/pages/events/widgets/event_details_images.dart';
import 'package:zipbuzz/pages/events/widgets/event_qrcode.dart';
import 'package:zipbuzz/pages/events/widgets/event_urls.dart';
import 'package:zipbuzz/pages/home/widgets/bottom_bar.dart';

import 'widgets/event_details_common_guest_list.dart';

// ignore: must_be_immutable
class EventDetailsPage extends ConsumerStatefulWidget {
  static const id = '/event/details';
  final EventModel event;
  final int randInt;
  final bool isPreview;
  final bool rePublish;
  final bool clone;
  final bool showBottomBar;
  Color dominantColor;
  EventDetailsPage({
    super.key,
    required this.event,
    this.randInt = 0,
    this.isPreview = false,
    this.rePublish = false,
    required this.dominantColor,
    this.clone = false,
    this.showBottomBar = false,
  });

  @override
  ConsumerState<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends ConsumerState<EventDetailsPage> {
  final bodyScrollController = ScrollController();
  Color eventColor = Colors.white;
  double horizontalMargin = 16;
  int maxImages = 0;
  List<UserModel> coHosts = [];
  File? image;

  void fixInviteGuests() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (widget.event.eventMembers.isEmpty) {
      widget.rePublish
          ? ref.read(newEventProvider.notifier).resetEventMembers()
          : ref.read(editEventControllerProvider.notifier).resetEventMembers();
      return;
    }
    if (!(widget.isPreview || widget.rePublish)) return;
    setState(() {});
  }

  void getEventColor() {
    eventColor = interestColors[widget.event.category]!;
    setState(() {});
  }

  bool animateMargin() {
    if (horizontalMargin >= 0) {
      horizontalMargin = 12 - bodyScrollController.offset;
      if (horizontalMargin < 0) {
        horizontalMargin = 0;
      }
      setState(() {});
    }
    return true;
  }

  void initialise() async {
    maxImages = ref.read(newEventProvider.notifier).maxImages;
    getEventColor();
    fixInviteGuests();
    if (widget.isPreview || widget.rePublish || widget.clone) {
      return;
    }
    await ref.read(dbServicesProvider).getEventRequestMembers(widget.event.id);
    final members = await ref
        .read(dioServicesProvider)
        .getEventMembers(EventMembersRequestModel(eventId: widget.event.id));
    widget.event.eventMembers = members;
    final joined = ref
        .read(eventRequestMembersProvider)
        .firstWhereOrNull((element) => element.id == ref.read(userProvider).id);
    if (joined != null) {
      widget.event.status = "confirmed";
    }
    setState(() {});
  }

  @override
  void initState() {
    initialise();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hosted = widget.event.hostId == ref.read(userProvider).id;
    return CustomBezel(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            backgroundColor: widget.dominantColor,
            resizeToAvoidBottomInset: false,
            appBar: EventDetailsAppBar(
              isPreview: widget.isPreview,
              rePublish: widget.rePublish,
              pickImage: _pickImage,
            ),
            extendBodyBehindAppBar: true,
            body: Stack(
              children: [
                SizedBox(
                  height: size.height,
                  width: size.width,
                  child: NotificationListener<ScrollUpdateNotification>(
                    onNotification: (notification) => animateMargin(),
                    child: SingleChildScrollView(
                      controller: bodyScrollController,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          EventDetailsBanner(
                            event: widget.event,
                            isPreview: widget.isPreview,
                            dominantColor: widget.dominantColor,
                          ),
                          Transform.translate(
                            offset: const Offset(0, -40),
                            child: AnimatedPadding(
                              padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                              duration: const Duration(milliseconds: 100),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.event.title,
                                      style: AppStyles.h2.copyWith(fontWeight: FontWeight.w600),
                                      softWrap: true,
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      direction: Axis.horizontal,
                                      alignment: WrapAlignment.start,
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        EventChip(
                                          eventColor: eventColor,
                                          interest: widget.event.category,
                                          iconPath: widget.event.iconPath,
                                        ),
                                        EventDetailsAttendeeNumbers(
                                            event: widget.event,
                                            isPreview: widget.isPreview,
                                            rePublish: widget.rePublish),
                                        if (!widget.isPreview) EventQRCode(event: widget.event),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Divider(
                                      color: AppColors.greyColor.withOpacity(0.2),
                                      thickness: 0,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Event details",
                                      style: AppStyles.h5.copyWith(
                                        color: AppColors.lightGreyColor,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    EventDetails(event: widget.event),
                                    const SizedBox(height: 16),
                                    Divider(
                                      color: AppColors.greyColor.withOpacity(0.2),
                                      thickness: 0,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Event description",
                                      style: AppStyles.h5.copyWith(
                                        color: AppColors.lightGreyColor,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    buildDescription(),
                                    const SizedBox(height: 16),
                                    Divider(
                                      color: AppColors.greyColor.withOpacity(0.2),
                                      thickness: 0,
                                    ),
                                    EventDetailsCommonGuestList(
                                      event: widget.event,
                                      isPreview: widget.isPreview,
                                      rePublish: widget.rePublish,
                                      clone: widget.clone,
                                      hosted: hosted,
                                    ),
                                    const SizedBox(height: 16),
                                    buildPhotos(widget.isPreview, widget.rePublish, ref),
                                    const SizedBox(height: 16),
                                    Divider(
                                      color: AppColors.greyColor.withOpacity(0.2),
                                      thickness: 0,
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 16),
                                        Text(
                                          "Hosts",
                                          style: AppStyles.h5.copyWith(
                                            color: AppColors.lightGreyColor,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            EventHosts(
                                              event: widget.event,
                                              isPreview: widget.isPreview,
                                            ),
                                            const SizedBox(height: 16),
                                            Divider(
                                              color: AppColors.greyColor.withOpacity(0.2),
                                              thickness: 0,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: widget.isPreview ? 100 : 40),
                        ],
                      ),
                    ),
                  ),
                ),
                buildLoader(),
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: EventButtons(
              event: widget.event,
              isPreview: widget.isPreview,
              rePublish: widget.rePublish,
            ),
            bottomNavigationBar: BottomBar(
              selectedTab: ref.watch(homeTabControllerProvider).homeTabIndex,
              pop: () {
                navigatorKey.currentState!.pushNamedAndRemoveUntil(Home.id, (route) => false);
              },
            )),
      ),
    );
  }

  void _pickImage() async {
    final pickedImage = await ImageServices().pickImage();
    if (pickedImage == null) return;
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedImage.path,
      aspectRatioPresets: [CropAspectRatioPreset.ratio16x9],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: AppColors.primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: false),
        IOSUiSettings(title: 'Cropper'),
        WebUiSettings(
          context: navigatorKey.currentContext!,
        ),
      ],
    );
    if (croppedFile == null) return;
    image = File(croppedFile.path);
    ref.read(newEventProvider.notifier).updateBannerImage(image!);
    ref.read(editEventControllerProvider.notifier).updateBannerImage(image!);
    ref.read(loadingTextProvider.notifier).updateLoadingText("Updating banner image...");
    widget.dominantColor = await getDominantColor();
    ref.read(loadingTextProvider.notifier).reset();
    setState(() {});
  }

  Widget buildLoader() {
    return Consumer(
      builder: (context, ref, child) {
        final loading = ref.watch(eventsControllerProvider).loading;
        return loading
            ? Positioned.fill(
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 4,
                      sigmaY: 4,
                    ),
                    child: const Center(
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox();
      },
    );
  }

  Widget buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomHyperLinkedTextSpan(text: widget.event.about),
        widget.event.hyperlinks.isEmpty
            ? const SizedBox()
            : EventUrls(hyperlinks: widget.event.hyperlinks),
      ],
    );
  }

  Future<Color> getDominantColor() async {
    final previewBanner = ref.read(newEventProvider.notifier).bannerImage;
    Color dominantColor = Colors.green;
    if (previewBanner != null) {
      final image = FileImage(previewBanner);
      final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
        image,
      );
      dominantColor = generator.dominantColor!.color;
    } else {
      final image = NetworkImage(interestBanners[widget.event.category]!);
      final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
        image,
      );
      dominantColor = generator.dominantColor!.color;
    }
    setState(() {});
    return dominantColor;
  }

  Widget buildPhotos(bool isPreview, bool rePublish, WidgetRef ref) {
    final imageFiles = rePublish
        ? ref.watch(editEventControllerProvider.notifier).selectedImages
        : ref.watch(newEventProvider.notifier).selectedImages;
    final imageUrls = widget.event.imageUrls;
    return EventDetailsImages(
      isPreview: isPreview,
      rePublish: rePublish,
      ref: ref,
      imageFiles: imageFiles,
      imageUrls: imageUrls,
      maxImages: maxImages,
      clone: widget.clone,
    );
  }
}
