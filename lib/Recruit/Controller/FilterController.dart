import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheeps_app/Recruit/Controller/RecruitController.dart';
import 'package:sheeps_app/Recruit/Models/PersonalSeekTeams.dart';
import 'package:sheeps_app/Recruit/Models/TeamMemberRecruit.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/ListForProfileModify.dart';
import 'package:sheeps_app/dashboard/DashBoardMain.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';

class FilterController extends GetxController {
  static FilterController get to => Get.find<FilterController>();

  final int checkTrue = 0; // 필터 체크 여부
  final int checkFalse = 1; // 필터 체크 여부

  List<TeamMemberRecruit> filteredRecruitList = []; // 팀원모집 필터 리스트
  List<PersonalSeekTeam> filteredPersonalSeekList = []; // 팀 찾기 필터 리스트
  List<TeamMemberRecruit> recruitSearchList = []; // 팀원모집 검색 리스트
  List<PersonalSeekTeam> personalSeekSearchList = []; // 팀 찾기 검색 리스트

  List<TeamMemberRecruit> dashBoardRecruitList = []; // 대쉬보드 구직중인 포로필 리스트
  List<PersonalSeekTeam> dashBoardSeekList = []; // 대쉬보드 구직중인 포로필 리스트

  List<Team> myTeamList = []; // 내가 속한 모든 팀 리스트

  bool recruitFiltered = false; // 필터 적용 여부
  bool personalSeekFiltered = false; // 필터 적용 여부
  RxBool recruitFilterColor = false.obs; // 필터 아이콘 색 적용 여부
  RxBool personalSeekFilterColor = false.obs; // 필터 아이콘 색 적용 여부

  bool searchForRecruit = false; // 검색 적용 여부
  bool searchForPersonalSeek = false; // 검색 적용 여부
  String searchWordForRecruit = ''; // 검색어 저장할 변수
  String searchWordForSeek = ''; // 검색어 저장할 변수

  bool showRecruitmentOnly = false; // 모집중만 보기
  RxBool tempShowRecruitmentOnly = false.obs; // 임시 모집중만 보기
  bool showSeekingOnly = false; // 구직중만 보기
  RxBool tempShowSeekingOnly = false.obs; // 임시 구직중만 보기

  bool canCallOffset = true; // offset 중복호출 방지

  // 대시보드 필터에 적용된 단어 (팀원모집)
  Map<String, String> dashBoardFilterWordForRecruit = {
    'recruitPart': '',
    'location': '',
  };

  // 대시보드 필터에 적용된 단어 (팁 찾기)
  Map<String, String> dashBoardFilterWordForSeek = {
    'personalSeekPart': '',
    'location': '',
  };

  // 팀원모집 분야 (Recruit)
  RxList<bool> jobFieldForRecruit = List<bool>.generate(FieldCategory.length, (index) => false).obs;
  RxList<bool> tempJobFieldForRecruit = List<bool>.generate(FieldCategory.length, (index) => false).obs;

  // 서비스 분야 (Recruit)
  RxList<bool> serviceFieldForRecruit = List<bool>.generate(serviceFieldList.length, (index) => false).obs;
  RxList<bool> tempServiceFieldForRecruit = List<bool>.generate(serviceFieldList.length, (index) => false).obs;

  // 지역 (Recruit)
  RxList<bool> locationListForRecruit = List<bool>.generate(locationNameList.length, (index) => false).obs;
  RxList<bool> tempLocationListForRecruit = List<bool>.generate(locationNameList.length, (index) => false).obs;

  // 구직 분야 (Seek)
  RxList<bool> jobFieldForSeek = List<bool>.generate(FieldCategory.length, (index) => false).obs;
  RxList<bool> tempJobFieldForSeek = List<bool>.generate(FieldCategory.length, (index) => false).obs;

  // 최소 학력 (Seek)
  RxList<bool> educationListForSeek = List<bool>.generate(educationList.length, (index) => false).obs;
  RxList<bool> tempEducationListForSeek = List<bool>.generate(educationList.length, (index) => false).obs;

  // 근무 형태 (Seek)
  RxList<bool> workTypeForSeek = List<bool>.generate(workTypeList.length, (index) => false).obs;
  RxList<bool> tempWorkTypeForSeek = List<bool>.generate(workTypeList.length, (index) => false).obs;

  // 지역 (Seek)
  RxList<bool> locationListForSeek = List<bool>.generate(locationNameList.length, (index) => false).obs;
  RxList<bool> tempLocationListForSeek = List<bool>.generate(locationNameList.length, (index) => false).obs;

  // 팀원모집 필터 검색 시 사용되는 변수
  int recruitOrderRule = 0;
  String recruitPart, servicePart, recruitLocation;
  int recruitCheckAll = 1;
  int serviceCheckAll = 1;
  int recruitLocationCheckAll = 1;

