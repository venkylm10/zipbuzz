import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/custom_text_field.dart';

class CreateEventTicketTypeFields extends ConsumerWidget {
  final bool rePublish;
  const CreateEventTicketTypeFields({super.key, required this.rePublish});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late EventModel event;
    if (rePublish) {
      event = ref.watch(editEventControllerProvider);
    } else {
      event = ref.watch(newEventProvider);
    }
    return Column(
      children: [
        _buildToggleButton(ref, event),
        _buildTicketTypes(ref, event),
        _buildAddNewTypeButton(ref, event),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text("PayPal.me", style: AppStyles.h4),
              const SizedBox(width: 8),
              Expanded(
                child: CustomTextField(
                    controller: rePublish
                        ? ref.read(editEventControllerProvider.notifier).paypalLinkController
                        : ref.read(newEventProvider.notifier).paypalLinkController),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text("Venmo ID", style: AppStyles.h4),
              const SizedBox(width: 8),
              Expanded(
                child: CustomTextField(
                    controller: rePublish
                        ? ref.read(editEventControllerProvider.notifier).venmoIdController
                        : ref.read(newEventProvider.notifier).venmoIdController),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTicketTypes(WidgetRef ref, EventModel event) {
    List<TextEditingController> titles;
    List<TextEditingController> prices;
    if (rePublish) {
      titles = ref.read(editEventControllerProvider.notifier).ticketTitleControllers;
      prices = ref.read(editEventControllerProvider.notifier).ticketPriceControllers;
    } else {
      titles = ref.read(newEventProvider.notifier).ticketTitleControllers;
      prices = ref.read(newEventProvider.notifier).ticketPriceControllers;
    }
    if (event.ticketTypes.isEmpty) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: List.generate(event.ticketTypes.length, (index) {
          return _buildTicketType(titles[index], prices[index], ref, index);
        }),
      ),
    );
  }

  Widget _buildToggleButton(WidgetRef ref, EventModel event) {
    return Row(
      children: [
        Expanded(child: Text("Ticketed Event", style: AppStyles.h4)),
        Switch.adaptive(
          value: event.ticketTypes.isNotEmpty,
          onChanged: (val) {
            if (rePublish) {
              ref.read(editEventControllerProvider.notifier).toggleTicketTypes(val);
            } else {
              ref.read(newEventProvider.notifier).toggleTicketTypes(val);
            }
          },
          activeColor: AppColors.primaryColor,
          thumbColor: WidgetStateProperty.resolveWith((state) {
            if (state.contains(WidgetState.selected)) {
              return AppColors.primaryColor;
            }
            return AppColors.lightGreyColor;
          }),
          trackColor: WidgetStateProperty.resolveWith((state) {
            if (state.contains(WidgetState.selected)) {
              return AppColors.primaryColor.withOpacity(0.5);
            }
            return AppColors.bgGrey;
          }),
          trackOutlineColor: WidgetStateProperty.resolveWith((state) {
            if (state.contains(WidgetState.selected)) {
              return AppColors.primaryColor.withOpacity(0.5);
            }
            return AppColors.lightGreyColor;
          }),
        ),
      ],
    );
  }

  Widget _buildAddNewTypeButton(WidgetRef ref, EventModel event) {
    if (event.ticketTypes.isEmpty) return const SizedBox();
    return InkWell(
      onTap: () {
        if (rePublish) {
          ref.read(editEventControllerProvider.notifier).addTicketType();
        } else {
          ref.read(newEventProvider.notifier).addTicketType();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.bgGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(Assets.icons.add_circle),
            const SizedBox(width: 8),
            Text(
              "Add",
              style: AppStyles.h4.copyWith(
                color: AppColors.greyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketType(TextEditingController titleController,
      TextEditingController priceController, WidgetRef ref, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: CustomTextField(
              controller: titleController,
              onChanged: (val) {
                _updateTitle(ref, val, index);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: CustomTextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              onChanged: (val) {
                _updatePrice(ref, val, index);
              },
            ),
          ),
          const SizedBox(width: 8),
          Consumer(builder: (context, ref, child) {
            EventModel event;
            if (rePublish) {
              event = ref.watch(editEventControllerProvider);
            } else {
              event = ref.watch(newEventProvider);
            }
            if (event.ticketTypes.length == 1) return const SizedBox();
            return InkWell(
              onTap: () {
                if (rePublish) {
                  ref.read(editEventControllerProvider.notifier).removeTicketType(index);
                } else {
                  ref.read(newEventProvider.notifier).removeTicketType(index);
                }
              },
              child: SvgPicture.asset(
                Assets.icons.delete_fill,
                height: 36,
                colorFilter: const ColorFilter.mode(
                  AppColors.greyColor,
                  BlendMode.srcIn,
                ),
              ),
            );
          })
        ],
      ),
    );
  }

  void _updateTitle(WidgetRef ref, String val, int index) {
    if (rePublish) {
      ref.read(editEventControllerProvider.notifier).updateTicketTitle(index, val);
    } else {
      ref.read(newEventProvider.notifier).updateTicketTitle(index, val);
    }
  }

  void _updatePrice(WidgetRef ref, String val, int index) {
    if (rePublish) {
      ref.read(editEventControllerProvider.notifier).updateTicketPrice(index, val);
    } else {
      ref.read(newEventProvider.notifier).updateTicketPrice(index, val);
    }
  }
}
