import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/controllers/new_event_controller.dart';
import 'package:zipbuzz/widgets/common/broad_divider.dart';
import 'package:zipbuzz/widgets/common/custom_text_field.dart';

class CreateEventForm extends ConsumerStatefulWidget {
  const CreateEventForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateEventFormState();
}

class _CreateEventFormState extends ConsumerState<CreateEventForm> {
  String category = allInterests.entries.first.key;
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController dateController;
  late TextEditingController locationController;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;
  DateTime date = DateTime.now();
  late NewEvent newEvent;

  @override
  void initState() {
    newEvent = ref.read(newEventProvider.notifier);
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    dateController = TextEditingController();
    locationController = TextEditingController();
    startTimeController = TextEditingController();
    endTimeController = TextEditingController();
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

  void updateEventName(String value) {
    newEvent.updateName(value);
  }

  void updateCategory({String? category = 'Hiking'}) {
    newEvent.updateCategory(category!);
  }

  void updateDescription(String value) {
    newEvent.updateDescription(value);
  }

  void updateLocation(String value) {
    newEvent.updateLocation(value);
  }

  void updateDate() async {
    date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.utc(2026),
        ) ??
        DateTime.now();
    newEvent.updateDate(date.toString());
    dateController.text = DateFormat('d\'th\' MMMM (EEEE)').format(date);
    setState(() {});
  }

  void updateTime({bool? isEnd = false}) async {
    final time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) {
      var eventDate = DateTime.parse(ref.read(newEventProvider).date);
      final tempTime = DateTime(eventDate.year, eventDate.month, eventDate.day,
          time.hour, time.minute);
      final noon = tempTime.hour >= 12 ? true : false;
      if (isEnd!) {
        newEvent.updateTime(tempTime.toUtc().toString(), isEnd: true);
        endTimeController.text =
            "${tempTime.hour >= 13 ? tempTime.hour - 12 : tempTime.hour}:${tempTime.minute} ${noon ? "PM" : "AM"}";
      } else {
        newEvent.updateTime(tempTime.toUtc().toString());
        startTimeController.text =
            "${tempTime.hour >= 13 ? tempTime.hour - 12 : tempTime.hour}:${tempTime.minute} ${noon ? "PM" : "AM"}";
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
    category = ref.watch(newEventProvider).category;
  }

  @override
  Widget build(BuildContext context) {
    // getNewEvent();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Category",
          style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text("Event category", style: AppStyles.h4),
            Text(
              "*",
              style: AppStyles.h4.copyWith(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 16),
        categoryDropDown(),
        broadDivider(),
        Text(
          "Title & Description",
          style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
        ),
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
        const SizedBox(height: 16),
        CustomTextField(
          controller: nameController,
          hintText: "eg: A madcap house party",
          onChanged: updateEventName,
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
        const SizedBox(height: 16),
        CustomTextField(
          controller: descriptionController,
          hintText: "Event description",
          maxLines: 5,
          maxLength: 100,
          onChanged: updateDescription,
        ),
        broadDivider(),
        Text(
          "Location & Time",
          style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
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
        const SizedBox(height: 16),
        GestureDetector(
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
            Text("Enter venue location", style: AppStyles.h4),
            Text(
              "*",
              style: AppStyles.h4.copyWith(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: locationController,
          hintText: "eg: 420 Gala St, San Jose 95125",
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: SvgPicture.asset(Assets.icons.geo_mini, height: 20),
          ),
          enabled: true,
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
        const SizedBox(height: 16),
        Row(
          children: [
            // start time
            Expanded(
              child: GestureDetector(
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
              child: GestureDetector(
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

  Container categoryDropDown() {
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
        items: allInterests.entries
            .map(
              (e) => DropdownMenuItem(
                onTap: () {
                  setState(() {
                    category = e.key;
                  });
                },
                value: e.key,
                child: Row(
                  children: [
                    Text(e.key),
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
