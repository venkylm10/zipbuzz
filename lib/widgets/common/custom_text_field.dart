import 'package:flutter/material.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final int? maxLength;
  final Widget? prefixIcon;
  final bool? enabled;
  const CustomTextField({
    super.key,
    required this.controller,
    this.maxLength,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          if (prefixIcon != null) prefixIcon!,
          Expanded(
            child: TextField(
              controller: controller,
              cursorColor: AppColors.primaryColor,
              style: AppStyles.h4,
              maxLines: null,
              maxLength: maxLength,
              decoration: InputDecoration(
                enabled: enabled!,
                hintText: "",
                hintStyle: AppStyles.h4,
                contentPadding: const EdgeInsets.all(8),
                counter: maxLength != null
                    ? Transform.translate(
                        offset: const Offset(0, -8),
                        child: Text(
                          "${controller.text.length}/$maxLength",
                          style: AppStyles.h6
                              .copyWith(color: AppColors.lightGreyColor),
                        ),
                      )
                    : null,
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                disabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}