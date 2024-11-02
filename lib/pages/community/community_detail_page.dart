import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:zipbuzz/controllers/community/community_controller.dart';
import 'package:zipbuzz/models/community/res/community_details_model.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class CommunityDetailPage extends ConsumerStatefulWidget {
  static const id = "/home/community-detail";
  const CommunityDetailPage({super.key});

  @override
  ConsumerState<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends ConsumerState<CommunityDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final id = ref.read(communityControllerProvider).currentCommunityDescription!.id;
      ref.read(communityControllerProvider.notifier).getCommunityDetails(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(communityControllerProvider).loading;
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      );
    }
    final community = ref.watch(communityControllerProvider).currentCommunity!;
    return Scaffold(
      appBar: _buildAppBar(community),
      body: const Center(
        child: Text("Community Details"),
      ),
    );
  }

  AppBar _buildAppBar(CommunityDetailsModel community) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
            onPressed: () {
              navigatorKey.currentState!.pop();
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(community.communityImage, width: 30, height: 30),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              community.communityName,
              style: AppStyles.h2,
            ),
          ),
        ],
      ),
      elevation: 0,
      actions: const [
        // Consumer(builder: (context, ref, child) {
        //   if (!ref.watch(groupControllerProvider).isAdmin) return const SizedBox();
        //   return IconButton(
        //     onPressed: _moveToEditScreen,
        //     icon: const Icon(Icons.edit_rounded, color: AppColors.primaryColor),
        //   );
        // })
      ],
    );
  }
}
