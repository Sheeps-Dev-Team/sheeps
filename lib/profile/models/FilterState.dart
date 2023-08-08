import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/ListForProfileModify.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';

class FilterStateForPersonal extends GetxController {
  static get to => Get.find<FilterStateForPersonal>();

  bool isSearch = false;

  String searchWords = "";

  //개인프로필 필터
  AlignmentGeometry tabAlignForPerson = Alignment.centerLeft;

  //분야야
  List<bool> cataForPerson = [];
  List<bool> tempCataForPerson = [];

  //지역
  List<bool> locaForPerson = [];
  List<bool> tempLocaForPerson = [];

  AlignmentGeometry tabAlignForTeam = Alignment.centerLeft;

  //분야
  List<bool> cataForTeam = [];
  List<bool> tempCataForTeam = [];

  //지역
  List<bool> locaForTeam = [];
  List<bool> tempLocaForTeam = [];

  //팀 형
  List<bool> distingForTeam = [];
  List<bool> tempDistingForTeam = [];

  // 필터 적용 여부
  bool isFilteredForPersonal = false; // 개인
  bool isFilteredForTeam = false; // 팀

  // 필터 색 적용 여부
  RxBool filterColorForPersonal = false.obs;
  RxBool filterColorForTeam = false.obs;
  RxBool filterColorForExpert = false.obs;

  // orderRule
  int orderRuleForPersonal = 0;
  int orderRuleForTeam = 0;

  // 검색 아이콘 색 적용 여부
  bool searchIconColor = false;

  @override
  void onInit() {

    cataForPerson = List<bool>.filled(FieldCategory.length, false, growable: true);
    tempCataForPerson = List<bool>.filled(FieldCategory.length, false, growable: true);

    locaForPerson = List<bool>.filled(locationNameList.length, false, growable: true);
    tempLocaForPerson = List<bool>.filled(locationNameList.length, false, growable: true);

    cataForTeam = List<bool>.filled(serviceFieldList.length, false, growable: true);
    tempCataForTeam = List<bool>.filled(serviceFieldList.length, false, growable: true);

    locaForTeam = List<bool>.filled(locationNameList.length, false, growable: true);
    tempLocaForTeam = List<bool>.filled(locationNameList.length, false, growable: true);

    distingForTeam = List<bool>.filled(distingNameList.length, false, growable: true);
    tempDistingForTeam = List<bool>.filled(distingNameList.length, false, growable: true);

    super.onInit();
  }

  void closeSearchEvent(){
    isSearch = false; // 검색 바 끄기
    if(GlobalProfile.personalFiltered || GlobalProfile.teamFiltered) searchIconColor = true; // 검색이 적용되어 있으면 검색 아이콘 켜주기
    else searchIconColor = false; // 검색 아이콘 끄기
  }

  // 필터 아이콘 컬러 체크
  void checkFilterColorForPersonal(){
    // 직군 체크
    if(tempCataForPerson.contains(true)){
      filterColorForPersonal(true);
      return;
    }
    // 지역 체크
    if(tempLocaForPerson.contains(true)){
      filterColorForPersonal(true);
      return;
    }

    filterColorForPersonal(false); // 아무것도 적용 안되어있을 때
  }

  // 필터 아이콘 컬러 체크
  void checkFilterColorForTeam(){
    // 서비스 분야 체크
    if(tempCataForTeam.contains(true)){
      filterColorForTeam(true);
      return;
    }
    // 지역 체크
    if(tempLocaForTeam.contains(true)){
      filterColorForTeam(true);
      return;
    }
    // 설립 유형 체크
    if(tempDistingForTeam.contains(true)){
      filterColorForTeam(true);
      return;
    }

    filterColorForTeam(false); // 아무것도 적용 안되어있을 때
  }

