import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/models/events/event_invite_members.dart';
import 'package:zipbuzz/models/events/posts/event_invite_post_model.dart';
import 'package:zipbuzz/models/events/posts/event_post_model.dart';
import 'package:zipbuzz/models/interests/requests/user_interests_update_model.dart';
import 'package:zipbuzz/models/interests/responses/interest_model.dart';
import 'package:zipbuzz/pages/events/event_details_page.dart';
import 'package:zipbuzz/pages/sign-in/sign_in_page.dart';
import 'package:zipbuzz/services/contact_services.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/user/user_model.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/utils/constants/defaults.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/widgets/loader.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

final newEventProvider = StateNotifierProvider<NewEvent, EventModel>((ref) => NewEvent(ref: ref));

class NewEvent extends StateNotifier<EventModel> {
  final Ref ref;

  NewEvent({required this.ref})
      : super(
          EventModel(
              id: ref.read(userProvider).id,
              title: "",
              location: "",
              date: DateTime.now().toString(),
              startTime: "",
              endTime: "",
              attendees: 0,
              category: 'Please select',
              isFavorite: false,
              bannerPath: "",
              iconPath: "",
              // updating this just after getting allInterests from the API
              about: "",
              hostId: ref.read(userProvider).id,
              hostName: ref.read(userProvider).name,
              hostPic: ref.read(userProvider).imageUrl,
              capacity: 10,
              isPrivate: true,
              privateGuestList: false,
              imageUrls: [],
              eventMembers: [],
              status: "nothing",
              userDeviceToken: "",
              hyperlinks: [],
              members: 0,
              groupName: 'zipbuzz-null'),
        );
  List<File> selectedImages = [];
  int maxImages = 7;
  File? bannerImage;
  List<UserModel> coHosts = [];
  List<ContactModel> eventInvites = [];
  List<ContactModel> allContacts = [];
  List<ContactModel> contactSearchResult = [];
  List<TextEditingController> urlControllers = [TextEditingController()];
  List<TextEditingController> urlNameControllers = [TextEditingController()];
  bool cloneEvent = false;

  void cloneHyperLinks(List<HyperLinks> hyperlinks) {
    if (hyperlinks.isEmpty) return;
    urlControllers = [];
    urlNameControllers = [];
    for (var i = 0; i < hyperlinks.length; i++) {
      urlControllers.add(TextEditingController(text: hyperlinks[i].url));
      urlNameControllers.add(TextEditingController(text: hyperlinks[i].urlName));
    }
  }

  void addUrlField() {
    urlControllers.add(TextEditingController());
    urlNameControllers.add(TextEditingController());
  }

  void removeUrlField(int index) {
    if (urlControllers.length == 1) {
      if (urlControllers.first.text.isNotEmpty || urlNameControllers.first.text.isNotEmpty) {
        urlControllers.first.clear();
        urlNameControllers.first.clear();
        return;
      }
      showSnackBar(message: "This field is optional");
      return;
    }
    urlControllers.removeAt(index);
    urlNameControllers.removeAt(index);
  }

  void updateHyperlinks() {
    state = state.copyWith(hyperlinks: []);
    for (var i = 0; i < urlControllers.length; i++) {
      final url = urlControllers[i].text;
      final name = urlNameControllers[i].text;
      if (url.isNotEmpty && name.isNotEmpty) {
        state = state.copyWith(
          hyperlinks: state.hyperlinks
            ..add(
              HyperLinks(
                id: 0,
                urlName: name,
                url: url,
              ),
            ),
        );
      }
    }
  }

  void updateEvent(EventModel event) {
    state = event;
  }

  void updateHostId(int id) {
    state = state.copyWith(hostId: id);
  }

  void updateHostPic(String url) {
    state = state.copyWith(hostPic: url);
  }

  void updateHostName(String name) {
    state = state.copyWith(hostName: name);
  }

  void toggleGuestListPrivacy() {
    state = state.copyWith(privateGuestList: !state.privateGuestList);
  }

  void updateBannerImage(File file) {
    bannerImage = file;
  }

  void updateName(String title) {
    state = state.copyWith(title: title);
  }

