import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sheeps_app/Recruit/Controller/FilterController.dart';
import 'package:sheeps_app/Recruit/Models/PersonalSeekTeams.dart';
import 'package:sheeps_app/Recruit/Models/RecruitLikes.dart';
import 'package:sheeps_app/Recruit/Models/TeamMemberRecruit.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/NavigationNum.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';

class RecruitController extends GetxController {
  static get to => Get.find<RecruitController>();
  final NavigationNum navigationNum = Get.put(NavigationNum());

  final Duration duration = Duration(milliseconds: 500);
  final Curve curve = Curves.fastOutSlowIn;

  bool isRecruit = true; // 리쿠르트 상태
  Team teamData; // 팀 데이터

  final List<String> recruitCategoryList = ['전체', '팀・스타트업', '지원사업', '공모전', '소모임'];
  final List<String> seekCategoryList = ['전체', '개발', '경영', '디자인', '마케팅', '영업'];
  final List<double> recruitCategoryWidthList = [30 * sizeUnit, 90 * sizeUnit, 59 * sizeUnit, 45 * sizeUnit, 45 * sizeUnit];
  final List<double> seekCategoryWidthList = [30 * sizeUnit, 30 * sizeUnit, 30 * sizeUnit, 45 * sizeUnit, 45 * sizeUnit, 30 * sizeUnit];

  // 팀원모집 카테고리 상태
  static const int RECRUIT_ALL = 0; // 전체
  static const int RECRUIT_STARTUP = 1; // 팀 · 스타트업
  static const int RECRUIT_SUPPORT = 2; // 지원 사업
  static const int RECRUIT_COMPETITION = 3; // 공모전
  static const int RECRUIT_SMALL_CLASS = 4; // 소모임

  // 팀 찾기 카테고리 상태
  static const int SEEK_ALL = 0; // 전체
  static const int SEEK_DEVELOPMENT = 1; // 개발
  static const int SEEK_OPERATION = 2; // 경영
  static const int SEEK_DESIGN = 3; // 디자인
  static const int SEEK_MARKETING = 4; // 마케팅
  static const int SEEK_SALES = 5; // 영업

  final int minimum = 10; // 카테고라별 정한 최솟 값

  bool activeSearchBar = false; // 검색창 유무
  bool filterActive = false; // 필터창 유무
  bool canCallOffset = true; // offset 중복 호출 방지
  bool canCallLackList = true; // lackList 중복 호출 방지

  int recruitPageIndex = 0; // 팀원모집 페이지 인덱스
  int seekPageIndex = 0; // 팀 찾기 페이지 인덱스

  RxInt recruitBarIndex = 0.obs; // 팀원모집 카테고리 인덱스
  RxInt seekBarIndex = 0.obs; // 팀 찾기 카테고리 인덱스

  Rx<Alignment> tabAlignForRecruit = Alignment.centerLeft.obs; // 팀원모집 필터 버튼 정렬
  Rx<Alignment> tabAlignForSeek = Alignment.centerLeft.obs; // 팀 찾기 필터 버튼 정렬

  int recruitExtraLength = 0; // 나중에 추가 된 포스트 길이
  int seekExtraLength = 0; // 나중에 추가 된 포스트 길이

  RxBool showFloating = true.obs; // 플로팅 버튼 보여주기 여부
  bool searchIconColorForRecruit = false; // 검색창 색 적용 여부
  bool searchIconColorForSeek = false; // 검색창 색 적용 여부

  // 리쿠르트 포스트 카드 데이터 변수
  int id;
  String title;
  String name;
  List<String> firstWrapList = [];
  List<String> secondWrapList = [];
  String state = '';
  String contents = '';
  String photoURL = '';
  bool isLike = false;