  // 팀 찾기 필터 검색 시 사용되는 변수
  int seekingOrderRule = 0;
  String seekingFieldPart, education, workForm, seekingLocation;
  int seekingFieldPartCheckAll = 1;
  int educationCheckAll = 1;
  int workFormCheckAll = 1;
  int seekingLocationCheckAll = 1;

  // filter 아이콘 색 체크 함수
  void checkFilterColorForRecruit(){
    // 모집 중만 보기 체크
    if(tempShowRecruitmentOnly.value) {
      recruitFilterColor(true);
      return;
    }
    // 팀원모집 분야 체크
    if(tempJobFieldForRecruit.contains(true)) {
      recruitFilterColor(true);
      return;
    }
    // 서비스 분야 체크
    if(tempServiceFieldForRecruit.contains(true)) {
      recruitFilterColor(true);
      return;
    }
    // 지역 체크
    if(tempLocationListForRecruit.contains(true)) {
      recruitFilterColor(true);
      return;
    }

    recruitFilterColor(false); // 아무것도 켜져 있지 않을 때
  }

  // filter 아이콘 색 체크 함수
  void checkFilterColorForPersonalSeek(){
    // 모집 중만 보기 체크
    if(tempShowSeekingOnly.value) {
      personalSeekFilterColor(true);
      return;
    }
    // 구직분야 체크
    if(tempJobFieldForSeek.contains(true)) {
      personalSeekFilterColor(true);
      return;
    }
    // 최소학력 체크
    if(tempEducationListForSeek.contains(true)) {
      personalSeekFilterColor(true);
      return;
    }
    // 근무형태 체크
    if(tempWorkTypeForSeek.contains(true)) {
      personalSeekFilterColor(true);
      return;
    }
    // 지역 체크
    if(tempLocationListForSeek.contains(true)) {
      personalSeekFilterColor(true);
      return;
    }

    personalSeekFilterColor(false); // 아무것도 켜져 있지 않을 때
  }

  // 로그아웃시 필터, 검색 다 끄기
  void recruitLogoutEvent(){
    offAllFilterForRecruit(); // 필터 다 끄기
    offAllFilterForSeek(); // 필터 다 끄기

    recruitFiltered = false; // 필터 적용 여부
    personalSeekFiltered = false; // 필터 적용 여부

    // checkFilterColorForRecruit(); // 필터 색 여부
    // checkFilterColorForPersonalSeek(); // 필터 색 여부
    
    searchForRecruit = false; // 검색 여부
    searchForPersonalSeek = false; // 검색 여부

    RecruitController.to.searchBarOffEvent();
  }

  // 검색 이벤트
  Future<void> searchEvent(BuildContext context, bool isRecruit, String value) async {
    value = controlSpace(value); // 공백 제거
    if (value.isEmpty || value.length < 2) {
      showSheepsToast(context: context, text: '최소 두 글자 이상을 입력해 주세요.');
      return;
    }
    if (isRecruit) {
      recruitSearchList.clear(); // 검색 리스트 초기화
      var res = await ApiProvider().post(
        '/Matching/Search/TeamMemberRecruit',
        jsonEncode({
          "words": value,
        }),
      );
      if (res != null) {
        searchWordForRecruit = value;
        for (int i = 0; i < res.length; i++) {
          TeamMemberRecruit temp = TeamMemberRecruit.fromJson(res[i]);
          await GlobalProfile.getFutureTeamByID(temp.teamId); // 팀 정보 불러오기
          recruitSearchList.add(temp);
        }
      }

      offAllFilterForRecruit(); // 필터 적용된 거 빼기
      recruitFiltered = false; // 필터 활성화 off
      checkFilterColorForRecruit(); // 필터 색 체크
      searchForRecruit = true;
    } else {
      personalSeekSearchList.clear(); // 검색 리스트 초기화
      var res = await ApiProvider().post(
        '/Matching/Search/PersonalSeekTeam',
        jsonEncode({
          "words": value,
        }),
      );
      if (res != null) {
        searchWordForSeek = value;
        for (int i = 0; i < res.length; i++) {
          PersonalSeekTeam temp = PersonalSeekTeam.fromJson(res[i]);
          await GlobalProfile.getFutureUserByUserID(temp.userId); // 유저 정보 불러오기
          personalSeekSearchList.add(temp);
        }
      }

      offAllFilterForSeek(); // 필터 적용된 거 빼기
      personalSeekFiltered = false; // 필터 활성화 off
      checkFilterColorForPersonalSeek(); // 필터 색 체크
      searchForPersonalSeek = true;
    }
  }

