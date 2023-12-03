import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/controllers/user_controller.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

class AddHosts extends ConsumerWidget {
  const AddHosts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    // final newEvent = ref.watch(newEventProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hosts & Co-hosts",
          style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: AppColors.greyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.network(
                    user.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                user.name,
                style: AppStyles.h5,
              ),
              const Expanded(child: SizedBox()),
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "Host",
                    style: AppStyles.h5.copyWith(color: AppColors.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        // ListView.builder(
        //     itemCount: newEvent.coHosts.length,
        //     shrinkWrap: true,
        //     scrollDirection: Axis.vertical,
        //     itemBuilder: (context, index) {
        //       final cohost = newEvent.coHosts[index];
        //       return Padding(
        //         padding: const EdgeInsets.only(bottom: 8.0),
        //         child: Row(
        //           crossAxisAlignment: CrossAxisAlignment.center,
        //           children: [
        //             Container(
        //               height: 32,
        //               width: 32,
        //               decoration: BoxDecoration(
        //                 color: AppColors.greyColor.withOpacity(0.1),
        //                 borderRadius: BorderRadius.circular(16),
        //               ),
        //               child: ClipRRect(
        //                 borderRadius: BorderRadius.circular(16),
        //                 child: Container(
        //                   height: 32,
        //                   width: 32,
        //                   decoration: BoxDecoration(
        //                     color: AppColors.greyColor.withOpacity(0.1),
        //                     borderRadius: BorderRadius.circular(16),
        //                   ),
        //                   child: Image.network(
        //                     cohost.imageUrl,
        //                     fit: BoxFit.cover,
        //                   ),
        //                 ),
        //               ),
        //             ),
        //             const SizedBox(width: 8),
        //             Text(
        //               cohost.name,
        //               style: AppStyles.h5,
        //             ),
        //             const Expanded(child: SizedBox()),
        //             GestureDetector(
        //               onTap: showSnackBar,
        //               child: Container(
        //                 height: 32,
        //                 padding: const EdgeInsets.symmetric(horizontal: 6),
        //                 decoration: BoxDecoration(
        //                   color: AppColors.borderGrey,
        //                   borderRadius: BorderRadius.circular(8),
        //                 ),
        //                 child: Center(
        //                   child: Row(
        //                     children: [
        //                       Text(
        //                         "Co-host",
        //                         style: AppStyles.h5,
        //                       ),
        //                       const SizedBox(width: 8),
        //                       SvgPicture.asset(
        //                         Assets.icons.remove,
        //                         colorFilter: const ColorFilter.mode(
        //                           AppColors.textColor,
        //                           BlendMode.srcIn,
        //                         ),
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //       );
        //     }),
        GestureDetector(
          onTap: showSnackBar,
          child: Container(
            height: 44,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.bgGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(Assets.icons.add_circle, height: 20),
                const SizedBox(width: 8),
                Text(
                  "Add Co-host",
                  style: AppStyles.h4.copyWith(
                    color: AppColors.greyColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
