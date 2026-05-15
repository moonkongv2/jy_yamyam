import 'package:image_picker/image_picker.dart';

abstract interface class AvatarImagePicker {
  Future<XFile?> pickAvatarImage();
}

class DefaultAvatarImagePicker implements AvatarImagePicker {
  DefaultAvatarImagePicker({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  @override
  Future<XFile?> pickAvatarImage() {
    return _imagePicker.pickImage(source: ImageSource.gallery);
  }
}
