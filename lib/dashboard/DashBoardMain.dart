import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:badges/badges.dart' as badge;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sheeps_app/Community/models/CommunityDetailController.dart';
import 'package:sheeps_app/notification/notificationPage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/Community/models/CommunityController.dart';
import 'package:sheeps_app/Community/CommunityMainDetail.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/LoadingUI.dart';
import 'package:sheeps_app/config/NavigationNum.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/dashboard/MyPage.dart';
import 'package:sheeps_app/network/FirebaseNotification.dart';

import 'package:sheeps_app/notification/models/NotificationModel.dart';
import 'package:sheeps_app/profile/models/ProfileState.dart';
import 'package:sheeps_app/Recruit/Controller/FilterController.dart';
import 'package:sheeps_app/Recruit/Controller/RecruitController.dart';
import 'package:sheeps_app/Recruit/Models/PersonalSeekTeams.dart';
import 'package:sheeps_app/Recruit/Models/TeamMemberRecruit.dart';
import 'package:sheeps_app/Recruit/RecruitDetailPage.dart';
import 'package:sheeps_app/Setting/model/Banner.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';

const int MAX_COMMUNITY_VIEW = 3; // 커뮤니티 보여주는 최대 갯수
const int MAX_RECRUIT_VIEW = 2; // 리쿠르트 보여주는 최대 갯수

class DashBoardMain extends StatefulWidget {
  @override
  _DashBoardMainState createState() => _DashBoardMainState();
}

class _DashBoardMainState extends State<DashBoardMain> with SingleTickerProviderStateMixin {
  final CommunityController communityController = Get.put(CommunityController());
  final RecruitController recruitController = Get.put(RecruitController());
  final FilterController recruitFilterController = Get.put(FilterController());
  NavigationNum navigationNum = Get.put(NavigationNum());

  late ScrollController _scrollController;

  PageController _pageController = PageController(
    initialPage: globalClientBannerList.length * 100,
    viewportFraction: 0.9,
  );
  late Timer timer;

  bool showNotificationBadge = false;
  late AnimationController extendedController;

  List<bool> popularPersonalVisibleList = [];

  bool isCanTapLike = true;
  int tapLikeDelayMilliseconds = 500;

  late ProfileState profileState;

