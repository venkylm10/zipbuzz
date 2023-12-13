import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/models/user_model/user_model.dart';

class EventHosts extends ConsumerStatefulWidget {
  const EventHosts({
    super.key,
    required this.hostId,
    required this.hostName,
    required this.hostPic,
    required this.coHosts,
  });
  final int hostId;
  final String hostName;
  final String hostPic;
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
        buildHost(widget.hostId, widget.hostName, widget.hostPic),
        Column(
          children: List.generate(
            widget.coHosts.length,
            (index) {
              final coHost = widget.coHosts[index];
              return buildHost(coHost.id, coHost.name, coHost.imageUrl);
            },
          ),
        )
      ],
    );
  }

  Padding buildHost(int hostId, String hostName, String hostPic) {
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
                  hostPic,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            hostName,
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
