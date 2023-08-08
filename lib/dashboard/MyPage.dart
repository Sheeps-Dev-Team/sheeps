import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';


import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sheeps_app/Community/CommunityWriteNoticePostPage.dart';

import 'package:sheeps_app/Community/PostedPage.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/Coupon/CouponPage.dart';
import 'package:sheeps_app/chat/models/ChatDatabase.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/LoadingUI.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/notification/models/NotiDatabase.dart';
import 'package:sheeps_app/profile/DetailProfile.dart';
import 'package:sheeps_app/profile/MyTeamProfile.dart';
import 'package:sheeps_app/profile/ProfileLikes.dart';
import 'package:sheeps_app/profile/models/ModelLikes.dart';
import 'package:sheeps_app/Recruit/Models/PersonalSeekTeams.dart';
import 'package:sheeps_app/Recruit/Models/TeamMemberRecruit.dart';
import 'package:sheeps_app/Recruit/ViewMyAppliedPage.dart';
import 'package:sheeps_app/Recruit/SpecificUserRecruitPage.dart';
import 'package:sheeps_app/Recruit/SavedRecruitPage.dart';
import 'package:sheeps_app/Setting/AppSetting.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with SingleTickerProviderStateMixin {
  late AnimationController extendedController;

  @override
  void initState() {
    super.initState();

    extendedController = AnimationController(vsync: this, duration: const Duration(seconds: 1), lowerBound: 0.0, upperBound: 1.0);
  }

  @override
  void dispose() {
    extendedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future.microtask(() async {
      AllNotification = await getNotiByStatus();
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: null,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Scaffold(
                backgroundColor: Color(0xFFF8F8F8),
                appBar: SheepsAppBar(context, '${GlobalProfile.loggedInUser!.name}의 쉽스', actions: [
                  GestureDetector(
                    onTap: () async {
                      PackageInfo packageInfo = await PackageInfo.fromPlatform();
                      Get.to(() => AppSetting(packageInfo: packageInfo));
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 13*sizeUnit),
                      child: SvgPicture.asset(
                        svgSetting,
                        color: sheepsColorDarkGrey,
                        width: 28 * sizeUnit,
                        height: 28 * sizeUnit,
                      ),
                    ),
                  ),
                ]),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: 360 * sizeUnit,
                        height: 30 * sizeUnit,
                        color: Colors.transparent,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                          child: Row(
                            children: [
                              Text(
                                '프로필',
                                style: SheepsTextStyle.h4(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SettingColumn(
                        str: "내 프로필",
                        myFunc: () {
                          Get.to(() => DetailProfile(index: 0, user: GlobalProfile.loggedInUser!, profileStatus: PROFILE_STATUS.MyProfile));
                        },
                      ),
                      SettingColumn(
                        str: "팀・스타트업 프로필",
                        myFunc: () {
                          Get.to(() => MyTeamProfile());
                        },
                      ),
                      SettingColumn(
                        str: "저장한 프로필",
                        myFunc: () async{
                          for (int i = 0; i < globalPersonalLikeList.length; ++i) {
                            await GlobalProfile.getFutureUserByUserID(globalPersonalLikeList[i].TargetID);
                          }
                          for (int i = 0; i < globalTeamLikeList.length; ++i) {
                            await GlobalProfile.getFutureTeamByID(globalTeamLikeList[i].TargetID);
                          }
                          Get.to(() => ProfileLikesPage());
                        },
                      ),
                      Container(
                        width: 360 * sizeUnit,
                        height: 30 * sizeUnit,
                        color: Colors.transparent,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                          child: Row(
                            children: [
                              Text(
                                '리쿠르트',
                                style: SheepsTextStyle.h4(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SettingColumn(
                        str: "나의 모집 공고",
                        myFunc: () async {
                          List<TeamMemberRecruit> recruitList = [];

                          DialogBuilder(context).showLoadingIndicator();

                          var res = await ApiProvider().post(
                              '/Matching/Select/TeamMemberRecruitByUserID',
                              jsonEncode({
                                'userID': GlobalProfile.loggedInUser!.userID,
                              }));

                          if (res != null) {
                            for (int i = 0; i < res.length; i++) {
                              TeamMemberRecruit tmpRecruit = TeamMemberRecruit.fromJson(res[i]);
                              recruitList.add(tmpRecruit);
                              await GlobalProfile.getFutureTeamByID(tmpRecruit.teamId);
                            }
                          }

                          DialogBuilder(context).hideOpenDialog();

                          Get.to(() => SpecificUserRecruitPage(isRecruit: true, myRecruitList: recruitList, appBarTitle: '나의 모집 공고'));
                        },
                      ),
                      SettingColumn(
                        str: "나의 구직 공고",
                        myFunc: () async {
                          List<PersonalSeekTeam> seekList = [];

                          DialogBuilder(context).showLoadingIndicator();

                          var res = await ApiProvider().post(
                              '/Matching/Select/PersonalSeekTeamByUserID',
                              jsonEncode({
                                'userID': GlobalProfile.loggedInUser!.userID,
                              }));

                          if (res != null) {
                            for (int i = 0; i < res.length; i++) {
                              PersonalSeekTeam tmpSeek = PersonalSeekTeam.fromJson(res[i]);
                              seekList.add(tmpSeek);
                              await GlobalProfile.getFutureUserByUserID(tmpSeek.userId);
                            }
                          }

                          DialogBuilder(context).hideOpenDialog();

                          Get.to(() => SpecificUserRecruitPage(isRecruit: false, mySeekList: seekList, appBarTitle: '나의 구직 공고'));
                        },
                      ),
                      SettingColumn(
                        str: "내가 지원한 팀",
                        myFunc: () async {
                          List<Team> teamList = [];

                          DialogBuilder(context).showLoadingIndicator();

                          var res = await ApiProvider().post(
                              '/Matching/Select/Volunteer/TeamList',
                              jsonEncode({
                                'userID': GlobalProfile.loggedInUser!.userID,
                              }));

                          if (res != null) {
                            for (int i = 0; i < res.length; i++) {
                              Team tmpTeam = Team.fromJson(res[i]);
                              teamList.add(tmpTeam);
                              await GlobalProfile.getFutureTeamByID(tmpTeam.id);
                            }
                          }

                          DialogBuilder(context).hideOpenDialog();

                          Get.to(() => ViewMyAppliedPage(teamList: teamList));
                        },
                      ),
                      SettingColumn(
                        str: "내가 제안한 구직자",
                        myFunc: () async {
                          List<UserData> userList = [];

                          DialogBuilder(context).showLoadingIndicator();

                          var res = await ApiProvider().post(
                              '/Matching/Select/Suggest/PersonalList',
                              jsonEncode({
                                'userID': GlobalProfile.loggedInUser!.userID,
                              }));

                          if (res != null) {
                            for (int i = 0; i < res.length; i++) {
                              UserData tmpUser = UserData.fromJson(res[i][0]);
                              userList.add(tmpUser);
                              await GlobalProfile.getFutureUserByUserID(tmpUser.userID);
                            }
                          }

                          DialogBuilder(context).hideOpenDialog();

                          Get.to(() => ViewMyAppliedPage(userList: userList, isRecruit: false));
                        },
                      ),
                      SettingColumn(
                        str: "저장한 공고",
                        myFunc: () async {
                          List<TeamMemberRecruit> recruitList = [];

                          DialogBuilder(context).showLoadingIndicator();

                          var resRecruit = await ApiProvider().post(
                              '/Matching/Select/Save/TeamMemberRecruit',
                              jsonEncode({
                                'userID': GlobalProfile.loggedInUser!.userID,
                              }));

                          if (resRecruit != null) {
                            for (int i = 0; i < resRecruit.length; i++) {
                              TeamMemberRecruit tmpRecruit = TeamMemberRecruit.fromJson(resRecruit[i]);
                              recruitList.add(tmpRecruit);
                              await GlobalProfile.getFutureTeamByID(tmpRecruit.teamId);
                            }
                          }

                          List<PersonalSeekTeam> seekList = [];

                          var resSeek = await ApiProvider().post(
                              '/Matching/Select/Save/PersonalSeekTeam',
                              jsonEncode({
                                'userID': GlobalProfile.loggedInUser!.userID,
                              }));

                          if (resSeek != null) {
                            for (int i = 0; i < resSeek.length; i++) {
                              PersonalSeekTeam tmpSeek = PersonalSeekTeam.fromJson(resSeek[i]);
                              seekList.add(tmpSeek);
                              await GlobalProfile.getFutureUserByUserID(tmpSeek.userId);
                            }
                          }

                          DialogBuilder(context).hideOpenDialog();

                          Get.to(() => SavedRecruitPage(recruitList: recruitList, seekList: seekList));
                        },
                      ),
                      Container(
                        width: 360 * sizeUnit,
                        height: 32 * sizeUnit,
                        color: Colors.transparent,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                          child: Row(
                            children: [
                              Text(
                                '커뮤니티',
                                style: SheepsTextStyle.h4(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SettingColumn(
                        str: "내가 쓴 글",
                        myFunc: () async {
                          GlobalProfile.myCommunityList.clear();

                          var tmp = [];

                          DialogBuilder(context).showLoadingIndicator();

                          tmp = await ApiProvider().post(
                              '/CommunityPost/SelectUser',
                              jsonEncode({
                                "userID": GlobalProfile.loggedInUser!.userID,
                              }));
                          if (tmp != null) {
                            for (int i = 0; i < tmp.length; i++) {
                              Community community = Community.fromJson(tmp[i]);
                              GlobalProfile.myCommunityList.add(community);
                            }
                          }

                          DialogBuilder(context).hideOpenDialog();

                          Get.to(() => PostedPage(a_communityList: GlobalProfile.myCommunityList, a_title: '내가 쓴 글'))?.then((value) => GlobalProfile.myCommunityList.clear());
                        },
                      ),
                      SettingColumn(
                        str: "댓글 단 글",
                        myFunc: () async {
                          GlobalProfile.myCommunityList.clear();

                          var tmp = [];

                          DialogBuilder(context).showLoadingIndicator();

                          tmp = await ApiProvider().post(
                              '/CommunityPost/Reply/SelectUser',
                              jsonEncode({
                                "userID": GlobalProfile.loggedInUser!.userID,
                              }));
                          if (tmp != null) {
                            for (int i = 0; i < tmp.length; i++) {
                              Community community = Community.fromJson(tmp[i]);
                              GlobalProfile.myCommunityList.add(community);
                            }
                          }

                          DialogBuilder(context).hideOpenDialog();

                          Get.to(() => PostedPage(a_communityList: GlobalProfile.myCommunityList, a_title: '댓글 단 글'))?.then((value) => GlobalProfile.myCommunityList.clear());
                        },
                      ),
                      SettingColumn(
                        str: "좋아요 한 글",
                        myFunc: () async {
                          GlobalProfile.myCommunityList.clear();

                          var tmp = [];

                          DialogBuilder(context).showLoadingIndicator();

                          tmp = await ApiProvider().post(
                              '/CommunityPost/SelectUserLIke',
                              jsonEncode({
                                "userID": GlobalProfile.loggedInUser!.userID,
                              }));
                          if (tmp != null) {
                            for (int i = 0; i < tmp.length; i++) {
                              Community community = Community.fromJson(tmp[i]);
                              GlobalProfile.myCommunityList.add(community);
                            }
                          }

                          DialogBuilder(context).hideOpenDialog();

                          Get.to(() => PostedPage(a_communityList: GlobalProfile.myCommunityList, a_title: '좋아요 한 글'))?.then((value) => GlobalProfile.myCommunityList.clear());
                        },
                      ),
                      if(GlobalProfile.loggedInUser!.userID == 1)...[
                        SettingColumn(
                          str: "공지글 쓰기",
                          myFunc: () => Get.to(() => CommunityWriteNoticePostPage()),
                        ),
                      ],
                      Container(
                        width: 360 * sizeUnit,
                        height: 32 * sizeUnit,
                        color: Colors.transparent,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                          child: Row(
                            children: [
                              Text(
                                '이벤트',
                                style: SheepsTextStyle.h4(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SettingColumn(
                        str: "쿠폰함",
                        myFunc: () => Get.to(() => CouponPage()),
                      ),
                      SizedBox(height: 40 * sizeUnit),
                      if(!kReleaseMode) ... [
                        Container(
                          width: 360 * sizeUnit,
                          height: 32 * sizeUnit,
                          color: Colors.transparent,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                            child: Row(
                              children: [
                                Text(
                                  '디버그용',
                                  style: SheepsTextStyle.h4(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SettingColumn(
                          str: "로컬디비날리기",
                          myFunc: () async {
                            await NotiDBHelper().dropTable();
                            await ChatDBHelper().dropTable();
                            Fluttertoast.showToast(msg: "로컬 데이터 삭제 완료", toastLength: Toast.LENGTH_SHORT);
                          },
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
