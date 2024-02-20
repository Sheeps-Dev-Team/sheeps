import 'package:get/get.dart';

import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/config/AppConfig.dart';

class CommunityWriteController extends GetxController {
  RxBool isCategoryCompany = false.obs;
  RxBool isCategorySecret = false.obs;
  RxBool isCategoryPromotion = false.obs;
  RxBool isCategoryFree = false.obs;
  RxBool isCategoryMeeting = false.obs;
  RxBool isCategoryDevelopment = false.obs;
  RxBool isCategoryOperation = false.obs;
  RxBool isCategoryDesign = false.obs;
  RxBool isCategoryMarketing = false.obs;
  RxBool isCategorySales = false.obs;
  RxBool isCategoryCollegeStudent = false.obs;

  void categoryReset() {
    isCategoryCompany.value = false;
    isCategorySecret.value = false;
    isCategoryPromotion.value = false;
    isCategoryFree.value = false;
    isCategoryMeeting.value = false;
    isCategoryDevelopment.value = false;
    isCategoryOperation.value = false;
    isCategoryDesign.value = false;
    isCategoryMarketing.value = false;
    isCategorySales.value = false;
    isCategoryCollegeStudent.value = false;
  }

  RxString title = ''.obs;
  RxString contents = ''.obs;

  RxBool isFilledRequired = true.obs;

  bool checkFilledRequired() {
    isFilledRequired.value = true;
    return true;

    if (removeSpace(title.value).length >= 2 &&
        removeSpace(title.value).length <= 40 &&
        removeSpace(contents.value).length >= 10 &&
        (isCategoryCompany.value ||
            isCategorySecret.value ||
            isCategoryPromotion.value ||
            isCategoryFree.value ||
            isCategoryMeeting.value ||
            isCategoryDevelopment.value ||
            isCategoryOperation.value ||
            isCategoryDesign.value ||
            isCategoryMarketing.value||
            isCategorySales.value ||
            isCategoryCollegeStudent.value)) {
      isFilledRequired.value = true;
      return true;
    } else {
      isFilledRequired.value = false;
      return false;
    }
  }

  RxList imgUrlFilePathList = [].obs;
  List<bool> isFilePathList = [];//새 img 추가하면 true, 수정하기시 기본 false 파일로 변환 완료되면 true.

  void resetData(){
    title.value = '';
    contents.value = '';
    categoryReset();
    imgUrlFilePathList.clear();
    isFilePathList.clear();
  }

  void loading(Community community){
    setCategory(community.category); // 카테고리 설정

    title.value = community.title;
    contents.value = community.contents;
    if(community.imageUrl1 != null && community.imageUrl1!.isNotEmpty){
      imgUrlFilePathList.add(community.imageUrl1);
      isFilePathList.add(false);
    }
    if(community.imageUrl2 != null && community.imageUrl2!.isNotEmpty){
      imgUrlFilePathList.add(community.imageUrl2);
      isFilePathList.add(false);
    }
    if(community.imageUrl3 != null && community.imageUrl3!.isNotEmpty){
      imgUrlFilePathList.add(community.imageUrl3);
      isFilePathList.add(false);
    }
  }

  // 카테고리 set
  void setCategory(String selectedCategory){
    switch(selectedCategory){
      case '회사' :{
        isCategoryCompany.value = true;
        break;
      }
      case '비밀' :{
        isCategorySecret.value = true;
        break;
      }
      case '홍보' :{
        isCategoryPromotion.value = true;
        break;
      }
      case '자유' :{
        isCategoryFree.value = true;
        break;
      }
      case '소모임' :{
        isCategoryMeeting.value = true;
        break;
      }
      case '개발' :{
        isCategoryDevelopment.value = true;
        break;
      }
      case '경영' :{
        isCategoryOperation.value = true;
        break;
      }
      case '디자인' :{
        isCategoryDesign.value = true;
        break;
      }
      case '마케팅' :{
        isCategoryMarketing.value = true;
        break;
      }
      case '영업' :{
        isCategorySales.value = true;
        break;
      }
      case '대학생' :{
        isCategoryCollegeStudent.value = true;
        break;
      }
    }
  }

  // 카테고리에 맞는 bool 매칭
  bool matchingBool(String selectedCategory){
    bool result = false;

    switch(selectedCategory){
      case '회사' :{
        result = isCategoryCompany.value;
        break;
      }
      case '비밀' :{
        result = isCategorySecret.value;
        break;
      }
      case '홍보' :{
        result = isCategoryPromotion.value;
        break;
      }
      case '자유' :{
        result = isCategoryFree.value;
        break;
      }
      case '소모임' :{
        result = isCategoryMeeting.value;
        break;
      }
      case '개발' :{
        result = isCategoryDevelopment.value;
        break;
      }
      case '경영' :{
        result = isCategoryOperation.value;
        break;
      }
      case '디자인' :{
        result = isCategoryDesign.value;
        break;
      }
      case '마케팅' :{
        result = isCategoryMarketing.value;
        break;
      }
      case '영업' :{
        result = isCategorySales.value;
        break;
      }
      case '대학생' :{
        result = isCategoryCollegeStudent.value;
        break;
      }
    }

    return result;
  }
}
