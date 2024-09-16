import 'package:flutter/material.dart';
import 'package:zipbuzz/pages/groups/create_group_form.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class EditGroupScreen extends StatelessWidget {
  const EditGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            navigatorKey.currentState!.pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Text("Edit Group", style: AppStyles.h2),
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: CreateGroupForm(editing: true),
      ),
    );
  }
}
