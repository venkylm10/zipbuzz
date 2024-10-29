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
import 'package:zipbuzz/models/trace_log_model.dart';
import 'package:zipbuzz/pages/events/widgets/event_details_app_bar.dart';
import 'package:zipbuzz/pages/events/widgets/event_details_attendee_numbers.dart';
import 'package:zipbuzz/pages/events/widgets/event_details_banner.dart';
import 'package:zipbuzz/pages/events/widgets/event_details_ticket_info.dart';
import 'package:zipbuzz/pages/events/widgets/send_broadcast_message_button.dart';
import 'package:zipbuzz/pages/events/widgets/send_invitation_bell.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/services/image_picker.dart';
import 'package:zipbuzz/utils/action_code.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/widgets/broad_divider.dart';
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
  final bool isPreview;
  final bool rePublish;
  final bool clone;
  final bool showBottomBar;
  final Color dominantColor;
  final bool groupEvent;
  const EventDetailsPage({
    super.key,
    required this.event,
    this.isPreview = false,
    this.rePublish = false,
    required this.dominantColor,
    this.clone = false,
    this.showBottomBar = false,
    this.groupEvent = false,
  });

  @override
  ConsumerState<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends ConsumerState<EventDetailsPage> {
  final bodyScrollController = ScrollController();
  Color eventColor = Colors.white;
  late Color dominantColor;
  double horizontalMargin = 16;
  int maxImages = 0;
  List<UserModel> coHosts = [];
  File? image;
  late EventModel event;

  void fixInviteGuests() async {
    if (event.eventMembers.isEmpty) {
      widget.rePublish
          ? ref.read(newEventProvider.notifier).resetEventMembers()
          : ref.read(editEventControllerProvider.notifier).resetEventMembers();
      return;
    }
    if (!widget.isPreview && !widget.rePublish) return;
    setState(() {});
  }

  void getEventColor() {
    eventColor = interestColors[event.category]!;
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
    final user = ref.read(userProvider);
    final trace = TraceLogModel(
      userId: user.id,
      actionCode: ActionCode.ViewEvent,
      actionDetails: "Event Details Page",
      eventId: event.id,
      successFlag: true,
    );
    ref.read(dioServicesProvider).traceLog(trace);
    await ref.read(dbServicesProvider).getEventRequestMembers(event.id);
    final members = await ref
        .read(dioServicesProvider)
        .getEventMembers(EventMembersRequestModel(eventId: event.id));
    event.eventMembers = members;
    final joined = ref
        .read(eventRequestMembersProvider)
        .firstWhereOrNull((element) => element.id == ref.read(userProvider).id);
    if (joined != null) {
      event.status = "confirmed";
    }
    setState(() {});
  }

  @override
  void initState() {
    event = widget.event;
    dominantColor = widget.dominantColor;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialise();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hosted = event.hostId == ref.read(userProvider).id;
    return CustomBezel(
        child: GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          backgroundColor: dominantColor,
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
                          event: event,
                          isPreview: widget.isPreview,
                          dominantColor: dominantColor,
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
                                  RichText(
                                    softWrap: true,
                                    text: TextSpan(
                                      children: [
                                        if (event.groupName != 'zipbuzz-null')
                                          TextSpan(
                                            text: '${event.groupName} > ',
                                            style: AppStyles.h2.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        TextSpan(
                                          text: event.title,
                                          style: AppStyles.h2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildDetailTags(),
                                  broadDivider(host: hosted),
                                  Text(
                                    "Event details",
                                    style: AppStyles.h5.copyWith(
                                      color: AppColors.lightGreyColor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  EventDetails(event: event),
                                  broadDivider(host: hosted),
                                  Text(
                                    "Event description",
                                    style: AppStyles.h5.copyWith(
                                      color: AppColors.lightGreyColor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDescription(),
                                  broadDivider(host: hosted),
                                  EventDetailsTicketInfo(
                                    event: event,
                                    isPreview: widget.isPreview,
                                    rePublish: widget.rePublish,
                                  ),
                                  EventDetailsCommonGuestList(
                                    event: event,
                                    isPreview: widget.isPreview,
                                    rePublish: widget.rePublish,
                                    clone: widget.clone,
                                    hosted: hosted,
                                  ),
                                  _buildPhotos(widget.isPreview, widget.rePublish, ref),
                                  EventHosts(
                                    event: event,
                                    isPreview: widget.isPreview,
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
              _buildLoader(),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: EventButtons(
            event: event,
            isPreview: widget.isPreview,
            rePublish: widget.rePublish,
            groupEvent: widget.groupEvent,
          ),
          bottomNavigationBar: BottomBar(
            selectedTab: ref.watch(homeTabControllerProvider).selectedTab.index,
            pop: () {
              navigatorKey.currentState!.pushNamedAndRemoveUntil(Home.id, (route) => false);
            },
          )),
    ));
  }

  Wrap _buildDetailTags() {
    return Wrap(
      direction: Axis.horizontal,
      alignment: WrapAlignment.start,
      spacing: 8,
      runSpacing: 8,
      children: [
        EventChip(
          eventColor: eventColor,
          interest: event.category,
          iconPath: event.iconPath,
        ),
        EventDetailsAttendeeNumbers(
            event: event, isPreview: widget.isPreview, rePublish: widget.rePublish),
        if (!widget.isPreview) EventQRCode(event: event),
        if (!widget.isPreview && !widget.rePublish) SendNotificationBell(event: event),
        if (!widget.isPreview && !widget.rePublish)
          SendBroadcastMessageButton(
            event: event,
            guests: event.eventMembers,
          ),
      ],
    );
  }

  void _pickImage() async {
    final pickedImage = await ImageServices().pickImage();
    if (pickedImage == null) return;
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedImage.path,
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
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
    dominantColor = await _getDominantColor();
    ref.read(loadingTextProvider.notifier).reset();
    setState(() {});
  }

  Widget _buildLoader() {
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

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomHyperLinkedTextSpan(text: event.about),
        event.hyperlinks.isEmpty ? const SizedBox() : EventUrls(hyperlinks: event.hyperlinks),
      ],
    );
  }

  Future<Color> _getDominantColor() async {
    final previewBanner = ref.read(newEventProvider.notifier).bannerImage;
    Color dominantColor = Colors.green;
    if (previewBanner != null) {
      final image = FileImage(previewBanner);
      final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
        image,
      );
      dominantColor = generator.dominantColor!.color;
    } else {
      final image = NetworkImage(interestBanners[event.category]!);
      final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
        image,
      );
      dominantColor = generator.dominantColor!.color;
    }
    setState(() {});
    return dominantColor;
  }

  Widget _buildPhotos(bool isPreview, bool rePublish, WidgetRef ref) {
    final imageFiles = rePublish
        ? ref.watch(editEventControllerProvider.notifier).selectedImages
        : ref.watch(newEventProvider.notifier).selectedImages;
    final imageUrls = event.imageUrls;
    return EventDetailsImages(
      isPreview: isPreview,
      rePublish: rePublish,
      ref: ref,
      imageFiles: imageFiles,
      imageUrls: imageUrls,
      maxImages: maxImages,
      clone: widget.clone,
      status: event.status,
      eventId: event.id,
      updateEvent: (val) {
        setState(() {
          event = val;
        });
        ref.read(eventsControllerProvider.notifier).fetchEvents();
        ref.read(eventsControllerProvider.notifier).fetchUserEvents();
      },
    );
  }
}
