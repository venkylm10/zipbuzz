import 'package:flutter/material.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class ResponseNotiCard extends StatelessWidget {
  const ResponseNotiCard({
    super.key,
    required this.hostName,
    required this.hostProfilePic,
    required this.eventId,
    required this.positiveResponse,
    required this.time,
  });

  final String hostName;
  final String hostProfilePic;
  final int eventId;
  final bool positiveResponse;
  final String time;

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
      ),
    );
  }
}
