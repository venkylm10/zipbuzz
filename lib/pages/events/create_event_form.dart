import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:interval_time_picker/interval_time_picker.dart';
import 'package:interval_time_picker/models/visible_step.dart';
import 'package:intl/intl.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/pages/events/widgets/create_event_category_drop_down.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/utils/widgets/custom_text_field.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

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

  void updateDate() async {
    FocusScope.of(navigatorKey.currentContext!).unfocus();
    final chosenDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.utc(2026),
    );
    FocusScope.of(navigatorKey.currentContext!).unfocus();
    if (chosenDate == null) return;
    date = chosenDate;
    newEventController.updateDate(date);
    dateController.text = DateFormat('d\'th,\' MMMM (EEEE)').format(date);
    setState(() {});
    FocusScope.of(navigatorKey.currentContext!).unfocus();
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
      final dateTimeString = ref.read(newEventProvider).date;
      final dt = DateTime.parse(dateTimeString).copyWith(hour: time.hour, minute: time.minute);
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
      FocusScope.of(navigatorKey.currentContext!).unfocus();
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
        _title("Event category", neccessary: true),
        const SizedBox(height: 4),
        const CreateEventCategoryDropDown(),
        const SizedBox(height: 16),
        _title("Event title", neccessary: true),
        const SizedBox(height: 4),
        CustomTextField(
          controller: nameController,
          hintText: "eg: A madcap house party",
          onChanged: updateEventName,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _title("Event description", neccessary: true),
        const SizedBox(height: 4),
        CustomTextField(
          controller: descriptionController,
          hintText: "Event description",
          maxLines: 5,
          onChanged: updateDescription,
        ),
        const SizedBox(height: 16),
        _title("Event venue/location", neccessary: true),
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
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 16),
        _title("Choose date", neccessary: true),
        const SizedBox(height: 4),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
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
            Expanded(child: _title("Start Time", neccessary: true)),
            const SizedBox(width: 8),
            Expanded(child: _title("End Time")),
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

  Widget _title(String title, {bool neccessary = false}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style: AppStyles.h4,
          ),
          if (neccessary)
            TextSpan(
              text: "*",
              style: AppStyles.h4.copyWith(color: Colors.red),
            ),
        ],
      ),
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
