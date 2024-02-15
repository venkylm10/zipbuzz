import 'package:flutter/material.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class InviteNotiCard extends StatelessWidget {
  const InviteNotiCard({
    super.key,
    required this.hostName,
    required this.hostUsername,
    required this.hostProfilePic,
    required this.eventId,
    required this.eventName,
    required this.time,
  });

  final String hostName;
  final String hostUsername;
  final String hostProfilePic;
  final int eventId;
  final String eventName;
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
                      text: 'Invited you for ',
                      style: AppStyles.h5,
                    ),
                    TextSpan(
                      text: eventName,
                      style: AppStyles.h5.copyWith(
                        color: AppColors.primaryColor,
                        fontStyle: FontStyle.italic,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'RSVP - Yes',
                          style: AppStyles.h5.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.borderGrey,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'RSVP - No',
                          style: AppStyles.h5.copyWith(
                            color: AppColors.greyColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
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
