import 'package:flutter/material.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/models/interests/responses/interest_model.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class HomeInterestChip extends StatelessWidget {
  final InterestModel interest;
  final VoidCallback toggleHomeCategory;
  const HomeInterestChip({super.key, required this.interest, required this.toggleHomeCategory});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: toggleHomeCategory,
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: EventsControllerProvider.hexStringToColor(
            interest.color,
          ).withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              interest.iconUrl,
              height: 24,
            ),
            const SizedBox(width: 8),
            Text(
              interest.activity,
              style: AppStyles.h5.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
