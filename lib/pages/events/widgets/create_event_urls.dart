import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/broad_divider.dart';
import 'package:zipbuzz/utils/widgets/custom_text_field.dart';

class CreateEventUrls extends StatelessWidget {
  final VoidCallback rebuild;
  const CreateEventUrls({super.key, required this.rebuild});

  @override
  Widget build(BuildContext context) {
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
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 4),
                              CustomTextField(
                                controller:
                                    ref.read(newEventProvider.notifier).urlControllers[index],
                                hintText: "URL",
                                textInputAction: TextInputAction.next,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            ref.read(newEventProvider.notifier).removeUrlField(index);
                            rebuild();
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
                rebuild();
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
}
