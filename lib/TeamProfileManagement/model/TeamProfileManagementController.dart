
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'Team.dart';

class TeamProfileManagementController extends GetxController {

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
        category.value.isNotEmpty &&
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

  RxString category = ''.obs;
  RxString part = ''.obs;

  RxString location = ''.obs;
  RxString subLocation = ''.obs;

  RxBool isRecruiting = true.obs;

  RxString information = ''.obs;

  RxList badgeList = [].obs;

  RxList certificationList = [].obs;
  RxList performancesList = [].obs;
  RxList winList = [].obs;

  RxString siteUrl = ''.obs;
  RxString recruitUrl = ''.obs;
  RxString instagramUrl = ''.obs;
  RxString facebookUrl = ''.obs;

  RxList profileImgList = [].obs;
  List<int> deletedImgIdList = [];
  bool isChangePhotos = false;

  @override
  void onInit() {
    super.onInit();
  }

  void reset(){
    setBarIndex(0);
    name.value = '';
    category.value = '';
    part.value = '';
    location.value = '';
    subLocation.value = '';
    isRecruiting.value = true;
    information.value = '';
    badgeList.clear();
    certificationList.clear();
    performancesList.clear();
    winList.clear();
    siteUrl.value = '';
    recruitUrl.value = '';
    instagramUrl.value = '';
    facebookUrl.value = '';
    profileImgList = [].obs;
    deletedImgIdList = [];
    isChangePhotos = false;
  }

  void loading(Team team){
    name.value = team.name;
    category.value = team.category;
    part.value = team.part;
    location.value = team.location;
    subLocation.value = team.subLocation;
    isRecruiting.value = team.possibleJoin == 1 ? true : false;
    information.value = team.information;
    if(team.badge1 != null && team.badge1 > 0) badgeList.add(team.badge1);
    if(team.badge2 != null && team.badge2 > 0) badgeList.add(team.badge2);
    if(team.badge3 != null && team.badge3 > 0) badgeList.add(team.badge3);
    certificationList.addAll(team.teamAuthList);
    performancesList.addAll(team.teamPerformList);
    winList.addAll(team.teamWinList);
    siteUrl.value = team.teamLink.siteUrl ?? '';
    recruitUrl.value = team.teamLink.recruitUrl ?? '';
    instagramUrl.value = team.teamLink.instagramUrl ?? '';
    facebookUrl.value = team.teamLink.facebookUrl ?? '';

    if(team.profileImgList[0].id == -2){//기본이미지만 담겨있으면.
      profileImgList.clear();
    } else {
      profileImgList.addAll(team.profileImgList);
    }

    Future.microtask(()async{
      for(int i = 0; i < certificationList.length; i++){
        var uri = Uri.parse(ApiProvider().getUrl + certificationList[i].imgUrl);
        var response = await get(uri);
        var documentDirectory = await getApplicationDocumentsDirectory();
        var firstPath = documentDirectory.path + "/images";
        var filePathAndName = documentDirectory.path + '/images/pict_certification' + i.toString() + getMimeType(certificationList[i].imgUrl);
        await Directory(firstPath).create(recursive: true);
        File file2 = File(filePathAndName);
        file2.writeAsBytesSync(response.bodyBytes);
        certificationList[i].imgUrl = file2.path;
      }

      for(int i = 0; i < performancesList.length; i++){
        var uri = Uri.parse(ApiProvider().getUrl + performancesList[i].imgUrl);
        var response = await get(uri);
        var documentDirectory = await getApplicationDocumentsDirectory();
        var firstPath = documentDirectory.path + "/images";
        var filePathAndName = documentDirectory.path + '/images/pict_performance' + i.toString() + getMimeType(performancesList[i].imgUrl);
        await Directory(firstPath).create(recursive: true);
        File file2 = File(filePathAndName);
        file2.writeAsBytesSync(response.bodyBytes);
        performancesList[i].imgUrl = file2.path;
      }

      for(int i = 0; i < winList.length; i++){
        var uri = Uri.parse(ApiProvider().getUrl + winList[i].imgUrl);
        var response = await get(uri);
        var documentDirectory = await getApplicationDocumentsDirectory();
        var firstPath = documentDirectory.path + "/images";
        var filePathAndName = documentDirectory.path + '/images/pict_teamWin' + i.toString() + getMimeType(winList[i].imgUrl);
        await Directory(firstPath).create(recursive: true);
        File file2 = File(filePathAndName);
        file2.writeAsBytesSync(response.bodyBytes);
        winList[i].imgUrl = file2.path;
      }
    });
  }
}