  // 대시보드 구직중인 프로필
  Future<void> getRecommendPersonalSeek() async {
    TeamMemberRecruit myRecruit; // 내가 쓴 최신 리쿠르트 글
    dashBoardSeekList.clear(); // 대시보드 리스트 초기화

    var res = await ApiProvider().post(
        '/Matching/Select/TeamMemberRecruitByUserID',
        jsonEncode({
          'userID': GlobalProfile.loggedInUser.userID,
        }));

    if (res != null) {
      myRecruit = TeamMemberRecruit.fromJson(res[0]);
      await GlobalProfile.getFutureTeamByID(myRecruit.teamId);
    }

    // 내가 쓴 팀원모집 글이 없다면 글로벌에 있는 거 담아서 리턴
    if (myRecruit == null) return noRecommendationResultForSeek();

    // 1차 검색 (구직 분야, 지역)
    await specificFilterForPersonalSeek(
      seekingFieldPart: myRecruit.recruitField,
      seekingLocation: myRecruit.location,
      seekingFieldPartCheckAll: checkTrue,
      seekingLocationCheckAll: checkTrue,
    );

    // 1차 검색 결과 있으면 단어 담아주고 리턴
    if (dashBoardSeekList.isNotEmpty)
      return dashBoardFilterWordForSeek = {
        'personalSeekPart': myRecruit.recruitField,
        'location': myRecruit.location,
      };

    // 2차 검색 (구직 분야)
    await specificFilterForPersonalSeek(
      seekingFieldPart: myRecruit.recruitField,
      seekingFieldPartCheckAll: checkTrue,
    );

    // 2차 검색 결과 있으면 단어 담아주고 리턴
    if (dashBoardSeekList.isNotEmpty) return dashBoardFilterWordForSeek['personalSeekPart'] = myRecruit.recruitField;

    // 3차 검색 (지역)
    await specificFilterForPersonalSeek(
      seekingLocation: myRecruit.location,
      seekingLocationCheckAll: checkTrue,
    );

    // 3차 검색 결과 있으면 단어 담아주고 리턴
    if (dashBoardSeekList.isNotEmpty) return dashBoardFilterWordForSeek['location'] = myRecruit.location;

    // 검색 결과 없으면
    if (dashBoardSeekList.isEmpty) noRecommendationResultForSeek();
  }

  // 검색 결과 없을 때
  void noRecommendationResultForSeek(){
    int num = globalPersonalSeekTeamList.length > MAX_RECRUIT_VIEW ? MAX_RECRUIT_VIEW : globalPersonalSeekTeamList.length;

    for (int i = 0; i < num; i++) {
      if (globalPersonalSeekTeamList[i].userId != GlobalProfile.loggedInUser.userID && globalPersonalSeekTeamList[i].seekingState == 1) {
        dashBoardSeekList.add(globalPersonalSeekTeamList[i]); // 내 글이 아니고, 구직중일 때 넣어주기
      } else {
        if(num < globalPersonalSeekTeamList.length) num++;
      }
    }
  }

  // 특정 필터
  Future<void> specificFilterForPersonalSeek({String seekingFieldPart = '', String seekingLocation = '', int seekingFieldPartCheckAll = 1, int seekingLocationCheckAll = 1}) async {
    var res = await ApiProvider().post(
        '/Matching/Filter/PersonalSeekTeam',
        jsonEncode({
          "seekingFieldPart": seekingFieldPart,
          "education": '',
          "workForm": '',
          "location": abbreviateForLocation(seekingLocation),
          "seekingFieldPartCheckAll": seekingFieldPartCheckAll,
          "educationCheckAll": checkFalse,
          "workFormCheckAll": checkFalse,
          "locationCheckAll": seekingLocationCheckAll,
          "orderrule": 0, // 최근 게시 순
          "isRecommend" : true
        }));

    if (res != null) {
      for (int i = 0; i < res.length; i++) {
        PersonalSeekTeam personalSeekTeam = PersonalSeekTeam.fromJson(res[i]);

        // 내 글이 아니고, 구직중인 것만
        if (personalSeekTeam.userId != GlobalProfile.loggedInUser.userID && personalSeekTeam.seekingState == 1) {
          await GlobalProfile.getFutureUserByUserID(personalSeekTeam.userId); // 유저 정보 불러오기
          dashBoardSeekList.add(personalSeekTeam);
        }
      }
    }
  }

