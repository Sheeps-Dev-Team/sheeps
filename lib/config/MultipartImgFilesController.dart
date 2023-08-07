import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sheeps_app/config/AppConfig.dart';

class MultipartImgFilesController extends GetxController {
  static MultipartImgFilesController get to => Get.find();

  var filesList = [].obs;

  MultipartImgFilesController(){
    File f;
    filesList.add(f);
  }

  List<bool> flagList = [false, false, false, false, false, false,];
  void addFiles(File addFile) {
    filesList.add(addFile);
    flagList[filesList.length-1] = true;
    var tmp = filesList[filesList.length-1];
    removeFile(targetFile : filesList[filesList.length-2]);
    filesList.add(tmp);
    return;
  }


  void removeFile({File targetFile}) {
    int index = filesList.indexOf(targetFile);
    if (index < 0) return;
    flagList[filesList.length-1] = false;
    filesList.removeAt(index);
    return;
  }


  void swap(int i) {
    var tmp = filesList[i - 1];
    filesList[i - 1] = filesList[i];
    filesList[i] = tmp;
  }


  void reset() {
    List<File> tmp = [];
    filesList(tmp);
  }

  // 갤러리에서 사진 가져오기
  Future getImageGallery() async {
    final picker = ImagePicker();

    var imageFile = await picker.getImage(source: ImageSource.gallery);
    if (imageFile == null) return;

    int fileSize = (await imageFile.readAsBytes()).lengthInBytes;

    if (isBigFile(fileSize)) return;

    addFiles(File(imageFile.path));
    Get.back();
    return;
  }

  // 카메라에서 사진 가져오기
  Future getImageCamera() async {
    final picker = ImagePicker();

    var imageFile = await picker.getImage(source: ImageSource.camera);
    if (imageFile == null) return;

    int fileSize = (await imageFile.readAsBytes()).lengthInBytes;

    if (isBigFile(fileSize)) return;

    addFiles(File(imageFile.path));
    Get.back();
    return;
  }
}
