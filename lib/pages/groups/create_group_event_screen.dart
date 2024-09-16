import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/pages/events/create_event_tab.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class CreateGroupEventScreen extends StatelessWidget {
  const CreateGroupEventScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Event",
          style: AppStyles.h2.copyWith(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            navigatorKey.currentState!.pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
          ),
        ),
      ),
      body: Stack(
        children: [
          const SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CreateEventTab(rePublish: false, groupEvent: true),
          ),
          _buildLoader(),
        ],
      ),
    );
  }

  Widget _buildLoader() {
    return Consumer(
      builder: (context, ref, child) {
        return ref.watch(groupControllerProvider).loading
            ? Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              )
            : const SizedBox();
      },
    );
  }
}
