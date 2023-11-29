import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/controllers/user_controller.dart';
import 'package:zipbuzz/main.dart';
import 'package:zipbuzz/models/user_model.dart';
import 'package:zipbuzz/widgets/common/back_button.dart';
import 'package:zipbuzz/widgets/common/custom_text_field.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  static const id = "/profile/edit";
  const EditProfilePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late UserModel user;
  late TextEditingController nameController;
  late TextEditingController aboutController;
  late TextEditingController zipcodeController;
  late TextEditingController mobileController;
  late TextEditingController handleController;
  late TextEditingController linkedinIdControler;
  late TextEditingController instagramIdController;
  late TextEditingController twitterIdController;

  void updateInterest(String interest) {
    print("interest: $interest");
    if (user.interests.contains(interest)) {
      user.interests.remove(interest);
      setState(() {});
      return;
    }
    user.interests.add(interest);
    setState(() {});
  }

  void initialise() {
    user = ref.read(userProvider).getClone();
    nameController.text = user.name;
    aboutController.text = user.about;
    zipcodeController.text = user.zipcode;
    mobileController.text = user.mobileNumber;
    handleController.text = user.handle;
    linkedinIdControler.text = "linkedin.com/in/${user.linkedinId ?? ""}/";
    instagramIdController.text = "instagram.com/${user.instagramId ?? ""}";
    twitterIdController.text = "twitter.com/${user.twitterId ?? ""}";
  }

  void saveChanges() {
    ref.read(userProvider.notifier).update((state) => user);
    navigatorKey.currentState!.pop();
  }

  @override
  void initState() {
    nameController = TextEditingController();
    aboutController = TextEditingController();
    zipcodeController = TextEditingController();
    mobileController = TextEditingController();
    handleController = TextEditingController();
    linkedinIdControler = TextEditingController();
    instagramIdController = TextEditingController();
    twitterIdController = TextEditingController();
    initialise();
    super.initState();
  }

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
        leading: backButton(),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: showSnackBar,
                        // add image picker for profile editing page
                        child: SizedBox(
                          height: 120,
                          width: 120,
                          child: Stack(
                            children: [
                              Image.asset(user.imagePath),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  height: 32,
                                  width: 32,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.borderGrey,
                                        blurRadius: 1,
                                        spreadRadius: 2,
                                      )
                                    ],
                                  ),
                                  child: SvgPicture.asset(
                                    Assets.icons.edit,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
                              user.position,
                              style: AppStyles.h5.copyWith(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text("Name:", style: AppStyles.h4),
              const SizedBox(height: 4),
              CustomTextField(controller: nameController),
              const SizedBox(height: 8),
              Text("About me:", style: AppStyles.h4),
              const SizedBox(height: 4),
              CustomTextField(controller: aboutController, maxLength: 550),
              const SizedBox(height: 24),
              Divider(color: AppColors.borderGrey.withOpacity(0.5), height: 1),
              const SizedBox(height: 24),
              Text(
                "Personal details",
                style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
              ),
              const SizedBox(height: 16),
              Text("Zipcode:", style: AppStyles.h4),
              const SizedBox(height: 4),
              CustomTextField(
                controller: zipcodeController,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: SvgPicture.asset(Assets.icons.geo_mini, height: 20),
                ),
              ),
              const SizedBox(height: 8),
              Text("Mobile no:", style: AppStyles.h4),
              const SizedBox(height: 4),
              CustomTextField(
                controller: mobileController,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: SvgPicture.asset(Assets.icons.telephone, height: 20),
                ),
              ),
              const SizedBox(height: 8),
              Text("ZipBuzz handle:", style: AppStyles.h4),
              const SizedBox(height: 4),
              CustomTextField(
                controller: handleController,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: SvgPicture.asset(Assets.icons.at, height: 20),
                ),
                enabled: false,
              ),
              const SizedBox(height: 24),
              Divider(color: AppColors.borderGrey.withOpacity(0.5), height: 1),
              const SizedBox(height: 24),
              Text(
                "Social links",
                style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
              ),
              const SizedBox(height: 16),
              Text("LinkedIn", style: AppStyles.h4),
              const SizedBox(height: 4),
              CustomTextField(
                controller: linkedinIdControler,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Image.asset(Assets.icons.linkedin, height: 20),
                ),
              ),
              const SizedBox(height: 8),
              Text("Instagram", style: AppStyles.h4),
              const SizedBox(height: 4),
              CustomTextField(
                controller: instagramIdController,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Image.asset(Assets.icons.instagram, height: 20),
                ),
              ),
              const SizedBox(height: 8),
              Text("Twitter", style: AppStyles.h4),
              const SizedBox(height: 4),
              CustomTextField(
                controller: twitterIdController,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Image.asset(Assets.icons.twitter, height: 20),
                ),
              ),
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
              InkWell(
                onTap: showSnackBar,
                child: Ink(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(Assets.icons.delete),
                      const SizedBox(width: 8),
                      Text(
                        "Delete Account",
                        style: AppStyles.h3.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Divider(color: AppColors.borderGrey.withOpacity(0.5), height: 1),
              const SizedBox(height: 24),
              InkWell(
                onTap: saveChanges,
                child: Ink(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(Assets.icons.save),
                      const SizedBox(width: 8),
                      Text(
                        "Save Changes",
                        style: AppStyles.h3.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Wrap buildInterests() {
    final myInterests = user.interests;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allInterests.entries.map(
        (interest) {
          {
            final iconPath = interest.value;
            final color = getInterestColor(iconPath);
            final present = myInterests.contains(interest.key);
            return GestureDetector(
              onTap: () => updateInterest(interest.key),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: present ? color.withOpacity(0.1) : AppColors.bgGrey,
                  border:
                      !present ? Border.all(color: AppColors.borderGrey) : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Opacity(
                      opacity: present ? 1 : 0.4,
                      child: Image.asset(iconPath, height: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      interest.key,
                      style: AppStyles.h4.copyWith(
                        color: present ? color : Colors.grey[800],
                      ),
                    ),
                    if (present)
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          SvgPicture.asset(
                            Assets.icons.remove,
                            colorFilter: ColorFilter.mode(
                              color,
                              BlendMode.srcIn,
                            ),
                          )
                        ],
                      ),
                  ],
                ),
              ),
            );
          }
        },
      ).toList(),
    );
  }
}