  // 로그아웃할 때 필터, 검색 끄기
  void profileFilterLogoutEvent(){
    resetFilterList(); // 필터 리스트 리셋
    resetTempList(); // 임시 필터 리스트 리셋

    GlobalProfile.personalFiltered = false; // 검색 끄기
    GlobalProfile.teamFiltered = false; // 검색 끄기

    isFilteredForPersonal = false; // 필터 끄기
    isFilteredForTeam = false; // 필터 끄기

  }

  // filterList 리셋 함수
  void resetFilterList() {
    cataForPerson = List.generate(cataForPerson.length, (index) => false);
    locaForPerson = List.generate(locaForPerson.length, (index) => false);
    cataForTeam = List.generate(cataForTeam.length, (index) => false);
    locaForTeam = List.generate(locaForTeam.length, (index) => false);
    distingForTeam = List.generate(distingForTeam.length, (index) => false);
  }

  // tempList 리셋 함수
  void resetTempList() {
    resetTempListForPersonal();
    resetTempListForTeam();
  }

  // 필터 색 초기화 함수
  void offFilterColor(){
    filterColorForPersonal.value = false;
    filterColorForTeam.value = false;
  }


  // tempList 리셋 개인
 void resetTempListForPersonal(){
    tempCataForPerson = List.generate(tempCataForPerson.length, (index) => false);
    tempLocaForPerson = List.generate(tempLocaForPerson.length, (index) => false);
  }

  // tempList 리셋 팀
  void resetTempListForTeam(){
    tempCataForTeam = List.generate(tempCataForTeam.length, (index) => false);
    tempLocaForTeam = List.generate(tempLocaForTeam.length, (index) => false);
    tempDistingForTeam = List.generate(tempDistingForTeam.length, (index) => false);
  }

  void syncTempListForPersonal(){
    tempCataForPerson = List.generate(cataForPerson.length, (index) => cataForPerson[index]);
    tempLocaForPerson = List.generate(locaForPerson.length, (index) => locaForPerson[index]);
  }

  void syncTempListForTeam(){
    tempCataForTeam = List.generate(cataForTeam.length, (index) => cataForTeam[index]);
    tempLocaForTeam = List.generate(locaForTeam.length, (index) => locaForTeam[index]);
    tempDistingForTeam = List.generate(distingForTeam.length, (index) => distingForTeam[index]);
  }

  // 필터 리스트에 임시 리스트 저장 (Person)
  void saveTempListForPerson() {
    for (int i = 0; i < tempCataForPerson.length; i++) {
      if (tempCataForPerson[i] == true) {
        cataForPerson[i] = true;
      } else {
        cataForPerson[i] = false;
      }
    }
    for (int i = 0; i < tempLocaForPerson.length; i++) {
      if (tempLocaForPerson[i] == true) {
        locaForPerson[i] = true;
      } else {
        locaForPerson[i] = false;
      }
    }
  }

  // 필터 리스트에 임시 리스트 저장 (Team)
  void saveTempListForTeam() {
    for (int i = 0; i < tempCataForTeam.length; i++) {
      if (tempCataForTeam[i] == true) {
        cataForTeam[i] = true;
      } else {
        cataForTeam[i] = false;
      }
    }
    for (int i = 0; i < tempLocaForTeam.length; i++) {
      if (tempLocaForTeam[i] == true) {
        locaForTeam[i] = true;
      } else {
        locaForTeam[i] = false;
      }
    }
    for (int i = 0; i < tempDistingForTeam.length; i++) {
      if (tempDistingForTeam[i] == true) {
        distingForTeam[i] = true;
      } else {
        distingForTeam[i] = false;
      }
    }
  }

