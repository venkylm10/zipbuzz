import 'package:flutter/material.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/custom_text_field.dart';

class AddGroupMembers extends StatelessWidget {
  static const id = '/groups/group-details/add-group-members';
  const AddGroupMembers({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Members", style: AppStyles.h1),
        leading: IconButton(
          onPressed: () {
            navigatorKey.currentState!.pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            CustomTextField(
              controller: TextEditingController(),
              hintText: "Search contact",
            ),
          ],
        ),
      ),
    );
  }
}