  // 리쿠르트 포스트 카드 데이터 set 함수
  void postCardDataSet({@required data, @required bool isRecruit}) {
    firstWrapList.clear();
    secondWrapList.clear();

    if (isRecruit) {
      TeamMemberRecruit teamMemberRecruit = data;
      Team team = GlobalProfile.getTeamByID(teamMemberRecruit.teamId); // 팀 데이터

      id = teamMemberRecruit.id;
      title = cutAuthInfo(teamMemberRecruit.title);
      name = team.name;
      state = setPeriodState(teamMemberRecruit.recruitPeriodEnd);
      contents = teamMemberRecruit.recruitInfo;
      photoURL = team.profileImgList[0].imgUrl;

      firstWrapList.add(teamMemberRecruit.servicePart);
      firstWrapList.add(abbreviateForLocation(teamMemberRecruit.location));
      firstWrapList.add(team.category);
      secondWrapList.add(teamMemberRecruit.recruitSubField);
      secondWrapList.add(teamMemberRecruit.education);
      secondWrapList.add(teamMemberRecruit.career);

      String workFormFirst = teamMemberRecruit.workFormFirst == '협의' ? '직급협의' : teamMemberRecruit.workFormFirst;
      secondWrapList.add(workFormFirst);
      String workDayOfWeek = teamMemberRecruit.workDayOfWeek == '협의' ? '근무일협의' : teamMemberRecruit.workDayOfWeek;
      secondWrapList.add(workDayOfWeek);
      String workTime = teamMemberRecruit.workTime;
      if (workTime == '자율') workTime = '자율출퇴근';
      if (workTime == '협의') workTime = '근무시간협의';
      secondWrapList.add(workTime);

      checkLike(isRecruit); // 좋아요 여부 확인
    } else {
      PersonalSeekTeam personalSeekTeam = data;
      UserData user = GlobalProfile.getUserByUserID(personalSeekTeam.userId);

      id = personalSeekTeam.id;
      title = cutAuthInfo(personalSeekTeam.title);
      name = user.name;
      state = personalSeekTeam.seekingState == 1 ? "구직중" : "구직완료";
      contents = personalSeekTeam.selfInfo;
      photoURL = user.profileImgList[0].imgUrl;

      firstWrapList.add(personalSeekTeam.seekingFieldSubPart);
      if (user.part != personalSeekTeam.seekingFieldSubPart)
        firstWrapList.add(user.part);
      else
        firstWrapList.add(user.subPart);

      firstWrapList.add(abbreviateForLocation(personalSeekTeam.location));
      secondWrapList.add(personalSeekTeam.education);
      secondWrapList.add(personalSeekTeam.career);

      String workFormFirst = personalSeekTeam.workFormFirst == '협의' ? '직급협의' : personalSeekTeam.workFormFirst;
      secondWrapList.add(workFormFirst);
      String workDayOfWeek = personalSeekTeam.workDayOfWeek == '협의' ? '근무일협의' : personalSeekTeam.workDayOfWeek;
      secondWrapList.add(workDayOfWeek);
      String workTime = personalSeekTeam.workTime;
      if (workTime == '자율') workTime = '자율출퇴근';
      if (workTime == '협의') workTime = '근무시간협의';
      secondWrapList.add(workTime);

      checkLike(isRecruit); // 좋아요 여부 확인
    }
  }

  // 검색 설정 함수
  void closeSearchEvent() {
    activeSearchBar = false; // 검색 바 닫기

    if (FilterController.to.searchForRecruit) searchIconColorForRecruit = true; // 검색 아이콘 색 켜주기
    else searchIconColorForRecruit = false; // 검색 아이콘 색 꺼주기

    if (FilterController.to.searchForPersonalSeek) searchIconColorForSeek = true; // 검색 아이콘 색 켜주기
    else searchIconColorForSeek = false; // 검색 아이콘 색 꺼주기
  }

  // 검색창 끄기 함수
  void searchBarOffEvent() {
    activeSearchBar = false;
    isRecruit = true;
  }

  // 최소 글 갯수 채워주는 함수
  Future<void> recruitGetLackList() async {
    int limit;
    int index;

    // recruit 카테고리 돌면서 부족하면 추가
    // 0은 전체라서 제외
    for (int i = 1; i < recruitCategoryList.length; i++) {
      List<TeamMemberRecruit> resultList = globalTeamMemberRecruitList.where((element) => element.category == recruitCategoryList[i]).toList();
      if (resultList.length < minimum) {
        limit = minimum - resultList.length;
        index = resultList.length;
        var res = await ApiProvider().post(
            '/Matching/Select/Offset/TeamMemberRecruit',
            jsonEncode({
              "category": recruitCategoryList[i],
              "limit": limit,
              "index": index,
            }));

        if (res != null) {
          for (int i = 0; i < res.length; i++) {
            TeamMemberRecruit temp = TeamMemberRecruit.fromJson(res[i]);
            globalTeamMemberRecruitList.add(temp);
            recruitExtraLength++;
            await GlobalProfile.getFutureTeamByID(temp.teamId);
          }
        }
      }
    }

    // globalTeamMemberRecruitList createdAt 큰 순으로 정렬
    globalTeamMemberRecruitList.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 초까지 같으면 순서 랜덤으로 바뀜
    debugPrint('Recruit sort!');
  }

