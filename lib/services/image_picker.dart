import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final imageServicesProvider = Provider((ref) => ImageServices());

class ImageServices {
  final imagePicker = ImagePicker();

  Future<XFile?> pickImage() async {
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    return pickedImage;
  }
}
