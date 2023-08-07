import 'package:get/get.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/Recruit/Models/TeamMemberRecruit.dart';

class TeamMemberRecruitEditController extends GetxController {
  RxInt barIndex = 0.obs;

  int getBarIndex() => barIndex.value;

  void setBarIndex(int _index) {
    barIndex.value = _index;
  }

  RxString title = ''.obs;

  RxBool isAlwaysRecruit = false.obs;
  RxString recruitPeriodStart = ''.obs;
  RxString recruitPeriodEnd = ''.obs;

  RxString recruitInfo = ''.obs;

  RxBool isCategoryStartup = false.obs;
  RxBool isCategorySupport = false.obs;
  RxBool isCategoryCompetition = false.obs;
  RxBool isCategorySmallClass = false.obs;

  String recruitJob = '';
  RxString recruitPart = ''.obs;

  RxString roleContents = ''.obs;

  RxBool isEduAny = false.obs; //무관
  RxBool isEduHighSchool = false.obs; //고졸
  RxBool isEduCollege = false.obs; //초대졸
  RxBool isEduBachelor = false.obs; //대졸
  RxBool isEduMaster = false.obs; //석사
  RxBool isEduDoctor = false.obs; //박사

  RxBool isCareerNew = false.obs; //신입
  RxBool isCareerCareer = false.obs; //경력
  RxBool isCareerAny = false.obs; //무관

  RxString detailEligibility = ''.obs;

  RxList preferenceInfoList = [].obs;

  RxString detailPreferenceInfoContents = ''.obs;

  RxList workFormList = [].obs;

  RxBool isWorkDayOfWeek5 = false.obs;
  RxBool isWorkDayOfWeek6 = false.obs;
  RxBool isWorkDayOfWeek3 = false.obs;
  RxBool isWorkDayOfWeekFlexible = false.obs;
  RxBool isWorkDayOfWeekNegotiable = false.obs;

  RxBool isWorkTime8 = false.obs;
  RxBool isWorkTimeFlexible = false.obs;
  RxBool isWorkTimeAutonomous = false.obs;
  RxBool isWorkTimeNegotiable = false.obs;

  RxList welfareList = [].obs;

  RxString detailWorkCondition = ''.obs;

  bool checkFilledRequiredInfo() {
    if (title.value.isNotEmpty &&
        removeSpace(title.value).length <= 42 &&
        recruitPeriodStart.value.isNotEmpty &&
        recruitPeriodEnd.value.isNotEmpty &&
        recruitInfo.value.isNotEmpty &&
        (isCategoryStartup.value || isCategorySupport.value || isCategoryCompetition.value || isCategorySmallClass.value) &&
        recruitPart.value.isNotEmpty &&
        roleContents.isNotEmpty &&
        (isEduAny.value || isEduHighSchool.value || isEduCollege.value || isEduBachelor.value || isEduMaster.value || isEduDoctor.value) &&
        (isCareerNew.value || isCareerCareer.value || isCareerAny.value) &&
        (workFormList.length > 0) &&
        (isWorkDayOfWeek5.value || isWorkDayOfWeek6.value || isWorkDayOfWeek3.value || isWorkDayOfWeekFlexible.value || isWorkDayOfWeekNegotiable.value) &&
        (isWorkTime8.value || isWorkTimeFlexible.value || isWorkTimeAutonomous.value || isWorkTimeNegotiable.value)) {
      return true;
    } else {
      return false;
    }
  }

  bool checkFilledDetailQualification(){
    if(detailEligibility.value.isEmpty && preferenceInfoList.length == 0 && detailPreferenceInfoContents.value.isEmpty && welfareList.length == 0 && detailWorkCondition.value.isEmpty){
      return true;
    } else {
      return false;
    }
  }

  bool checkActiveNext1(){
    if(title.value.isNotEmpty &&
        removeSpace(title.value).length <= 42 &&
        recruitPeriodStart.value.isNotEmpty &&
        recruitPeriodEnd.value.isNotEmpty &&
        recruitInfo.value.isNotEmpty &&
        (isCategoryStartup.value || isCategorySupport.value || isCategoryCompetition.value || isCategorySmallClass.value) &&
        recruitPart.value.isNotEmpty &&
        roleContents.isNotEmpty){
      return true;
    }else{
      return false;
    }
  }