  // 최소 글 갯수 채워주는 함수
  Future<void> seekGetLackList() async {
    int limit;
    int index;

    // personal seek 카테고리 돌면서 부족하면 추가
    // 0은 전체라서 제외
    for (int i = 1; i < seekCategoryList.length; i++) {
      List<PersonalSeekTeam> resultList = globalPersonalSeekTeamList.where((element) => element.category == seekCategoryList[i]).toList();
      if (resultList.length < minimum) {
        limit = minimum - resultList.length;
        index = resultList.length;
        var res = await ApiProvider().post(
            '/Matching/Select/Offset/PersonalSeekTeam',
            jsonEncode({
              "category": seekCategoryList[i],
              "limit": limit,
              "index": index,
            }));

        if (res != null) {
          for (int i = 0; i < res.length; i++) {
            PersonalSeekTeam temp = PersonalSeekTeam.fromJson(res[i]);
            globalPersonalSeekTeamList.add(temp);
            seekExtraLength++;
            await GlobalProfile.getFutureUserByUserID(temp.userId);
          }
        }
      }
    }

    // globalPersonalSeekTeamList updateAt 큰 순으로 정렬
    globalPersonalSeekTeamList.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 초까지 같으면 순서 랜덤으로 바뀜
    debugPrint('Personal Seek sort!');
  }

  // 모집상태 set
  String setPeriodState(String recruitPeriodEnd) {
    if (recruitPeriodEnd == '상시모집') {
      return '상시모집';
    } else {
      String periodEnd = recruitPeriodEnd;
      String now = DateTime.now().toString().replaceAll('-', '').replaceAll(' ', '').replaceAll(':', '').substring(0, 14);
      if (periodEnd.compareTo(now) == -1)
        return '모집마감';
      else
        return '모집중';
    }
  }

  // 좋아요 여부 확인
  void checkLike(bool isRecruit) {
    isLike = false; // false로 초기화 후 리스트에 값이 있으면 true

    if (isRecruit) {
      recruitLikesList.forEach((element) {
        if (element.targetId == id) isLike = true;
      });
    } else {
      personalSeekLikesList.forEach((element) {
        if (element.targetId == id) isLike = true;
      });
    }
  }

  // max scroll event 함수
  Future<void> maxScrollEvent() async {
    if (canCallOffset) {
      canCallOffset = false; // 중복 호출 방지

      if (isRecruit) {
        var res = await ApiProvider().post(
            '/Matching/Select/Offset/TeamMemberRecruit',
            jsonEncode({
              'category': '전체',
              "limit": 30,
              "index": globalTeamMemberRecruitList.length - recruitExtraLength,
            }));

        if (null == res || 0 == res.length) return offsetDelayEvent(); // 중복 호출 방지

        for (int i = 0; i < res.length; i++) {
          bool contains = false; // 기존 리스트 포함 여부

          globalTeamMemberRecruitList.forEach((element) {
            if (element.id == res[i]['id']) contains = true;
          });

          if (!contains) {
            await GlobalProfile.getFutureTeamByID(res[i]['TeamID']); // 팀 정보 불러오기
            globalTeamMemberRecruitList.add(TeamMemberRecruit.fromJson(res[i]));
          }
        }
      } else {
        var res = await ApiProvider().post(
            '/Matching/Select/Offset/PersonalSeekTeam',
            jsonEncode({
              'category': '전체',
              "limit": 30,
              "index": globalPersonalSeekTeamList.length - seekExtraLength,
            }));

        if (null == res || 0 == res.length) return offsetDelayEvent(); // 중복 호출 방지

        for (int i = 0; i < res.length; i++) {
          bool contains = false; // 기존 리스트 포함 여부

          globalPersonalSeekTeamList.forEach((element) {
            if (element.id == res[i]['id']) contains = true;
          });

          if (!contains) {
            await GlobalProfile.getFutureUserByUserID(res[i]['UserID']); // 유저 정보 불러오기
            globalPersonalSeekTeamList.add(PersonalSeekTeam.fromJson(res[i]));
          }
        }
      }
    }

    offsetDelayEvent(); // 중복 호출 방지
  }

  // offset 중복 호출 방지
  void offsetDelayEvent() {
    Future.delayed(Duration(milliseconds: 500), () {
      canCallOffset = true;
    });
  }

