import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';

class CustomBezel extends StatelessWidget {
  final Widget child;
  const CustomBezel({super.key, required this.child});
  

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = height * 1484 / 2000; // don't change
    return Scaffold(
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
    );
  }
}
