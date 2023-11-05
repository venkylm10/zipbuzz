import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/models/event_model.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  const EventCard({super.key, required this.event});

  Color getCategoryColor(String categoryPath) {
    return categoryColors[categoryPath]!.withOpacity(0.2);
  }

  String getMonth(DateTime date) {
    final formatter = DateFormat.MMM();
    return formatter.format(date);
  }

  String getWeekDay(DateTime date) {
    return DateFormat.EEEE().format(date).substring(0, 3);
  }

  String getTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                constraints: const BoxConstraints(minWidth: 50),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        getMonth(event.dateTime),
                        style: AppStyles.h4.copyWith(
                          color: AppColors.greyColor,
                        ),
                      ),
                    ),
                    Text(
                      event.dateTime.day.toString(),
                      style: AppStyles.titleStyle,
                    ),
                    Text(
                      getWeekDay(event.dateTime),
                      style: AppStyles.h4.copyWith(
                        color: AppColors.greyColor,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 50,
                width: 50,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: getCategoryColor(event.iconPath),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Image.asset(event.iconPath),
              )
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(-2, 4),
                    blurRadius: 10,
                    spreadRadius: 4,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Image.asset(
                            event.bannerPath,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.favorite_rounded,
                              color: event.favourite
                                  ? Colors.pink[400]
                                  : Colors.grey[300],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  Assets.icons.people,
                                  height: 16,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "8/10",
                                  style: AppStyles.h4,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                Assets.icons.person_fill,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.primaryColor,
                                  BlendMode.srcIn,
                                ),
                                height: 16,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                event.collabName,
                                style: AppStyles.h5.copyWith(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          event.title,
                          softWrap: true,
                          style: AppStyles.h4.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        if (event.description != null)
                          Text(
                            event.description!,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.h5.copyWith(
                              color: AppColors.greyColor,
                            ),
                          ),
                        if (event.description != null)
                          const SizedBox(height: 10),
                        Row(
                          children: [
                            SvgPicture.asset(
                              Assets.icons.geo_mini,
                              height: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              event.location,
                              style: AppStyles.h5.copyWith(
                                color: AppColors.greyColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            SvgPicture.asset(
                              Assets.icons.clock,
                              height: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              getTime(event.dateTime),
                              style: AppStyles.h5.copyWith(
                                color: AppColors.greyColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final Map<String, Color> categoryColors = {
  Assets.icons.hiking: Colors.brown,
  Assets.icons.sports: Colors.green,
  Assets.icons.music: Colors.yellow,
  Assets.icons.movieClubs: Colors.deepPurple,
  Assets.icons.dance: Colors.red,
  Assets.icons.fitness: Colors.blueGrey,
  Assets.icons.parties: Colors.pink,
  Assets.icons.book: Colors.lightGreen,
  Assets.icons.boating: Colors.lime,
  Assets.icons.wineTasting: Colors.blueGrey,
  Assets.icons.gaming: Colors.red,
  Assets.icons.kidPlaydates: Colors.pink,
  Assets.icons.petActivites: Colors.orange,
};
