
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';

class PersonalProfileModifyController extends GetxController {

  RxInt barIndex = 0.obs;

  int getBarIndex() => barIndex.value;

  void setBarIndex(int _index) {
    barIndex.value = _index;
  }

  RxString name = ''.obs;

  String getName() => name.value;

  void setName(String _name) {
    name.value = _name;
    checkName();
  }

  RxBool isCheckName = false.obs;

  bool getIsCheckName() => isCheckName.value;

  void setIsCheckName(bool _isCheck) {
    isCheckName.value = _isCheck;
  }

  void checkName() {
    if (validNameErrorText(getName()) == null) {
      setIsCheckName(true);
    } else {
      setIsCheckName(false);
    }
    checkFilledRequiredInfo();
  }

  var isCheckFilledRequiredInfo = false.obs;

  bool getIsCheckFilledRequiredInfo() => isCheckFilledRequiredInfo.value;

  void setIsCheckFilledRequiredInfo(bool _isCheck) {
    isCheckFilledRequiredInfo.value = _isCheck;
  }

  bool checkFilledRequiredInfo() {
    if (isCheckName.value &&
        job.value.isNotEmpty &&
        part.value.isNotEmpty &&
        location.value.isNotEmpty &&
        subLocation.value.isNotEmpty &&
        information.value.isNotEmpty) {
      setIsCheckFilledRequiredInfo(true);
      return true;
    } else {
      setIsCheckFilledRequiredInfo(false);
      return false;
    }
  }

  RxString job = ''.obs;
  RxString part = ''.obs;
  RxString subJob = ''.obs;
  RxString subPart = ''.obs;

  RxString location = ''.obs;
  RxString subLocation = ''.obs;

  RxString information = ''.obs;

  RxList badgeList = [].obs;

  RxList educationList = [].obs;
  RxList careerList = [].obs;
  RxList licenseList = [].obs;
  RxList winList = [].obs;

  RxString portfolioUrl = ''.obs;
  RxString resumeUrl = ''.obs;
  RxString siteUrl = ''.obs;
  RxString linkedInUrl = ''.obs;
  RxString instagramUrl = ''.obs;
  RxString facebookUrl = ''.obs;
  RxString gitHubUrl = ''.obs;
  RxString notionUrl = ''.obs;

  RxList profileImgList = [].obs;
  List<int> deletedImgIdList = [];
  bool isChangePhotos = false;

  @override
  void onInit() {
    super.onInit();
  }

  void loading(){
    name.value = GlobalProfile.loggedInUser.name;
    job.value = GlobalProfile.loggedInUser.job;
    part.value = GlobalProfile.loggedInUser.part;
    subJob.value = GlobalProfile.loggedInUser.subJob;
    subPart.value = GlobalProfile.loggedInUser.subPart;
    location.value = GlobalProfile.loggedInUser.location;
    subLocation.value = GlobalProfile.loggedInUser.subLocation;
    information.value = GlobalProfile.loggedInUser.information;
    if(GlobalProfile.loggedInUser.profileImgList[0].id == -2){//기본이미지만 담겨있으면.
      profileImgList.clear();
    } else {
      profileImgList.addAll(GlobalProfile.loggedInUser.profileImgList);
    }
    isChangePhotos = false;
    if(GlobalProfile.loggedInUser.badge1 != null && GlobalProfile.loggedInUser.badge1 > 0) badgeList.add(GlobalProfile.loggedInUser.badge1);
    if(GlobalProfile.loggedInUser.badge2 != null && GlobalProfile.loggedInUser.badge2 > 0) badgeList.add(GlobalProfile.loggedInUser.badge2);
    if(GlobalProfile.loggedInUser.badge3 != null && GlobalProfile.loggedInUser.badge3 > 0) badgeList.add(GlobalProfile.loggedInUser.badge3);
    educationList.addAll(GlobalProfile.loggedInUser.userEducationList);
    careerList.addAll(GlobalProfile.loggedInUser.userCareerList);
    licenseList.addAll(GlobalProfile.loggedInUser.userLicenseList);
    winList.addAll(GlobalProfile.loggedInUser.userWinList);
    portfolioUrl.value = GlobalProfile.loggedInUser.userLink.portfolioUrl;
    resumeUrl.value = GlobalProfile.loggedInUser.userLink.resumeUrl;
    siteUrl.value = GlobalProfile.loggedInUser.userLink.siteUrl;
    linkedInUrl.value = GlobalProfile.loggedInUser.userLink.linkedInUrl;
    instagramUrl.value = GlobalProfile.loggedInUser.userLink.instagramUrl;
    facebookUrl.value = GlobalProfile.loggedInUser.userLink.facebookUrl;
    gitHubUrl.value = GlobalProfile.loggedInUser.userLink.gitHubUrl;
    notionUrl.value = GlobalProfile.loggedInUser.userLink.notionUrl;

    Future.microtask(()async{
      for(int i = 0; i < educationList.length; i++){
        var uri = Uri.parse(ApiProvider().getUrl + educationList[i].imgUrl);
        var response = await get(uri);
        var documentDirectory = await getApplicationDocumentsDirectory();
        var firstPath = documentDirectory.path + "/images";
        var filePathAndName = documentDirectory.path + '/images/pict_education' + i.toString() + getMimeType(educationList[i].imgUrl);
        await Directory(firstPath).create(recursive: true);
        File file2 = File(filePathAndName);
        file2.writeAsBytesSync(response.bodyBytes);
        educationList[i].imgUrl = file2.path;
      }

      for(int i = 0; i < careerList.length; i++){
        var uri = Uri.parse(ApiProvider().getUrl + careerList[i].imgUrl);
        var response = await get(uri);
        var documentDirectory = await getApplicationDocumentsDirectory();
        var firstPath = documentDirectory.path + "/images";
        var filePathAndName = documentDirectory.path + '/images/pict_career' + i.toString() + getMimeType(careerList[i].imgUrl);
        await Directory(firstPath).create(recursive: true);
        File file2 = File(filePathAndName);
        file2.writeAsBytesSync(response.bodyBytes);
        careerList[i].imgUrl = file2.path;
      }

      for(int i = 0; i < licenseList.length; i++){
        var uri = Uri.parse(ApiProvider().getUrl + licenseList[i].imgUrl);
        var response = await get(uri);
        var documentDirectory = await getApplicationDocumentsDirectory();
        var firstPath = documentDirectory.path + "/images";
        var filePathAndName = documentDirectory.path + '/images/pict_license' + i.toString() + getMimeType(licenseList[i].imgUrl);
        await Directory(firstPath).create(recursive: true);
        File file2 = File(filePathAndName);
        file2.writeAsBytesSync(response.bodyBytes);
        licenseList[i].imgUrl = file2.path;
      }

      for(int i = 0; i < winList.length; i++){
        var uri = Uri.parse(ApiProvider().getUrl + winList[i].imgUrl);
        var response = await get(uri);
        var documentDirectory = await getApplicationDocumentsDirectory();
        var firstPath = documentDirectory.path + "/images";
        var filePathAndName = documentDirectory.path + '/images/pict_win' + i.toString() + getMimeType(winList[i].imgUrl);
        await Directory(firstPath).create(recursive: true);
        File file2 = File(filePathAndName);
        file2.writeAsBytesSync(response.bodyBytes);
        winList[i].imgUrl = file2.path;
      }
    });
  }
}
