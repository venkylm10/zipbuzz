import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/pages/events/create_event_form.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({super.key});

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  String category = allInterests.entries.first.key;
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  @override
  void initState() {
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image picker
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.borderGrey,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Column(
                  children: [
                    SvgPicture.asset(
                      Assets.icons.gallery,
                      height: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tap to add image from gallery",
                      style: AppStyles.h5.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 40),
                Divider(color: AppColors.greyColor.withOpacity(0.2), height: 1),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "Choose from template",
                    style: AppStyles.h5.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const CreateEventForm(),
          const SizedBox(height: 32),
          Divider(color: AppColors.borderGrey.withOpacity(0.5), height: 1),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