  void updateDescription(String description) {
    state = state.copyWith(about: description);
  }

  void updateLocation(String location) {
    state = state.copyWith(location: location);
  }

  void updateCategory(String category) {
    state = state.copyWith(
        category: category,
        iconPath: interestIcons[category] ?? interestIcons[allInterests.first.activity]);
  }

  void onChangeCapacity(String value) {
    if (value.isEmpty) {
      state = state.copyWith(capacity: 0);

      return;
    }
    if (value.length > 1 && value[0] == '0') {
      value = value.substring(1);
    }
    final num = int.parse(value);

    if (num < 0) {
      state = state.copyWith(capacity: 0);
    } else {
      state = state.copyWith(capacity: num);
    }
  }

  void updateEventType(bool value) {
    state = state.copyWith(isPrivate: value);
  }

  void increaseCapacity() {
    state = state.copyWith(capacity: state.capacity + 1);
  }

  void decreaseCapacity() {
    if (state.capacity != 0) {
      state = state.copyWith(capacity: state.capacity - 1);
      return;
    }
  }

  void updateDate(DateTime date) {
    final formatedDate = getDateFromDateTime(date);
    state = state.copyWith(date: formatedDate);
  }

  void updateTime(TimeOfDay time, {bool? isEnd = false}) {
    final formatedTime = getTimeFromTimeOfDay(time);
    if (isEnd!) {
      state = state.copyWith(endTime: formatedTime);
    } else {
      state = state.copyWith(startTime: formatedTime);
    }
  }

  void updateAllContacts(List<ContactModel> contacts) {
    allContacts = contacts;
  }

  void updateInvites(List<ContactModel> contacts) {
    eventInvites = contacts;
    final members = eventInvites
        .map((e) => EventInviteMember(
              image: Defaults.contactAvatarUrl,
              phone: e.phones.first,
              name: e.displayName,
              status: 'invited',
            ))
        .toList();
    state = state.copyWith(
      eventMembers: members,
      attendees: members.length,
    );
  }

  void resetContactSearch() {
    contactSearchResult = allContacts;
  }

  void removeInviteMember(String phone) {
    final members = state.eventMembers;
    members.removeWhere((element) => element.phone == phone);
    state = state.copyWith(
      eventMembers: members,
      attendees: state.attendees - 1,
    );
    eventInvites.removeWhere(
      (element) {
        var number = element.phones.first;
        if (number.length > 10) {
          number = number.substring(number.length - 10);
        }
        phone = phone.replaceAll(RegExp(r'[\s()-]+'), "").replaceAll(" ", "");
        if (phone.length > 10) {
          phone = phone.substring(phone.length - 10);
        }
        return phone == number;
      },
    );
  }

  void updateSelectedContact(ContactModel contact, {bool fix = false}) {
    if (!eventInvites.contains(contact)) {
      if (state.attendees >= state.capacity) {
        state = state.copyWith(capacity: state.capacity + 1);
      }
      if (!fix) eventInvites.add(contact);
      final member = EventInviteMember(
        image: "null",
        phone: contact.phones.first,
        name: contact.displayName,
        status: 'invited',
      );
      addEventMember(member);
      return;
    }
    if (!fix) eventInvites.remove(contact);
    final member = state.eventMembers.firstWhere(
      (element) {
        var number =
            contact.phones.first;
        if (number.length > 10) {
          number = number.substring(number.length - 10);
        }
        var phone = element.phone.replaceAll(RegExp(r'[\s()-]+'), "").replaceAll(" ", "");
        if (phone.length > 10) {
          phone = phone.substring(phone.length - 10);
        }
        return phone == number;
      },
    );
    state = state.copyWith(
      attendees: state.attendees - 1,
      eventMembers: state.eventMembers..remove(member),
    );
  }

  void resetEventMembers() {
    state = state.copyWith(eventMembers: []);
    eventInvites = [];
  }

  void addEventMember(EventInviteMember member, {bool increase = true}) {
    state = state.copyWith(
      attendees: increase ? state.attendees + 1 : state.attendees,
      eventMembers: state.eventMembers..add(member),
    );
  }

