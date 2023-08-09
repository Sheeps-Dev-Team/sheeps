import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sheeps_app/Recruit/Controller/FilterController.dart';
import 'package:sheeps_app/Recruit/Controller/RecruitController.dart';
import 'package:sheeps_app/Recruit/ExpandableFab.dart';
import 'package:sheeps_app/Recruit/Models/PersonalSeekTeams.dart';
import 'package:sheeps_app/Recruit/Models/TeamMemberRecruit.dart';
import 'package:sheeps_app/Recruit/RecruitDetailPage.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/ListForProfileModify.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/dashboard/MyPage.dart';
import 'package:sheeps_app/network/ApiProvider.dart';

class RecruitPage extends StatefulWidget {
  @override
  _RecruitPageState createState() => _RecruitPageState();
}

class _RecruitPageState extends State<RecruitPage> {
  final RecruitController controller = Get.put(RecruitController()); // 리쿠르트 페이지 컨트롤러
  final FilterController filterController = Get.put(FilterController()); // 필터 컨트롤러
  PageController pageController = PageController();
  final FocusNode focusNode = FocusNode();
  final ScrollController scrollController = ScrollController();
  final ScrollController filterScrollController = ScrollController();
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController tabBarScrollController = ScrollController(); // 애니메이티드 탭바 스크롤 컨트롤러

  final String svgCheckInWhiteCircle = 'assets/images/Recruit/checkInWhiteCircle.svg';
  final String svgCheckInGreenCircle = 'assets/images/Recruit/checkInGreenCircle.svg';
  final String svgCheckInBlueCircle = 'assets/images/Recruit/checkInBlueCircle.svg';

