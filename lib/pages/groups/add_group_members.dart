import 'package:flutter/material.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class AddGroupMembers extends StatelessWidget {
  static const id = '/groups/group-details/add-group-members';
  const AddGroupMembers({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight),
            Text("Add Members", style: AppStyles.h1),
          ],
        ),
      ),
    );
  }
}