  void updateSelectedContactsList(List<ContactModel> contacts) {
    eventInvites.clear();
    eventInvites.addAll(contacts);
  }

  void updateContactSearchResult(String query) {
    query = query.toLowerCase().trim();
    contactSearchResult = allContacts.where(
      (element) {
        var name = element.displayName.toLowerCase().contains(query);
        var number = false;
        number = element.phones.any((e) {
            final phone = e;
            if (phone.length > 10) {
              return phone.substring(phone.length - 10).contains(query);
            }
            return phone.contains(query);
          });
        return name || number;
      },
    ).toList();
  }

  String getDateFromDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  String getTimeFromTimeOfDay(TimeOfDay timeOfDay) {
    final hr = timeOfDay.hourOfPeriod.toString().length == 1
        ? '0${timeOfDay.hourOfPeriod}'
        : timeOfDay.hourOfPeriod;
    final min = timeOfDay.minute.toString().length == 1 ? '0${timeOfDay.minute}' : timeOfDay.minute;
    return '$hr:$min ${timeOfDay.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  bool validateNewEvent() {
    if (state.category == 'Please select') {
      showSnackBar(message: "Please select event category");
      return false;
    }
    if (state.title.isEmpty) {
      showSnackBar(message: "Please enter event title");
      return false;
    }
    if (state.about.isEmpty) {
      showSnackBar(message: "Please enter event description");
      return false;
    }
    if (state.location.isEmpty) {
      showSnackBar(message: "Please enter event location");
      return false;
    }
    if (state.startTime.isEmpty) {
      showSnackBar(message: "Please enter event start time");
      return false;
    }
    return true;
  }

  void showSignInForm() {
    showModalBottomSheet(
      context: navigatorKey.currentContext!,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      barrierColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      builder: (context) {
        return const SignInSheet();
      },
    );
  }

