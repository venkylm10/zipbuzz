import 'package:flutter/material.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';

class CreateEventGuestList extends StatefulWidget {
  const CreateEventGuestList({super.key});

  @override
  State<CreateEventGuestList> createState() => _CreateEventGuestListState();
}

class _CreateEventGuestListState extends State<CreateEventGuestList> {
  bool isPrivate = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Guest list",
          style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            setState(() {
              isPrivate = !isPrivate;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.bgGrey,
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: Row(
              children: [
                Radio(
                  value: true,
                  groupValue: isPrivate,
                  toggleable: true,
                  activeColor: AppColors.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      isPrivate = !isPrivate;
                    });
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Make guest list public", style: AppStyles.h4),
                    Text(
                      "Anyone can view the guest list",
                      style: AppStyles.h5
                          .copyWith(color: AppColors.lightGreyColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Default:",
                style: AppStyles.h4.copyWith(
                  color: AppColors.primaryColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
              TextSpan(
                text: " Private (only you can see it)",
                style: AppStyles.h4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
