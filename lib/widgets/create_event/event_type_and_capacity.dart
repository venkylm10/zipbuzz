import 'package:flutter/material.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';

class EventTypeAndCapacity extends StatefulWidget {
  const EventTypeAndCapacity({super.key});

  @override
  State<EventTypeAndCapacity> createState() => _EventTypeAndCapacityState();
}

class _EventTypeAndCapacityState extends State<EventTypeAndCapacity> {
  int capacity = 10;
  var isPrivate = false;
  final capacityController = TextEditingController();

  void updateType(bool value) {
    setState(() {
      isPrivate = value;
    });
  }

  void increaseCapacity() {
    setState(() {
      capacity++;
      capacityController.text = capacity.toString();
    });
  }

  void decreaseCapacity() {
    setState(() {
      if (capacity > 0) {
        capacity--;
        capacityController.text = capacity.toString();
      }
    });
  }

  void onChange(String value) {
    if (value.isEmpty) {
      capacityController.text = 0.toString();
      setState(() {
        capacity = 0;
      });
      return;
    }
    if (value.length > 1 && value[0] == '0') {
      value = value.substring(1);
    }
    final num = int.parse(value);

    if (num < 0) {
      capacityController.text = 0.toString();
      setState(() {
        capacity = 0;
      });
    } else {
      capacityController.text = value;
      setState(() {
        capacity = num;
      });
    }
  }

  @override
  void initState() {
    capacityController.text = capacity.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Type & Capacity",
          style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => updateType(false),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.bgGrey,
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: Row(
              children: [
                Radio(
                  value: false,
                  groupValue: isPrivate,
                  activeColor: AppColors.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      isPrivate = !isPrivate;
                    });
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Public event", style: AppStyles.h4),
                    SizedBox(
                      width: size.width * 0.7,
                      child: Text(
                        "Anyone can view the guest list",
                        style: AppStyles.h5
                            .copyWith(color: AppColors.lightGreyColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => updateType(true),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.bgGrey,
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: Row(
              children: [
                Radio(
                  value: true,
                  groupValue: isPrivate,
                  activeColor: AppColors.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      isPrivate = !isPrivate;
                    });
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Private event", style: AppStyles.h4),
                    SizedBox(
                      width: size.width * 0.7,
                      child: Text(
                        "Only people whom you invite can join this event",
                        softWrap: true,
                        style: AppStyles.h5
                            .copyWith(color: AppColors.lightGreyColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Event capacity", style: AppStyles.h4),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGrey),
                color: AppColors.bgGrey,
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * .4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: decreaseCapacity,
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(Icons.remove_rounded),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: capacityController,
                        cursorColor: AppColors.primaryColor,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        onChanged: (value) => onChange(value),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: increaseCapacity,
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(Icons.add_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
