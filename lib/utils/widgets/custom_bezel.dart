import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/widgets/no_internet_screen.dart';

class CustomBezel extends ConsumerWidget {
  final Widget child;
  final bool showLoader;
  const CustomBezel({super.key, required this.child, this.showLoader = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;
    final width = height * 1484 / 2000; // don't change
    final internetConnection = ref.watch(checkInternetProvider);
    return internetConnection != const AsyncData(false)
        ? Scaffold(
            backgroundColor: kIsWeb ? AppColors.primaryColor.withOpacity(0.4) : null,
            body: kIsWeb
                ? Center(
                    child: SizedBox(
                      height: height,
                      width: width,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              Assets.images.ipad_border,
                              fit: BoxFit.fitHeight,
                              color: Colors.black,
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.all(height * 0.06),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(height * 0.02),
                                child: child,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : child,
          )
        : NoInternetScreen(showLoader: showLoader);
  }
}