  // 필터 적용 함수
  void filterFunc() {
    filterController
        .filterEvent(
      controller.isRecruit,
      controller.tabAlignForRecruit.value,
      controller.tabAlignForSeek.value,
    )
        .then((value) {
      if (scrollController.hasClients && scrollController.position.pixels != 0) {
        if (controller.isRecruit) {
          if (filterController.filteredRecruitList.length > 0) scrollController.jumpTo(0.1);
        } else {
          if (filterController.filteredPersonalSeekList.length > 0) scrollController.jumpTo(0.1);
        }
      }

      controller.activeSearchBar = false; // 검색창 닫기
      controller.filterActive = false; // 필터창 닫기
      textEditingController.clear(); // 검색어 날리기
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    // 한 번만 호출 됨
    if (controller.canCallLackList) {
      controller.recruitGetLackList(); // 최소 글 갯수 채워주는 함수
      controller.seekGetLackList(); // 최소 글 갯수 채워주는 함수
      filterController.checkFilterColorForRecruit(); // 필터 색 체크
      filterController.checkFilterColorForPersonalSeek(); // 필터 색 체크
      controller.canCallLackList = false;
    }

    // 검색이 켜져 있을 때
    if (controller.isRecruit) {
      if (filterController.searchForRecruit) textEditingController.text = filterController.searchWordForRecruit;
    } else {
      if (filterController.searchForPersonalSeek) textEditingController.text = filterController.searchWordForSeek;
    }

    // page 설정
    pageController = PageController(initialPage: controller.isRecruit ? controller.recruitPageIndex : controller.seekPageIndex);
    filterController.initTempList(); // tempList 설정
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (filterController.recruitFiltered || filterController.personalSeekFiltered) {
          filterController.maxFilterScrollEvent(controller.isRecruit).then((value) => setState(() {}));
        }
        if (filterController.searchForRecruit || filterController.searchForPersonalSeek) {
          filterController.maxSearchScrollEvent(controller.isRecruit).then((value) => setState(() {}));
        }
        controller.maxScrollEvent().then((value) => setState(() {}));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (controller.filterActive == true) controller.closeFilterActive(); // 필터 액티브 끄기
    controller.closeSearchEvent(); // 검색 창, 검색 아이콘 설정 함수
    focusNode.dispose();
    pageController.dispose();
    scrollController.dispose();
    filterScrollController.dispose();
    filterController.resetTempList(); // tempList 리셋
    textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), // 사용자 스케일팩터 무시
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: GestureDetector(
              onTap: () => unFocus(context), // 텍스트 포커스 해제
              child: Scaffold(
                backgroundColor: Colors.white,
                body: Column(
                  children: [
                    Obx(() => controller.navScrollEvent(scrollController)), // 하단 네비게이션 스크롤 이벤트
                    recruitTopBar(), // 상단 팀원모집, 팀 찾기, 검색, 필터
                    filterBox(), // 필터 박스
                    if (!controller.filterActive) ...[
                      controller.isRecruit // 상단 카테고리 바
                          ? Obx(() => categoryBar(
                                barIndex: controller.recruitBarIndex.value,
                                categoryList: controller.recruitCategoryList,
                                widthList: controller.recruitCategoryWidthList,
                              ))
                          : Obx(() => categoryBar(
                                barIndex: controller.seekBarIndex.value,
                                categoryList: controller.seekCategoryList,
                                widthList: controller.seekCategoryWidthList,
                              )),
                    ],
                    if (controller.isRecruit) ...[
                      Expanded(
                        child: PageView.builder(
                          controller: pageController,
                          onPageChanged: (index) => controller.pageChangeEvent(index),
                          itemBuilder: (context, index) {
                            switch (index) {
                              case RecruitController.RECRUIT_STARTUP:
                                {
                                  List<TeamMemberRecruit> resultList = [];
                                  if (filterController.recruitFiltered)
                                    resultList = filterController.filteredRecruitList.where((element) => element.category == '팀・스타트업').toList();
                                  else if (filterController.searchForRecruit)
                                    resultList = filterController.recruitSearchList.where((element) => element.category == '팀・스타트업').toList();
                                  else
                                    resultList = globalTeamMemberRecruitList.where((element) => element.category == '팀・스타트업').toList();
                                  return buildRecruitListView(resultList);
                                }
                              case RecruitController.RECRUIT_SUPPORT:
                                {
                                  List<TeamMemberRecruit> resultList = [];
                                  if (filterController.recruitFiltered)
                                    resultList = filterController.filteredRecruitList.where((element) => element.category == '지원사업').toList();
                                  else if (filterController.searchForRecruit)
                                    resultList = filterController.recruitSearchList.where((element) => element.category == '지원사업').toList();
                                  else
                                    resultList = globalTeamMemberRecruitList.where((element) => element.category == '지원사업').toList();
                                  return buildRecruitListView(resultList);
                                }
                              case RecruitController.RECRUIT_COMPETITION:
                                {
                                  List<TeamMemberRecruit> resultList = [];
                                  if (filterController.recruitFiltered)
                                    resultList = filterController.filteredRecruitList.where((element) => element.category == '공모전').toList();
                                  else if (filterController.searchForRecruit)
                                    resultList = filterController.recruitSearchList.where((element) => element.category == '공모전').toList();
                                  else
                                    resultList = globalTeamMemberRecruitList.where((element) => element.category == '공모전').toList();
                                  return buildRecruitListView(resultList);
                                }
                              case RecruitController.RECRUIT_SMALL_CLASS:
                                {
                                  // 카테고리 바 스크롤 이동
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (tabBarScrollController.hasClients) {
                                      tabBarScrollController.animateTo(tabBarScrollController.position.maxScrollExtent, duration: controller.duration, curve: controller.curve);
                                    }
                                  });
                                  List<TeamMemberRecruit> resultList = [];
                                  if (filterController.recruitFiltered)
                                    resultList = filterController.filteredRecruitList.where((element) => element.category == '소모임').toList();
                                  else if (filterController.searchForRecruit)
                                    resultList = filterController.recruitSearchList.where((element) => element.category == '소모임').toList();
                                  else
                                    resultList = globalTeamMemberRecruitList.where((element) => element.category == '소모임').toList();
                                  return buildRecruitListView(resultList);
                                }
                              default:
                                {
                                  // 카테고리 바 스크롤 이동
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (tabBarScrollController.hasClients) {
                                      tabBarScrollController.animateTo(0, duration: controller.duration, curve: controller.curve);
                                    }
                                  });
                                  List<TeamMemberRecruit> resultList = [];
                                  if (filterController.recruitFiltered)
                                    resultList = filterController.filteredRecruitList;
                                  else if (filterController.searchForRecruit)
                                    resultList = filterController.recruitSearchList;
                                  else
                                    resultList = globalTeamMemberRecruitList;
                                  return buildRecruitListView(resultList);
                                }
                            }
                          },
                          itemCount: controller.recruitCategoryList.length,
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: PageView.builder(
                          controller: pageController,
                          onPageChanged: (index) => controller.pageChangeEvent(index),
                          itemBuilder: (context, index) {
                            switch (index) {
                              case RecruitController.SEEK_DEVELOPMENT:
                                {
                                  List<PersonalSeekTeam> resultList = [];
                                  if (filterController.personalSeekFiltered)
                                    resultList = filterController.filteredPersonalSeekList.where((element) => element.category == '개발').toList();
                                  else if (filterController.searchForPersonalSeek)
                                    resultList = filterController.personalSeekSearchList.where((element) => element.category == '개발').toList();
                                  else
                                    resultList = globalPersonalSeekTeamList.where((element) => element.category == '개발').toList();
                                  return buildRecruitListView(resultList);
                                }
                              case RecruitController.SEEK_OPERATION:
                                {
                                  List<PersonalSeekTeam> resultList = [];
                                  if (filterController.personalSeekFiltered)
                                    resultList = filterController.filteredPersonalSeekList.where((element) => element.category == '경영').toList();
                                  else if (filterController.searchForPersonalSeek)
                                    resultList = filterController.personalSeekSearchList.where((element) => element.category == '경영').toList();
                                  else
                                    resultList = globalPersonalSeekTeamList.where((element) => element.category == '경영').toList();
                                  return buildRecruitListView(resultList);
                                }
                              case RecruitController.SEEK_DESIGN:
                                {
                                  List<PersonalSeekTeam> resultList = [];
                                  if (filterController.personalSeekFiltered)
                                    resultList = filterController.filteredPersonalSeekList.where((element) => element.category == '디자인').toList();
                                  else if (filterController.searchForPersonalSeek)
                                    resultList = filterController.personalSeekSearchList.where((element) => element.category == '디자인').toList();
                                  else
                                    resultList = globalPersonalSeekTeamList.where((element) => element.category == '디자인').toList();
                                  return buildRecruitListView(resultList);
                                }
                              case RecruitController.SEEK_MARKETING:
                                {
                                  List<PersonalSeekTeam> resultList = [];
                                  if (filterController.personalSeekFiltered)
                                    resultList = filterController.filteredPersonalSeekList.where((element) => element.category == '마케팅').toList();
                                  else if (filterController.searchForPersonalSeek)
                                    resultList = filterController.personalSeekSearchList.where((element) => element.category == '마케팅').toList();
                                  else
                                    resultList = globalPersonalSeekTeamList.where((element) => element.category == '마케팅').toList();
                                  return buildRecruitListView(resultList);
                                }
                              case RecruitController.SEEK_SALES:
                                {
                                  List<PersonalSeekTeam> resultList = [];
                                  if (filterController.personalSeekFiltered)
                                    resultList = filterController.filteredPersonalSeekList.where((element) => element.category == '영업').toList();
                                  else if (filterController.searchForPersonalSeek)
                                    resultList = filterController.personalSeekSearchList.where((element) => element.category == '영업').toList();
                                  else
                                    resultList = globalPersonalSeekTeamList.where((element) => element.category == '영업').toList();
                                  return buildRecruitListView(resultList);
                                }
                              default:
                                {
                                  List<PersonalSeekTeam> resultList = [];
                                  if (filterController.personalSeekFiltered)
                                    resultList = filterController.filteredPersonalSeekList;
                                  else if (filterController.searchForPersonalSeek)
                                    resultList = filterController.personalSeekSearchList;
                                  else
                                    resultList = globalPersonalSeekTeamList;
                                  return buildRecruitListView(resultList);
                                }
                            }
                          },
                          itemCount: controller.seekCategoryList.length,
                        ),
                      ),
                    ],
                  ],
                ),
                floatingActionButton: Obx(
                  () => controller.showFloating.value
                      ? FloatingActionButton(
                          onPressed: () {
                            Get.dialog(
                              ExpandableFab(isRecruit: controller.isRecruit),
                              barrierColor: Color.fromRGBO(136, 136, 136, 0.5),
                            ).then((value) {
                              controller.showFloating.value = true; // 플로팅 버튼 보이기
                              setState(() {});
                            });

                            controller.showFloating.value = false; // 플로팅 버튼 없애기
                          },
                          backgroundColor: controller.isRecruit ? sheepsColorGreen : sheepsColorBlue,
                          child: SvgPicture.asset(svgPlusIcon),
                        )
                      : Container(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  AnimatedContainer filterBox() {
    return AnimatedContainer(
      margin: EdgeInsets.only(bottom: controller.filterActive ? 4 * sizeUnit : 0),
      constraints: BoxConstraints(maxHeight: Get.height * 0.70),
      height: controller.filterActive ? 455 * sizeUnit : 0 * sizeUnit,
      duration: Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24 * sizeUnit),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            offset: Offset(0, 2 * sizeUnit), //(x,y)
            blurRadius: 1 * sizeUnit,
          ),
        ],
        color: Colors.white,
      ),
      child: Obx(
        () => ListView(
          controller: filterScrollController,
          children: [
            SizedBox(height: 16 * sizeUnit),
            buildFilterTopButtonList(),
            SizedBox(height: 16 * sizeUnit),
            // 팀원모집 필터
            if (controller.isRecruit) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20 * sizeUnit),
                child: Column(
                  children: [
                    filterTitleAndList(
                      title: '팀원모집 분야',
                      referenceList: FieldCategory,
                      tempList: filterController.tempJobFieldForRecruit,
                    ),
                    filterTitleAndList(
                      title: '서비스 분야',
                      referenceList: serviceFieldList,
                      tempList: filterController.tempServiceFieldForRecruit,
                    ),
                    filterTitleAndList(
                      title: '지역',
                      referenceList: locationNameList,
                      tempList: filterController.tempLocationListForRecruit,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // 팀 찾기 필터
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20 * sizeUnit),
                child: Column(
                  children: [
                    filterTitleAndList(
                      title: '구직분야',
                      referenceList: FieldCategory,
                      tempList: filterController.tempJobFieldForSeek,
                    ),
                    filterTitleAndList(
                      title: '최소학력',
                      referenceList: educationList,
                      tempList: filterController.tempEducationListForSeek,
                    ),
                    filterTitleAndList(
                      title: '근무형태',
                      referenceList: workTypeList,
                      tempList: filterController.tempWorkTypeForSeek,
                    ),
                    filterTitleAndList(
                      title: '지역',
                      referenceList: locationNameList,
                      tempList: filterController.tempLocationListForSeek,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget filterTitleAndList({required String title, required List<String> referenceList, required List<bool> tempList}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: SheepsTextStyle.h3(),
            ),
            SizedBox(width: 16 * sizeUnit),
            filterDeselectButton(() => filterController.tempListReset(tempList)),
          ],
        ),
        SizedBox(height: 12 * sizeUnit),
        Wrap(
          runSpacing: 4 * sizeUnit,
          spacing: 4 * sizeUnit,
          children: referenceList
              .asMap()
              .map(
                (index, item) => MapEntry(
                  index,
                  GestureDetector(
                    onTap: () => filterController.toggleFilterButton(index, tempList),
                    child: SheepsFilterItem(
                      context,
                      item,
                      tempList[index],
                      color: controller.isRecruit ? sheepsColorGreen : sheepsColorBlue,
                    ),
                  ),
                ),
              )
              .values
              .toList()
              .cast<Widget>(),
        ),
        SizedBox(height: 20 * sizeUnit),
      ],
    );
  }

  // 필터 선택해제 위젯
  Widget filterDeselectButton(Function press) {
    return GestureDetector(
      onTap: () => press(),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            width: 16 * sizeUnit,
            height: 16 * sizeUnit,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: sheepsColorLightGrey),
            ),
            child: SvgPicture.asset(svgFilterDeselect, width: 8 * sizeUnit),
          ),
          SizedBox(width: 4 * sizeUnit),
          Text(
            '선택 해제',
            style: SheepsTextStyle.s3().copyWith(fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget buildFilterTopButtonList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20 * sizeUnit),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20 * sizeUnit),
              border: Border.all(color: sheepsColorLightGrey),
            ),
            width: 196 * sizeUnit,
            height: 32 * sizeUnit,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    AnimatedContainer(
                      alignment: controller.isRecruit ? controller.tabAlignForRecruit.value : controller.tabAlignForSeek.value,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      color: Colors.transparent,
                      width: 188 * sizeUnit,
                      height: 32 * sizeUnit,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16 * sizeUnit),
                          color: controller.isRecruit ? sheepsColorGreen : sheepsColorBlue,
                        ),
                        width: 84 * sizeUnit,
                        height: 24 * sizeUnit,
                      ),
                    ),
                    Container(
                      width: 188 * sizeUnit,
                      height: 32 * sizeUnit,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildAnimationButton(Alignment.centerLeft, '최근 게시 순'),
                          buildAnimationButton(Alignment.centerRight, '최근 접속 순'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 28 * sizeUnit),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (controller.isRecruit) {
                filterController.tempShowRecruitmentOnly.value = !filterController.tempShowRecruitmentOnly.value;
                filterController.checkFilterColorForRecruit();
              } else {
                filterController.tempShowSeekingOnly.value = !filterController.tempShowSeekingOnly.value;
                filterController.checkFilterColorForPersonalSeek();
              }
            },
            child: Row(
              children: [
                if (controller.isRecruit) ...[
                  filterController.tempShowRecruitmentOnly.value ? SvgPicture.asset(svgCheckInGreenCircle) : SvgPicture.asset(svgCheckInWhiteCircle),
                ] else ...[
                  filterController.tempShowSeekingOnly.value ? SvgPicture.asset(svgCheckInBlueCircle) : SvgPicture.asset(svgCheckInWhiteCircle),
                ],
                SizedBox(width: 6 * sizeUnit),
                Text(controller.isRecruit ? '모집중만 보기' : '구직중만 보기', style: SheepsTextStyle.b4())
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAnimationButton(Alignment setAlign, String text) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => controller.setTabAlign(setAlign),
      child: Container(
        width: 84 * sizeUnit,
        height: 24 * sizeUnit,
        alignment: Alignment.center,
        child: AnimatedDefaultTextStyle(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInCubic,
          style: SheepsTextStyle.b4().copyWith(
            fontWeight: controller.isRecruit
                ? controller.tabAlignForRecruit.value == setAlign
                    ? FontWeight.w500
                    : FontWeight.normal
                : controller.tabAlignForSeek.value == setAlign
                    ? FontWeight.w500
                    : FontWeight.normal,
            color: controller.isRecruit
                ? controller.tabAlignForRecruit.value == setAlign
                    ? Colors.white
                    : sheepsColorDarkGrey
                : controller.tabAlignForSeek.value == setAlign
                    ? Colors.white
                    : sheepsColorDarkGrey,
          ),
          child: Text(text),
        ),
      ),
    );
  }

  // 리스트뷰 위젯
  Widget buildRecruitListView(List resultList) {
    // 모집중만 보기, 구직중만 보기 켜져 있을 때
    if (controller.isRecruit) {
      if (filterController.showRecruitmentOnly) resultList = resultList.where((element) => controller.setPeriodState(element.recruitPeriodEnd) != '모집마감').toList();
    } else {
      if (filterController.showSeekingOnly) resultList = resultList.where((element) => element.seekingState == 1).toList();
    }

    if (resultList.length == 0) {
      return sheepsCustomRefreshIndicator(
        child: GestureDetector(
          onTap: () {
            if (controller.filterActive) filterFunc();
          },
          child: ListView(
            children: [
              SizedBox(height: Get.height * 0.2),
              noSearchResultsPage(null),
            ],
          ),
        ),
        onRefresh: () => controller.refreshData(context: context, value: textEditingController.text).then((value) => setState(() {})),
        indicatorColor: controller.isRecruit ? sheepsColorGreen : sheepsColorBlue,
      );
    }

    return sheepsCustomRefreshIndicator(
      onRefresh: () => controller.refreshData(context: context, value: textEditingController.text).then((value) => setState(() {})),
      indicatorColor: controller.isRecruit ? sheepsColorGreen : sheepsColorBlue,
      child: ListView.builder(
        controller: scrollController,
        physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemCount: resultList.length,
        itemBuilder: (context, index) {
          return sheepsRecruitPostCard(
            isRecruit: controller.isRecruit,
            dataSetFunc: () => controller.postCardDataSet(data: resultList[index], isRecruit: controller.isRecruit),
            press: () async {
              if (controller.filterActive) {
                filterFunc();
              } else {
                if (controller.isRecruit) {
                  var res = await ApiProvider().post('/Matching/Select/TeamMemberRecruitByID', jsonEncode({"id": resultList[index].id}));

                  TeamMemberRecruit teamMemberRecruit = TeamMemberRecruit.fromJson(res);
                  resultList[index] = teamMemberRecruit;
                  globalTeamMemberRecruitList.forEach((element) {
                    if (element.id == teamMemberRecruit.id) {
                      element = teamMemberRecruit;
                    }
                  });
                } else {
                  var res = await ApiProvider().post('/Matching/Select/PersonalSeekTeamByID', jsonEncode({"id": resultList[index].id}));

                  PersonalSeekTeam personalSeekTeam = PersonalSeekTeam.fromJson(res);
                  resultList[index] = personalSeekTeam;
                  globalPersonalSeekTeamList.forEach((element) {
                    if (element.id == personalSeekTeam.id) {
                      element = personalSeekTeam;
                    }
                  });
                }

                Get.to(() => RecruitDetailPage(isRecruit: controller.isRecruit, data: resultList[index]))?.then((value) => setState(() {}));
              }
            },
            controller: controller,
          );
        },
      ),
    );
  }

  // 카테고리 바
  Column categoryBar({
    required int barIndex,
    required List<String> categoryList,
    required List<double> widthList,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.isRecruit) ...[
          SingleChildScrollView(
            controller: tabBarScrollController,
            scrollDirection: Axis.horizontal,
            child: Container(
              height: 36 * sizeUnit,
              padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
              child: SheepsAnimatedTabBar(
                pageController: pageController,
                barIndex: barIndex,
                insidePadding: 20 * sizeUnit,
                listTabItemTitle: categoryList,
                listTabItemWidth: widthList,
              ),
            ),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            height: 36 * sizeUnit,
            padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
            child: SheepsAnimatedTabBar(
              pageController: pageController,
              barIndex: barIndex,
              insidePadding: 20 * sizeUnit,
              listTabItemTitle: categoryList,
              listTabItemWidth: widthList,
            ),
          ),
        ],
        Container(
          width: 360 * sizeUnit,
          height: 1,
          color: sheepsColorLightGrey,
        ),
      ],
    );
  }

  // 상단 팀원모집, 팀 찾기, 검색, 필터
  Container recruitTopBar() {
    return Container(
      width: double.infinity,
      height: 44 * sizeUnit,
      child: Row(
        children: [
          SizedBox(width: 16 * sizeUnit),
          // 검색 창 뜰때
          if (controller.activeSearchBar) ...[
            Expanded(
              child: Container(
                height: 28 * sizeUnit,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sheepsColorLightGrey,
                  borderRadius: BorderRadius.circular(16 * sizeUnit),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8 * sizeUnit),
                      child: SvgPicture.asset(
                        svgGreyMagnifyingGlass,
                        width: 16 * sizeUnit,
                        height: 16 * sizeUnit,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                          focusNode: focusNode,
                          controller: textEditingController,
                          decoration: InputDecoration(
                            hintText: controller.isRecruit ? '팀원 모집글 검색' : '팀 찾기글 검색',
                            border: InputBorder.none,
                            hintStyle: SheepsTextStyle.info1(),
                            isDense: true,
                            contentPadding: EdgeInsets.only(left: 8 * sizeUnit),
                          ),
                          style: SheepsTextStyle.b3(),
                          onSubmitted: (value) => filterController.searchEvent(context, controller.isRecruit, value).then((value) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (scrollController.hasClients && scrollController.position.pixels != 0) {
                                    if (controller.isRecruit) {
                                      if (filterController.recruitSearchList.length > 0) scrollController.jumpTo(0.1);
                                    } else {
                                      if (filterController.personalSeekSearchList.length > 0) scrollController.jumpTo(0.1);
                                    }
                                  }
                                });
                                setState(() {});
                              })),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 8 * sizeUnit),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            textEditingController.clear();

                            if (controller.isRecruit) {
                              filterController.searchForRecruit = false; // 검색 끄기
                              filterController.recruitFiltered = false; // 필터 끄기
                              filterController.resetTempListForRecruit(); // 임시리스트 초기화
                              controller.tabAlignForRecruit.value = Alignment.centerLeft; // orderRule 초기화
                              filterController.checkFilterColorForRecruit(); // 필터 색 체크
                              controller.searchIconColorForRecruit = false; // 검색 아이콘 색 끄기
                            } else {
                              filterController.searchForPersonalSeek = false; // 검색 끄기
                              filterController.personalSeekFiltered = false; // 필터 끄기
                              filterController.resetTempListForSeek(); // 임시리스트 초기화
                              controller.tabAlignForSeek.value = Alignment.centerLeft; // orderRule 초기화
                              filterController.checkFilterColorForPersonalSeek(); // 필터 색 체크
                              controller.searchIconColorForSeek = false; // 검색 아이콘 색 끄기
                            }

                            controller.activeSearchBar = !controller.activeSearchBar;
                          });
                        },
                        constraints: BoxConstraints(maxWidth: 16 * sizeUnit, maxHeight: 16 * sizeUnit),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        iconSize: 16 * sizeUnit,
                        color: sheepsColorDarkGrey,
                        icon: Icon(Icons.clear),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ] else ...[
            recruitStateTitle(
              '팀원모집',
              true,
            ),
            SizedBox(width: 22 * sizeUnit),
            recruitStateTitle(
              '팀 찾기',
              false,
            ),
            Spacer(),
            InkWell(
              onTap: () {
                setState(() {
                  controller.closeFilterActive(); // 필터 닫기
                  controller.activeSearchBar = !controller.activeSearchBar;
                  focusNode.requestFocus();
                });
              },
              child: SvgPicture.asset(
                svgGreyMagnifyingGlass,
                color: controller.isRecruit
                    ? controller.searchIconColorForRecruit
                        ? sheepsColorGreen
                        : sheepsColorDarkGrey
                    : controller.searchIconColorForSeek
                        ? sheepsColorBlue
                        : sheepsColorDarkGrey,
                width: 28 * sizeUnit,
                height: 28 * sizeUnit,
              ),
            ),
          ],
          SizedBox(
            width: 12 * sizeUnit,
          ),
          GestureDetector(
              // 필터 아이콘
              onTap: () {
                if (controller.filterActive) {
                  filterFunc();
                } else {
                  setState(() {
                    controller.filterActive = true;
                  });
                }
              },
              child: Obx(
                () => SvgPicture.asset(
                  svgBlackFilterIcon,
                  color: controller.isRecruit
                      ? filterController.recruitFilterColor.value
                          ? sheepsColorGreen
                          : sheepsColorDarkGrey
                      : filterController.personalSeekFilterColor.value
                          ? sheepsColorBlue
                          : sheepsColorDarkGrey,
                  width: 28 * sizeUnit,
                  height: 28 * sizeUnit,
                ),
              )),
          SizedBox(
            width: 12 * sizeUnit,
          ),
          GestureDetector(
            onTap: () => Get.to(() => MyPage())?.then((value) => setState(() {})),
            child: SvgPicture.asset(
              svgGreyMyPageButton,
              width: 28 * sizeUnit,
              height: 28 * sizeUnit,
            ),
          ),
          SizedBox(
            width: 12 * sizeUnit,
          ),
        ],
      ),
    );
  }

  // 상단 타이틀 위젯
  GestureDetector recruitStateTitle(String text, bool recruitState) {
    return GestureDetector(
      onTap: () {
        controller.setRecruitState(recruitState, pageController, filterScrollController, textEditingController);

        // 위젯 변경 후 스크롤 상단으로 이동
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients && scrollController.position.pixels != 0) {
            scrollController.jumpTo(0.1);
          }
        });
        setState(() {});
      },
      child: Text(
        text,
        style: SheepsTextStyle.h2().copyWith(color: controller.isRecruit == recruitState ? sheepsColorBlack : sheepsColorDarkGrey),
      ),
    );
  }
}
