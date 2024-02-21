import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class ActivitiesSheet extends StatelessWidget {
  const ActivitiesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
              Text(
                "Note: Select minimum of 3 interests",
                style: AppStyles.h5.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Expanded(child: SizedBox()),
              GestureDetector(
                onTap: () {
                  navigatorKey.currentState!.pop();
                },
                child: Icon(
                  Icons.cancel,
                  color: AppColors.primaryColor.withOpacity(0.8),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                allInterests.length,
                (index) {
                  final interest = allInterests[index];
                  return Consumer(builder: (context, ref, child) {
                    // ignore: unused_local_variable
                    final homeTabController = ref.watch(homeTabControllerProvider);
                    final selected = ref
                        .watch(homeTabControllerProvider.notifier)
                        .containsInterest(interest.activity);
                    return GestureDetector(
                      onTap: () {
                        ref
                            .read(homeTabControllerProvider.notifier)
                            .toggleHomeTabInterest(interest);
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
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