  // 검색한 필터 리스트 임시 리스트에 저장
  void saveFilterListLog() {
    for (int i = 0; i < cataForPerson.length; i++) {
      if (cataForPerson[i] == true) {
        tempCataForPerson[i] = true;
      } else {
        tempCataForPerson[i] = false;
      }
    }
    for (int i = 0; i < locaForPerson.length; i++) {
      if (locaForPerson[i] == true) {
        tempLocaForPerson[i] = true;
      } else {
        tempLocaForPerson[i] = false;
      }
    }
    for (int i = 0; i < cataForTeam.length; i++) {
      if (cataForTeam[i] == true) {
        tempCataForTeam[i] = true;
      } else {
        tempCataForTeam[i] = false;
      }
    }
    for (int i = 0; i < locaForTeam.length; i++) {
      if (locaForTeam[i] == true) {
        tempLocaForTeam[i] = true;
      } else {
        tempLocaForTeam[i] = false;
      }
    }
    for (int i = 0; i < distingForTeam.length; i++) {
      if (distingForTeam[i] == true) {
        tempDistingForTeam[i] = true;
      } else {
        tempDistingForTeam[i] = false;
      }
    }
  }

  Future<void> filterEventForPersonal({bool isOffset = false}) async{
    GlobalProfile.personalFiltered = false; // 검색 끄기
      isFilteredForPersonal = false; //필터 활성화 안됨으로 해두고, 필터 적용된게 있으면 활성으로 바꿀것..
      saveTempListForPerson(); // 필터 리스트에 임시 리스트 저장

      //Alignment는 정렬 기준에 대해서 나타냄
      //CenterLeft : 최근 접속 순
      //Center : 보유 뱃지 순
      //CetnerRight : 신규 가입 순
      orderRuleForPersonal = tabAlignForPerson == Alignment.centerLeft
          ? 0
          : tabAlignForPerson == Alignment.center
          ? 1
          : 2;

      int partCheckAll = 1;
      String partSearch = '';
      bool bPartFirst = false;
      for (int i = 0; i < FieldCategory.length; i++) {
        if (cataForPerson[i] == true) {
          if (bPartFirst == false) {
            partSearch = FieldCategory[i];
            bPartFirst = true;
          } else {
            partSearch = partSearch + "|^" + FieldCategory[i];
          }
          partCheckAll = 0;
          isFilteredForPersonal = true; //필터 활성화
        }
      }

      int locationCheckAll = 1;
      String locationSearch = '';
      bool bLocationFirst = false;
      for (int i = 0; i < locationNameList.length; i++) {
        if (locaForPerson[i] == true) {
          if (bLocationFirst == false) {
            locationSearch = revertAbbreviateForLocation(locationNameList[i]); //축약어 풀어주는 함수
            bLocationFirst = true;
          } else {
            locationSearch = locationSearch + "|^" + revertAbbreviateForLocation(locationNameList[i]);
          }
          locationCheckAll = 0;
          isFilteredForPersonal = true; //필터 활성화
        }
      }

      if (partCheckAll == 1 && locationCheckAll == 1 && orderRuleForPersonal == 0) {
        GlobalProfile.personalFiltered = false;
      } else {
        if(!isOffset) GlobalProfile.personalProfileFiltered.clear(); // offset 아닐 때 클리어

        var tmp3 = await ApiProvider().post(
            '/Search/ProfileFilter',
            jsonEncode({
              "orderrule": orderRuleForPersonal,
              "partcheckall": partCheckAll,
              "partSearch": partSearch,
              "locationcheckall": locationCheckAll,
              "locationSearch": locationSearch,
              "userID": GlobalProfile.loggedInUser!.userID,
              "index": GlobalProfile.personalProfileFiltered.length
            }));
        if (tmp3 != null) {
          for (int i = 0; i < tmp3.length; i++) {
            UserData _userTmp = UserData.fromJson(tmp3[i]);
            GlobalProfile.personalProfileFiltered.add(_userTmp);
          }
        }
        isFilteredForPersonal = true;
      }
  }

