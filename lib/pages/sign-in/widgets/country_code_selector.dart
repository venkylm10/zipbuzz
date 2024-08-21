import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/services/auth_services.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class CountryCodeSelector extends StatefulWidget {
  const CountryCodeSelector({super.key});

  @override
  State<CountryCodeSelector> createState() => _CountryCodeSelectorState();
}

class _CountryCodeSelectorState extends State<CountryCodeSelector> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: DropdownButton(
            value: ref.watch(authServicesProvider).countryCodeController.text,
            elevation: 0,
            underline: const SizedBox(),
            items: [
              DropdownMenuItem(
                value: "1",
                child: Text(
                  "+1",
                  style: AppStyles.h4,
                ),
              ),
              DropdownMenuItem(
                value: "91",
                child: Text(
                  "+91",
                  style: AppStyles.h4,
                ),
              ),
              DropdownMenuItem(
                value: "971",
                child: Text(
                  "+971",
                  style: AppStyles.h4,
                ),
              ),
            ],
            onChanged: (val) {
              if (val == null) return;
              ref.read(authServicesProvider).updateCountryCode(val);
              setState(() {});
            },
          ),
        ),
      );
    });
  }
}
