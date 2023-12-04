import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/models/user_model.dart';

class EventHosts extends ConsumerStatefulWidget {
  const EventHosts({
    super.key,
    required this.host,
    required this.coHosts,
  });

  final UserModel host;
  final List<UserModel> coHosts;

  @override
  ConsumerState<EventHosts> createState() => _EventHostsState();
}

class _EventHostsState extends ConsumerState<EventHosts> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      //TODO: Update host and co-hosts
      children: [
        buildHost(widget.host),
        Column(
          children: List.generate(
            widget.coHosts.length,
            (index) {
              final coHost = widget.coHosts[index];
              return buildHost(coHost);
            },
          ),
        )
      ],
    );
  }

  Padding buildHost(UserModel user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: AppColors.greyColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: AppColors.greyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.network(
                  user.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            user.name,
            style: AppStyles.h5,
          ),
          const Expanded(child: SizedBox()),
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                "Message",
                style: AppStyles.h4.copyWith(color: AppColors.primaryColor),
              ),
            ),
          )
        ],
      ),
    );
  }
}