  // 커뮤니티 리스트 카운트 정해주기
  int checkListLength({required int listLength, required int maxLength}) {
    int result = maxLength;

    if (listLength < result) result = listLength;
    return result;
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });

    _scrollController = ScrollController(initialScrollOffset: 0.0);

    setState(() {
      Future.microtask(() async {
        await permissionRequest();
        AllNotification = await getNotiByStatus();
      });
    });

    extendedController = AnimationController(vsync: this, duration: const Duration(seconds: 1), lowerBound: 0.0, upperBound: 1.0);

    profileState = Get.put(ProfileState());

    if (isCanDynamicLink) {
      initDynamicLinks();
      isCanDynamicLink = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // new FirebaseNotifications().setUpFirebase(context);
    Get.lazyPut<CommunityDetailController>(() => CommunityDetailController());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    extendedController.dispose();
    timer.cancel();
    super.dispose();
  }

  final String svgBellButton = 'assets/images/DashBoard/BellButton.svg';

  @override
  Widget build(BuildContext context) {
    var tmp = false;
    if (GlobalProfile.popularCommunityList != null) {
      for (int i = 0; i < GlobalProfile.popularCommunityList.length; i++) {
        popularPersonalVisibleList.add(tmp);
      }
    }

    UserData user = GlobalProfile.loggedInUser ?? UserData();

    showNotificationBadge = isHaveReadNoti();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Scaffold(
            body: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 44 * sizeUnit,
                    child: Row(
                      children: [
                        Obx(() {
                          if (navigationNum.getNum() == navigationNum.getPastNum()) {
                            if (_scrollController.hasClients) {
                              Future.microtask(() => _scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut));
                              navigationNum.setNormalPastNum(-1);
                            }
                          }
                          return SizedBox(height: navigationNum.forSetState.value * 0, width: 16 * sizeUnit);
                        }),
                        SvgPicture.asset(
                          svgSheepsGreenWriteLogo,
                          width: 75 * sizeUnit,
                          height: 14 * sizeUnit,
                        ),
                        Spacer(),
                        InkWell(
                          onTap: () async {
                            for (int i = 0; i < notiList.length; ++i) {
                              if (notiList[i].isLoad == true) continue;
                              DialogBuilder(context).showLoadingIndicator();

                              NotificationModel notificationModel = notiList[i];

                              await loadNotificationFutureData(notificationModel);

                              notificationModel.isLoad = true;

                              DialogBuilder(context).hideOpenDialog();
                            }

                            Get.to(() => TotalNotificationPage());
                          },
                          child: badge.Badge(
                            showBadge: showNotificationBadge,
                            position: badge.BadgePosition.topEnd(top: -8 * sizeUnit, end: 2 * sizeUnit),
                            // padding: EdgeInsets.all(3 * sizeUnit),
                            // elevation: 0,
                            // badgeColor: sheepsColorRed,
                            // toAnimate: false,
                            badgeContent: Text(''),
                            child: SvgPicture.asset(
                              svgBellButton,
                              width: 28 * sizeUnit,
                              height: 28 * sizeUnit,
                            ),
                          ),
                        ),
                        SizedBox(width: 8 * sizeUnit),
                        InkWell(
                          onTap: () {
                            Get.to(() => MyPage())?.then((value) {
                              setState(() {});
                            });
                          },
                          child: SvgPicture.asset(
                            svgMyPageButton,
                            width: 28 * sizeUnit,
                            height: 28 * sizeUnit,
                          ),
                        ),
                        SizedBox(
                          width: 12 * sizeUnit,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        SizedBox(height: 12 * sizeUnit),
                        Padding(
                          padding: EdgeInsets.only(left: 16 * sizeUnit),
                          child: Text(
                            '반가워요, ${user.name ?? ''} 님!',
                            style: SheepsTextStyle.h2(),
                          ),
                        ),
                        SizedBox(height: 12 * sizeUnit),
                        // Container(
                        //   width: 360 * sizeUnit,
                        //   height: 116 * sizeUnit,
                        //   color: sheepsColorLightGrey,
                        //   child: Padding(
                        //     padding: EdgeInsets.symmetric(vertical: 8 * sizeUnit),
                        //     child: PageView.builder(
                        //       pageSnapping: true,
                        //       controller: _pageController,
                        //       itemBuilder: (context, index) {
                        //         return GestureDetector(
                        //           onTap: () async {
                        //             switch(globalClientBannerList[index % globalClientBannerList.length].type){
                        //               case BANNER_TYPE_EXTERNAL:
                        //                 launch(globalClientBannerList[index % globalClientBannerList.length].webURL);
                        //                 break;
                        //               case BANNER_TYPE_INTERNAL:
                        //                 bannerInternalFunction(globalClientBannerList[index % globalClientBannerList.length].webURL);
                        //                 break;
                        //               case BANNER_TYPE_NOACTION:
                        //                 //행동없음
                        //                 break;
                        //             }
                        //           },
                        //           child: Padding(
                        //             padding: EdgeInsets.only(right: 8 * sizeUnit),
                        //             child: Container(
                        //               width: 310 * sizeUnit,
                        //               height: 100 * sizeUnit,
                        //               decoration: BoxDecoration(
                        //                 color: Colors.transparent,
                        //                 borderRadius: BorderRadius.circular(24 * sizeUnit),
                        //               ),
                        //               child: Image.asset(
                        //                 globalClientBannerList[index % globalClientBannerList.length].imgURL,
                        //               ),
                        //             ),
                        //           ),
                        //         );
                        //       },
                        //     ),
                        //   ),
                        // ),
                        Padding(
                          padding: EdgeInsets.only(left: 16 * sizeUnit, top: 12 * sizeUnit, right: 16 * sizeUnit),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '구직중인 프로필',
                                style: SheepsTextStyle.h4(),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () {
                                  recruitController.isRecruit = false;
                                  recruitFilterController.setSpecificFilterForSeek(); // 필터 걸어서 보내주기
                                  navigationNum.setNum(TEAM_RECRUIT_PAGE);
                                },
                                child: Container(
                                  height: 12 * sizeUnit,
                                  color: Colors.white,
                                  child: Text(
                                    '모두 보기',
                                    style: SheepsTextStyle.s3().copyWith(color: sheepsColorBlue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4 * sizeUnit),
                        if (GlobalProfile.loggedInUser != null) ...[
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: checkListLength(listLength: recruitFilterController.dashBoardSeekList.length, maxLength: MAX_RECRUIT_VIEW),
                            itemBuilder: (context, index) {
                              PersonalSeekTeam personalSeek = recruitFilterController.dashBoardSeekList[index];

                              return sheepsRecruitPostCard(
                                isRecruit: false,
                                dataSetFunc: () => recruitController.postCardDataSet(data: personalSeek, isRecruit: false),
                                press: () => Get.to(() => RecruitDetailPage(isRecruit: false, data: personalSeek)),
                                controller: recruitController,
                              );
                            },
                          ),
                        ],
                        if (checkListLength(listLength: recruitFilterController.dashBoardSeekList.length, maxLength: MAX_RECRUIT_VIEW) == 0)
                          Container(width: 360 * sizeUnit, height: 1 * sizeUnit, color: sheepsColorLightGrey),
                        Padding(
                          padding: EdgeInsets.only(left: 16 * sizeUnit, right: 16 * sizeUnit, top: 12 * sizeUnit),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                user.name != null ? user.name + '님을 위한 추천 리쿠르트' : '',
                                style: SheepsTextStyle.h4(),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () {
                                  recruitController.isRecruit = true;
                                  recruitFilterController.setSpecificFilterForRecruit(); // 필터 걸어서 보내주기
                                  navigationNum.setNum(TEAM_RECRUIT_PAGE);
                                },
                                child: Container(
                                  height: 12 * sizeUnit,
                                  child: Text(
                                    '모두 보기',
                                    style: SheepsTextStyle.s3().copyWith(color: sheepsColorGreen),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4 * sizeUnit),
                        if (GlobalProfile.loggedInUser != null) ...[
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: checkListLength(listLength: recruitFilterController.dashBoardRecruitList.length, maxLength: MAX_RECRUIT_VIEW),
                            itemBuilder: (context, index) {
                              TeamMemberRecruit recruit = recruitFilterController.dashBoardRecruitList[index];

                              return sheepsRecruitPostCard(
                                isRecruit: true,
                                dataSetFunc: () => recruitController.postCardDataSet(data: recruit, isRecruit: true),
                                press: () => Get.to(() => RecruitDetailPage(isRecruit: true, data: recruit)),
                                controller: recruitController,
                              );
                            },
                          ),
                        ],
                        if (checkListLength(listLength: recruitFilterController.dashBoardRecruitList.length, maxLength: MAX_RECRUIT_VIEW) == 0)
                          Container(width: 360 * sizeUnit, height: 1 * sizeUnit, color: sheepsColorLightGrey),
                        Padding(
                          padding: EdgeInsets.only(left: 16 * sizeUnit, right: 16 * sizeUnit, top: 12 * sizeUnit, bottom: 4 * sizeUnit),
                          child: Row(
                            children: [
                              Text(
                                '커뮤니티 HOT 게시글',
                                style: SheepsTextStyle.h4(),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () {
                                  communityController.selectedCategory.value = '전체';
                                  navigationNum.setNum(COMMUNITY_MAIN_PAGE);
                                },
                                child: Container(
                                  height: 12 * sizeUnit,
                                  child: Text(
                                    '모두 보기',
                                    style: SheepsTextStyle.s3().copyWith(color: sheepsColorBlack),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (GlobalProfile.loggedInUser != null) ...[
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: checkListLength(listLength: GlobalProfile.hotCommunityList.length, maxLength: MAX_COMMUNITY_VIEW),
                            itemBuilder: (context, index) {
                              Community community = GlobalProfile.hotCommunityList[index];

                              return communityPostCard(
                                community: community,
                                likeCheckFunc: communityController.likeCheckFunc(community),
                                press: () async {
                                  DialogBuilder(context).showLoadingIndicator();
                                  var tmp = await communityController.getReply(context, community);
                                  DialogBuilder(context).hideOpenDialog();

                                  if (tmp != null) Get.to(() => CommunityMainDetail(community))?.then((value) => setState(() {}));
                                },
                                typeCheck: communityController.typeCheck(community),
                              );
                            },
                          ),
                        ],
                        if (checkListLength(listLength: GlobalProfile.hotCommunityList.length, maxLength: MAX_COMMUNITY_VIEW) == 0)
                          Container(width: 360 * sizeUnit, height: 1 * sizeUnit, color: sheepsColorLightGrey),
                        Padding(
                          padding: EdgeInsets.only(left: 16 * sizeUnit, right: 16 * sizeUnit, top: 12 * sizeUnit, bottom: 4 * sizeUnit),
                          child: Row(
                            children: [
                              Text(
                                '커뮤니티 인기 게시글',
                                style: SheepsTextStyle.h4(),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () {
                                  communityController.selectedCategory.value = '인기';
                                  navigationNum.setNum(COMMUNITY_MAIN_PAGE);
                                },
                                child: Container(
                                  height: 12 * sizeUnit,
                                  child: Text(
                                    '모두 보기',
                                    style: SheepsTextStyle.s3().copyWith(color: sheepsColorBlack),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (GlobalProfile.loggedInUser != null) ...[
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: checkListLength(listLength: GlobalProfile.popularCommunityList.length, maxLength: MAX_COMMUNITY_VIEW),
                            itemBuilder: (context, index) {
                              Community community = GlobalProfile.popularCommunityList[index];

                              return communityPostCard(
                                community: community,
                                likeCheckFunc: communityController.likeCheckFunc(community),
                                press: () async {
                                  DialogBuilder(context).showLoadingIndicator();
                                  var tmp = await communityController.getReply(context, community);
                                  DialogBuilder(context).hideOpenDialog();

                                  if (tmp != null) Get.to(() => CommunityMainDetail(community))?.then((value) => setState(() {}));
                                },
                                typeCheck: communityController.typeCheck(community),
                              );
                            },
                          ),
                        ],
                        if (checkListLength(listLength: GlobalProfile.hotCommunityList.length, maxLength: MAX_COMMUNITY_VIEW) == 0)
                          Container(width: 360 * sizeUnit, height: 1 * sizeUnit, color: sheepsColorLightGrey),
                        SizedBox(height: 20 * sizeUnit),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