  bool checkActiveNext2(){
    if((isEduAny.value || isEduHighSchool.value || isEduCollege.value || isEduBachelor.value || isEduMaster.value || isEduDoctor.value) &&
        (isCareerNew.value || isCareerCareer.value || isCareerAny.value)){
      return true;
    }else{
      return false;
    }
  }

  void editLoading(TeamMemberRecruit teamMemberRecruit) {
    title.value = cutAuthInfo(teamMemberRecruit.title);

    recruitPeriodStart.value = setDate(teamMemberRecruit.recruitPeriodStart);
    recruitPeriodEnd.value = setDate(teamMemberRecruit.recruitPeriodEnd);
    if (teamMemberRecruit.recruitPeriodEnd == '상시모집') {
      isAlwaysRecruit.value = true;
    }

    recruitInfo.value = teamMemberRecruit.recruitInfo;

    switch (teamMemberRecruit.category) {
      case '팀・스타트업':
        isCategoryStartup.value = true;
        break;
      case '지원사업':
        isCategorySupport.value = true;
        break;
      case '공모전':
        isCategoryCompetition.value = true;
        break;
      case '소모임':
        isCategorySmallClass.value = true;
        break;
    }

    recruitJob = teamMemberRecruit.recruitField;
    recruitPart.value = teamMemberRecruit.recruitSubField;

    roleContents.value = teamMemberRecruit.roleContents;

    switch (teamMemberRecruit.education) {
      case '학력무관':
        isEduAny.value = true;
        break;
      case '고졸이상':
        isEduHighSchool.value = true;
        break;
      case '초대졸이상':
        isEduCollege.value = true;
        break;
      case '대졸이상':
        isEduBachelor.value = true;
        break;
      case '석사이상':
        isEduMaster.value = true;
        break;
      case '박사졸업':
        isEduDoctor.value = true;
        break;
    }

    switch (teamMemberRecruit.career) {
      case '신입':
        isCareerNew.value = true;
        break;
      case '경력':
        isCareerCareer.value = true;
        break;
      case '경력무관':
        isCareerAny.value = true;
        break;
    }

    detailEligibility.value = teamMemberRecruit.detailVolunteerQualification;

    preferenceInfoList.addAll(teamMemberRecruit.preferenceInfo.split(' | '));

    detailPreferenceInfoContents.value = teamMemberRecruit.detailPreferenceInfoContents;

    workFormList.add(teamMemberRecruit.workFormFirst);
    if (teamMemberRecruit.workFormSecond.isNotEmpty) {
      workFormList.add(teamMemberRecruit.workFormSecond);
    }

    switch (teamMemberRecruit.workDayOfWeek) {
      case '주 5일':
        isWorkDayOfWeek5.value = true;
        break;
      case '주 6일':
        isWorkDayOfWeek6.value = true;
        break;
      case '주 3일':
        isWorkDayOfWeek3.value = true;
        break;
      case '탄력근무제':
        isWorkDayOfWeekFlexible.value = true;
        break;
      case '협의':
        isWorkDayOfWeekNegotiable.value = true;
        break;
    }

    switch (teamMemberRecruit.workTime) {
      case '1일 8시간':
        isWorkTime8.value = true;
        break;
      case '탄력근무':
        isWorkTimeFlexible.value = true;
        break;
      case '자율':
        isWorkTimeAutonomous.value = true;
        break;
      case '협의':
        isWorkTimeNegotiable.value = true;
        break;
    }

    welfareList.addAll(teamMemberRecruit.welfare.split(' | '));

    detailWorkCondition.value = teamMemberRecruit.detailWorkCondition;
  }

  String setDate(String date) {
    if(date.length < 8){
      return date;
    } else{
      String result = date.substring(0, 4) + '년 ' + date.substring(4, 6) + '월 ' + date.substring(6, 8) + '일';
      return result;
    }
  }
}
