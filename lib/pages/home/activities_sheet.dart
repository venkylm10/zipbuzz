import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/custom_text_field.dart';

class ActivitiesSheet extends StatefulWidget {
  final bool querySheet;
  const ActivitiesSheet({super.key, this.querySheet = false});

  @override
  State<ActivitiesSheet> createState() => _ActivitiesSheetState();
}

class _ActivitiesSheetState extends State<ActivitiesSheet> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return SizedBox(
      height: height * 0.85,
      width: kIsWeb ? height * Assets.images.border_ratio * 0.94 : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 4,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: widget.querySheet
                    ? const SizedBox()
                    : Text(
                        "Note: Select minimum of 3 interests",
                        style: AppStyles.h5.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ),
              InkWell(
                onTap: () {
                  navigatorKey.currentState!.pop();
                },
                child: Icon(
                  Icons.cancel,
                  color: AppColors.primaryColor.withOpacity(0.8),
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer(builder: (context, ref, child) {
              return CustomTextField(
                controller: ref.read(eventsControllerProvider).activitySearchController,
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SvgPicture.asset(
                    Assets.icons.searchBarIcon,
                    height: 28,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                borderRadius: 24,
                onChanged: (val) {
                  setState(() {});
                },
              );
            }),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Consumer(builder: (context, ref2, child) {
                final interests = allInterests
                    .where(
                      (element) => element.activity.toLowerCase().contains(
                            ref2
                                .read(eventsControllerProvider)
                                .activitySearchController
                                .text
                                .toLowerCase(),
                          ),
                    )
                    .toList();
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    crossAxisCount: 4,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(
                      interests.length,
                      (index) {
                        final interest = interests[index];
                        return Consumer(builder: (context, ref, child) {
                          final selected = ref
                              .watch(homeTabControllerProvider.notifier)
                              .containsInterest(interest.activity, querySheet: widget.querySheet);
                          return InkWell(
                            onTap: () {
                              if (widget.querySheet) {
                                ref
                                    .read(homeTabControllerProvider.notifier)
                                    .toggleQueryInterest(interest);
                              } else {
                                ref
                                    .read(homeTabControllerProvider.notifier)
                                    .toggleHomeTabInterest(interest);
                              }
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primaryColor.withOpacity(0.3)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    constraints: const BoxConstraints(minHeight: 50),
                                    child: Image.network(
                                      interest.iconUrl,
                                      height: 40,
                                    ),
                                  ),
                                  Text(
                                    interest.activity,
                                    softWrap: true,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: AppStyles.h5.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                      },
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
