import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/widgets/custom_text_field.dart';

class HyperlinkFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController urlController;
  final VoidCallback onDelete;
  const HyperlinkFields({
    super.key,
    required this.nameController,
    required this.urlController,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: nameController,
                    hintText: "HyperLink Name",
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 4),
                  CustomTextField(
                    controller: urlController,
                    hintText: "URL",
                    textInputAction: TextInputAction.next,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onDelete,
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
      ],
    );
  }
}
