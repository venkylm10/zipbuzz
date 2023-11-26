import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/widgets/home/custom_calendar.dart';

class ProfileTab extends StatelessWidget {
  ProfileTab({super.key});
  List<String> myInterests = ['Hiking', 'Sports', 'Dance', 'Wine Tasting'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Container(
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
                        "Alex Lee",
                        style:
                            AppStyles.h1.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "@bealexlee",
                        style:
                            AppStyles.h4.copyWith(color: AppColors.greyColor),
                      ),
                      const SizedBox(height: 8),
                      Container(
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
                      ),
                    ],
                  ),
                  Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: Image.asset(
                      Assets.images.profile,
                      height: 72,
                      width: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              buildStats(),
              const SizedBox(height: 24),
              Divider(color: AppColors.borderGrey.withOpacity(0.5), height: 1),
              const SizedBox(height: 24),
              Text(
                "Personal details",
                style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
              ),
              const SizedBox(height: 16),
              buildDetailTile(Assets.icons.geo_mini, "Zipcode:", "444444"),
              const SizedBox(height: 4),
              buildDetailTile(
                  Assets.icons.telephone, "Mobile no:", "(408) 238-3322"),
              const SizedBox(height: 4),
              buildDetailTile(Assets.icons.at, "ZipBuzz handle:", "bealexlee",
                  handle: true),
              const SizedBox(height: 24),
              Divider(color: AppColors.borderGrey.withOpacity(0.5), height: 1),
              const SizedBox(height: 24),
              Text(
                "Social Links",
                style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
              ),
              const SizedBox(height: 16),
              buildHyperLink(Assets.icons.linkedin, "LinkedIn", "444-444"),
              const SizedBox(height: 4),
              buildHyperLink(
                  Assets.icons.instagram, "Instagram", "(408) 238-3322"),
              const SizedBox(height: 4),
              buildHyperLink(Assets.icons.twitter, "Twitter", "bealexlee"),
              const SizedBox(height: 24),
              Divider(color: AppColors.borderGrey.withOpacity(0.5), height: 1),
              const SizedBox(height: 24),
              Text(
                "My Interests",
                style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
              ),
              const SizedBox(height: 16),
              buildInterests(),
              const SizedBox(height: 24),
              Divider(color: AppColors.borderGrey.withOpacity(0.5), height: 1),
              const SizedBox(height: 24),
              Text(
                "About me",
                style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
              ),
              const SizedBox(height: 16),
              Text(
                "I'm here to ensure that your experience is nothing short of extraordinary. With a passion for creating unforgettable moments and a knack for connecting with people, I thrive on the energy of the event and the joy it brings to all attendees. I'm your go-to person for any questions, assistance, or just a friendly chat.\nMy commitment is to make you feel welcome, entertained, and truly part of the event's magic. So, let's embark on this exciting journey together, and I promise you won't leave without a smile and wonderful memories to cherish.",
                style: AppStyles.h4,
              ),
              const SizedBox(height: 24),
              Divider(color: AppColors.borderGrey.withOpacity(0.5), height: 1),
              const SizedBox(height: 24),
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
                    buildSettingsTile("FAQs", Assets.icons.faqs),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Divider(
                        color: AppColors.borderGrey.withOpacity(0.5),
                        height: 1,
                      ),
                    ),
                    buildSettingsTile(
                        "Notification", Assets.icons.notifications_settings),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Divider(
                        color: AppColors.borderGrey.withOpacity(0.5),
                        height: 1,
                      ),
                    ),
                    buildSettingsTile("Terms & Conditions", Assets.icons.tnc),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Divider(
                        color: AppColors.borderGrey.withOpacity(0.5),
                        height: 1,
                      ),
                    ),
                    buildSettingsTile(
                        "Privacy Policy", Assets.icons.privacy_policy),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                child: Ink(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppColors.borderGrey,
                      borderRadius: BorderRadius.circular(24)),
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
    );
  }

  Padding buildSettingsTile(String label, String iconPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        children: [
          SvgPicture.asset(iconPath, height: 20),
          const SizedBox(width: 8),
          Text(label, style: AppStyles.h4),
          const Spacer(),
          const Icon(Icons.arrow_right_rounded)
        ],
      ),
    );
  }

  Wrap buildInterests() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: myInterests.map(
        (e) {
          final iconPath = interests[e]!;
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

  Row buildDetailTile(String iconPath, String label, String value,
      {bool handle = false}) {
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

  Row buildHyperLink(String iconPath, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          iconPath,
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
              Text(
                value,
                style: AppStyles.h4.copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(width: 8),
              SvgPicture.asset(Assets.icons.follow_link, height: 16)
            ],
          ),
        ),
      ],
    );
  }

  Container buildStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.bgGrey,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          SvgPicture.asset(Assets.icons.hosts, height: 40),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "8",
                style: AppStyles.h3.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                "Events hosted",
                style: AppStyles.h6.copyWith(
                  color: AppColors.lightGreyColor,
                ),
              )
            ],
          ),
          const Expanded(child: SizedBox()),
          Container(
            height: 24,
            width: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.borderGrey,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(1),
              ),
            ),
          ),
          SvgPicture.asset(Assets.icons.rating, height: 40),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "4.5",
                style: AppStyles.h3.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                "Host rating",
                style: AppStyles.h6.copyWith(
                  color: AppColors.lightGreyColor,
                ),
              )
            ],
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}
