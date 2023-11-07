import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/styles.dart';

class AttendeeNumbers extends StatelessWidget {
  final int attendees;
  final int total;
  final Color? backgroundColor;
  const AttendeeNumbers({
    super.key,
    required this.attendees,
    required this.total,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            Assets.icons.people,
            height: 16,
          ),
          const SizedBox(width: 5),
          Text(
            "$attendees/$total",
            style: AppStyles.h4,
          )
        ],
      ),
    );
  }
}
