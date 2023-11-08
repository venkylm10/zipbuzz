import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/models/host_model.dart';

class EventHosts extends StatelessWidget {
  const EventHosts({
    super.key,
    required this.hosts,
  });

  final List<Host> hosts;

  @override
  Widget build(BuildContext context) {
    return Column(
      //TODO: change this later
      children: List.generate(
        2,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              if (hosts.first.imagePath == null)
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
                hosts.first.name,
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
        ),
      ),
    );
  }
}
