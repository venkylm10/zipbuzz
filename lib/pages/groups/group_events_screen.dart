import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/groups/res/group_description_res.dart';
import 'package:zipbuzz/pages/groups/group_details_screen.dart';
import 'package:zipbuzz/pages/home/widgets/event_card.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/tabs.dart';

class GroupEventsScreen extends ConsumerStatefulWidget {
  static const id = '/groups/group-events';
  const GroupEventsScreen({super.key});

  @override
  ConsumerState<GroupEventsScreen> createState() => _GroupEventsScreenState();
}

class _GroupEventsScreenState extends ConsumerState<GroupEventsScreen> {
  late GroupDescriptionModel groupDescription;

  @override
  void initState() {
    groupDescription = ref.read(groupControllerProvider).currentGroupDescription!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(groupControllerProvider).groupEventsTab;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          groupDescription.groupName,
          style: AppStyles.h2.copyWith(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () {
            navigatorKey.currentState!.pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(groupControllerProvider.notifier).updateLoading(false);
              navigatorKey.currentState!.pushNamed(GroupDetailsScreen.id);
            },
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTabs(ref, selectedTab),
              const SizedBox(height: 24),
              EventCard(
                event: EventModel(
                  id: 12,
                  title: "Under 19 Match",
                  hostId: 12,
                  location: "Home",
                  date: DateTime.now().toString(),
                  startTime: "10:20 AM",
                  endTime: "10:30 AM",
                  attendees: 3,
                  category: allInterests.first.activity,
                  bannerPath:
                      "https://images.pexels.com/photos/45201/kitty-cat-kitten-pet-45201.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
                  iconPath:
                      "https://images.pexels.com/photos/45201/kitty-cat-kitten-pet-45201.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
                  about: "Welcome",
                  isPrivate: false,
                  capacity: 5,
                  imageUrls: [],
                  privateGuestList: false,
                  hostName: "Dhiransh",
                  hostPic:
                      "https://images.pexels.com/photos/45201/kitty-cat-kitten-pet-45201.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
                  eventMembers: [],
                  status: 'pending',
                  userDeviceToken: 'zipbuzz-null',
                  hyperlinks: [],
                  members: 3,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(WidgetRef ref, GroupEventsTab selectedTab) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.borderGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(
          GroupEventsTab.values.length,
          (index) {
            final tab = GroupEventsTab.values[index];
            return Expanded(
              child: InkWell(
                onTap: () {
                  ref.read(groupControllerProvider.notifier).changeGroupEventsTab(tab);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: selectedTab == tab ? AppColors.bgGrey : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      GroupEventsTab.values[index].name,
                      style: AppStyles.h5.copyWith(
                        color: selectedTab == tab ? AppColors.primaryColor : AppColors.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