  // 특정 필터 보여주기 위한 세팅
  void setSpecificFilterForSeek() {
    if (dashBoardFilterWordForSeek['personalSeekPart'].isEmpty && dashBoardFilterWordForSeek['location'].isEmpty) return; // 필터 반영 되어있지 않으면 리턴

    filteredPersonalSeekList.clear(); // 필터 리스트 초기화
    searchForRecruit = false; // 검색 여부 꺼주기

    offAllFilterForSeek(); // 필터 다 끄기

    // 구직분야 필터 켜기
    if (dashBoardFilterWordForSeek['personalSeekPart'].isNotEmpty) {
      for (int i = 0; i < FieldCategory.length; i++) {
        if (FieldCategory[i].contains(dashBoardFilterWordForSeek['personalSeekPart'])) {
          jobFieldForSeek[i] = true;
          tempJobFieldForSeek[i] = true;
          break;
        }
      }
    }

    // 지역 필터 켜기
    if (dashBoardFilterWordForSeek['location'].isNotEmpty) {
      for (int i = 0; i < locationNameList.length; i++) {
        if (locationNameList[i] == abbreviateForLocation(dashBoardFilterWordForSeek['location'])) {
          locationListForSeek[i] = true;
          tempLocationListForSeek[i] = true;
          break;
        }
      }
    }

    filteredPersonalSeekList.addAll(dashBoardSeekList); // 리쿠르트 필터 리스트에 넣기
    personalSeekFilterColor(true); // 필터 색 켜주기
    personalSeekFiltered = true; // 필터 켜주기
  }

  // 대시보드 추천 리쿠르트
  Future<void> getRecommendRecruit() async {
    UserData user = GlobalProfile.loggedInUser;

    await setTeamList();

    dashBoardRecruitList.clear(); // 대시보드 필터 리스트 초기화
    dashBoardFilterWordForRecruit = {
      'recruitPart': '',
      'location': '',
    };

    // 유저 정보가 없으면 글로벌에서 가져와서 주고 리턴
    if (user.job.isEmpty && user.location.isEmpty) {
      return noRecommendationResultForRecruit();
    }

    // 1차 검색 (리쿠르트 파트 & 지역)
    if (user.job.isNotEmpty && user.location.isNotEmpty) {
      await specificFilterForRecruit(
        recruitPart: user.job,
        location: user.location,
        recruitCheckAll: checkTrue,
        locationCheckAll: checkTrue,
      );

      // 1차 검색 결과 있으면 단어 담고 리턴
      if (dashBoardRecruitList.isNotEmpty)
        return dashBoardFilterWordForRecruit = {
          'recruitPart': user.job,
          'location': user.location,
        };
    }

    // 2차 검색 (리쿠르트 파트)
    if (user.job.isNotEmpty) {
      if (dashBoardRecruitList.isEmpty) {
        await specificFilterForRecruit(
          recruitPart: user.job,
          recruitCheckAll: checkTrue,
        );
      }

      // 2차 검색 결과 있으면 단어 담고 리턴
      if (dashBoardRecruitList.isNotEmpty) return dashBoardFilterWordForRecruit['recruitPart'] = user.job;
    }

    // 3차 검색 (지역)
    if (user.location.isNotEmpty) {
      if (dashBoardRecruitList.isEmpty) {
        await specificFilterForRecruit(
          location: user.location,
          locationCheckAll: checkTrue,
        );
      }

      // 3차 검색 결과 있으면 단어 담고 리턴
      if (dashBoardRecruitList.isNotEmpty) return dashBoardFilterWordForRecruit['location'] = user.location;
    }

    // 모든 검색 결과 없으면 글로벌 리스트에서 가져오기
    if (dashBoardRecruitList.isEmpty) noRecommendationResultForRecruit();

  }

  // 검색 결과 없을 때
  void noRecommendationResultForRecruit(){
    int num = globalTeamMemberRecruitList.length > MAX_RECRUIT_VIEW ? MAX_RECRUIT_VIEW : globalTeamMemberRecruitList.length;

    for (int i = 0; i < num; i++) {
      bool contains = false;

      // 모집마감이 아닐 때
      if (RecruitController.to.setPeriodState(globalTeamMemberRecruitList[i].recruitPeriodEnd) != '모집마감') {
        // 내 팀 리스트에 있는 팀의 글이면
        for (int j = 0; j < myTeamList.length; j++) {
          if (myTeamList[j].id == globalTeamMemberRecruitList[i].teamId) {
            contains = true;
            if(num < globalTeamMemberRecruitList.length) num++;
            break;
          }
        }

        if (!contains) {
          dashBoardRecruitList.add(globalTeamMemberRecruitList[i]);
        }
      }
    }
  }

  // 특정 필터
  Future<void> specificFilterForRecruit({String recruitPart = '', String location = '', int recruitCheckAll = 1, int locationCheckAll = 1}) async {
    var res = await ApiProvider().post(
        '/Matching/Filter/TeamMemberRecruit',
        jsonEncode({
          "recruitPart": recruitPart,
          "servicePart": '',
          "location": abbreviateForLocation(location),
          "recruitCheckAll": recruitCheckAll,
          "serviceCheckAll": checkFalse,
          "locationCheckAll": locationCheckAll,
          "orderrule": 0, // 최근 게시 순
          "isRecommend" : true,
        }));

    if (res != null) {
      for (int i = 0; i < res.length; i++) {
        bool contains = false; // 들어있는지 여부
        TeamMemberRecruit tempRecruit = TeamMemberRecruit.fromJson(res[i]);

        // 모집마감이 아닐 때
        if(RecruitController.to.setPeriodState(tempRecruit.recruitPeriodEnd) != '모집마감') {
          // 내 팀 리스트에 있는 팀의 글이면
          for (int j = 0; j < myTeamList.length; j++) {
            if (myTeamList[j].id == tempRecruit.teamId) {
              contains = true;
              break;
            }
          }

          if (!contains) {
            dashBoardRecruitList.add(tempRecruit);
            await GlobalProfile.getFutureTeamByID(tempRecruit.teamId); // 팀 정보 불러오기
          }
        }

      }
    }
  }

