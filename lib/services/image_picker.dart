import 'package:image_picker/image_picker.dart';

class ImageServices {
  final imagePicker = ImagePicker();

  Future<XFile?> pickImage() async {
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    return pickedImage;
  }
}
