import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final imageServicesProvider = Provider((ref) => ImageServices());

class ImageServices {
  final imagePicker = ImagePicker();

  Future<XFile?> pickImage() async {
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 20);
    return pickedImage;
  }

  Future<List<XFile?>> pickMultipleImages() async {
    final pickedImages = await imagePicker.pickMultiImage(imageQuality: 20, maxWidth: 1920);
    return pickedImages;
  }
}