  Future<void> publishEvent({bool groupEvent = false}) async {
    ref.read(loadingTextProvider.notifier).reset();
    if (GetStorage().read(BoxConstants.guestUser) != null) {
      showSnackBar(message: "You need to be Signed In to create an event!", duration: 2);
      await Future.delayed(const Duration(seconds: 2));
      showSignInForm();
      return;
    }
    final check = validateNewEvent();
    if (!check) return;
    try {
      final groupId =
          groupEvent ? ref.read(groupControllerProvider).currentGroupDescription!.id : 0;
      final groupName = groupEvent
          ? ref.read(groupControllerProvider).currentGroupDescription!.groupName
          : "zipbuzz-null";
      final currentDay = ref.read(eventsControllerProvider.notifier).currentDay;
      ref
          .read(eventsControllerProvider.notifier)
          .updateCurrentDay(currentDay.add(const Duration(days: 1)));
      var bannerUrl = "";
      if (bannerImage != null) {
        ref.read(loadingTextProvider.notifier).updateLoadingText("Uploading banner image...");
        bannerUrl = await ref.read(dioServicesProvider).postEventBanner(bannerImage!);
      } else {
        bannerUrl = interestBanners[state.category]!;
      }
      final user = ref.read(userProvider);
      state = state.copyWith(bannerPath: bannerUrl);
      debugPrint("New Event: ${state.toMap()}");
      final date = DateTime.parse(state.date);
      state = state.copyWith(
        privateGuestList: state.isPrivate ? state.privateGuestList : false,
      );

      final eventPostModel = EventPostModel(
        banner: bannerUrl,
        category: state.category,
        name: state.title,
        description: state.about,
        date: DateTime(date.year, date.month, date.day).toString(),
        venue: state.location,
        startTime: state.startTime,
        endTime: state.endTime.isEmpty ? "null" : state.endTime,
        hostId: user.id,
        hostName: user.name,
        hostPic: user.imageUrl,
        eventType: state.isPrivate,
        capacity: state.capacity,
        filledCapacity: eventInvites.length,
        guestList: !state.privateGuestList,
        isPrivate: state.isPrivate,
        groupId: groupId,
        groupName: groupName,
      );

      // print(eventPostModel.toMap());
      // ref.read(loadingTextProvider.notifier).reset();
      // return;

      ref.read(loadingTextProvider.notifier).updateLoadingText("Creating Event...");
      int eventId = 0;
      if (groupEvent) {
        eventId = await ref.read(dioServicesProvider).createGroupEvent(eventPostModel);
      } else {
        eventId = await ref.read(dbServicesProvider).createEvent(eventPostModel);
      }

      //update eventId locally
      state = state.copyWith(id: eventId);

      var eventDateTime = DateTime.parse(state.date);
      var formattedDate = formatWithSuffix(eventDateTime);
      // ref.read(loadingTextProvider.notifier).updateLoadingText("Sending invites...");
      final inviteePicUrls = eventInvites.map((e) => Defaults.contactAvatarUrl).toList();
      final userNumber = ref.read(userProvider).mobileNumber;
      final countryDialCode = userNumber.substring(0, userNumber.length - 10);
      final phoneNumbers = eventInvites.map((e) {
        Set<String> nums = {};
        String code = "";
        for (var num in e.phones) {
          code = num.substring(0, num.length - 10);
          if (num.length == 10) {
            num = countryDialCode + num;
          } else if (num.length > 10 && !num.startsWith("+")) {
            num = num.substring(num.length - 10);
            num = "+$code$num";
          }
          nums.add(num);
        }
        return nums.join(',');
      }).toList();
      final names = eventInvites.map((e) {
        return e.displayName;
      }).toList();
      for (var e in phoneNumbers) {
        debugPrint("Phone Numbers: $e");
      }
      final eventInvitePostModel = EventInvitePostModel(
        phoneNumbers: phoneNumbers,
        images: inviteePicUrls,
        names: names,
        senderName: ref.read(userProvider).name,
        eventName: eventPostModel.name,
        eventDescription: eventPostModel.description,
        eventDate: formattedDate,
        eventLocation: eventPostModel.venue,
        eventStart: eventPostModel.startTime,
        eventEnd: eventPostModel.endTime,
        eventId: eventId,
        banner: bannerUrl,
        hostId: ref.read(userProvider).id,
        notificationData: InviteData(eventId: eventId, senderId: ref.read(userProvider).id),
      );
      debugPrint(eventInvitePostModel.toMap().toString());
      ref.read(loadingTextProvider.notifier).updateLoadingText("Inviting Guests...");
      await ref.read(dioServicesProvider).sendEventInvite(eventInvitePostModel);
      // upload event urls
      ref.read(loadingTextProvider.notifier).updateLoadingText("Updating Event URLs...");
      await ref
          .read(dioServicesProvider)
          .sendEventUrls(eventId, urlControllers, urlNameControllers);
      // upload event images
      if (state.imageUrls.isNotEmpty) {
        for (var i = 0; i < state.imageUrls.length; i++) {
          await ref.read(dioServicesProvider).addClonedImage(eventId, state.imageUrls[i]);
        }
      }
      ref.read(loadingTextProvider.notifier).updateLoadingText("Uploading event images...");
      await ref.read(dioServicesProvider).postEventImages(eventId, selectedImages);
      ref.read(eventsControllerProvider.notifier).updatedFocusedDay(eventDateTime);
      final interests =
          ref.read(homeTabControllerProvider.notifier).containsInterest(state.category);
      final queryInterest = ref
          .read(homeTabControllerProvider.notifier)
          .containsInterest(state.category, querySheet: true);
      if (!interests) {
        final interest = allInterests.firstWhere((element) => element.activity == state.category);
        updateInterests(interest);
      }
      if (!queryInterest) {
        final interest = allInterests.firstWhere((element) => element.activity == state.category);
        ref.read(homeTabControllerProvider.notifier).addQueryInterest(interest);
      }
      ref.read(loadingTextProvider.notifier).updateLoadingText("Updating events...");

      await ref.read(eventsControllerProvider.notifier).fetchEvents();
      await ref.read(eventsControllerProvider.notifier).fetchUserEvents();
      ref
          .read(eventsControllerProvider.notifier)
          .updateCurrentDay(currentDay.add(const Duration(days: -1)));
      ref.read(loadingTextProvider.notifier).reset();
    } catch (e) {
      ref.read(loadingTextProvider.notifier).reset();
      navigatorKey.currentState!.pop();
      debugPrint(e.toString());
    }
  }

