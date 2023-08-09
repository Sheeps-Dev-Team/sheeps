
import 'package:get/get.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/Recruit/Models/PersonalSeekTeams.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';

class PersonalSeekTeamsEditController extends GetxController {

  RxInt barIndex = 0.obs;

  int getBarIndex() => barIndex.value;

  void setBarIndex(int _index) {
    barIndex.value = _index;
  }

  RxString title = ''.obs;
  RxBool seekingState = true.obs;
  RxString selfInfo = ''.obs;

  RxBool isCategoryDevelopment = false.obs;
  RxBool isCategoryOperation = false.obs;
  RxBool isCategoryDesign = false.obs;
  RxBool isCategoryMarketing = false.obs;
  RxBool isCategorySales = false.obs;

  String job = '';
  String part = '';
  String subJob = '';
  String subPart = '';
  RxBool isPart1 = false.obs;
  RxBool isPart2 = false.obs;

  RxString abilityContents = ''.obs;

  List<UserEducation> educationList = [];

  RxBool isEduHighSchool = false.obs; //고졸
  RxBool isEduCollege = false.obs; //초대졸
  RxBool isEduBachelor = false.obs; //대졸
  RxBool isEduMaster = false.obs; //석사
  RxBool isEduDoctor = false.obs; //박사

  List<UserCareer> careerList = [];

  RxBool isCareerNew = false.obs;//신입
  RxBool isCareerCareer = false.obs;//경력
  RxBool isCareerAny = false.obs;//무관

  List<UserLicense> licenseList = [];
  List<UserWin> winList = [];

  RxString portfolioUrl = ''.obs;
  RxString resumeUrl = ''.obs;
  RxString siteUrl = ''.obs;
  RxString linkedInUrl = ''.obs;
  RxString instagramUrl = ''.obs;
  RxString facebookUrl = ''.obs;
  RxString gitHubUrl = ''.obs;
  RxString notionUrl = ''.obs;

  RxList workForm = [].obs;

  RxBool isWorkDayOfWeek5 = false.obs;
  RxBool isWorkDayOfWeek6 = false.obs;
  RxBool isWorkDayOfWeek3 = false.obs;
  RxBool isWorkDayOfWeekFlexible = false.obs;
  RxBool isWorkDayOfWeekNegotiable = false.obs;

  RxBool isWorkTime8 = false.obs;
  RxBool isWorkTimeFlexible = false.obs;
  RxBool isWorkTimeAutonomous = false.obs;
  RxBool isWorkTimeNegotiable = false.obs;

  RxList welfare = [].obs;

  RxString needWorkConditionContents = ''.obs;


  bool checkFilledRequiredInfo() {
    if (title.value.isNotEmpty &&
        removeSpace(title.value).length <= 42 &&
        selfInfo.value.isNotEmpty &&
        (isCategoryDevelopment.value||isCategoryOperation.value||isCategoryDesign.value||isCategoryMarketing.value||isCategorySales.value) &&
        (isPart1.value||isPart2.value)&&
        abilityContents.isNotEmpty&&
        (workForm.length > 0)&&
        (isWorkDayOfWeek5.value||isWorkDayOfWeek6.value||isWorkDayOfWeek3.value||isWorkDayOfWeekFlexible.value||isWorkDayOfWeekNegotiable.value) &&
        (isWorkTime8.value||isWorkTimeFlexible.value||isWorkTimeAutonomous.value||isWorkTimeNegotiable.value)) {
      return true;
    } else {
      return false;
    }
  }

  bool checkActiveNext1(){
    if(title.value.isNotEmpty &&
        removeSpace(title.value).length <= 42 &&
        selfInfo.value.isNotEmpty &&
        (isCategoryDevelopment.value||isCategoryOperation.value||isCategoryDesign.value||isCategoryMarketing.value||isCategorySales.value) &&
        (isPart1.value||isPart2.value)&&
        abilityContents.isNotEmpty){
      return true;
    }else{
      return false;
    }
  }

