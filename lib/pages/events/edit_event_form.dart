import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:interval_time_picker/interval_time_picker.dart';
import 'package:interval_time_picker/models/visible_step.dart';
import 'package:intl/intl.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/widgets/common/broad_divider.dart';
import 'package:zipbuzz/widgets/common/custom_text_field.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

class EditEventForm extends ConsumerStatefulWidget {
  const EditEventForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreateEventFormState();
}

class _CreateEventFormState extends ConsumerState<EditEventForm> {
  Color eventColor = Colors.white;
  String category = allInterests.first.activity;
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController dateController;
  late TextEditingController locationController;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;
  DateTime date = DateTime.now();
  late EditEventController editEventController;
  late TextEditingController urlController;
  DateTime? startTime;
  DateTime? endTime;

  @override
  void initState() {
    editEventController = ref.read(editEventControllerProvider.notifier);
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    dateController = TextEditingController();
    locationController = TextEditingController();
    startTimeController = TextEditingController();
    endTimeController = TextEditingController();
    urlController = TextEditingController();
    extractTimeFromEventDetails();
    getEventDetails();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    locationController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }

  void updateDate() async {
    final chosenDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.utc(2026),
    );
    FocusScope.of(navigatorKey.currentContext!).unfocus();
    if (chosenDate == null) return;
    date = chosenDate;
    editEventController.updateDate(date);
    extractTimeFromEventDetails();
    dateController.text = DateFormat('d\'th,\' MMMM (EEEE)').format(date);
    setState(() {});
    FocusScope.of(navigatorKey.currentContext!).unfocus();
  }

  DateTime extractTime(String time) {
    final hr = int.parse(time.split(":")[0]);
    final min = int.parse(time.split(":")[1].split(" ")[0]);
    final pm = time.split(' ').last == 'PM';
    final eventDate = DateTime.parse(ref.read(editEventControllerProvider).date);
    if (pm && hr != 12) {
      final dateTime = eventDate.copyWith(hour: hr + 12, minute: min);
      return dateTime;
    } else if (!pm && hr == 12) {
      final dateTime = eventDate.copyWith(hour: 0, minute: min);
      return dateTime;
    }
    final dateTime = eventDate.copyWith(hour: hr, minute: min);
    return dateTime;
  }

  void extractTimeFromEventDetails() {
    final event = ref.read(editEventControllerProvider);
    if (event.startTime != "null") {
      startTime = extractTime(event.startTime);
    }
    if (event.endTime != "null") {
      endTime = extractTime(event.endTime);
    }
  }

  void updateTime({bool isEnd = false}) async {
    if (isEnd) {
      if (startTime == null) {
        FocusScope.of(navigatorKey.currentContext!).unfocus();
        showSnackBar(message: "Please select start time first");
        return;
      }
    }
    final currentTime = TimeOfDay.fromDateTime(DateTime.now());
    var time = await showIntervalTimePicker(
      context: context,
      initialTime: currentTime.replacing(minute: currentTime.minute - (currentTime.minute % 5)),
      interval: 5,
      visibleStep: VisibleStep.fifths,
    );
    FocusScope.of(navigatorKey.currentContext!).unfocus();
    if (time != null) {
      final currentDate = DateTime.parse(ref.read(editEventControllerProvider).date);
      final dt = currentDate.copyWith(hour: time.hour, minute: time.minute);
      final now = DateTime.now();
      if (dt.isBefore(now)) {
        showSnackBar(message: "Choose time ahead");
        return;
      }

      if (isEnd) {
        endTime = dt;
        if (endTime!.isBefore(startTime!)) {
          showSnackBar(message: "End time should be after start time");
          return;
        }
      } else {
        startTime = dt;
      }
      ref.read(editEventControllerProvider.notifier).updateTime(time, isEnd: isEnd);
      final formatedTime = editEventController.getTimeFromTimeOfDay(time);
      if (isEnd) {
        endTimeController.text = formatedTime;
      } else {
        startTimeController.text = formatedTime;
      }
      setState(() {});
      FocusScope.of(navigatorKey.currentContext!).unfocus();
    }
  }

  void convertDateString() {
    DateTime date = DateTime.parse(ref.read(editEventControllerProvider).date);
    final DateFormat formatter = DateFormat('d\'th,\' MMMM (EEEE)');
    String formattedDate = formatter.format(date);
    dateController.text = formattedDate;
  }

  void getEventDetails() {
    final event = ref.read(editEventControllerProvider);
    nameController.text = event.title;
    descriptionController.text = event.about;
    date = DateTime.parse(event.date);
    locationController.text = event.location;
    category = ref.read(editEventControllerProvider).category;
    startTimeController.text = event.startTime;
    endTimeController.text = event.endTime != "null" ? event.endTime : "";
    convertDateString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   "Category",
        //   style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
        // ),
        // const SizedBox(height: 16),
        Row(
          children: [
            Text("Event category", style: AppStyles.h4),
            Text(
              "*",
              style: AppStyles.h4.copyWith(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 4),
        categoryDropDown(),
        // broadDivider(),
        // Text(
        //   "Title & Description",
        //   style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
        // ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text("Event name", style: AppStyles.h4),
            Text(
              "*",
              style: AppStyles.h4.copyWith(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 4),
        CustomTextField(
          controller: nameController,
          hintText: "eg: A madcap house party",
          onChanged: (value) {
            editEventController.updateName(value);
          },
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text("Event description", style: AppStyles.h4),
            Text(
              "*",
              style: AppStyles.h4.copyWith(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 4),
        CustomTextField(
          controller: descriptionController,
          hintText: "Event description",
          maxLines: 5,
          onChanged: (value) {
            editEventController.updateDescription(value);
          },
        ),
        const SizedBox(height: 16),
        buildUrlFields(),
        const SizedBox(height: 16),
        Row(
          children: [
            Text("Enter venue location", style: AppStyles.h4),
            Text(
              "*",
              style: AppStyles.h4.copyWith(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 4),
        CustomTextField(
          controller: locationController,
          hintText: "eg: 420 Gala St, San Jose 95125",
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: SvgPicture.asset(Assets.icons.geo_mini, height: 20),
          ),
          enabled: true,
          onChanged: (value) {
            editEventController.updateLocation(value);
          },
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text("Choose date", style: AppStyles.h4),
            Text(
              "*",
              style: AppStyles.h4.copyWith(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () {
            updateDate();
          },
          child: CustomTextField(
            controller: dateController,
            hintText: "eg: 25th, December (Friday)",
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: SvgPicture.asset(Assets.icons.calendar, height: 20),
            ),
            enabled: false,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text("Start Time", style: AppStyles.h4),
                  Text(
                    "*",
                    style: AppStyles.h4.copyWith(color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text("End Time", style: AppStyles.h4),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            // start time
            Expanded(
              child: InkWell(
                onTap: () {
                  updateTime();
                },
                child: CustomTextField(
                  controller: startTimeController,
                  hintText: "8:00 PM",
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SvgPicture.asset(Assets.icons.clock, height: 20),
                  ),
                  enabled: false,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // end time
            Expanded(
              child: InkWell(
                onTap: () {
                  updateTime(isEnd: true);
                },
                child: CustomTextField(
                  controller: endTimeController,
                  hintText: "12:00 PM",
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SvgPicture.asset(Assets.icons.clock, height: 20),
                  ),
                  enabled: false,
                  textInputAction: TextInputAction.done,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildUrlFields() {
    return Consumer(
      builder: (context, ref, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Event url",
              style: AppStyles.h4,
            ),
            const SizedBox(height: 4),
            Column(
              children: List.generate(
                ref.read(editEventControllerProvider.notifier).urlControllers.length,
                (index) => Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                                controller: ref
                                    .read(editEventControllerProvider.notifier)
                                    .urlNameControllers[index],
                                hintText: "HyperLink Name",
                              ),
                              const SizedBox(height: 4),
                              CustomTextField(
                                controller: ref
                                    .read(editEventControllerProvider.notifier)
                                    .urlControllers[index],
                                hintText: "URL",
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            ref.read(editEventControllerProvider.notifier).removeUrlField(index);
                            setState(() {});
                          },
                          child: SvgPicture.asset(
                            Assets.icons.delete_fill,
                            height: 36,
                            colorFilter: const ColorFilter.mode(
                              AppColors.greyColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    broadDivider(gap: 16),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                ref.read(editEventControllerProvider.notifier).addUrlField();
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.bgGrey,
                  border: Border.all(
                    color: AppColors.borderGrey,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(Assets.icons.add_circle, height: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Add URL",
                      style: AppStyles.h4,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Container categoryDropDown() {
    var interests =
        ref.read(homeTabControllerProvider).currentInterests.map((e) => e.activity).toList();
    for (var e in allInterests) {
      if (!interests.contains(e.activity)) {
        interests.add(e.activity);
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.bgGrey,
        border: Border.all(
          color: AppColors.borderGrey,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField(
        value: category,
        menuMaxHeight: 300,
        style: AppStyles.h4,
        hint: Text(
          "eg: Sports",
          style: AppStyles.h4.copyWith(
            color: AppColors.lightGreyColor,
          ),
        ),
        dropdownColor: AppColors.bgGrey,
        elevation: 1,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
        ),
        items: interests
            .map(
              (e) => DropdownMenuItem(
                onTap: () {
                  setState(() {
                    category = e;
                    ref.read(editEventControllerProvider.notifier).updateCategory(category);
                  });
                },
                value: e,
                child: Row(
                  children: [
                    Text(e),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          ref.read(editEventControllerProvider.notifier).updateCategory(value.toString());
        },
      ),
    );
  }

  Container buildCategoryChip() {
    final event = ref.read(editEventControllerProvider);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: eventColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            event.iconPath,
            height: 16,
          ),
          const SizedBox(width: 5),
          Text(
            event.category,
            style: AppStyles.h5.copyWith(color: eventColor),
          ),
        ],
      ),
    );
  }
}