  // 특정 필터 보여주기 위한 세팅
  void setSpecificFilterForRecruit() {
    if (dashBoardFilterWordForRecruit['recruitPart'].isEmpty && dashBoardFilterWordForRecruit['location'].isEmpty) return; // 필터 반영 되어있지 않으면 리턴

    filteredRecruitList.clear(); // 필터 리스트 초기화
    searchForRecruit = false; // 검색 여부 꺼주기

    offAllFilterForRecruit(); // 필터 다 끄기

    // 팀원모집 분야 필터 켜기
    if (dashBoardFilterWordForRecruit['recruitPart'].isNotEmpty) {
      for (int i = 0; i < FieldCategory.length; i++) {
        if (FieldCategory[i].contains(dashBoardFilterWordForRecruit['recruitPart'])) {
          jobFieldForRecruit[i] = true;
          tempJobFieldForRecruit[i] = true;
          break;
        }
      }
    }

    // 지역 필터 켜기
    if (dashBoardFilterWordForRecruit['location'].isNotEmpty) {
      for (int i = 0; i < locationNameList.length; i++) {
        if (locationNameList[i] == abbreviateForLocation(dashBoardFilterWordForRecruit['location'])) {
          locationListForRecruit[i] = true;
          tempLocationListForRecruit[i] = true;
          break;
        }
      }
    }

    filteredRecruitList.addAll(dashBoardRecruitList); // 리쿠르트 필터 리스트에 넣기
    recruitFilterColor(true); // 필터 색 켜주기
    recruitFiltered = true; // 필터 켜주기
  }

  // 내 팀 리스트 불러오기
  Future<void> setTeamList() async {
    var leaderList = await ApiProvider().post('/Team/Profile/Leader', jsonEncode({"userID": GlobalProfile.loggedInUser.userID}));

    if (leaderList != null) {
      for (int i = 0; i < leaderList.length; ++i) {
        myTeamList.add(Team.fromJson(leaderList[i]));
        await GlobalProfile.getFutureTeamByID(leaderList[i]['id']);
      }
    }

    var teamList = await ApiProvider().post('/Team/Profile/SelectUser', jsonEncode({"userID": GlobalProfile.loggedInUser.userID}));

    if (teamList != null) {
      for (int i = 0; i < teamList.length; ++i) {
        myTeamList.add(await GlobalProfile.getFutureTeamByID(teamList[i]['TeamID']));
      }
    }
  }

  // 팀원모집 필터 끄기
  void offAllFilterForRecruit(){
    jobFieldForRecruit = List<bool>.generate(jobFieldForRecruit.length, (index) => false).obs;
    tempJobFieldForRecruit = List<bool>.generate(jobFieldForRecruit.length, (index) => false).obs;
    serviceFieldForRecruit = List<bool>.generate(serviceFieldForRecruit.length, (index) => false).obs;
    tempServiceFieldForRecruit = List<bool>.generate(serviceFieldForRecruit.length, (index) => false).obs;
    locationListForRecruit = List<bool>.generate(locationListForRecruit.length, (index) => false).obs;
    tempLocationListForRecruit = List<bool>.generate(locationListForRecruit.length, (index) => false).obs;
  }

  // 팀 찾기 필터 끄기
  void offAllFilterForSeek(){
    jobFieldForSeek = List<bool>.generate(jobFieldForSeek.length, (index) => false).obs;
    tempJobFieldForSeek = List<bool>.generate(jobFieldForSeek.length, (index) => false).obs;
    educationListForSeek = List<bool>.generate(educationListForSeek.length, (index) => false).obs;
    tempEducationListForSeek = List<bool>.generate(educationListForSeek.length, (index) => false).obs;
    workTypeForSeek = List<bool>.generate(workTypeForSeek.length, (index) => false).obs;
    tempWorkTypeForSeek = List<bool>.generate(workTypeForSeek.length, (index) => false).obs;
    locationListForSeek = List<bool>.generate(locationListForSeek.length, (index) => false).obs;
    tempLocationListForSeek = List<bool>.generate(locationListForSeek.length, (index) => false).obs;
  }