  // 새로고침
  Future<void> refreshData({BuildContext context, String value}) async {
    if (isRecruit) {
      if (FilterController.to.recruitFiltered) {
        await FilterController.to.filterEvent(isRecruit, tabAlignForRecruit.value, tabAlignForSeek.value); // 필터가 켜져 있을 때
      } else if (FilterController.to.searchForRecruit) {
        await FilterController.to.searchEvent(context, isRecruit, value); // 검색이 켜져 있을 때
      } else {
        globalTeamMemberRecruitList.clear(); // 리스트 초기화

        await ApiProvider().get('/Matching/Select/TeamMemberRecruit').then((value) async {
          if (value != null) {
            for (int i = 0; i < value.length; ++i) {
              TeamMemberRecruit t = TeamMemberRecruit.fromJson(value[i]);
              await GlobalProfile.getFutureTeamByID(t.teamId);
              globalTeamMemberRecruitList.add(t);
            }
          }
        });

        recruitGetLackList(); // 최소 글 갯수 채워주는 함수
      }
    } else {
      if (FilterController.to.personalSeekFiltered) {
        await FilterController.to.filterEvent(isRecruit, tabAlignForRecruit.value, tabAlignForSeek.value); // 필터가 켜져 있을 때
      } else if (FilterController.to.searchForPersonalSeek) {
        await FilterController.to.searchEvent(context, isRecruit, value); // 검색이 켜져 있을 때
      } else {
        globalPersonalSeekTeamList.clear(); // 리스트 초기화

        await ApiProvider().get('/Matching/Select/PersonalSeekTeam').then((value) async {
          if (value != null) {
            for (int i = 0; i < value.length; ++i) {
              PersonalSeekTeam p = PersonalSeekTeam.fromJson(value[i]);
              await GlobalProfile.getFutureUserByUserID(p.userId);
              globalPersonalSeekTeamList.add(p);
            }
          }
        });

        seekGetLackList(); // 최소 글 갯수 채워주는 함수
      }
    }
  }

  // 필터 상단 탭 정렬 set 함수
  void setTabAlign(Alignment setAlign) {
    isRecruit ? tabAlignForRecruit(setAlign) : tabAlignForSeek(setAlign);
  }

  // 필터 닫히는 이벤트
  void closeFilterActive() {
    filterActive = false;

    if (isRecruit) {
      // orderRule 초기화
      if (FilterController.to.recruitOrderRule == 0)
        tabAlignForRecruit(Alignment.centerLeft);
      else
        tabAlignForRecruit(Alignment.centerRight);

      if (!FilterController.to.recruitFiltered)
        FilterController.to.resetTempListForRecruit(); // 임시 리스트 리셋
      else
        FilterController.to.syncTempListForRecruit(); // 임시 리스트 정식 리스트로 덮어쓰기
    } else {
      // orderRule 초기화
      if (FilterController.to.seekingOrderRule == 0)
        tabAlignForSeek(Alignment.centerLeft);
      else
        tabAlignForSeek(Alignment.centerRight);

      if (!FilterController.to.personalSeekFiltered)
        FilterController.to.resetTempListForSeek(); // 임시 리스트 리셋
      else
        FilterController.to.syncTempListForSeek(); // 임시 리스트 정식 리스트로 덮어쓰기
    }
  }

  // 페이지(카테고리) 체인지 이벤트
  void pageChangeEvent(int index) {
    if (isRecruit) {
      recruitBarIndex(index);
      recruitPageIndex = index;
    } else {
      seekBarIndex(index);
      seekPageIndex = index;
    }
  }

  // 리쿠르트 상태 set 함수
  void setRecruitState(bool recruitState, PageController pageController, ScrollController filterScrollController, TextEditingController textEditingController) {
    isRecruit = recruitState;
    filterActive = false;
    // textEditingController.clear();

    filterScrollController.jumpTo(0);

    if (isRecruit) {
      pageController.jumpToPage(recruitPageIndex); // 리쿠르트 상태에 따라 페이지 set

      // 검색이 켜져 있으면 검색어 설정
      if (FilterController.to.searchForRecruit)
        textEditingController.text = FilterController.to.searchWordForRecruit;
      else
        textEditingController.clear();
    } else {
      pageController.jumpToPage(seekPageIndex); // 리쿠르트 상태에 따라 페이지 set

      // 검색이 켜져 있으면 검색어 설정
      if (FilterController.to.searchForPersonalSeek)
        textEditingController.text = FilterController.to.searchWordForSeek;
      else
        textEditingController.clear();
    }
  }

  // 바텀 네비게이션 눌렀을 때 스크롤 이벤트 함수
  Widget navScrollEvent(ScrollController scrollController) {
    if (navigationNum.getNum() == navigationNum.getPastNum()) {
      if (scrollController.hasClients) {
        Future.microtask(() => scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut));
        navigationNum.setNormalPastNum(-1);
      }
    }
    return SizedBox(width: navigationNum.forSetState.value * 0);
  }
}
