import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, child) {
                final loadingText = ref.watch(loadingTextProvider) ?? "Loading...";
                return Text(
                  loadingText,
                  style: AppStyles.h4.copyWith(fontStyle: FontStyle.italic),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

final loadingTextProvider = StateNotifierProvider<LoadingText, String?>((ref) => LoadingText());

class LoadingText extends StateNotifier<String?> {
  LoadingText() : super(null);

  void updateLoadingText(String? loadingText) {
    state = loadingText;
  }

  void reset() {
    state = null;
  }
}
