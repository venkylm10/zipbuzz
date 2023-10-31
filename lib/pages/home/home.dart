import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/pages/events/event_tab.dart';
import 'package:zipbuzz/pages/home/home_tab.dart';
import 'package:zipbuzz/pages/map/map_tab.dart';
import 'package:zipbuzz/pages/person/person_tab.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0;
  final tabs = const [
    HomeTab(),
    EventsTab(),
    MapTab(),
    ProfileTab(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabs[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            label: 'home',
            icon: SvgPicture.asset(
              Assets.icons.home,
              colorFilter: ColorFilter.mode(
                selectedIndex == 0
                    ? AppColors.primaryColor
                    : AppColors.greyColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: 'events',
            icon: SvgPicture.asset(
              Assets.icons.events,
              colorFilter: ColorFilter.mode(
                selectedIndex == 1
                    ? AppColors.primaryColor
                    : AppColors.greyColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: 'map',
            icon: SvgPicture.asset(
              Assets.icons.map,
              colorFilter: ColorFilter.mode(
                selectedIndex == 2
                    ? AppColors.primaryColor
                    : AppColors.greyColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: 'person',
            icon: SvgPicture.asset(
              Assets.icons.person,
              colorFilter: ColorFilter.mode(
                selectedIndex == 3
                    ? AppColors.primaryColor
                    : AppColors.greyColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