  Future<void> moveToCreatedEvent() async {
    ref.read(eventsControllerProvider.notifier).updateLoadingState(true);
    try {
      final currentDay = ref.read(eventsControllerProvider.notifier).currentDay;
      ref
          .read(eventsControllerProvider.notifier)
          .updateCurrentDay(currentDay.add(const Duration(days: 1)));
      final image = NetworkImage(state.bannerPath);
      final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(image);
      final dominantColor = generator.dominantColor?.color;
      ref.read(loadingTextProvider.notifier).updateLoadingText("Getting event details...");
      final updatedEvent = await ref.read(dbServicesProvider).getEventDetails(state.id);
      ref.read(loadingTextProvider.notifier).reset();
      showSnackBar(message: "Event created successfully");
      Map<String, dynamic> args = {
        'event': updatedEvent,
        'isPreview': false,
        'dominantColor': dominantColor ?? const Color(0xFF4a5759),
        'randInt': 0,
        'showBottomBar': true,
      };
      ref.read(loadingTextProvider.notifier).reset();
      ref.read(eventsControllerProvider.notifier).updateLoadingState(false);
      await navigatorKey.currentState!.pushReplacementNamed(
        EventDetailsPage.id,
        arguments: args,
      );
      await Future.delayed(const Duration(milliseconds: 800));
      ref
          .read(eventsControllerProvider.notifier)
          .updateCurrentDay(currentDay.add(const Duration(days: -1)));
      resetNewEvent();
    } catch (e) {
      debugPrint("Failed to move to created event: $e");
      ref.read(loadingTextProvider.notifier).reset();
      ref.read(eventsControllerProvider.notifier).updateLoadingState(false);
    }
  }

  void updateInterests(InterestModel interest) async {
    ref.read(homeTabControllerProvider.notifier).toggleHomeTabInterest(interest);
    final contains = ref.read(userProvider).interests.contains(interest.activity);
    if (!contains) {
      var interests = ref.read(userProvider).interests;
      interests.add(interest.activity);
      ref.read(userProvider).copyWith(interests: interests);
    }
    await ref.read(dioServicesProvider).updateUserInterests(
          UserInterestsUpdateModel(
            userId: ref.read(userProvider).id,
            interests: ref
                .read(homeTabControllerProvider)
                .currentInterests
                .map((e) => e.activity)
                .toList(),
          ),
        );
  }

  String formatWithSuffix(DateTime date) {
    String dayOfMonth = DateFormat('d').format(date);
    String suffix;
    if (dayOfMonth.endsWith('1') && dayOfMonth != '11') {
      suffix = 'st';
    } else if (dayOfMonth.endsWith('2') && dayOfMonth != '12') {
      suffix = 'nd';
    } else if (dayOfMonth.endsWith('3') && dayOfMonth != '13') {
      suffix = 'rd';
    } else {
      suffix = 'th';
    }
    return DateFormat('d\'$suffix\' MMMM, y').format(date);
  }

  void resetNewEvent() {
    state = EventModel(
        id: ref.read(userProvider).id,
        title: "",
        location: "",
        date: DateTime.now().toString(),
        startTime: "",
        endTime: "",
        attendees: 0,
        category: 'Please select',
        isFavorite: false,
        bannerPath: "",
        iconPath: allInterests.first.iconUrl,
        about: "",
        hostId: ref.read(userProvider).id,
        hostName: ref.read(userProvider).name,
        hostPic: ref.read(userProvider).imageUrl,
        capacity: 10,
        isPrivate: true,
        imageUrls: [],
        privateGuestList: false,
        eventMembers: [],
        status: "nothing",
        userDeviceToken: "",
        hyperlinks: [],
        members: 0,
        groupName: 'zipbuzz-null');
    eventInvites = [];
    bannerImage = null;
    urlControllers = [TextEditingController()];
    urlNameControllers = [TextEditingController()];
  }
}
