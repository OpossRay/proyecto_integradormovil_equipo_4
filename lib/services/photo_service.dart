import 'dart:io';

import 'package:path_provider/path_provider.dart';

class PhotoService {
  Future<String> savePhoto(String sourcePath) async {
    final directory = await getApplicationDocumentsDirectory();

    final photosDirectory = Directory('${directory.path}/inspection_photos');

    if (!await photosDirectory.exists()) {
      await photosDirectory.create(recursive: true);
    }

    final fileName = 'photo_${DateTime.now().microsecondsSinceEpoch}.jpg';

    final destinationPath = '${photosDirectory.path}/$fileName';

    final savedFile = await File(sourcePath).copy(destinationPath);

    return savedFile.path;
  }
}
