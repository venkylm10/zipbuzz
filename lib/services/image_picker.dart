import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

final imageServicesProvider = Provider((ref) => ImageServices());

class ImageServices {
  final imagePicker = ImagePicker();

  Future<File?> pickImage({CropAspectRatio? aspectRatio}) async {
    if (kIsWeb) {
      showSnackBar(message: "Not available on web");
      return null;
    }
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 20,
    );

    if (pickedImage != null && aspectRatio != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        aspectRatio: aspectRatio,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: AppColors.primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.ratio16x9,
              lockAspectRatio: false),
          IOSUiSettings(title: 'Cropper'),
          WebUiSettings(
            context: navigatorKey.currentContext!,
          ),
        ],
      );
      if (croppedFile == null) return null;
      return File(croppedFile.path);
    }
    if (pickedImage == null) return null;
    return File(pickedImage.path);
  }

  Future<List<XFile?>> pickMultipleImages() async {
    if (kIsWeb) {
      showSnackBar(message: "Not available on web");
      return [];
    }
    final pickedImages = await imagePicker.pickMultiImage(imageQuality: 20, maxWidth: 1920);
    return pickedImages;
  }
}
