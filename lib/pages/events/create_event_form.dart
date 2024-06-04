import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:interval_time_picker/interval_time_picker.dart';
import 'package:interval_time_picker/models/visible_step.dart';
import 'package:intl/intl.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/widgets/common/broad_divider.dart';
import 'package:zipbuzz/widgets/common/custom_text_field.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

class CreateEventForm extends ConsumerStatefulWidget {
  const CreateEventForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreateEventFormState();
}

class _CreateEventFormState extends ConsumerState<CreateEventForm> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController dateController;
  late TextEditingController locationController;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;
  DateTime date = DateTime.now();
  late NewEvent newEventController;
  DateTime? startTime;
  DateTime? endTime;

  @override
  void initState() {
    initialise();
    super.initState();
  }

  void initialise() {
    newEventController = ref.read(newEventProvider.notifier);
    nameController = TextEditingController();
    nameController.text = ref.read(newEventProvider).title;
    descriptionController = TextEditingController();
    descriptionController.text = ref.read(newEventProvider).about;
    dateController = TextEditingController();
    dateController.text = DateFormat('d\'th,\' MMMM (EEEE)').format(date);
    locationController = TextEditingController();
    locationController.text = ref.read(newEventProvider).location;
    startTimeController = TextEditingController();
    startTimeController.text = ref.read(newEventProvider).startTime;
    endTimeController = TextEditingController();
    endTimeController.text = ref.read(newEventProvider).endTime;
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

  void updateEventName(String value) {
    newEventController.updateName(value);
  }

  void updateCategory({String? category = 'Hiking'}) {
    newEventController.updateCategory(category!);
  }

  void updateDescription(String value) {
    newEventController.updateDescription(value);
  }

  void updateLocation(String value) {
    newEventController.updateLocation(value);
  }

  void updateUrl(String value) {
    // newEventController.updateUrl(value);
  }

  void updateDate() async {
    date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.utc(2026),
        ) ??
        DateTime.now();
    newEventController.updateDate(date);
    dateController.text = DateFormat('d\'th,\' MMMM (EEEE)').format(date);
    setState(() {});
  }

  void updateTime({bool isEnd = false}) async {
    if (isEnd) {
      if (startTime == null) {
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
    if (time != null) {
      final dt = ref
          .read(eventsControllerProvider.notifier)
          .currentDay
          .copyWith(hour: time.hour, minute: time.minute);
      final now = DateTime.now();
      if (dt.isBefore(now)) {
        showSnackBar(message: "Choose a ahead time");
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
      newEventController.updateTime(time, isEnd: isEnd);
      final formatedTime = newEventController.getTimeFromTimeOfDay(time);
      if (isEnd) {
        endTimeController.text = formatedTime;
      } else {
        startTimeController.text = formatedTime;
      }
      setState(() {});
    }
  }

  void getNewEvent() {
    final dummy = ref.watch(newEventProvider);
    nameController.text = dummy.title;
    descriptionController.text = dummy.about;
    date = DateTime.parse(dummy.date);
    locationController.text = dummy.location;
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
            Text("Event title", style: AppStyles.h4),
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
          onChanged: updateEventName,
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Event description",
                style: AppStyles.h4,
              ),
              TextSpan(
                text: "*",
                style: AppStyles.h4.copyWith(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        CustomTextField(
          controller: descriptionController,
          hintText: "Event description",
          maxLines: 5,
          onChanged: updateDescription,
        ),
        const SizedBox(height: 16),
        buildUrlFields(),
        // broadDivider(),
        // Text(
        //   "Location & Time",
        //   style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
        // ),
        Row(
          children: [
            Text("Enter venue/location", style: AppStyles.h4),
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
            updateLocation(value);
          },
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
                ref.read(newEventProvider.notifier).urlControllers.length,
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
                                controller:
                                    ref.read(newEventProvider.notifier).urlNameControllers[index],
                                hintText: "HyperLink Name",
                                onChanged: updateUrl,
                              ),
                              const SizedBox(height: 4),
                              CustomTextField(
                                controller:
                                    ref.read(newEventProvider.notifier).urlControllers[index],
                                hintText: "URL",
                                onChanged: updateUrl,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            ref.read(newEventProvider.notifier).removeUrlField(index);
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
                ref.read(newEventProvider.notifier).addUrlField();
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
    interests.sort((a, b) => a.compareTo(b));
    for (var e in allInterests) {
      if (!interests.contains(e.activity)) {
        interests.add(e.activity);
      }
    }
    final category = ref.watch(newEventProvider).category;
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
        onSaved: (newValue) => updateCategory(category: newValue),
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
        items: ['Please select', ...interests]
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Row(
                  children: [
                    Text(e),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: (value) => updateCategory(category: value),
      ),
    );
  }
}
