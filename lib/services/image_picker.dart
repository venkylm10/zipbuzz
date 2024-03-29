import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

final imageServicesProvider = Provider((ref) => ImageServices());

class ImageServices {
  final imagePicker = ImagePicker();

  Future<XFile?> pickImage() async {
    if (kIsWeb) {
      showSnackBar(message: "Not available on web");
      return null;
    }
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 20,
    );
    return pickedImage;
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
