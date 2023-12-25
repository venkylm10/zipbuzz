import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/controllers/profile/edit_profile_controller.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/services/image_picker.dart';
import 'package:zipbuzz/widgets/common/back_button.dart';
import 'package:zipbuzz/widgets/common/custom_text_field.dart';
import 'package:zipbuzz/widgets/common/loader.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  static const id = "/profile/edit";
  const EditProfilePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late EditProfileController editProfileController;

  void updateInterest(String interest) {
    editProfileController.updateInterest(interest);
    setState(() {});
  }

  void pickImage() async {
    final pickedImage = await ImageServices().pickImage();
    if (pickedImage != null) {
      setState(() {
        editProfileController.updateImage(File(pickedImage.path));
      });
    }
  }

  void saveChanges() async {
    await editProfileController.saveChanges();
  }

  @override
  void initState() {
    editProfileController = ref.read(editProfileControllerProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    editProfileController = ref.watch(editProfileControllerProvider);
    final loadingText = ref.watch(loadingTextProvider);
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
              buildProfilePic(),
              const SizedBox(height: 8),
              Text("Name:", style: AppStyles.h4),
              const SizedBox(height: 4),
              CustomTextField(controller: editProfileController.nameController),
              const SizedBox(height: 8),
              Text("About me:", style: AppStyles.h4),
              const SizedBox(height: 4),
              CustomTextField(
                controller: editProfileController.aboutController,
                maxLength: 550,
                showCounter: true,
              ),
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
                controller: editProfileController.zipcodeController,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: SvgPicture.asset(Assets.icons.geo_mini, height: 20),
                ),
                maxLength: 6,
                maxLines: 1,
              ),
              const SizedBox(height: 8),
              Text("Mobile no:", style: AppStyles.h4),
              const SizedBox(height: 4),
              CustomTextField(
                controller: editProfileController.mobileController,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: SvgPicture.asset(Assets.icons.telephone, height: 20),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 8),
              Text("ZipBuzz handle:", style: AppStyles.h4),
              const SizedBox(height: 4),
              CustomTextField(
                controller: editProfileController.handleController,
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
                controller: editProfileController.linkedinIdControler,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Image.asset(Assets.icons.linkedin, height: 20),
                ),
              ),
              const SizedBox(height: 8),
              Text("Instagram", style: AppStyles.h4),
              const SizedBox(height: 4),
              CustomTextField(
                controller: editProfileController.instagramIdController,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Image.asset(Assets.icons.instagram, height: 20),
                ),
              ),
              const SizedBox(height: 8),
              Text("Twitter", style: AppStyles.h4),
              const SizedBox(height: 4),
              CustomTextField(
                controller: editProfileController.twitterIdController,
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
                onTap: () {
                  if (loadingText == null) {
                    saveChanges();
                  }
                },
                child: Ink(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: loadingText == null
                      ? Row(
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
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              loadingText,
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

  Widget buildProfilePic() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: SizedBox(
                height: 120,
                width: 120,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: editProfileController.image != null
                            ? Image.file(
                                editProfileController.image!,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                editProfileController.userClone.imageUrl,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
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
            if (editProfileController.userClone.isAmbassador)
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
      ],
    );
  }

  Wrap buildInterests() {
    final myInterests = editProfileController.userClone.interests;
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: present ? color.withOpacity(0.1) : AppColors.bgGrey,
                  border: !present ? Border.all(color: AppColors.borderGrey) : null,
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
