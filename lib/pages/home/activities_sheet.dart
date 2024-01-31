import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
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
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(360),
            ),
            child: Text(
              "Select minimum of 5 interests",
              style: AppStyles.h5.copyWith(
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