  Future<void> filterEventForTeam({bool isOffset = false}) async {
    GlobalProfile.teamFiltered = false; // 검색 끄기
    isFilteredForTeam = false; //필터 활성화 안됨으로 해두고,
    saveTempListForTeam();

    orderRuleForTeam = tabAlignForTeam == Alignment.centerLeft
        ? 0
        : tabAlignForTeam == Alignment.center
        ? 1
        : 2;

    String partcheckall = "1";
    String partSearch = "";
    bool firstpart = false;
    for (int i = 0; i < serviceFieldList.length; i++) {
      if (cataForTeam[i] == true) {
        partcheckall = "0";
        firstpart == false ? partSearch += serviceFieldList[i] : partSearch = partSearch + "|^" + serviceFieldList[i];
        firstpart = true;
        partcheckall = "0";
        isFilteredForTeam = true; //필터 활성화
      }
    }

    String locationcheckall = "1";
    String locationSearch = "";
    bool firstpart2 = false;
    for (int i = 0; i < locationNameList.length; i++) {
      if (locaForTeam[i] == true) {
        locationcheckall = "0";
        firstpart2 == false
            ? locationSearch += revertAbbreviateForLocation(locationNameList[i])
            : locationSearch = locationSearch + "|^" + revertAbbreviateForLocation(locationNameList[i]);
        firstpart2 = true;
        locationcheckall = "0";
        isFilteredForTeam = true; //필터 활성화
      }
    }

    String teamcheckall = "1";
    String teamSearch = "";
    bool firstpart3 = false;
    for (int i = 0; i < distingNameList.length; i++) {
      if (distingForTeam[i] == true) {
        teamcheckall = "0";
        firstpart3 == false ? teamSearch += distingNameList[i] : teamSearch = teamSearch + "|^" + distingNameList[i];
        firstpart3 = true;
        teamcheckall = "0";
        isFilteredForTeam = true; //필터 활성화
      }
    }

    if (partcheckall == "1" && locationcheckall == "1" && teamcheckall == "1" && orderRuleForTeam == 0) {
      GlobalProfile.teamFiltered = false;
    } else {
      if(!isOffset) GlobalProfile.teamProfileFiltered.clear();

      var tmp = await ApiProvider().post(
          '/Search/TeamFilter',
          jsonEncode({
            "orderrule": orderRuleForTeam,
            "partcheckall": partcheckall,
            "partSearch": partSearch,
            "locationcheckall": locationcheckall,
            "locationSearch": locationSearch,
            "teamcheckall": teamcheckall,
            "teamSearch": teamSearch,
            "index": GlobalProfile.teamProfileFiltered.length
          }));
      if (tmp != null) {
        for (int i = 0; i < tmp.length; i++) {
          Team _team = Team.fromJson(tmp[i]);
          GlobalProfile.teamProfileFiltered.add(_team);
        }
      }
      isFilteredForTeam = true;
    }
  }

  Future<void> searchEventForPersonal(String val, {bool isOffset = false}) async{
    if(!isOffset) GlobalProfile.personalProfileFiltered.clear();
    List<dynamic> tmp = [];

    tmp = await ApiProvider().post(
        '/Personal/Search/Name',
        jsonEncode({
          "searchWord": val,
          "index": GlobalProfile.personalProfileFiltered.length,
        }));

    if (tmp != null) {
      for (int i = 0; i < tmp.length; i++) {
        UserData _user = UserData.fromJson(tmp[i]);
        GlobalProfile.personalProfileFiltered.add(_user);
      }

      isFilteredForPersonal = false; // 필터 끄기
      GlobalProfile.personalFiltered = true; // 검색 켜주기
    }
  }

  Future<void> searchEventForTeam(String val, {bool isOffset = false}) async{
    if(!isOffset) GlobalProfile.teamProfileFiltered.clear();
    List<dynamic> tmp = [];

    tmp = await ApiProvider().post(
        '/Team/Profile/SearchName',
        jsonEncode({
          "searchWord": val,
          "index": GlobalProfile.teamProfileFiltered.length,
        }));

    if (tmp != null) {
      for (int i = 0; i < tmp.length; i++) {
        Team _team = Team.fromJson(tmp[i]);
        GlobalProfile.teamProfileFiltered.add(_team);
      }

      isFilteredForTeam = false; // 필터 끄기
      GlobalProfile.teamFiltered = true; // 검색 키기
    }
  }
}
