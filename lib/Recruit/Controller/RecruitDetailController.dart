import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sheeps_app/Recruit/Models/PersonalSeekTeams.dart';
import 'package:sheeps_app/Recruit/Models/RecruitLikes.dart';
import 'package:sheeps_app/Recruit/Models/TeamMemberRecruit.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';

class RecruitDetailController extends GetxController {
  final PageController pageController = PageController();

  RxInt currentPage = 0.obs;
  RxBool shrinkState = false.obs;

  // 디테일 페이지 데이터 변수
  int id;
  int targetID;
  String title = '',
      name = '',
      state = '',
      contents = '',
      periodStart = '',
      periodEnd = '',
      roleContents = '',
      preferenceInfo = '',
      workCondition = '',
      abilityContents = '',
      volunteerQualification = '';
  List<String> photoUrlList = [];
  List<String> firstWrapList = [];
  List<String> secondWrapList = [];
  List<String> thirdWrapList = [];
  List<String> fourthWrapList = [];
  List<String> workConditionList = [];
  List<String> careerList = [];
  List<int> careerAuthList = [];
  RxBool isLike = false.obs; // 좋아요

  @override
  void onClose() {
    super.onClose();
    pageController.dispose();
  }

  void dataSet(bool isRecruit, data) {
    photoUrlList.clear();
    firstWrapList.clear();
    secondWrapList.clear();
    thirdWrapList.clear();
    fourthWrapList.clear();
    workConditionList.clear();
    careerList.clear();
    careerAuthList.clear();

    if (isRecruit) {
      TeamMemberRecruit teamMemberRecruit = data;
      Team team = GlobalProfile.getTeamByID(teamMemberRecruit.teamId); // 팀 데이터

      id = teamMemberRecruit.id;
      targetID = team.leaderID;
      title = cutAuthInfo(teamMemberRecruit.title);
      name = team.name;
      state = setPeriodState(teamMemberRecruit.recruitPeriodEnd);
      contents = teamMemberRecruit.recruitInfo;
      roleContents = teamMemberRecruit.roleContents;
      photoUrlList = team.profileImgList.map((TeamProfileImg teamProfileImg) => teamProfileImg.imgUrl).toList();
      periodStart = setDateTime(teamMemberRecruit.recruitPeriodStart);
      periodEnd = setDateTime(teamMemberRecruit.recruitPeriodEnd);
      preferenceInfo = teamMemberRecruit.detailPreferenceInfoContents;
      workCondition = teamMemberRecruit.detailWorkCondition;
      volunteerQualification = teamMemberRecruit.detailVolunteerQualification;

      firstWrapList.add(teamMemberRecruit.servicePart);
      firstWrapList.add(teamMemberRecruit.location + ' ${teamMemberRecruit.subLocation}');
      firstWrapList.add(team.category);
      secondWrapList.add(teamMemberRecruit.recruitSubField);
      secondWrapList.add(teamMemberRecruit.category);
      thirdWrapList.add(teamMemberRecruit.education);
      thirdWrapList.add(teamMemberRecruit.career);
      if (teamMemberRecruit.preferenceInfo.isNotEmpty) fourthWrapList.addAll(teamMemberRecruit.preferenceInfo.split(' | '));
      for(int i = 0; i < fourthWrapList.length; i++){
        if(fourthWrapList[i].isEmpty) fourthWrapList.removeAt(i);
      }
      String workFormFirst = teamMemberRecruit.workFormFirst == '협의' ? '직급협의': teamMemberRecruit.workFormFirst;
      workConditionList.add(workFormFirst);
      if (teamMemberRecruit.workFormSecond.isNotEmpty){
        String workFormSecond = teamMemberRecruit.workFormSecond == '협의' ? '직급협의': teamMemberRecruit.workFormSecond;
        workConditionList.add(workFormSecond);
      }
      String workDayOfWeek = teamMemberRecruit.workDayOfWeek == '협의' ? '근무일협의' : teamMemberRecruit.workDayOfWeek;
      workConditionList.add(workDayOfWeek);
      String workTime = teamMemberRecruit.workTime;
      if(workTime == '자율') workTime = '자율출퇴근';
      if(workTime == '협의') workTime = '근무시간협의';
      workConditionList.add(workTime);
      if (teamMemberRecruit.welfare.isNotEmpty) workConditionList.addAll(teamMemberRecruit.welfare.split(' | '));

      checkLike(isRecruit); // 좋아요 여부 확인
    } else {
      PersonalSeekTeam personalSeekTeam = data;
      UserData user = GlobalProfile.getUserByUserID(personalSeekTeam.userId);

      id = personalSeekTeam.id;
      targetID = personalSeekTeam.userId;
      title = cutAuthInfo(personalSeekTeam.title);
      name = user.name;
      state = personalSeekTeam.seekingState == 1 ? "구직중" : "구직완료";
      contents = personalSeekTeam.selfInfo;
      abilityContents = personalSeekTeam.abilityContents;
      photoUrlList = user.profileImgList.map((UserProfileImg userProfileImg) => userProfileImg.imgUrl).toList();
      periodStart = timeCheck(user.updatedAt);
      workCondition = personalSeekTeam.needWorkConditionContents;

      firstWrapList.add(personalSeekTeam.seekingFieldSubPart);
      if (user.part != personalSeekTeam.seekingFieldSubPart)
        firstWrapList.add(user.part);
      else
        firstWrapList.add(user.subPart);
      firstWrapList.add(personalSeekTeam.location + ' ${personalSeekTeam.subLocation}');
      secondWrapList.add(personalSeekTeam.seekingFieldSubPart);
      secondWrapList.add(personalSeekTeam.category);
      thirdWrapList.add(personalSeekTeam.education);
      thirdWrapList.add(personalSeekTeam.career);

      // 학력
      if (user.userEducationList.isNotEmpty) careerList.add(user.userEducationList[0].contents);
      if (user.userEducationList.isNotEmpty) careerAuthList.add(user.userEducationList[0].auth);
      // 경력
      if (user.userCareerList.isNotEmpty) {
        List.generate(user.userCareerList.length, (index) {
          careerList.add(user.userCareerList[index].contents);
          careerAuthList.add(user.userCareerList[index].auth);
        });
      }
      // 자격증
      if (user.userLicenseList.isNotEmpty) {
        List.generate(user.userLicenseList.length, (index) {
          careerList.add(user.userLicenseList[index].contents);
          careerAuthList.add(user.userLicenseList[index].auth);
        });
      }

      String workFormFirst = personalSeekTeam.workFormFirst == '협의' ? '직급협의': personalSeekTeam.workFormFirst;
      workConditionList.add(workFormFirst);
      if (personalSeekTeam.workFormSecond.isNotEmpty){
        String workFormSecond = personalSeekTeam.workFormSecond == '협의' ? '직급협의': personalSeekTeam.workFormSecond;
        workConditionList.add(workFormSecond);
      }
      String workDayOfWeek = personalSeekTeam.workDayOfWeek == '협의' ? '근무일협의' : personalSeekTeam.workDayOfWeek;
      workConditionList.add(workDayOfWeek);
      String workTime = personalSeekTeam.workTime;
      if(workTime == '자율') workTime = '자율출퇴근';
      if(workTime == '협의') workTime = '근무시간협의';
      workConditionList.add(workTime);

      if (personalSeekTeam.welfare.isNotEmpty) workConditionList.addAll(personalSeekTeam.welfare.split(' | '));

      checkLike(isRecruit); // 좋아요 여부 확인
    }
  }

