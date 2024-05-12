import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/utils.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/requests/event_members_request_model.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/services/image_picker.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/widgets/common/custom_bezel.dart';
import 'package:zipbuzz/widgets/common/loader.dart';
import 'package:zipbuzz/widgets/event_details_page/event_host_guest_list.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/user/user_model.dart';
import 'package:zipbuzz/widgets/common/attendee_numbers.dart';
import 'package:zipbuzz/widgets/common/event_chip.dart';
import 'package:zipbuzz/widgets/event_details_page/event_buttons.dart';
import 'package:zipbuzz/widgets/event_details_page/event_details.dart';
import 'package:zipbuzz/widgets/event_details_page/event_hosts.dart';
import 'package:zipbuzz/widgets/event_details_page/event_images.dart';
import 'package:zipbuzz/widgets/event_details_page/event_qrcode.dart';
import 'package:zipbuzz/widgets/event_details_page/event_urls.dart';
import 'package:zipbuzz/widgets/event_details_page/guest_list.dart';
import 'package:zipbuzz/widgets/home/bottom_bar.dart';

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

  void pickImage() async {
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
      setState(() {});
    }
    // for (var e in ref.read(eventRequestMembersProvider)) {
    //   if (widget.event.eventMembers.firstWhereOrNull((element) => element.phone == e.phone) ==
    //       null) {
    //     final newMember = EventInviteMember(image: e.image, phone: e.phone, name: e.name);
    //     widget.event.eventMembers.add(newMember);
    //   }
    // }
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
            appBar: buildAppBar(),
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
                          buildBanner(),
                          Transform.translate(
                            offset: const Offset(0, -40),
                            child: AnimatedPadding(
                              padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                              duration: const Duration(milliseconds: 100),
                              child: Stack(
                                children: [
                                  Container(
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
                                            buildAttendeeNumber(),
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
                                        if (!widget.event.privateGuestList || hosted)
                                          buildGuestListTitle(),
                                        if (!widget.event.privateGuestList || hosted)
                                          const SizedBox(height: 16),
                                        if (!widget.event.privateGuestList || hosted)
                                          buildGuestList(),
                                        const SizedBox(height: 16),
                                        Text(
                                          "Photos",
                                          style: AppStyles.h5.copyWith(
                                            color: AppColors.lightGreyColor,
                                          ),
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
                                  // Friends registered notifier
                                  // const FriendsRegisteredBox()
                                ],
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

  Consumer buildGuestListTitle() {
    return Consumer(builder: (context, ref, child) {
      final newEvent = ref.watch(newEventProvider);
      var num = widget.event.eventMembers.length;
      if (widget.isPreview) {
        num = newEvent.eventMembers.length;
      }
      return Text(
        "Guest list ($num)",
        style: AppStyles.h5.copyWith(
          color: AppColors.lightGreyColor,
        ),
      );
    });
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
        Builder(
          builder: (context) {
            final splits = widget.event.about.split(" ");
            return RichText(
              text: TextSpan(
                children: splits.map(
                  (e) {
                    var isLink = false;
                    var url = "";
                    final up2 = RegExp(r'^(https?://)?(www\.)?[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                    if (up2.hasMatch(e)) {
                      isLink = true;
                      if (e.startsWith("http://") || e.startsWith("https://")) {
                        url = e;
                      } else {
                        url = "http://$e";
                      }
                    }
                    return TextSpan(
                      children: isLink
                          ? [
                              TextSpan(
                                text: e,
                                style: AppStyles.h4.copyWith(
                                  color: isLink ? Colors.blue : AppColors.greyColor,
                                  fontStyle: isLink ? FontStyle.italic : FontStyle.normal,
                                  decoration:
                                      isLink ? TextDecoration.underline : TextDecoration.none,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launchUrlString(url);
                                  },
                              ),
                              const TextSpan(text: " "),
                            ]
                          : [
                              TextSpan(
                                text: !isLink ? "$e " : null,
                                style: AppStyles.h4.copyWith(
                                  color: AppColors.greyColor,
                                  fontStyle: FontStyle.normal,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                    );
                  },
                ).toList(),
              ),
            );
          },
        ),
        widget.event.hyperlinks.isEmpty
            ? const SizedBox()
            : EventUrls(hyperlinks: widget.event.hyperlinks),
      ],
    );
  }

  Widget buildAttendeeNumber() {
    final hosted = widget.event.hostId == ref.read(userProvider).id;
    return InkWell(
      onTap: () {
        if (widget.isPreview || widget.rePublish) return;
        if (!(!widget.event.privateGuestList || hosted)) return;
        showModalBottomSheet(
          context: navigatorKey.currentContext!,
          isScrollControlled: true,
          enableDrag: true,
          builder: (context) {
            var guests = widget.isPreview
                ? ref.watch(newEventProvider).eventMembers
                : widget.event.eventMembers;
            if (widget.rePublish) {
              guests = ref.read(editEventControllerProvider).eventMembers;
            }
            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  width: kIsWeb
                      ? MediaQuery.of(context).size.height * Assets.images.border_ratio * 0.9
                      : null,
                  child: EventHostGuestList(
                    guests: guests,
                    eventId: widget.event.id,
                    interative: false,
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Consumer(builder: (context, ref, child) {
        var data = ref.watch(eventRequestMembersProvider);
        final confirmedMembers = data
            .where((element) => element.status == "confirm" || element.status == 'host')
            .toList();
        final respondedMembers = data;
        String attendees = "";
        if (widget.isPreview) {
          attendees = "${ref.watch(newEventProvider).attendees},0,0";
        } else {
          var responded = 0;
          for (var e in respondedMembers) {
            responded = responded + e.attendees;
          }
          var confirmed = 0;
          for (var e in confirmedMembers) {
            confirmed = confirmed + e.attendees;
          }
          attendees = "${widget.event.eventMembers.length},$responded,$confirmed";
        }

        var total = 1;

        if (widget.isPreview) {
          total = ref.watch(newEventProvider).capacity;
        } else if (widget.rePublish) {
          total = ref.watch(editEventControllerProvider).capacity;
        } else {
          total = widget.event.capacity;
        }
        return AttendeeNumbers(
          attendees: attendees,
          total: total,
          backgroundColor: AppColors.greyColor.withOpacity(0.1),
        );
      }),
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

  Widget buildGuestList() {
    return Consumer(
      builder: (context, ref, child) {
        final userId = GetStorage().read(BoxConstants.id);
        final newEvent = ref.watch(newEventProvider);
        final editEvent = ref.watch(editEventControllerProvider);
        if (widget.isPreview) {
          return EventGuestList(
            guests: newEvent.eventMembers,
            clone: widget.clone,
          );
        }
        if (widget.rePublish) {
          return EventGuestList(
            guests: editEvent.eventMembers,
            clone: widget.clone,
          );
        }
        if (widget.event.hostId != userId) {
          return EventGuestList(
            guests: widget.event.eventMembers,
            clone: widget.clone,
          );
        }
        return EventHostGuestList(
          guests: widget.event.eventMembers,
          eventId: widget.event.id,
        );
      },
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      shadowColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      leadingWidth: 0,
      leading: const SizedBox(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: InkWell(
            onTap: () => navigatorKey.currentState!.pop(),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Expanded(child: SizedBox()),
        if (widget.isPreview || widget.rePublish)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () => pickImage(),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: const Center(
                      child: Icon(
                        Icons.edit,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildBanner() {
    final previewBanner = ref.read(newEventProvider.notifier).bannerImage;

    if (widget.isPreview) {
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
              buildBannerGradient(),
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
                interestBanners[widget.event.category]!,
                fit: BoxFit.cover,
              ),
            ),
            buildBannerGradient(),
          ],
        ),
      );
    } else {
      final newBanner = ref.read(editEventControllerProvider.notifier).bannerImage;
      if (newBanner == null) {
        return SizedBox(
          height: 300,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  widget.event.bannerPath,
                  fit: BoxFit.cover,
                ),
              ),
              buildBannerGradient(),
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
              buildBannerGradient(),
            ],
          ),
        );
      }
    }
  }

  Positioned buildBannerGradient() {
    return Positioned(
      bottom: -10,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 300,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, widget.dominantColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.2, 1],
          ),
        ),
      ),
    );
  }

  Widget buildPhotos(bool isPreview, bool rePublish, WidgetRef ref) {
    final imageFiles = rePublish
        ? ref.watch(editEventControllerProvider.notifier).selectedImages
        : ref.watch(newEventProvider.notifier).selectedImages;
    final imageUrls = widget.event.imageUrls;
    return EventImages(
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
