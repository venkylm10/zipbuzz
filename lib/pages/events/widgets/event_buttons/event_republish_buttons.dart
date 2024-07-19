import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zipbuzz/pages/events/widgets/event_buttons/event_invite_guests_button.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/loader.dart';

class EventRepublishButtons extends ConsumerWidget {
  final VoidCallback inviteContacts;
  final Function(String?) republishEvent;
  const EventRepublishButtons({super.key, required this.inviteContacts, required this.republishEvent});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final loadingText = ref.watch(loadingTextProvider);
    return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            EventInviteGuestsButton(
              inviteContacts: inviteContacts,
              title: "Invite More Guests",
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap:()=> republishEvent(loadingText),
              child: Container(
                height: 48,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: loadingText == null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(Assets.icons.arrow_repeat, height: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Re-Publish",
                              style: AppStyles.h3.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          loadingText,
                          style: AppStyles.h4.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        );
  }
}