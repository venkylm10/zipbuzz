import 'package:flutter/material.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class ResponseNotiCard extends StatelessWidget {
  const ResponseNotiCard({
    super.key,
    required this.senderName,
    required this.senderProfilePic,
    required this.eventId,
    required this.eventName,
    required this.positiveResponse,
    this.confirmResponse = false,
    required this.time,
  });

  final String senderName;
  final String senderProfilePic;
  final int eventId;
  final String eventName;
  final bool positiveResponse;
  final bool confirmResponse;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              senderProfilePic,
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
                  senderName,
                  style: AppStyles.h5.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  softWrap: true,
                ),
                confirmResponse
                    ? Text(
                        "$senderName has confirmed your request for $eventName",
                        style: AppStyles.h5.copyWith(
                          color: AppColors.greyColor,
                        ),
                      )
                    : RichText(
                        softWrap: true,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$senderName - ',
                              style: AppStyles.h5.copyWith(
                                color: AppColors.greyColor,
                              ),
                            ),
                            TextSpan(
                              text: '${positiveResponse ? "Yes" : "No"} ',
                              style: AppStyles.h5.copyWith(
                                color: positiveResponse
                                    ? AppColors.positiveGreen
                                    : AppColors.negativeRed,
                              ),
                            ),
                            TextSpan(
                              text: 'your invite for $eventName',
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
      ),
    );
  }
}
