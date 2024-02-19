import 'package:flutter/material.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class InviteNotiCard extends StatelessWidget {
  const InviteNotiCard({
    super.key,
    required this.hostName,
    required this.hostProfilePic,
    required this.eventId,
    required this.eventName,
    required this.time,
    required this.acceptInvite,
    required this.declineInvite,
  });

  final String hostName;
  final String hostProfilePic;
  final int eventId;
  final String eventName;
  final String time;
  final VoidCallback acceptInvite;
  final VoidCallback declineInvite;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              hostProfilePic,
              height: 44,
              width: 44,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: MediaQuery.of(context).size.width - 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hostName,
                  style: AppStyles.h5.copyWith(
                    fontWeight: FontWeight.w600,
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
                      child: GestureDetector(
                        onTap: acceptInvite,
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
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: declineInvite,
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
      ),
    );
  }
}
