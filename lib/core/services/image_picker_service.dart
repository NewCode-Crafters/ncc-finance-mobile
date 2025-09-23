import 'package:image_picker/image_picker.dart';

enum ImageSourceType { camera, gallery }

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage({required ImageSourceType source}) async {
    final imageSource = source == ImageSourceType.camera
        ? ImageSource.camera
        : ImageSource.gallery;

    return await _picker.pickImage(source: imageSource);
  }
}
