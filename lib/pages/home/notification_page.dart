import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/widgets/common/back_button.dart';
import 'package:zipbuzz/widgets/home/invite_noti_card.dart';
import 'package:zipbuzz/widgets/home/response_noti_card.dart';

class NotificationPage extends ConsumerWidget {
  static const id = "/notification_page";
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: backButton(),
        title: Text(
          "Notificaitions",
          style: AppStyles.h2.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16).copyWith(bottom: 0),
          child: const Column(
            children: [
              InviteNotiCard(
                hostName: "Ralph Edwards",
                hostUsername: "ralhyy",
                hostProfilePic: "null",
                eventId: 100,
                eventName: "A Madcap House Party Extravaganza",
                time: "1hr",
              ),
              SizedBox(height: 24),
              ResponseNotiCard(
                hostName: "Jenny Wilson",
                hostUsername: "jwilsonness",
                hostProfilePic: "null",
                eventId: 100,
                positiveResponse: true,
                time: "4hr",
              ),
              SizedBox(height: 24),
              ResponseNotiCard(
                hostName: "Jenny Wilson",
                hostUsername: "jwilsonness",
                hostProfilePic: "null",
                eventId: 100,
                positiveResponse: false,
                time: "4hr",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