  // 임시 리스트 정식 리스트로 덮어쓰기
  void syncTempListForRecruit(){
    tempJobFieldForRecruit = List<bool>.generate(jobFieldForRecruit.length, (index) => jobFieldForRecruit[index]).obs;
    tempServiceFieldForRecruit = List<bool>.generate(serviceFieldForRecruit.length, (index) => serviceFieldForRecruit[index]).obs;
    tempLocationListForRecruit = List<bool>.generate(locationListForRecruit.length, (index) => locationListForRecruit[index]).obs;
  }

  // 임시 리스트 정식 리스트로 덮어쓰기
  void syncTempListForSeek(){
    tempJobFieldForSeek = List<bool>.generate(jobFieldForSeek.length, (index) => jobFieldForSeek[index]).obs;
    tempEducationListForSeek = List<bool>.generate(educationListForSeek.length, (index) => educationListForSeek[index]).obs;
    tempWorkTypeForSeek = List<bool>.generate(workTypeForSeek.length, (index) => workTypeForSeek[index]).obs;
    tempLocationListForSeek = List<bool>.generate(locationListForSeek.length, (index) => locationListForSeek[index]).obs;
  }

  // 필터 이벤트
  Future<void> filterEvent(bool isRecruit, Alignment tabAlignForRecruit, Alignment tabAlignForSeek) async {
    final prefs = await SharedPreferences.getInstance();

    if (isRecruit) {
      searchForRecruit = false; // 검색 끄기

      // 임시 리스트에 있는 값 정식 리스트로 옮겨주기
      jobFieldForRecruit = List<bool>.generate(tempJobFieldForRecruit.length, (index) => tempJobFieldForRecruit[index]).obs;
      serviceFieldForRecruit = List<bool>.generate(tempServiceFieldForRecruit.length, (index) => tempServiceFieldForRecruit[index]).obs;
      locationListForRecruit = List<bool>.generate(tempLocationListForRecruit.length, (index) => tempLocationListForRecruit[index]).obs;

      if (tabAlignForRecruit == Alignment.centerLeft) recruitOrderRule = 0; // 최근 게시 순
      if (tabAlignForRecruit == Alignment.centerRight) recruitOrderRule = 1; // 최근 접속 순
      showRecruitmentOnly = tempShowRecruitmentOnly.value; // 모집중만 보기
      prefs.setBool('showRecruitmentOnly', showRecruitmentOnly); // 기기에 저장하기

      recruitPart = makeSearchWord(
        boolList: jobFieldForRecruit,
        filterCategoryList: FieldCategory,
      );
      if (recruitPart.isNotEmpty)
        recruitCheckAll = 0;
      else
        recruitCheckAll = 1;

      servicePart = makeSearchWord(
        boolList: serviceFieldForRecruit,
        filterCategoryList: serviceFieldList,
      );
      if (servicePart.isNotEmpty)
        serviceCheckAll = 0;
      else
        serviceCheckAll = 1;

      recruitLocation = makeSearchWord(
        boolList: locationListForRecruit,
        filterCategoryList: locationNameList,
      );
      if (recruitLocation.isNotEmpty)
        recruitLocationCheckAll = 0;
      else
        recruitLocationCheckAll = 1;

      if (recruitOrderRule == 0 && recruitCheckAll == 1 && serviceCheckAll == 1 && recruitLocationCheckAll == 1) {
        recruitFiltered = false; // 필터 끄기
      } else {
        filteredRecruitList.clear(); // 필터 리스트 초기화
        var res = await ApiProvider().post(
            '/Matching/Filter/TeamMemberRecruit',
            jsonEncode({
              "recruitPart": recruitPart,
              "servicePart": servicePart,
              "location": recruitLocation,
              "recruitCheckAll": recruitCheckAll,
              "serviceCheckAll": serviceCheckAll,
              "locationCheckAll": recruitLocationCheckAll,
              "orderrule": recruitOrderRule,
              "isRecommend" : false
            }));

        if (res != null) {
          for (int i = 0; i < res.length; i++) {
            TeamMemberRecruit teamMemberRecruit = TeamMemberRecruit.fromJson(res[i]);
            await GlobalProfile.getFutureTeamByID(teamMemberRecruit.teamId); // 팀 정보 불러오기
            filteredRecruitList.add(teamMemberRecruit);
          }
        }

        recruitFiltered = true;
      }
    } else {
      searchForPersonalSeek = false; // 검색 끄기

      // 임시 리스트에 있는 값 정식 리스트에 옮겨주기
      jobFieldForSeek = List<bool>.generate(tempJobFieldForSeek.length, (index) => tempJobFieldForSeek[index]).obs;
      educationListForSeek = List<bool>.generate(tempEducationListForSeek.length, (index) => tempEducationListForSeek[index]).obs;
      workTypeForSeek = List<bool>.generate(tempWorkTypeForSeek.length, (index) => tempWorkTypeForSeek[index]).obs;
      locationListForSeek = List<bool>.generate(tempLocationListForSeek.length, (index) => tempLocationListForSeek[index]).obs;

      if (tabAlignForSeek == Alignment.centerLeft) seekingOrderRule = 0; // 최근 게시 순
      if (tabAlignForSeek == Alignment.centerRight) seekingOrderRule = 1; // 최근 접속 순
      showSeekingOnly = tempShowSeekingOnly.value; // 구직중만 보기
      prefs.setBool('showSeekingOnly', showSeekingOnly); // 기기에 저장하기

      seekingFieldPart = makeSearchWord(
        boolList: jobFieldForSeek,
        filterCategoryList: FieldCategory,
      );
      if (seekingFieldPart.isNotEmpty)
        seekingFieldPartCheckAll = 0;
      else
        seekingFieldPartCheckAll = 1;

      education = makeSearchWord(
        boolList: educationListForSeek,
        filterCategoryList: educationList,
      );
      if (education.isNotEmpty)
        educationCheckAll = 0;
      else
        educationCheckAll = 1;

      workForm = makeSearchWord(
        boolList: workTypeForSeek,
        filterCategoryList: workTypeList,
      );
      if (workForm.isNotEmpty)
        workFormCheckAll = 0;
      else
        workFormCheckAll = 1;

      seekingLocation = makeSearchWord(
        boolList: locationListForSeek,
        filterCategoryList: locationNameList,
      );
      if (seekingLocation.isNotEmpty)
        seekingLocationCheckAll = 0;
      else
        seekingLocationCheckAll = 1;

      if (seekingOrderRule == 0 && seekingFieldPartCheckAll == 1 && educationCheckAll == 1 && workFormCheckAll == 1 && seekingLocationCheckAll == 1) {
        personalSeekFiltered = false; // 필터 끄기
      } else {
        filteredPersonalSeekList.clear(); // 필터 리스트 초기화
        var res = await ApiProvider().post(
            '/Matching/Filter/PersonalSeekTeam',
            jsonEncode({
              "seekingFieldPart": seekingFieldPart,
              "education": education,
              "workForm": workForm,
              "location": seekingLocation,
              "seekingFieldPartCheckAll": seekingFieldPartCheckAll,
              "educationCheckAll": educationCheckAll,
              "workFormCheckAll": workFormCheckAll,
              "locationCheckAll": seekingLocationCheckAll,
              "orderrule": seekingOrderRule,
              "isRecommend" : false
            }));

        if (res != null) {
          for (int i = 0; i < res.length; i++) {
            PersonalSeekTeam personalSeekTeam = PersonalSeekTeam.fromJson(res[i]);
            await GlobalProfile.getFutureUserByUserID(personalSeekTeam.userId); // 유저 정보 불러오기
            filteredPersonalSeekList.add(personalSeekTeam);
          }
        }
        personalSeekFiltered = true;
      }
    }
  }

