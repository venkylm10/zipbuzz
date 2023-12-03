import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/models/user_model.dart';
import 'package:zipbuzz/services/db_services.dart';

class EventHosts extends ConsumerStatefulWidget {
  const EventHosts({
    super.key,
    required this.hostId,
    required this.coHostIds,
  });

  final String hostId;
  final List<String> coHostIds;

  @override
  ConsumerState<EventHosts> createState() => _EventHostsState();
}

class _EventHostsState extends ConsumerState<EventHosts> {
  UserModel? host;
  void getHostData(String uid) async {
    final dbEvent = await ref.read(dbServicesProvider).getUserData(uid).first;
    if (dbEvent.snapshot.exists) {
      final jsonString = jsonEncode(dbEvent.snapshot.value);
      final userMap = jsonDecode(jsonString);
      host = UserModel.fromMap(userMap);
      setState(() {});
    }
  }

  @override
  void initState() {
    getHostData(widget.hostId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      //TODO: Update host and co-hosts
      children: [
        host != null
            ? Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Container(
                      height: 32,
                      width: 32,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.greyColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SvgPicture.asset(
                        Assets.icons.person,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      host!.name,
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
                          style: AppStyles.h4
                              .copyWith(color: AppColors.primaryColor),
                        ),
                      ),
                    )
                  ],
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
