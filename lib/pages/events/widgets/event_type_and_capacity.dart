import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/pages/events/widgets/guest_list_type.dart';

class EventTypeAndCapacity extends ConsumerStatefulWidget {
  const EventTypeAndCapacity({super.key, this.rePublish = false});
  final bool rePublish;

  @override
  ConsumerState<EventTypeAndCapacity> createState() => _EventTypeAndCapacityState();
}

class _EventTypeAndCapacityState extends ConsumerState<EventTypeAndCapacity> {
  int newCapacity = 10;
  var newIsPrivate = false;
  final capacityController = TextEditingController();
  late NewEvent newEvent;
  late EditEventController editEventController;

  void updateEventType(bool value) {
    if (widget.rePublish) {
      editEventController.updateEventType(value);
      return;
    }
    newEvent.updateEventType(value);
  }

  void increaseCapacity() {
    if (widget.rePublish) {
      editEventController.increaseCapacity();
    }
    newEvent.increaseCapacity();
  }

  void decreaseCapacity() {
    if (widget.rePublish) {
      editEventController.decreaseCapacity();
    }
    newEvent.decreaseCapacity();
  }

  void onChange(String value) {
    if (value.isEmpty) {
      capacityController.text = 0.toString();
    } else {
      capacityController.text = newCapacity.toString();
    }
    if (widget.rePublish) {
      editEventController.onChangeCapacity(value);
    }
    newEvent.onChangeCapacity(value);
  }

  @override
  void initState() {
    editEventController = ref.read(editEventControllerProvider.notifier);
    newEvent = ref.read(newEventProvider.notifier);
    capacityController.text = newCapacity.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    newCapacity = widget.rePublish
        ? ref.watch(editEventControllerProvider).capacity
        : ref.watch(newEventProvider).capacity;
    newIsPrivate = widget.rePublish
        ? ref.watch(editEventControllerProvider).isPrivate
        : ref.watch(newEventProvider).isPrivate;
    capacityController.text = newCapacity.toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   "Type & Capacity",
        //   style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
        // ),
        // const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => updateEventType(false),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.bgGrey,
                    border: Border.all(
                        color: newIsPrivate ? AppColors.borderGrey : AppColors.primaryColor),
                  ),
                  child: Row(
                    children: [
                      Radio(
                        value: false,
                        groupValue: newIsPrivate,
                        activeColor: AppColors.primaryColor,
                        onChanged: (value) {
                          updateEventType(false);
                        },
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Public event", style: AppStyles.h4),
                          Text(
                            "Open to All",
                            style: AppStyles.h5.copyWith(
                              color: AppColors.lightGreyColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () => updateEventType(true),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.bgGrey,
                    border: Border.all(
                      color: !newIsPrivate ? AppColors.borderGrey : AppColors.primaryColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Radio(
                        value: true,
                        groupValue: newIsPrivate,
                        activeColor: AppColors.primaryColor,
                        onChanged: (value) {
                          updateEventType(true);
                        },
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Private event", style: AppStyles.h4),
                          Text(
                            "By Invitation Only",
                            style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (newIsPrivate)
          CreateEventGuestListType(
            rePublish: widget.rePublish,
          ),
        if (newIsPrivate) const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Event capacity", style: AppStyles.h4),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGrey),
                color: AppColors.bgGrey,
              ),
              child: SizedBox(
                width: kIsWeb
                    ? MediaQuery.of(context).size.height * Assets.images.border_ratio * 0.4
                    : MediaQuery.of(context).size.width * .4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: decreaseCapacity,
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(Icons.remove_rounded),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: capacityController,
                        cursorColor: AppColors.primaryColor,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        onChanged: (value) => onChange(value),
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
                      ),
                    ),
                    InkWell(
                      onTap: increaseCapacity,
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(Icons.add_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
