import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class EventInviteGuestsButton extends StatelessWidget {
  final VoidCallback inviteContacts;
  final String title;
  const EventInviteGuestsButton({
    super.key,
    required this.inviteContacts,
    this.title = "Invite Guests",
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: inviteContacts,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                Assets.icons.people,
                height: 22,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppStyles.h3.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
