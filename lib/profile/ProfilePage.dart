import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/ListForProfileModify.dart';
import 'package:sheeps_app/config/NavigationNum.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/profile/DetailProfile.dart';
import 'package:sheeps_app/profile/DetailTeamProfile.dart';
import 'package:sheeps_app/profile/models/FilterState.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/dashboard/MyPage.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/profile/models/ProfileState.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  int duration = 300;
  int durationFilter = 500;
  bool filterActive = false;
  TextEditingController _controller = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  ScrollController personalScrollController = ScrollController();
  ScrollController teamScrollController = ScrollController();
  NavigationNum navigationNum = Get.put(NavigationNum());

  late GlobalKey<RefreshIndicatorState> refreshKey;

  late GlobalKey actionKey;

  late ProfileState profileState;

  late PageController pageController;

  final svgGreyFilterIcon = 'assets/images/Profile/GreyFilterIcon.svg';
  final svgGreyMyPageButton = 'assets/images/Public/GreyMyPageButton.svg';
  final svgBlackFilterIcon = 'assets/images/Profile/BlackFilterIcon.svg';

  late FilterStateForPersonal _FilterStateForPersonal;

  Future<void> filterFuncForPersonal() async {
    await _FilterStateForPersonal.filterEventForPersonal();
    filterActive = false; // 필터 박스 올리기
    _FilterStateForPersonal.isSearch = false; // 검색창 끄기
    _controller.clear(); // 검색창 비우기
    setState(() {});
  }

  Future<void> filterFuncForTeam() async {
    await _FilterStateForPersonal.filterEventForTeam();
    filterActive = false; // 필터 박스 올리기
    _FilterStateForPersonal.isSearch = false; // 검색창 끄기
    _controller.clear(); // 검색창 비우기
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    refreshKey = GlobalKey<RefreshIndicatorState>();
    _FilterStateForPersonal = Get.put(FilterStateForPersonal());
    profileState = Get.put(ProfileState());
    pageController = PageController(initialPage: profileState.getState);
    _FilterStateForPersonal.saveFilterListLog(); // 검색한 필터 리스트 임시 리스트에 저장
    _controller.text = _FilterStateForPersonal.searchWords;
  }

  @override
  void dispose() {
    _controller.dispose();
    personalScrollController.dispose();
    teamScrollController.dispose();
    pageController.dispose();
    searchFocusNode.dispose();
    _FilterStateForPersonal.resetTempList(); // tempList 리셋
    closeFilterEvent();
    _FilterStateForPersonal.closeSearchEvent(); // 검색 관련 설정
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    personalScrollController.addListener(() {
      if (personalScrollController.position.pixels == personalScrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
    teamScrollController.addListener(() {
      if (teamScrollController.position.pixels == teamScrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
  }

  _getMoreData() async {
    List<dynamic> list = [];

    //개인프로필상태
    if (profileState.getState == ProfileState.STATE_PERSON) {
      // 필터 켜져 있을 때
      if (_FilterStateForPersonal.isFilteredForPersonal) {
        return await _FilterStateForPersonal.filterEventForPersonal(isOffset: true).then((value) => setState(() {}));
      } else if (GlobalProfile.personalFiltered) {
        return await _FilterStateForPersonal.searchEventForPersonal(_controller.text, isOffset: true); // 검색 켜져 있을 때
      } else {
        list = await ApiProvider().post(
            '/Personal/Select/Offset/UserList',
            jsonEncode({
              'userID': GlobalProfile.loggedInUser!.userID,
              "index": GlobalProfile.personalProfile.length,
            }));

        if (null == list || 0 == list.length) return;

        for (int i = 0; i < list.length; i++) {
          UserData user = UserData.fromJson(list[i]);
          bool isHave = false;

          GlobalProfile.personalProfile.forEach((element) {
            if (element.userID == user.userID) {
              isHave = true;
              return;
            }
          });

          if (!isHave) GlobalProfile.personalProfile.add(user);
        }

        GlobalProfile.profileSort();
      }
    } else {
      // 필터 켜져 있을 때
      if (_FilterStateForPersonal.isFilteredForTeam) {
        await _FilterStateForPersonal.filterEventForTeam(isOffset: true);
      } else if (GlobalProfile.teamFiltered) {
        await _FilterStateForPersonal.searchEventForTeam(_controller.text, isOffset: true); // 검색 켜져 있을 때
      } else {
        list = await ApiProvider().post(
            '/Team/Profile/SelectOffset',
            jsonEncode({
              "index": GlobalProfile.teamProfile.length,
            }));

        if (null == list || 0 == list.length) return;

        for (int i = 0; i < list.length; i++) {
          Team team = Team.fromJson(list[i]);
          bool isHave = false;

          GlobalProfile.teamProfile.forEach((element) {
            if (element.id == team.id) {
              isHave = true;
              return;
            }
          });

          if (!isHave) GlobalProfile.teamProfile.add(team);
        }

        GlobalProfile.profileSort(isTeam: true);
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (profileState.barIndex.value != profileState.getState) {
      profileState.barIndex.value = profileState.getState;
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: GestureDetector(
              onTap: () {
                unFocus(context);
              },
              child: Scaffold(
                backgroundColor: Colors.white,
                body: Column(
                  children: [
                    profilePageTopBar(context, profileState, navigationNum),
                    Obx(() {
                      if (navigationNum.getNum() == navigationNum.getPastNum()) {
                        if (personalScrollController.hasClients) {
                          Future.microtask(() => personalScrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut));
                          navigationNum.setNormalPastNum(-1);
                        }
                        if (teamScrollController.hasClients) {
                          Future.microtask(() => teamScrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut));
                          navigationNum.setNormalPastNum(-1);
                        }
                      }
                      return SizedBox(width: navigationNum.forSetState.value * 0);
                    }),
                    personalFilterBox(), // 개인 필터 박스
                    teamFilterBox(), // 팀·스타트업 필터 박스
                    if (!filterActive) ...[
                      Padding(
                        padding: EdgeInsets.only(left: 16 * sizeUnit),
                        child: Obx(() => SheepsAnimatedTabBar(
                              pageController: pageController,
                              barIndex: profileState.barIndex.value,
                              insidePadding: 20 * sizeUnit,
                              listTabItemTitle: ['개인', '팀・스타트업', '전문가'],
                              listTabItemWidth: [30 * sizeUnit, 90 * sizeUnit, 45 * sizeUnit],
                            )),
                      ),
                      Container(
                        width: 360 * sizeUnit,
                        height: 1 * sizeUnit,
                        color: sheepsColorLightGrey,
                      ),
                    ],
                    Expanded(
                      child: PageView(
                        controller: pageController,
                        onPageChanged: (index) {
                          profileState.barIndex.value = index;
                          profileState.setState(index);
                          switch (profileState.getState) {
                            case ProfileState.STATE_PERSON:
                              {
                                setState(() {
                                  if (profileState.getState != ProfileState.STATE_PERSON) {
                                    profileState.setState(ProfileState.STATE_PERSON);
                                  }
                                });
                              }
                              break;
                            case ProfileState.STATE_TEAM:
                              {
                                setState(() {
                                  if (profileState.getState != ProfileState.STATE_TEAM) {
                                    profileState.setState(ProfileState.STATE_TEAM);
                                  }
                                });
                              }
                              break;
                            case ProfileState.STATE_EXPERT:
                              {
                                setState(() {
                                  if (profileState.getState != ProfileState.STATE_EXPERT) {
                                    profileState.setState(ProfileState.STATE_EXPERT);
                                  }
                                });
                              }
                              break;
                          }
                        },
                        children: [
                          myCustomRefreshIndicator(child: personalProfilePage(context)), //개인프로필
                          myCustomRefreshIndicator(child: teamProfilePage(context)), //팀프로필
                          noSearchResultsPage('전문가 서비스는 개발 중입니다.\n추후 업데이트를 기다려 주세요!') //전문가프로필
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 개인 필터 박스
  Widget personalFilterBox() {
    return AnimatedContainer(
      constraints: BoxConstraints(maxHeight: Get.height * 0.70),
      margin: EdgeInsets.only(bottom: filterActive && profileState.getState == ProfileState.STATE_PERSON ? 4 * sizeUnit : 0),
      height: filterActive && profileState.getState == ProfileState.STATE_PERSON ? 340 * sizeUnit : 0,
      duration: Duration(milliseconds: durationFilter),
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
      child: ListView(
        children: [
          SizedBox(height: 16 * sizeUnit),
          buildFilterTopButtonList(_FilterStateForPersonal),
          SizedBox(height: 16 * sizeUnit),
          Row(
            children: [
              SizedBox(width: 20 * sizeUnit),
              Text(
                "직군",
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(width: 16 * sizeUnit),
              filterDeselectButton(() {
                setState(() {
                  _FilterStateForPersonal.tempCataForPerson = List.generate(_FilterStateForPersonal.tempCataForPerson.length, (index) => false);
                  _FilterStateForPersonal.checkFilterColorForPersonal();
                });
              }),
            ],
          ),
          SizedBox(height: 16 * sizeUnit),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * sizeUnit),
            child: Wrap(
              runSpacing: 4 * sizeUnit,
              spacing: 4 * sizeUnit,
              children: FieldCategory.asMap()
                  .map((index, item) => MapEntry(
                      index,
                      GestureDetector(
                          onTap: () {
                            _FilterStateForPersonal.tempCataForPerson[index] = !_FilterStateForPersonal.tempCataForPerson[index];
                            _FilterStateForPersonal.checkFilterColorForPersonal();
                            setState(() {});
                          },
                          child: SheepsFilterItem(
                            context,
                            item,
                            _FilterStateForPersonal.tempCataForPerson[index],
                            color: sheepsColorBlue,
                          ))))
                  .values
                  .toList()
                  .cast<Widget>(),
            ),
          ),
          SizedBox(height: 20 * sizeUnit),
          Row(
            children: [
              SizedBox(width: 20 * sizeUnit),
              Text(
                "지역",
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(width: 16 * sizeUnit),
              filterDeselectButton(() {
                setState(() {
                  _FilterStateForPersonal.tempLocaForPerson = List.generate(_FilterStateForPersonal.tempLocaForPerson.length, (index) => false);
                  _FilterStateForPersonal.checkFilterColorForPersonal();
                });
              }),
            ],
          ),
          SizedBox(height: 16 * sizeUnit),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * sizeUnit),
            child: Wrap(
              runSpacing: 4 * sizeUnit,
              spacing: 4 * sizeUnit,
              children: locationNameList
                  .asMap()
                  .map((index, item) => MapEntry(
                      index,
                      GestureDetector(
                          onTap: () {
                            _FilterStateForPersonal.tempLocaForPerson[index] = !_FilterStateForPersonal.tempLocaForPerson[index];
                            _FilterStateForPersonal.checkFilterColorForPersonal();
                            setState(() {});
                          },
                          child: SheepsFilterItem(
                            context,
                            item,
                            _FilterStateForPersonal.tempLocaForPerson[index],
                            color: sheepsColorBlue,
                          ))))
                  .values
                  .toList()
                  .cast<Widget>(),
            ),
          ),
          SizedBox(height: 20 * sizeUnit),
        ],
      ),
    );
  }

  // 팀 필터 박스
  Widget teamFilterBox() {
    return AnimatedContainer(
      constraints: BoxConstraints(maxHeight: Get.height * 0.70),
      margin: EdgeInsets.only(bottom: filterActive && profileState.getState == ProfileState.STATE_TEAM ? 4 * sizeUnit : 0),
      height: filterActive && profileState.getState == ProfileState.STATE_TEAM ? 445 * sizeUnit : 0,
      duration: Duration(milliseconds: durationFilter),
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
      child: ListView(
        children: [
          SizedBox(height: 16 * sizeUnit),
          buildFilterTopButtonList(_FilterStateForPersonal),
          SizedBox(height: 16 * sizeUnit),
          Row(
            children: [
              SizedBox(width: 20 * sizeUnit),
              Text(
                "서비스 분야",
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(width: 16 * sizeUnit),
              filterDeselectButton(() {
                setState(() {
                  _FilterStateForPersonal.tempCataForTeam = List.generate(_FilterStateForPersonal.tempCataForTeam.length, (index) => false);
                  _FilterStateForPersonal.checkFilterColorForTeam();
                });
              }),
            ],
          ),
          SizedBox(height: 16 * sizeUnit),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * sizeUnit),
            child: Wrap(
              runSpacing: 4 * sizeUnit,
              spacing: 4 * sizeUnit,
              children: serviceFieldList
                  .asMap()
                  .map((index, item) => MapEntry(
                      index,
                      GestureDetector(
                          onTap: () {
                            _FilterStateForPersonal.tempCataForTeam[index] = !_FilterStateForPersonal.tempCataForTeam[index];
                            _FilterStateForPersonal.checkFilterColorForTeam();
                            setState(() {});
                          },
                          child: SheepsFilterItem(context, item, _FilterStateForPersonal.tempCataForTeam[index]))))
                  .values
                  .toList()
                  .cast<Widget>(),
            ),
          ),
          SizedBox(height: 20 * sizeUnit),
          Row(
            children: [
              SizedBox(width: 20 * sizeUnit),
              Text(
                "지역",
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(width: 16 * sizeUnit),
              filterDeselectButton(() {
                setState(() {
                  _FilterStateForPersonal.tempLocaForTeam = List.generate(_FilterStateForPersonal.tempLocaForTeam.length, (index) => false);
                  _FilterStateForPersonal.checkFilterColorForTeam();
                });
              }),
            ],
          ),
          SizedBox(height: 16 * sizeUnit),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * sizeUnit),
            child: Wrap(
              runSpacing: 4 * sizeUnit,
              spacing: 4 * sizeUnit,
              children: locationNameList
                  .asMap()
                  .map((index, item) => MapEntry(
                      index,
                      GestureDetector(
                          onTap: () {
                            _FilterStateForPersonal.tempLocaForTeam[index] = !_FilterStateForPersonal.tempLocaForTeam[index];
                            _FilterStateForPersonal.checkFilterColorForTeam();
                            setState(() {});
                          },
                          child: SheepsFilterItem(context, item, _FilterStateForPersonal.tempLocaForTeam[index]))))
                  .values
                  .toList()
                  .cast<Widget>(),
            ),
          ),
          SizedBox(height: 20 * sizeUnit),
          Material(
            color: Colors.white,
            child: Row(
              children: [
                SizedBox(width: 20 * sizeUnit),
                Text(
                  "설립 유형",
                  style: SheepsTextStyle.h3(),
                ),
                SizedBox(width: 16 * sizeUnit),
                filterDeselectButton(() {
                  setState(() {
                    _FilterStateForPersonal.tempDistingForTeam = List.generate(_FilterStateForPersonal.tempDistingForTeam.length, (index) => false);
                    _FilterStateForPersonal.checkFilterColorForTeam();
                  });
                }),
              ],
            ),
          ),
          SizedBox(height: 16 * sizeUnit),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * sizeUnit),
            child: Wrap(
              runSpacing: 4 * sizeUnit,
              spacing: 4 * sizeUnit,
              children: distingNameList
                  .asMap()
                  .map((index, item) => MapEntry(
                      index,
                      GestureDetector(
                          onTap: () {
                            _FilterStateForPersonal.tempDistingForTeam[index] = !_FilterStateForPersonal.tempDistingForTeam[index];
                            _FilterStateForPersonal.checkFilterColorForTeam();
                            setState(() {});
                          },
                          child: SheepsFilterItem(context, item, _FilterStateForPersonal.tempDistingForTeam[index]))))
                  .values
                  .toList()
                  .cast<Widget>(),
            ),
          ),
          SizedBox(height: 20 * sizeUnit),
        ],
      ),
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

  Material buildFilterTopButtonList(FilterStateForPersonal _FilterStateForPersonal) {
    return Material(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20 * sizeUnit),
              border: Border.all(color: sheepsColorLightGrey),
            ),
            width: 320 * sizeUnit,
            height: 32 * sizeUnit,
            child: Row(
              children: [
                SizedBox(width: 4 * sizeUnit),
                Stack(
                  children: [
                    AnimatedContainer(
                      alignment: profileState.getState == ProfileState.STATE_PERSON ? _FilterStateForPersonal.tabAlignForPerson : _FilterStateForPersonal.tabAlignForTeam,
                      duration: Duration(milliseconds: duration),
                      curve: Curves.easeInOut,
                      color: Colors.transparent,
                      width: 312 * sizeUnit,
                      height: 32 * sizeUnit,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16 * sizeUnit),
                          color: profileState.getState == ProfileState.STATE_PERSON ? sheepsColorBlue : sheepsColorGreen,
                        ),
                        width: 84 * sizeUnit,
                        height: 24 * sizeUnit,
                      ),
                    ),
                    Container(
                      width: 312 * sizeUnit,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildAnimationButton(_FilterStateForPersonal, Alignment.centerLeft, '최근 접속 순'),
                          buildAnimationButton(_FilterStateForPersonal, Alignment.center, '보유 뱃지 순'),
                          buildAnimationButton(_FilterStateForPersonal, Alignment.centerRight, '신규 가입 순'),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 2 * sizeUnit),
              ],
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget buildAnimationButton(FilterStateForPersonal _FilterStateForPersonal, Alignment setAlign, String text) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        if (profileState.getState == ProfileState.STATE_PERSON) {
          _FilterStateForPersonal.tabAlignForPerson = setAlign;
        } else if (profileState.getState == ProfileState.STATE_TEAM) {
          _FilterStateForPersonal.tabAlignForTeam = setAlign;
        }
        setState(() {});
      },
      child: Container(
        width: 84 * sizeUnit,
        height: 24 * sizeUnit,
        alignment: Alignment.center,
        child: AnimatedDefaultTextStyle(
          duration: Duration(milliseconds: duration),
          curve: Curves.easeInCubic,
          style: SheepsTextStyle.b4().copyWith(
            fontWeight: profileState.getState == ProfileState.STATE_PERSON
                ? _FilterStateForPersonal.tabAlignForPerson == setAlign
                    ? FontWeight.w500
                    : FontWeight.normal
                : _FilterStateForPersonal.tabAlignForTeam == setAlign
                    ? FontWeight.w500
                    : FontWeight.normal,
            color: profileState.getState == ProfileState.STATE_PERSON
                ? _FilterStateForPersonal.tabAlignForPerson == setAlign
                    ? Colors.white
                    : sheepsColorDarkGrey
                : _FilterStateForPersonal.tabAlignForTeam == setAlign
                    ? Colors.white
                    : sheepsColorDarkGrey,
          ),
          child: Text(text),
        ),
      ),
    );
  }

  Widget profilePageTopBar(BuildContext context, ProfileState profileState, NavigationNum navigationNum) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: 44 * sizeUnit,
      child: Row(
        children: [
          SizedBox(width: 16 * sizeUnit),
          _FilterStateForPersonal.isSearch
              ? Expanded(
                  child: Container(
                    // width: 256 * sizeUnit,
                    height: 28 * sizeUnit,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16 * sizeUnit),
                      color: sheepsColorLightGrey,
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
                            controller: _controller,
                            focusNode: searchFocusNode,
                            onSubmitted: (val) async {
                              if (val.isEmpty || val.length < 2) {
                                showSheepsToast(context: context, text: '최소 두 글자 이상을 입력해 주세요.');
                                return;
                              }

                              _FilterStateForPersonal.resetFilterList();
                              _FilterStateForPersonal.resetTempList();
                              _FilterStateForPersonal.offFilterColor(); // filterColor 초기화

                              _FilterStateForPersonal.searchWords = val;

                              await _FilterStateForPersonal.searchEventForPersonal(val);
                              await _FilterStateForPersonal.searchEventForTeam(val);
                              setState(() {});
                            },
                            decoration: InputDecoration(
                                hintText: profileState.getState == ProfileState.STATE_PERSON ? "개인 프로필 검색" : "팀 프로필 검색",
                                border: InputBorder.none,
                                hintStyle: SheepsTextStyle.info1(),
                                isDense: true,
                                contentPadding: EdgeInsets.only(left: 8 * sizeUnit)),
                            style: SheepsTextStyle.b3(),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8 * sizeUnit),
                          child: IconButton(
                            onPressed: () {
                              _controller.clear();
                              setState(() {
                                GlobalProfile.personalFiltered = false;
                                GlobalProfile.teamFiltered = false;
                                _FilterStateForPersonal.isFilteredForPersonal = false;
                                _FilterStateForPersonal.isFilteredForTeam = false;
                                _FilterStateForPersonal.tabAlignForPerson = Alignment.centerLeft; // orderRule 초기화
                                _FilterStateForPersonal.tabAlignForTeam = Alignment.centerLeft; // orderRule 초기화
                                _FilterStateForPersonal.offFilterColor(); // filter Color 초기화
                                closeFilterEvent(); // 필터 초기화
                                _FilterStateForPersonal.isSearch = false;
                                _FilterStateForPersonal.searchWords = '';
                                _FilterStateForPersonal.searchIconColor = false; // 검색 아이콘 꺼주기
                              });
                            },
                            constraints: BoxConstraints(maxWidth: 16 * sizeUnit, maxHeight: 16 * sizeUnit),
                            padding: EdgeInsets.zero,
                            iconSize: 16 * sizeUnit,
                            color: sheepsColorDarkGrey,
                            icon: Icon(Icons.clear, color: sheepsColorDarkGrey),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Expanded(child: Text('프로필', style: SheepsTextStyle.h2())),
          // Spacer(),
          _FilterStateForPersonal.isSearch
              ? SizedBox.shrink()
              : InkWell(
                  onTap: () {
                    if (profileState.getState != ProfileState.STATE_EXPERT) {
                      setState(() {
                        filterActive = false;
                        _FilterStateForPersonal.isSearch = true;
                        searchFocusNode.requestFocus();
                      });
                    }
                  },
                  child: SvgPicture.asset(
                    svgGreyMagnifyingGlass,
                    color: _FilterStateForPersonal.searchIconColor
                        ? profileState.getState == ProfileState.STATE_PERSON
                            ? sheepsColorBlue
                            : profileState.getState == ProfileState.STATE_TEAM
                                ? sheepsColorGreen
                                : sheepsColorDarkGrey
                        : sheepsColorDarkGrey,
                    width: 28 * sizeUnit,
                    height: 28 * sizeUnit,
                  ),
                ),
          SizedBox(width: 12 * sizeUnit),
          InkWell(
            onTap: () {
              if (profileState.getState != ProfileState.STATE_EXPERT) {
                setState(() {
                  if (filterActive) {
                    if (profileState.getState == ProfileState.STATE_PERSON)
                      filterFuncForPersonal();
                    else if (profileState.getState == ProfileState.STATE_TEAM) filterFuncForTeam();
                  } else {
                    filterActive = true;
                  }
                });
              }
            },
            child: Obx(
              () => SvgPicture.asset(
                // 필터 아이콘
                svgBlackFilterIcon,
                color: profileState.getState == ProfileState.STATE_PERSON
                    ? _FilterStateForPersonal.filterColorForPersonal.value
                        ? sheepsColorBlue
                        : sheepsColorDarkGrey
                    : profileState.getState == ProfileState.STATE_TEAM
                        ? _FilterStateForPersonal.filterColorForTeam.value
                            ? sheepsColorGreen
                            : sheepsColorDarkGrey
                        : _FilterStateForPersonal.filterColorForExpert.value
                            ? sheepsColorGreen
                            : sheepsColorDarkGrey,
                width: 28 * sizeUnit,
                height: 28 * sizeUnit,
              ),
            ),
          ),
          SizedBox(
            width: 12 * sizeUnit,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .push(CupertinoPageRoute(
                builder: (context) => MyPage(),
              ))
                  .then((value) {
                setState(() {});
              });
            },
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

  Widget teamProfilePage(BuildContext context) {
    List resultList = [];

    // 검색이나 필터가 켜져있을 때
    if (GlobalProfile.teamFiltered || _FilterStateForPersonal.isFilteredForTeam)
      resultList = GlobalProfile.teamProfileFiltered;
    else
      resultList = GlobalProfile.teamProfile;

    if (resultList.length == 0)
      return GestureDetector(
        onTap: () {
          // 필터 켜져있으면 꺼주기
          if (filterActive && profileState.getState == ProfileState.STATE_TEAM) {
            filterFuncForTeam();
            setState(() {});
          }
        },
        child: ListView(
          children: [
            SizedBox(height: Get.height * 0.2),
            noSearchResultsPage(null),
          ],
        ),
      );
    return GestureDetector(
      onTap: () {
        // 필터 켜져있으면 꺼주기
        if (filterActive && profileState.getState == ProfileState.STATE_TEAM) {
          filterFuncForTeam();
          setState(() {});
        }
      },
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit),
        child: GridView.count(
            controller: teamScrollController,
            physics: AlwaysScrollableScrollPhysics(),
            mainAxisSpacing: 8 * sizeUnit,
            crossAxisSpacing: 8 * sizeUnit,
            crossAxisCount: 2,
            childAspectRatio: 160 / 284,
            //각 그리드뷰 비율 조정
            children: List.generate(resultList.length, (index) {
              Team team = resultList[index];

              if (index == resultList.length) return CupertinoActivityIndicator();
              return SheepsTeamProfileCard(
                context,
                team,
                index,
                onTap: () async {
                  // 필터 열려있을 때
                  if (filterActive && profileState.getState == ProfileState.STATE_TEAM) {
                    filterFuncForTeam();
                    return setState(() {});
                  }

                  var getData = await ApiProvider().post('/Team/Profile/SelectID', jsonEncode({"id": team.id, "updatedAt": team.updatedAt}));

                  Team resTeam = team;
                  if (getData != null) {
                    Team resTeam = Team.fromJson(getData);
                    await GlobalProfile.getFutureUserByUserID(resTeam.leaderID);
                    GlobalProfile.teamProfile[index] = resTeam;
                  }

                  Get.to(() => DetailTeamProfile(index: index, team: resTeam))?.then((value) => setState(() {}));
                },
              );
            })),
      ),
    );
  }

  Widget personalProfilePage(BuildContext context) {
    List resultList = [];

    // 검색이나 필터가 켜져있을 때
    if (GlobalProfile.personalFiltered || _FilterStateForPersonal.isFilteredForPersonal)
      resultList = GlobalProfile.personalProfileFiltered;
    else
      resultList = GlobalProfile.personalProfile;

    if (resultList.length == 0)
      return GestureDetector(
        onTap: () {
          // 필터 켜져있으면 꺼주기
          if (filterActive && profileState.getState == ProfileState.STATE_PERSON) {
            filterFuncForPersonal();
            setState(() {});
          }
        },
        child: ListView(
          children: [
            SizedBox(height: Get.height * 0.2),
            noSearchResultsPage(null),
          ],
        ),
      );
    return GestureDetector(
      onTap: () {
        // 필터 켜져있으면 꺼주기
        if (filterActive && profileState.getState == ProfileState.STATE_PERSON) {
          filterFuncForPersonal();
          setState(() {});
        }
      },
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit),
        child: GridView.count(
            primary: false,
            controller: personalScrollController,
            physics: AlwaysScrollableScrollPhysics(),
            mainAxisSpacing: 8 * sizeUnit,
            crossAxisSpacing: 8 * sizeUnit,
            crossAxisCount: 2,
            childAspectRatio: 160 / 284,
            //각 그리드뷰 비율 조정
            children: List.generate(resultList.length, (index) {
              UserData person = resultList[index];

              if (index == resultList.length) return CupertinoActivityIndicator();
              return SheepsPersonalProfileCard(context, person, index, onTap: () async {
                // 필터 열려있을 때
                if (filterActive && profileState.getState == ProfileState.STATE_PERSON) {
                  filterFuncForPersonal();
                  return setState(() {});
                }

                var getData = await ApiProvider().post('/Personal/Select/ModifyUser', jsonEncode({"userID": person.userID, "updatedAt": person.updatedAt}));

                UserData user = person;
                if (getData != null) {
                  user = UserData.fromJson(getData);
                  GlobalProfile.personalProfile[index] = user; //개인 프로필 바뀐 데이터로 전역 데이터 세팅
                }

                if (person.userID == GlobalProfile.loggedInUser!.userID)
                  Get.to(() => DetailProfile(index: 0, user: GlobalProfile.loggedInUser!, profileStatus: PROFILE_STATUS.MyProfile));
                else
                  Get.to(() => DetailProfile(index: 0, user: user, profileStatus: PROFILE_STATUS.OtherProfile))?.then((value) => setState(() {}));
              });
            })),
      ),
    );
  }

  Widget myCustomRefreshIndicator({required Widget child}) {
    return CustomRefreshIndicator(
      onRefresh: () async {
        //개인프로필상태
        if (profileState.getState == ProfileState.STATE_PERSON) {
          // 필터 켜져 있을 때
          if (_FilterStateForPersonal.isFilteredForPersonal) {
            await _FilterStateForPersonal.filterEventForPersonal();
          } else if (GlobalProfile.personalFiltered) {
            await _FilterStateForPersonal.searchEventForPersonal(_controller.text); // 검색 켜져 있을 때
          } else {
            // 리쿠르트에서 프로필 정보를 공유하기 때문에 clear 안하고 중복 체크 함
            var tmp = await ApiProvider().post('/Personal/Select/UserList', jsonEncode({"userID": GlobalProfile.loggedInUser!.userID}));
            if (tmp != null) {
              for (int i = 0; i < tmp.length; i++) {
                UserData _user = UserData.fromJson(tmp[i]);
                bool contain = false;

                // 이미 포함되어 있는지 체크
                for (int j = 0; j < GlobalProfile.personalProfile.length; j++) {
                  if (GlobalProfile.personalProfile[j].userID == _user.userID) {
                    contain = true;
                    GlobalProfile.personalProfile[j] = _user; // 포함되어 있으면 바꿔치기
                    break;
                  }
                }

                if (!contain) GlobalProfile.personalProfile.add(_user); // 포함되어 있지 않다면 집어넣기
              }

              GlobalProfile.personalProfile.sort((a, b) => b.updatedAt.compareTo(a.updatedAt)); // 최근 접속순으로 정렬
            }
          }
        } else {
          // 필터 켜져 있을 때
          if (_FilterStateForPersonal.isFilteredForTeam) {
            await _FilterStateForPersonal.filterEventForTeam();
          } else if (GlobalProfile.teamFiltered) {
            await _FilterStateForPersonal.searchEventForTeam(_controller.text); // 검색 켜져 있을 때
          } else {
            // 리쿠르트에서 프로필 정보를 공유하기 때문에 clear 안하고 중복 체크 함
            var tmp = await ApiProvider().get('/Team/Profile/Select');
            if (tmp != null) {
              for (int i = 0; i < tmp.length; i++) {
                Team _team = Team.fromJson(tmp[i]);
                bool contain = false;

                // 이미 포함되어 있는지 체크
                for (int j = 0; j < GlobalProfile.teamProfile.length; j++) {
                  if (GlobalProfile.teamProfile[j].id == _team.id) {
                    contain = true;
                    GlobalProfile.teamProfile[j] = _team; // 포함되어 있다면 바꿔치기
                    break;
                  }
                }

                if (!contain) GlobalProfile.teamProfile.add(_team); // 포함되어 있지 않다면 집어넣기

                GlobalProfile.teamProfile.sort((a, b) => b.updatedAt.compareTo(a.updatedAt)); // 최근 접속순으로 정렬
              }
            }
          }
        }
        //데이터 세팅 초기화
        setState(() {});
        return Future.delayed(const Duration(milliseconds: 500));
      },
      builder: (
        BuildContext context,
        Widget child,
        IndicatorController controller,
      ) {
        return AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, _) {
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                // !controller.isDragging && !controller.isHiding && !controller.isIdle
                !controller.isDragging && !controller.isIdle
                    ? Positioned(
                        top: 10 * sizeUnit * controller.value,
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(profileState.getState == ProfileState.STATE_PERSON ? sheepsColorBlue : sheepsColorGreen),
                          ),
                        ),
                      )
                    : Container(),
                Transform.translate(
                  offset: Offset(0, 55 * sizeUnit * controller.value),
                  child: child,
                ),
              ],
            );
          },
        );
      },
      child: child,
    );
  }

  void closeFilterEvent() {
    filterActive = false;

    if (profileState.getState == ProfileState.STATE_PERSON) {
      // orderRule 초기화
      switch (_FilterStateForPersonal.orderRuleForPersonal) {
        case 0:
          _FilterStateForPersonal.tabAlignForPerson = Alignment.centerLeft;
          break;
        case 1:
          _FilterStateForPersonal.tabAlignForPerson = Alignment.center;
          break;
        case 2:
          _FilterStateForPersonal.tabAlignForPerson = Alignment.centerRight;
          break;
      }

      if (!_FilterStateForPersonal.isFilteredForPersonal)
        _FilterStateForPersonal.resetTempListForPersonal(); // 임시 리스트 리셋
      else
        _FilterStateForPersonal.syncTempListForPersonal(); // 임시 리스트에 정식 리스트 덮어쓰기
    } else if (profileState.getState == ProfileState.STATE_TEAM) {
      // orderRule 초기화
      switch (_FilterStateForPersonal.orderRuleForTeam) {
        case 0:
          _FilterStateForPersonal.tabAlignForTeam = Alignment.centerLeft;
          break;
        case 1:
          _FilterStateForPersonal.tabAlignForTeam = Alignment.center;
          break;
        case 2:
          _FilterStateForPersonal.tabAlignForTeam = Alignment.centerRight;
          break;
      }

      if (!_FilterStateForPersonal.isFilteredForTeam)
        _FilterStateForPersonal.resetTempListForTeam(); // 임시 리스트 리셋
      else
        _FilterStateForPersonal.syncTempListForTeam(); // 임시 리스트에 정식 리스트 덮어쓰기
    }
  }
}
