import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/pages/settings/faqs_page.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

class SettingsTiles extends StatelessWidget {
  const SettingsTiles({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Settings",
          style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderGrey),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              buildSettingsTile(
                "FAQs",
                Assets.icons.faqs,
                onTap: () => navigatorKey.currentState!.pushNamed(FAQsPage.id),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Divider(
                  color: AppColors.borderGrey.withOpacity(0.5),
                  height: 1,
                ),
              ),
              buildSettingsTile(
                "Notification",
                Assets.icons.notifications_settings,
                onTap: showSnackBar,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Divider(
                  color: AppColors.borderGrey.withOpacity(0.5),
                  height: 1,
                ),
              ),
              buildSettingsTile(
                "Terms & Conditions",
                Assets.icons.tnc,
                onTap: showSnackBar,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Divider(
                  color: AppColors.borderGrey.withOpacity(0.5),
                  height: 1,
                ),
              ),
              buildSettingsTile(
                "Privacy Policy",
                Assets.icons.privacy_policy,
                onTap: showSnackBar,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Padding buildSettingsTile(String label, String iconPath,
      {void Function()? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            SvgPicture.asset(iconPath, height: 20),
            const SizedBox(width: 8),
            Text(label, style: AppStyles.h4),
            const Spacer(),
            const Icon(Icons.arrow_right_rounded)
          ],
        ),
      ),
    );
  }
}