  // 필터 검색어 조합
  String makeSearchWord({List<bool> boolList, List<String> filterCategoryList}) {
    bool firstPart = true; // 들어온 값중 처음인지
    String result = '';

    for (int i = 0; i < boolList.length; i++) {
      if (boolList[i] == true) {
        if (firstPart) {
          // 첫 번째 단어이면
          result = filterCategoryList[i];
          firstPart = false;
        } else {
          result += "|^" + filterCategoryList[i];
        }
      }
    }
    return result;
  }

  // 필터 스크롤 이벤트
  Future<void> maxFilterScrollEvent(bool isRecruit) async {
    if (canCallOffset) {
      canCallOffset = false; // 중복 호출 방지
      
      if (isRecruit) {
        var res = await ApiProvider().post(
            '/Matching/Filter/Offset/TeamMemberRecruit',
            jsonEncode({
              "index": filteredRecruitList.length,
              'recruitPart': recruitPart,
              'servicePart': servicePart,
              'location': recruitLocation,
              'recruitCheckAll': recruitCheckAll,
              'serviceCheckAll': serviceCheckAll,
              'locationCheckAll': recruitLocationCheckAll,
              "orderrule": recruitOrderRule,
            }));
        if (null == res || 0 == res.length) return;
        for (int i = 0; i < res.length; i++) {
          TeamMemberRecruit teamMemberRecruit = TeamMemberRecruit.fromJson(res[i]);

          filteredRecruitList.add(teamMemberRecruit);
          await GlobalProfile.getFutureTeamByID(teamMemberRecruit.teamId); // 팀 정보 불러오기
        }
      } else {
        var res = await ApiProvider().post(
            '/Matching/Filter/Offset/PersonalSeekTeam',
            jsonEncode({
              "index": filteredPersonalSeekList.length,
              'seekingFieldPart': seekingFieldPart,
              'education': education,
              'workform': workForm,
              'location': seekingLocation,
              'seekingFieldPartCheckAll': seekingFieldPartCheckAll,
              'educationCheckAll': educationCheckAll,
              'workFormCheckAll': workFormCheckAll,
              'locationCheckAll': seekingLocationCheckAll,
              "orderrule": seekingOrderRule,
            }));
        if (null == res || 0 == res.length) return;
        for (int i = 0; i < res.length; i++) {
          PersonalSeekTeam personalSeekTeam = PersonalSeekTeam.fromJson(res[i]);

          filteredPersonalSeekList.add(personalSeekTeam);
          await GlobalProfile.getFutureUserByUserID(res[i]['UserID']); // 유저 정보 불러오기
        }
      }
    }

    // offset 중복호출 방지
    Future.delayed(Duration(milliseconds: 500), () {
      canCallOffset = true;
    });
  }

