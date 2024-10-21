import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/loader.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

class EventUploadNewImages extends ConsumerStatefulWidget {
  final int eventId;
  final List<XFile> images;
  const EventUploadNewImages({super.key, required this.eventId, required this.images});

  @override
  ConsumerState<EventUploadNewImages> createState() => _EventUploadNewImagesState();
}

class _EventUploadNewImagesState extends ConsumerState<EventUploadNewImages> {
  var loading = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final loadingText = ref.read(loadingTextProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new images", style: AppStyles.h3),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: PageView.builder(
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  margin: const EdgeInsets.all(16),
                  child: Image.file(
                    File(widget.images[index].path),
                    fit: BoxFit.fitWidth,
                  ),
                );
              },
            ),
          ),
          if (loading)
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                    if (loadingText != null)
                      Text(
                        loadingText,
                        style: AppStyles.h4,
                        textAlign: TextAlign.center,
                      )
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        onPressed: _uploadImages,
        child: const Icon(Icons.upload_rounded),
      ),
    );
  }

  void _uploadImages() async {
    if (loading) return;
    setState(() {
      loading = true;
    });
    try {
      await ref.read(dioServicesProvider).postEventImages(
            widget.eventId,
            widget.images.map((e) => File(e.path)).toList(),
          );
      setState(() {
        loading = false;
      });
      navigatorKey.currentState!.pop(true);
      showSnackBar(message: "Images uploaded successfully");
    } catch (e) {
      setState(() {
        loading = false;
      });
      showSnackBar(message: "Something went wrong!");
    }
  }
}
