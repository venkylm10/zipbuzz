import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/user/user_model.dart';
import 'package:zipbuzz/pages/profile/edit_profile_page.dart';
import 'package:zipbuzz/services/auth_services.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';
import 'package:zipbuzz/widgets/profile/settings.dart';
import 'package:zipbuzz/widgets/profile/socials.dart';
import 'package:zipbuzz/widgets/profile/user_stats.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  var isMounted = true;
  void editProfile(UserModel user) async {
    await navigatorKey.currentState!.pushNamed(EditProfilePage.id, arguments: {"user": user});
    if (isMounted) {
      setState(() {});
    }
  }

  void logOut() async {
    await ref.read(authServicesProvider).signOut();
    showSnackBar(message: "Logged out successfully!");
  }

  @override
  void dispose() {
    isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    return PopScope(
      canPop: false,
      onPopInvoked: (value) => ref.read(homeTabControllerProvider.notifier).backToHomeTab(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Profile",
            style: AppStyles.h2.copyWith(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          leading: const SizedBox(),
          elevation: 0,
          actions: [
            GestureDetector(
              onTap: () => editProfile(user),
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderGrey),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Row(
                    children: [
                      SvgPicture.asset(Assets.icons.edit, height: 16),
                      const SizedBox(width: 4),
                      Text(
                        "Edit",
                        style: AppStyles.h5.copyWith(color: AppColors.greyColor),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: AppStyles.h1.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user.handle,
                          style: AppStyles.h4.copyWith(color: AppColors.greyColor),
                        ),
                        const SizedBox(height: 8),
                        if (user.isAmbassador) buildAmbassadorTag(),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: Image.network(
                        user.imageUrl,
                        height: 72,
                        width: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const UserStats(),
                const SizedBox(height: 24),
                Divider(color: AppColors.borderGrey.withOpacity(0.5), height: 1),
                const SizedBox(height: 24),
                Text(
                  "Personal details",
                  style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
                ),
                const SizedBox(height: 16),
                buildDetailTile(Assets.icons.geo_mini, "Zipcode:", user.zipcode),
                const SizedBox(height: 4),
                buildDetailTile(Assets.icons.telephone, "Mobile no:", user.mobileNumber),
                const SizedBox(height: 4),
                buildDetailTile(Assets.icons.at, "ZipBuzz handle:", user.handle, handle: true),
                const SizedBox(height: 24),
                Divider(color: AppColors.borderGrey.withOpacity(0.5), height: 1),
                const SizedBox(height: 24),
                // User social links
                const UserSocials(),
                const SizedBox(height: 24),
                Divider(color: AppColors.borderGrey.withOpacity(0.5), height: 1),
                const SizedBox(height: 24),
                Text(
                  "My Interests",
                  style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
                ),
                const SizedBox(height: 16),
                buildInterests(user, ref),
                const SizedBox(height: 24),
                Divider(color: AppColors.borderGrey.withOpacity(0.5), height: 1),
                const SizedBox(height: 24),
                Text(
                  "About me",
                  style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
                ),
                const SizedBox(height: 16),
                Text(
                  user.about,
                  style: AppStyles.h4,
                ),
                const SizedBox(height: 24),
                Divider(color: AppColors.borderGrey.withOpacity(0.5), height: 1),
                const SizedBox(height: 24),
                const SettingsTiles(),
                const SizedBox(height: 24),
                InkWell(
                  onTap: () => logOut(),
                  child: Ink(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppColors.borderGrey, borderRadius: BorderRadius.circular(24)),
                    child: Center(
                      child: Text(
                        "Log out",
                        style: AppStyles.h3.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container buildAmbassadorTag() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            Assets.icons.check,
            colorFilter: const ColorFilter.mode(
              AppColors.primaryColor,
              BlendMode.srcIn,
            ),
            height: 20,
          ),
          const SizedBox(width: 5),
          Text(
            "Brand Ambassador",
            style: AppStyles.h5.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Wrap buildInterests(UserModel user, WidgetRef ref) {
    final interests = ref.watch(userProvider).interests;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: interests.map(
        (e) {
          final iconPath = allInterests[e]!;
          final color = getInterestColor(iconPath);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: getInterestColor(iconPath).withOpacity(0.1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(iconPath, height: 16),
                const SizedBox(width: 8),
                Text(
                  e,
                  style: AppStyles.h4.copyWith(color: color),
                ),
              ],
            ),
          );
        },
      ).toList(),
    );
  }

  Row buildDetailTile(String iconPath, String label, String value, {bool handle = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          iconPath,
          colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          height: 24,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppStyles.h4,
        ),
        const Expanded(child: SizedBox()),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGrey),
          ),
          child: Row(
            children: [
              if (handle)
                Text(
                  "@",
                  style: AppStyles.h4.copyWith(color: AppColors.lightGreyColor),
                ),
              Text(value, style: AppStyles.h4),
            ],
          ),
        ),
      ],
    );
  }
}
