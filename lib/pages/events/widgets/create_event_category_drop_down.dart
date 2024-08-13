import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class CreateEventCategoryDropDown extends StatelessWidget {
  const CreateEventCategoryDropDown({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
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
          onSaved: (newValue) => ref.read(newEventProvider.notifier).updateCategory(newValue ?? allInterests.first.activity),
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
          onChanged: (value) => ref.read(newEventProvider.notifier).updateCategory(value ?? allInterests.first.activity),
        ),
      );
    });
  }
}
