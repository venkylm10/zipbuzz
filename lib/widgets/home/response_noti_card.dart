import 'package:flutter/material.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class ResponseNotiCard extends StatelessWidget {
  const ResponseNotiCard({
    super.key,
    required this.hostName,
    required this.hostUsername,
    required this.hostProfilePic,
    required this.eventId,
    required this.positiveResponse,
    required this.time,
  });

  final String hostName;
  final String hostUsername;
  final String hostProfilePic;
  final int eventId;
  final bool positiveResponse;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: MediaQuery.of(context).size.width - 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "$hostName ",
                      style: AppStyles.h5.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: "@$hostUsername",
                      style: AppStyles.h5.copyWith(
                        color: AppColors.lightGreyColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                softWrap: true,
              ),
              RichText(
                softWrap: true,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'RSVP - ${positiveResponse ? "Yes" : "No"} ',
                      style: AppStyles.h5.copyWith(
                        color: positiveResponse ? AppColors.positiveGreen : AppColors.negativeRed,
                      ),
                    ),
                    TextSpan(
                      text: 'your invite',
                      style: AppStyles.h5.copyWith(
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Text(
          time,
          style: AppStyles.h6,
        ),
      ],
    );
  }
}
