import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class CustomHyperLinkedTextSpan extends StatelessWidget {
  const CustomHyperLinkedTextSpan({
    super.key,
    required this.text
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final splits = text.split(" ");
        return RichText(
          text: TextSpan(
            children: splits.map(
              (e) {
                var isLink = false;
                var url = "";
                final up2 = RegExp(r'^(https?://)?(www\.)?[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                if (up2.hasMatch(e)) {
                  isLink = true;
                  if (e.startsWith("http://") || e.startsWith("https://")) {
                    url = e;
                  } else {
                    url = "http://$e";
                  }
                }
                return TextSpan(
                  children: isLink
                      ? [
                          TextSpan(
                            text: e,
                            style: AppStyles.h4.copyWith(
                              color: isLink ? Colors.blue : AppColors.greyColor,
                              fontStyle: isLink ? FontStyle.italic : FontStyle.normal,
                              decoration:
                                  isLink ? TextDecoration.underline : TextDecoration.none,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrlString(url);
                              },
                          ),
                          const TextSpan(text: " "),
                        ]
                      : [
                          TextSpan(
                            text: !isLink ? "$e " : null,
                            style: AppStyles.h4.copyWith(
                              color: AppColors.greyColor,
                              fontStyle: FontStyle.normal,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                );
              },
            ).toList(),
          ),
        );
      },
    );
  }
}