  void loading(){
    job = GlobalProfile.loggedInUser!.job;
    part = GlobalProfile.loggedInUser!.part;
    subJob = GlobalProfile.loggedInUser!.subJob;
    subPart = GlobalProfile.loggedInUser!.subPart;
    for(int i = 0; i < GlobalProfile.loggedInUser!.userEducationList.length; i++){
      if(GlobalProfile.loggedInUser!.userEducationList[i].auth != 0){
        educationList.add(GlobalProfile.loggedInUser!.userEducationList[i]);
      }
    }
    for(int i = 0; i < GlobalProfile.loggedInUser!.userCareerList.length; i++){
      if(GlobalProfile.loggedInUser!.userCareerList[i].auth != 0){
        careerList.add(GlobalProfile.loggedInUser!.userCareerList[i]);
      }
    }
    for(int i = 0; i < GlobalProfile.loggedInUser!.userLicenseList.length; i++){
      if(GlobalProfile.loggedInUser!.userLicenseList[i].auth != 0){
        licenseList.add(GlobalProfile.loggedInUser!.userLicenseList[i]);
      }
    }
    for(int i = 0; i < GlobalProfile.loggedInUser!.userWinList.length; i++){
      if(GlobalProfile.loggedInUser!.userWinList[i].auth != 0){
        winList.add(GlobalProfile.loggedInUser!.userWinList[i]);
      }
    }
    if(GlobalProfile.loggedInUser!.userLink != null) {
      portfolioUrl.value = GlobalProfile.loggedInUser!.userLink!.portfolioUrl;
      resumeUrl.value = GlobalProfile.loggedInUser!.userLink!.resumeUrl;
      siteUrl.value = GlobalProfile.loggedInUser!.userLink!.siteUrl;
      linkedInUrl.value = GlobalProfile.loggedInUser!.userLink!.linkedInUrl;
      instagramUrl.value = GlobalProfile.loggedInUser!.userLink!.instagramUrl;
      facebookUrl.value = GlobalProfile.loggedInUser!.userLink!.facebookUrl;
      gitHubUrl.value = GlobalProfile.loggedInUser!.userLink!.gitHubUrl;
      notionUrl.value = GlobalProfile.loggedInUser!.userLink!.notionUrl;
    }
  }

  void editLoading(PersonalSeekTeam personalSeekTeam){
    title.value = cutAuthInfo(personalSeekTeam.title);
    seekingState.value = personalSeekTeam.seekingState == 1 ? true : false;
    selfInfo.value = personalSeekTeam.selfInfo;

    switch(personalSeekTeam.category){
      case '개발' :
        isCategoryDevelopment.value = true;
        break;
      case '경영' :
        isCategoryOperation.value = true;
        break;
      case '디자인' :
        isCategoryDesign.value = true;
        break;
      case '마케팅' :
        isCategoryMarketing.value = true;
        break;
      case '영업' :
        isCategorySales.value = true;
        break;
    }

    if(part == personalSeekTeam.seekingFieldSubPart){
      isPart1.value = true;
    } else if(part == personalSeekTeam.seekingFieldSubPart){
      isPart2.value = true;
    }

    abilityContents.value = personalSeekTeam.abilityContents;

    switch(personalSeekTeam.education){
      case '고졸' :
        isEduHighSchool.value = true;
        break;
      case '초대졸' :
        isEduCollege.value = true;
        break;
      case '대졸' :
        isEduBachelor.value = true;
        break;
      case '석사' :
        isEduMaster.value = true;
        break;
      case '박사' :
        isEduDoctor.value = true;
        break;
    }

    switch(personalSeekTeam.career){
      case '신입' :
        isCareerNew.value = true;
        break;
      case '경력' :
        isCareerCareer.value = true;
        break;
      case '경력무관' :
        isCareerAny.value = true;
        break;
    }

    workForm.add(personalSeekTeam.workFormFirst);
    if(personalSeekTeam.workFormSecond.isNotEmpty){
      workForm.add(personalSeekTeam.workFormSecond);
    }

    switch(personalSeekTeam.workDayOfWeek){
      case '주 5일' :
        isWorkDayOfWeek5.value = true;
        break;
      case '주 6일' :
        isWorkDayOfWeek6.value = true;
        break;
      case '주 3일' :
        isWorkDayOfWeek3.value = true;
        break;
      case '탄력근무제' :
        isWorkDayOfWeekFlexible.value = true;
        break;
      case '협의' :
        isWorkDayOfWeekNegotiable.value = true;
        break;
    }

    switch(personalSeekTeam.workTime){
      case '1일 8시간' :
        isWorkTime8.value = true;
        break;
      case '탄력근무' :
        isWorkTimeFlexible.value = true;
        break;
      case '자율' :
        isWorkTimeAutonomous.value = true;
        break;
      case '협의' :
        isWorkTimeNegotiable.value = true;
        break;
    }

    welfare.addAll(personalSeekTeam.welfare.split(' | '));

    needWorkConditionContents.value = personalSeekTeam.needWorkConditionContents;
  }
}
