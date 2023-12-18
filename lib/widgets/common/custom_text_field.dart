import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool? enabled;
  final String? hintText;
  final int? maxLines;
  final void Function(String)? onChanged;
  final bool? showCounter;
  final double? borderRadius;
  final CrossAxisAlignment? crossAxisAlignment;
  const CustomTextField({
    super.key,
    required this.controller,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.hintText,
    this.maxLines,
    this.onChanged,
    this.showCounter = false,
    this.borderRadius = 12,
    this.crossAxisAlignment,
  });

  Widget? buildCounter() {
    if (maxLength != null && showCounter!) {
      return Transform.translate(
        offset: const Offset(0, -8),
        child: Text(
          "${controller.text.length}/$maxLength",
          style: AppStyles.h6.copyWith(color: AppColors.lightGreyColor),
        ),
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgGrey,
        borderRadius: BorderRadius.circular(borderRadius!),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
        children: [
          if (prefixIcon != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: prefixIcon!,
            ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              cursorColor: AppColors.primaryColor,
              style: AppStyles.h4,
              inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
              maxLines: maxLines,
              onChanged: onChanged,
              decoration: InputDecoration(
                enabled: enabled!,
                hintText: hintText,
                hintStyle:
                    AppStyles.h4.copyWith(color: AppColors.lightGreyColor),
                contentPadding: const EdgeInsets.all(8),
                counter: buildCounter(),
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
          const SizedBox(width: 8),
          if (suffixIcon != null) suffixIcon!,
        ],
      ),
    );
  }
}