  // 검색 스크롤 이벤트
  Future<void> maxSearchScrollEvent(bool isRecruit) async {
    if (isRecruit) {
      var res = await ApiProvider().post(
          '/Matching/Search/Offset/TeamMemberRecruit',
          jsonEncode({
            "index": recruitSearchList.length,
            'words': searchWordForRecruit,
          }));
      if (null == res || 0 == res.length) return;
      for (int i = 0; i < res.length; i++) {
        await GlobalProfile.getFutureTeamByID(res[i]['TeamID']); // 팀 정보 불러오기
        recruitSearchList.add(TeamMemberRecruit.fromJson(res[i]));
      }
    } else {
      var res = await ApiProvider().post(
          '/Matching/Search/Offset/PersonalSeekTeam',
          jsonEncode({
            "index": personalSeekSearchList.length,
            'words': searchWordForSeek,
          }));
      if (null == res || 0 == res.length) return;
      for (int i = 0; i < res.length; i++) {
        await GlobalProfile.getFutureUserByUserID(res[i]['UserID']); // 유저 정보 불러오기
        personalSeekSearchList.add(PersonalSeekTeam.fromJson(res[i]));
      }
    }
  }

  // tempList 리셋 함수
  void resetTempList() {
    resetTempListForRecruit();
    resetTempListForSeek();
  }

  void resetTempListForRecruit(){
    tempJobFieldForRecruit = List<bool>.generate(FieldCategory.length, (index) => false).obs;
    tempServiceFieldForRecruit = List<bool>.generate(serviceFieldList.length, (index) => false).obs;
    tempLocationListForRecruit = List<bool>.generate(locationNameList.length, (index) => false).obs;
  }

  void resetTempListForSeek(){
    tempJobFieldForSeek = List<bool>.generate(FieldCategory.length, (index) => false).obs;
    tempEducationListForSeek = List<bool>.generate(educationList.length, (index) => false).obs;
    tempWorkTypeForSeek = List<bool>.generate(workTypeList.length, (index) => false).obs;
    tempLocationListForSeek = List<bool>.generate(locationNameList.length, (index) => false).obs;
  }

  // tempList 설정 함수
  void initTempList() {
    tempJobFieldForRecruit = List<bool>.generate(jobFieldForRecruit.length, (index) => jobFieldForRecruit[index]).obs;
    tempServiceFieldForRecruit = List<bool>.generate(serviceFieldForRecruit.length, (index) => serviceFieldForRecruit[index]).obs;
    tempLocationListForRecruit = List<bool>.generate(locationListForRecruit.length, (index) => locationListForRecruit[index]).obs;
    tempJobFieldForSeek = List<bool>.generate(jobFieldForSeek.length, (index) => jobFieldForSeek[index]).obs;
    tempEducationListForSeek = List<bool>.generate(educationListForSeek.length, (index) => educationListForSeek[index]).obs;
    tempWorkTypeForSeek = List<bool>.generate(workTypeForSeek.length, (index) => workTypeForSeek[index]).obs;
    tempLocationListForSeek = List<bool>.generate(locationListForSeek.length, (index) => locationListForSeek[index]).obs;
  }

  // 필터 버튼 토글 함수
  void toggleFilterButton(int index, List<bool> tempList) {
    tempList[index] = !tempList[index];

    if(RecruitController.to.isRecruit) checkFilterColorForRecruit(); // 필터 아이콘 색 체크
    else checkFilterColorForPersonalSeek(); // 필터 아이콘 색 체크
  }

  // 선택 해제
  void tempListReset(List<bool> tempList) {
    for (int i = 0; i < tempList.length; i++) {
      tempList[i] = false;
    }

    if(RecruitController.to.isRecruit) checkFilterColorForRecruit(); // 필터 아이콘 색 체크
    else checkFilterColorForPersonalSeek(); // 필터 아이콘 색 체크
  }

}