  // 좋아요 처리 함수
  Future<void> likeFunc(bool isRecruit, {@required List dataList}) async {
    if (isRecruit) {
      var res = await ApiProvider().post(
        '/Matching/Insert/TeamMemberRecruitLike',
        jsonEncode({
          "userID": GlobalProfile.loggedInUser.userID,
          "targetID": id,
        }),
      );

      if (res['created']) {
        RecruitLikes recruitLikes = RecruitLikes.fromJson(res['item']);
        recruitLikesList.add(recruitLikes);
      } else {
        recruitLikesList.removeWhere((element) => element.targetId == id);
        if(dataList.isNotEmpty) dataList.removeWhere((element) => element.id == id); // 전 페이지에 삭제되는거 반영
      }
    } else {
      var res = await ApiProvider().post(
        '/Matching/Insert/PersonalSeekTeamLike',
        jsonEncode({
          "userID": GlobalProfile.loggedInUser.userID,
          "targetID": id,
        }),
      );

      if (res['created']) {
        RecruitLikes recruitLikes = RecruitLikes.fromJson(res['item']);
        personalSeekLikesList.add(recruitLikes);
      } else {
        personalSeekLikesList.removeWhere((element) => element.targetId == id);
        if(dataList.isNotEmpty) dataList.removeWhere((element) => element.id == id); // 전 페이지에 삭제되는거 반영
      }
    }

    checkLike(isRecruit); // 화면에 다시 그려주기 위해 체크
  }

  // 좋아요 여부 확인
  void checkLike(bool isRecruit) {
    isLike(false); // false로 초기화 후 리스트에 값이 있으면 true

    if (isRecruit) {
      recruitLikesList.forEach((element) {
        if (element.targetId == id) isLike(true);
      });
    } else {
      personalSeekLikesList.forEach((element) {
        if (element.targetId == id) isLike(true);
      });
    }
  }

  // 날짜 변환 함수
  String setDateTime(String dateTime) {
    if (dateTime == '상시모집') return '상시';

    DateTime tempDate = DateTime.parse(dateTime.substring(0, 8));
    String result = DateFormat('yyyy년 M월 d일').format(tempDate);
    return result;
  }

  // 스크롤 이벤트
  void scrollListenerEvent(ScrollController scrollController) {
    bool isShrink = scrollController.hasClients && scrollController.offset > (Get.height * 0.45 - kToolbarHeight);

    if (isShrink != shrinkState.value) shrinkState(isShrink);
  }

  // 페이지 체인지 이벤트
  void pageChangeEvent(int index) async {
    currentPage(index);
  }
}
