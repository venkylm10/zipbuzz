import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/community/community_controller.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class CreateCommunityButton extends ConsumerWidget {
  const CreateCommunityButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(communityControllerProvider).creatingCommunity) return const SizedBox();
    return GestureDetector(
      onTap: () => ref.read(communityControllerProvider.notifier).toggleCreatingCommunity(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(360),
          color: const Color(0xff1F98A9),
        ),
        child: Text(
          "Create Community",
          style: AppStyles.h4.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
