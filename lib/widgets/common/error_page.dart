import 'package:flutter/material.dart';
import 'package:zipbuzz/constants/styles.dart';

class ErrorPage extends StatelessWidget {
  final String error;
  const ErrorPage({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          error,
          style: AppStyles.h4,
        ),
      ),
    );
  }
}
