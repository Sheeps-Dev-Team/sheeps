import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:sheeps_app/Badge/model/ModelBadge.dart';
import 'package:sheeps_app/chat/ChatPage.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/chat/models/Room.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/LoadingUI.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/notification/models/NotificationModel.dart';
import 'package:sheeps_app/profile/models/DetailProfileController.dart';
import 'package:sheeps_app/profile/models/ModelLikes.dart';
import 'package:sheeps_app/profileModify/MyProfileModify.dart';
import 'package:sheeps_app/Recruit/Models/PersonalSeekTeams.dart';
import 'package:sheeps_app/Recruit/Models/RecruitLikes.dart';
import 'package:sheeps_app/Recruit/Models/TeamMemberRecruit.dart';
import 'package:sheeps_app/Recruit/SpecificUserRecruitPage.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';

import 'DetailTeamProfile.dart';

//초대 가능, 채팅방 이미 있음, 초대 응답 기다림, 초대 받음
enum PERSONAL_INVITE_STATUS { POSSIBLE, ALREADY, WAITING, RECEIVE }

// myProfile 일 경우 profileStatus 필요
// otherProfile 일 경우 user 필요
enum PROFILE_STATUS { MyProfile, OtherProfile, Applicant }

class DetailProfile extends StatefulWidget {
  final int index;
  final UserData? user;
  final PROFILE_STATUS profileStatus;

  DetailProfile({
    Key? key,
    required this.index,
    this.user,
    this.profileStatus = PROFILE_STATUS.OtherProfile,
  }) : super(key: key);

  @override
  _DetailProfileState createState() => _DetailProfileState();
}

class _DetailProfileState extends State<DetailProfile> with SingleTickerProviderStateMixin {
  final DetailProfileController controller = DetailProfileController();
  final RecruitInviteController recruitInviteController = Get.put(RecruitInviteController());

  late UserData _user;
  int currentPage = 0;
  bool lastStatus = true;
  bool lastStatus2 = true;
  bool showLastAccessTime = false;

  late String leftButtonWord;
  late String rightButtonWord;
  late Color leftButtonColor;
  late Color rightButtonColor;

  // ignore: non_constant_identifier_names
  late PERSONAL_INVITE_STATUS personal_invite_status;

  bool isActiveChat = false;
  String roomName = '';
  int inviteID = 0;

  late SocketProvider _socket;
  late ScrollController _scrollController;
  late AnimationController extendedController;

  final String svgWhiteBackArrow = 'assets/images/Profile/WhiteBackArrow.svg';
  final double appBarHeight = Get.height * 0.45;

  bool isCanTapLike = true;
  int tapLikeDelayMilliseconds = 500;

  bool loadTeamList = true;
  final Duration teamListDuration = Duration(milliseconds: 300);

  late PROFILE_STATUS _profileStatus;

  bool isReady = true;

  _scrollListener() {
    if (isShrink != lastStatus) {
      setState(() {
        lastStatus = isShrink;
      });
    }
    if (isShrink2 != lastStatus2) {
      setState(() {
        lastStatus2 = isShrink2;
      });
    }
    if (lastAccessTimeShrink != showLastAccessTime) {
      setState(() {
        showLastAccessTime = lastAccessTimeShrink;
      });
    }
  }

  bool get isShrink {
    return _scrollController.hasClients && _scrollController.offset > (appBarHeight - kToolbarHeight);
  }

  bool get isShrink2 {
    return _scrollController.hasClients && _scrollController.offset > (10);
  }

  bool get lastAccessTimeShrink {
    return _scrollController.hasClients && _scrollController.offset == _scrollController.position.maxScrollExtent;
  }

  Future setTeamList() async {
    var leaderList = await ApiProvider().post('/Team/Profile/Leader', jsonEncode({"userID": _user.userID}));

    if (leaderList != null) {
      for (int i = 0; i < leaderList.length; ++i) {
        myTeamList.add(Team.fromJson(leaderList[i]));
        await GlobalProfile.getFutureTeamByID(leaderList[i]['id']);
      }
    }

    var teamList = await ApiProvider().post('/Team/Profile/SelectUser', jsonEncode({"userID": _user.userID}));

    if (teamList != null) {
      for (int i = 0; i < teamList.length; ++i) {
        myTeamList.add(await GlobalProfile.getFutureTeamByID(teamList[i]['TeamID']));
      }
    }
  }

  Future setPersonalInviteStatus() async {
    var res = await ApiProvider().post('/Room/Invite/TargetSelect', jsonEncode({"userID": GlobalProfile.loggedInUser!.userID, "inviteID": _user.userID}));
    roomName = getRoomName(GlobalProfile.loggedInUser!.userID, _user.userID);

    if (res == null || res['res'] == 0) return;

    if (res['res'] == 1) {
      //상대방이 보낸 초대장 있음
      personal_invite_status = PERSONAL_INVITE_STATUS.RECEIVE;
      leftButtonWord = "채팅 수락";
      rightButtonWord = "채팅 거절";
      leftButtonColor = sheepsColorBlue;
      rightButtonColor = sheepsColorRed;
      inviteID = res['recruitID'];
    } else if (res['res'] == 2) {
      //내가 보낸 초대장 있음
      personal_invite_status = PERSONAL_INVITE_STATUS.WAITING;
      leftButtonWord = '채팅 요청중...';
      rightButtonWord = '구직 공고 보기';
      leftButtonColor = sheepsColorLightGrey;
      rightButtonColor = sheepsColorBlue;
      inviteID = res['recruitID'];
    } else if (res['res'] == 3 || res['res'] == 4) {
      //초대장 없음
      //채팅방 있는지 체크
      ChatGlobal.roomInfoList.forEach((element) {
        if (element.roomName == roomName) {
          isActiveChat = true;
          return;
        }
      });

      if (isActiveChat) {
        personal_invite_status = PERSONAL_INVITE_STATUS.ALREADY;
        leftButtonWord = '채팅방 가기';
        rightButtonWord = '구직 공고 보기';
        leftButtonColor = sheepsColorGreen;
        rightButtonColor = sheepsColorBlue;
        inviteID = 0;
      }
    }

    debugPrint(inviteID.toString());
  }

  List<Team> myTeamList = [];

  @override
  void initState() {
    _profileStatus = widget.profileStatus;
    // 내 프로필이 들어왔나 확인
    if (widget.user != null) {
      if (widget.user!.userID == GlobalProfile.loggedInUser!.userID) {
        _profileStatus = PROFILE_STATUS.MyProfile;
      }
    }
    // profileStatus 에 따라 _user 변경
    _user = _profileStatus == PROFILE_STATUS.MyProfile ? GlobalProfile.loggedInUser! : widget.user!;

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    if (_profileStatus == PROFILE_STATUS.OtherProfile) {
      personal_invite_status = PERSONAL_INVITE_STATUS.POSSIBLE;
      leftButtonWord = "채팅 요청";
      rightButtonWord = "구직 공고 보기";
      leftButtonColor = sheepsColorGreen;
      rightButtonColor = sheepsColorBlue;
    }

    (() async {
      await setTeamList();
      if (_profileStatus == PROFILE_STATUS.OtherProfile) {
        await setPersonalInviteStatus();
      }
    })()
        .then((value) {
      setState(() {
        loadTeamList = false;
      });
    });

    extendedController = AnimationController(vsync: this, duration: const Duration(seconds: 3), lowerBound: 0.0, upperBound: 1.0);

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    extendedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _socket = SocketProvider.to;
    controller.personalProfileDataSet(_user);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: null,
        child: Container(
          color: Colors.white,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
            child: SafeArea(
              child: Scaffold(
                body: Stack(
                  children: [
                    CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverAppBar(
                          elevation: 0,
                          expandedHeight: appBarHeight,
                          floating: false,
                          pinned: true,
                          backgroundColor: Colors.white,
                          centerTitle: true,
                          title: Text(
                            _user.name,
                            textAlign: TextAlign.center,
                            style: SheepsTextStyle.appBar().copyWith(
                              color: isShrink ? Colors.black : Colors.transparent,
                            ),
                          ),
                          leading: InkWell(
                            onTap: () {
                              //_filesProvider.filesList.clear();
                              Get.back();
                            },
                            child: Padding(
                              padding: EdgeInsets.all(12 * sizeUnit),
                              child: SvgPicture.asset(
                                svgWhiteBackArrow,
                                color: isShrink ? Colors.black : Colors.white,
                                width: 28 * sizeUnit,
                                height: 28 * sizeUnit,
                              ),
                            ),
                          ),
                          actions: [
                            if (isShrink) ...[
                              //공유
                              GestureDetector(
                                onTap: () {
                                  if (isReady) {
                                    isReady = false;
                                    Future.delayed(Duration(milliseconds: 800), () => isReady = true);
                                    sharePersonalProfile();
                                  }
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(right: 12 * sizeUnit),
                                  child: SvgPicture.asset(
                                    svgShareBox,
                                    width: 21 * sizeUnit,
                                    height: 21 * sizeUnit,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 14 * sizeUnit),
                                child: changeProfileWidget(),
                              ), // profileStatus 에 따라 좋아요 또는 설정 위젯 리턴
                            ],
                          ],
                          flexibleSpace: Container(
                            decoration: BoxDecoration(
                              border: isShrink
                                  ? Border(
                                      bottom: BorderSide(
                                        color: sheepsColorGrey,
                                        width: 0.5 * sizeUnit,
                                      ),
                                    )
                                  : null,
                            ),
                            child: FlexibleSpaceBar(
                              centerTitle: true,
                              background: Hero(
                                tag: 'personalProfile${_user.userID}',
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    PageView.builder(
                                      onPageChanged: (value) {
                                        setState(() {
                                          currentPage = value;
                                        });
                                      },
                                      itemCount: _user.profileImgList.length, //추후 이미지 여러개 부분 수정 필요
                                      itemBuilder: (context, index) => Stack(
                                        children: [
                                          if (_user.profileImgList[0].imgUrl == 'BasicImage') ...[
                                            Center(
                                              child: SvgPicture.asset(
                                                svgSheepsBasicProfileImage,
                                                width: 180 * sizeUnit,
                                                color: sheepsColorBlue,
                                              ),
                                            ),
                                          ] else ...[
                                            Positioned(
                                              left: 0,
                                              top: 0,
                                              child: Container(
                                                  width: 360 * sizeUnit,
                                                  height: 360 * sizeUnit,
                                                  child: FittedBox(
                                                    child: getExtendedImage(_user.profileImgList[index].imgUrl, 60, extendedController, isRounded: false),
                                                    fit: BoxFit.cover,
                                                  )),
                                            ),
                                          ],
                                          if (_user.profileImgList[0].imgUrl != 'BasicImage') ...[
                                            Positioned(
                                              left: 0,
                                              top: 0,
                                              child: Container(
                                                width: 360 * sizeUnit,
                                                height: 360 * sizeUnit,
                                                child: FittedBox(
                                                  fit: BoxFit.cover,
                                                  child: FadeInImage.memoryNetwork(
                                                    placeholder: kTransparentImage,
                                                    image: getOptimizeImageURL(_user.profileImgList[index].imgUrl, 0),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ] else ...[
                                            SizedBox.shrink(),
                                          ],
                                          gradationBox(),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      left: 12 * sizeUnit,
                                      bottom: 12 * sizeUnit,
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(
                                            _user.profileImgList.length,
                                            (index) => buildDot(index: index),
                                          ),
                                        ),
                                      ),
                                    ),
                                    _user.badge1 != 0
                                        ? Positioned(
                                            right: 12 * sizeUnit,
                                            bottom: 12 * sizeUnit,
                                            child: GestureDetector(
                                              onTap: () {
                                                showPersonalBadgeDialog(badgeID: _user.badge1);
                                              },
                                              child: Container(
                                                width: 48 * sizeUnit,
                                                height: 48 * sizeUnit,
                                                child: ClipRRect(
                                                  borderRadius: new BorderRadius.circular(8 * sizeUnit),
                                                  child: FittedBox(
                                                    child: SvgPicture.asset(
                                                      ReturnPersonalBadgeSVG(_user.badge1),
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    _user.badge2 != 0
                                        ? Positioned(
                                            right: 60 * sizeUnit,
                                            bottom: 12 * sizeUnit,
                                            child: GestureDetector(
                                              onTap: () {
                                                showPersonalBadgeDialog(badgeID: _user.badge2);
                                              },
                                              child: Container(
                                                width: 48 * sizeUnit,
                                                height: 48 * sizeUnit,
                                                child: ClipRRect(
                                                  borderRadius: new BorderRadius.circular(8 * sizeUnit),
                                                  child: FittedBox(
                                                    child: SvgPicture.asset(
                                                      ReturnPersonalBadgeSVG(_user.badge2),
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    _user.badge3 != 0
                                        ? Positioned(
                                            right: 108 * sizeUnit,
                                            bottom: 12 * sizeUnit,
                                            child: GestureDetector(
                                              onTap: () {
                                                showPersonalBadgeDialog(badgeID: _user.badge3);
                                              },
                                              child: Container(
                                                width: 48 * sizeUnit,
                                                height: 48 * sizeUnit,
                                                child: ClipRRect(
                                                  borderRadius: new BorderRadius.circular(8 * sizeUnit),
                                                  child: FittedBox(
                                                    child: SvgPicture.asset(
                                                      ReturnPersonalBadgeSVG(_user.badge3),
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildListDelegate([
                            Container(
                              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - 40 * sizeUnit),
                              color: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8 * sizeUnit),
                                  Center(
                                    child: Container(
                                      width: 20 * sizeUnit,
                                      height: 4 * sizeUnit,
                                      decoration: BoxDecoration(color: sheepsColorLightGrey, borderRadius: BorderRadius.circular(8 * sizeUnit)),
                                    ),
                                  ),
                                  SizedBox(height: 21 * sizeUnit),
                                  Row(
                                    children: [
                                      SizedBox(width: 16 * sizeUnit),
                                      Text(
                                        _user.name.length > 15 ? _user.name.substring(0, 15) : _user.name,
                                        style: SheepsTextStyle.h1().copyWith(fontSize: 24 * sizeUnit),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Spacer(),
                                      if (!isShrink) ...[
                                        //공유
                                        GestureDetector(
                                          onTap: () {
                                            if (isReady) {
                                              isReady = false;
                                              Future.delayed(Duration(milliseconds: 800), () => isReady = true);
                                              sharePersonalProfile();
                                            }
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.only(right: 12 * sizeUnit),
                                            child: SvgPicture.asset(
                                              svgShareBox,
                                              width: 21 * sizeUnit,
                                              height: 21 * sizeUnit,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(right: 14 * sizeUnit),
                                          child: changeProfileWidget(),
                                        ), // profileStatus 에 따라 좋아요 또는 설정 위젯 리턴
                                      ],
                                    ],
                                  ),
                                  SizedBox(height: 12 * sizeUnit),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          runSpacing: 8 * sizeUnit,
                                          spacing: 8 * sizeUnit,
                                          children: [
                                            if (_user.part != null && _user.part.isNotEmpty) profileBigWrapItem(_user.part),
                                            if (_user.subPart != null && _user.subPart.isNotEmpty) profileBigWrapItem(_user.subPart),
                                            if (_user.location != null && _user.location.isNotEmpty) profileBigWrapItem(_user.location + " " + _user.subLocation),
                                          ],
                                        ),
                                        SizedBox(height: 12 * sizeUnit),
                                        Text(
                                          _user.information == null ? '' : _user.information,
                                          style: SheepsTextStyle.b3(),
                                        ),
                                        SizedBox(height: 16 * sizeUnit),
                                        profileAuthWidget(
                                          title: '학력',
                                          description: '학력을 추가해 보세요',
                                          list: controller.userEducationList,
                                        ),
                                        profileAuthWidget(
                                          title: '경력',
                                          description: '경력을 추가해 보세요',
                                          list: controller.userCareerList,
                                        ),
                                        profileAuthWidget(
                                          title: '자격증',
                                          description: '자격증을 추가해 보세요',
                                          list: controller.userLicenseList,
                                        ),
                                        profileAuthWidget(
                                          title: '수상 이력',
                                          description: '수상 이력을 추가해 보세요',
                                          list: controller.userWinList,
                                        ),
                                        if (controller.showUserUrl) ...[
                                          Text(
                                            '이력 링크',
                                            style: SheepsTextStyle.h3(),
                                          ),
                                          SizedBox(height: 8 * sizeUnit),
                                          Wrap(
                                            spacing: 12 * sizeUnit,
                                            runSpacing: 8 * sizeUnit,
                                            children: [
                                              if (_user.userLink!.portfolioUrl.isNotEmpty) linkItem(title: '포트폴리오', linkUrl: _user.userLink!.portfolioUrl),
                                              if (_user.userLink!.resumeUrl.isNotEmpty) linkItem(title: '이력서', linkUrl: _user.userLink!.resumeUrl),
                                              if (_user.userLink!.siteUrl.isNotEmpty) linkItem(title: 'Site', linkUrl: _user.userLink!.siteUrl),
                                              if (_user.userLink!.linkedInUrl.isNotEmpty) linkItem(title: 'LinkedIn', linkUrl: _user.userLink!.linkedInUrl, color: Color(0xFF005AB6)),
                                              if (_user.userLink!.instagramUrl.isNotEmpty) linkItem(title: 'Instagram', linkUrl: _user.userLink!.instagramUrl, color: Color(0xFFDA4064)),
                                              if (_user.userLink!.facebookUrl.isNotEmpty) linkItem(title: 'Facebook', linkUrl: _user.userLink!.facebookUrl, color: Color(0xFF006AEA)),
                                              if (_user.userLink!.gitHubUrl.isNotEmpty) linkItem(title: 'GitHub', linkUrl: _user.userLink!.gitHubUrl, color: Color(0xFF191D20)),
                                              if (_user.userLink!.notionUrl.isNotEmpty) linkItem(title: 'Notion', linkUrl: _user.userLink!.notionUrl, color: Colors.black),
                                            ],
                                          ),
                                        ] else ...[
                                          if (_profileStatus == PROFILE_STATUS.MyProfile) ...[
                                            Text(
                                              '이력 링크',
                                              style: SheepsTextStyle.h3(),
                                            ),
                                            SizedBox(height: 8 * sizeUnit),
                                            Row(
                                              children: [
                                                Text('・ ', style: SheepsTextStyle.b3()),
                                                Text('이력 링크를 추가해 보세요', style: SheepsTextStyle.error()),
                                              ],
                                            ),
                                          ]
                                        ],
                                        if (myTeamList.isNotEmpty) ...[
                                          SizedBox(height: 32 * sizeUnit),
                                        ] else ...[
                                          SizedBox(height: 16 * sizeUnit),
                                        ],
                                        AnimatedOpacity(
                                          duration: teamListDuration,
                                          opacity: loadTeamList ? 0 : 1,
                                          child: Text(
                                            '소속 팀',
                                            style: SheepsTextStyle.h3(),
                                          ),
                                        ),
                                        SizedBox(height: 12 * sizeUnit),
                                      ],
                                    ),
                                  ),
                                  buildAffiliatedProfiles(),
                                  SizedBox(height: 95 * sizeUnit),
                                  if (_profileStatus != PROFILE_STATUS.MyProfile) SizedBox(height: 70 * sizeUnit), // 최근 접속시간 뜰 때
                                ],
                              ),
                            ),
                          ]),
                        ),
                      ],
                    ),
                    bottomOpacity(context),
                    if (_profileStatus != PROFILE_STATUS.MyProfile) lastAccessTime(),
                    if (_profileStatus == PROFILE_STATUS.OtherProfile) // otherProfile 일 때 바텀 버튼 생성
                      BottomButtons(context, _socket),
                    if (_profileStatus == PROFILE_STATUS.Applicant) ...[
                      if (recruitInviteController.getCurrRecruitInvite.response == 2) ...[responseDoneButton()] else ...[applicantBottomButtons()]
                    ] // applicant 일 때 바텀 버튼 생성
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column profileAuthWidget({required String title, required String description, required List list}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // MyProfile 이면 제목 무조건 나오기
        if (_profileStatus == PROFILE_STATUS.MyProfile) ...[
          Text(title, style: SheepsTextStyle.h3()),
          SizedBox(height: 8 * sizeUnit),
          if (list.length == 0) ...[
            Row(
              children: [
                Text('・ ', style: SheepsTextStyle.b3()),
                Text(description, style: SheepsTextStyle.error()),
              ],
            ),
          ]
        ] else ...[
          // MyProfile 아니면 빈 값이 아닐 때 제목 나오기
          if (list.isNotEmpty) ...[
            Text(title, style: SheepsTextStyle.h3()),
            SizedBox(height: 8 * sizeUnit),
          ],
        ],
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: list.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 1 * sizeUnit),
              child: authItem(list[index].contents, list[index].auth, iconColor: sheepsColorBlue),
            );
          },
        ),
        if (_profileStatus == PROFILE_STATUS.MyProfile || list.isNotEmpty) SizedBox(height: 16 * sizeUnit),
      ],
    );
  }

  Widget lastAccessTime() {
    return Positioned(
      bottom: 86 * sizeUnit,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 200),
        opacity: lastAccessTimeShrink ? 1 : 0,
        child: Column(
          children: [
            Container(
              height: 1 * sizeUnit,
              width: 328 * sizeUnit,
              color: sheepsColorLightGrey,
            ),
            Container(
              width: 360 * sizeUnit,
              height: 46 * sizeUnit,
              padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('최근 접속 시간', style: SheepsTextStyle.b3()),
                  Text(timeCheck(_user.updatedAt), style: SheepsTextStyle.b3().copyWith(color: sheepsColorGreen)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAffiliatedProfiles() {
    return AnimatedOpacity(
      duration: teamListDuration,
      opacity: loadTeamList ? 0 : 1,
      child: Container(
        padding: EdgeInsets.only(left: 16 * sizeUnit),
        height: 200 * sizeUnit,
        color: Colors.white,
        child: myTeamList.length == 0
            ? Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 1 * sizeUnit),
                    child: Row(
                      children: [
                        Text('・ ', style: SheepsTextStyle.b3()),
                        Text('현재 소속된 팀이 없어요!', style: SheepsTextStyle.error()),
                      ],
                    ),
                  ),
                  if (_profileStatus != PROFILE_STATUS.MyProfile) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 1 * sizeUnit),
                      child: Row(
                        children: [
                          Text('・ ', style: SheepsTextStyle.b3()),
                          Text('아래에서 팀으로 초대해 보세요.', style: SheepsTextStyle.error()),
                        ],
                      ),
                    ),
                  ]
                ],
              )
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                cacheExtent: 30,
                reverse: false,
                shrinkWrap: true,
                itemCount: myTeamList.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(() => DetailTeamProfile(index: index, team: myTeamList[index]));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 132 * sizeUnit,
                                  height: 132 * sizeUnit,
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.to(() => DetailTeamProfile(
                                            index: index,
                                            team: myTeamList[index],
                                          ));
                                    },
                                    child: myTeamList[index].profileImgList[0].imgUrl == 'BasicImage'
                                        ? Container(
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24 * sizeUnit), border: Border.all(width: 0.5 * sizeUnit, color: sheepsColorGrey)),
                                            child: Center(
                                              child: SvgPicture.asset(
                                                svgSheepsBasicProfileImage,
                                                height: 63 * sizeUnit,
                                                color: sheepsColorGreen,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            width: 132 * sizeUnit,
                                            height: 132 * sizeUnit,
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color.fromRGBO(116, 125, 130, 0.1),
                                                  blurRadius: 2 * sizeUnit,
                                                  offset: Offset(1 * sizeUnit, 1 * sizeUnit),
                                                ),
                                              ],
                                              borderRadius: BorderRadius.circular(24 * sizeUnit),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(24 * sizeUnit),
                                              child: FittedBox(
                                                fit: BoxFit.cover,
                                                child: getExtendedImage(myTeamList[index].profileImgList[0].imgUrl, 60, extendedController),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                Container(
                                  color: Colors.black.withOpacity(0.8),
                                ),
                                if (myTeamList[index].leaderID == _user.userID) ...[
                                  Positioned(
                                    top: 7 * sizeUnit,
                                    left: 8 * sizeUnit,
                                    child: Container(
                                      padding: EdgeInsets.all(4.5 * sizeUnit),
                                      height: 20 * sizeUnit,
                                      width: 20 * sizeUnit,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: sheepsColorBlue,
                                      ),
                                      child: SvgPicture.asset(svgCircleLeaderIcon),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 8 * sizeUnit),
                            Container(
                              height: 16 * sizeUnit,
                              width: 120 * sizeUnit,
                              child: Text(
                                myTeamList[index].name,
                                style: SheepsTextStyle.h4(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: 4 * sizeUnit),
                            Container(
                              width: 132 * sizeUnit,
                              child: Wrap(
                                runSpacing: 6 * sizeUnit,
                                spacing: 6 * sizeUnit,
                                children: [
                                  if (myTeamList[index].part != null && myTeamList[index].part.isNotEmpty) profileSmallWrapItem(myTeamList[index].part),
                                  if (myTeamList[index].location != null && myTeamList[index].location.isNotEmpty) profileSmallWrapItem(myTeamList[index].location),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8 * sizeUnit),
                    ],
                  );
                }),
      ),
    );
  }

  Positioned responseDoneButton() {
    return Positioned(
      bottom: 0,
      child: IgnorePointer(
        ignoring: isShrink ? false : true,
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 100),
          opacity: isShrink ? 1 : 0,
          child: Container(
              padding: EdgeInsets.all(16 * sizeUnit),
              width: 360 * sizeUnit,
              height: 86 * sizeUnit,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24 * sizeUnit)),
                boxShadow: [
                  bottomButtonBoxShadow(),
                ],
              ),
              child: GestureDetector(
                onTap: null,
                child: Container(
                  width: 360 * sizeUnit,
                  height: 54 * sizeUnit,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12 * sizeUnit),
                    color: sheepsColorGrey,
                  ),
                  child: Center(
                    child: Text(
                      "응답 완료",
                      style: SheepsTextStyle.button1(),
                    ),
                  ),
                ),
              )),
        ),
      ),
    );
  }

  Positioned applicantBottomButtons() {
    return Positioned(
      bottom: 0,
      child: IgnorePointer(
        ignoring: isShrink ? false : true,
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 100),
          opacity: isShrink ? 1 : 0,
          child: Container(
            padding: EdgeInsets.all(16 * sizeUnit),
            width: 360 * sizeUnit,
            height: 86 * sizeUnit,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24 * sizeUnit)),
              boxShadow: [
                bottomButtonBoxShadow(),
              ],
            ),
            child: Row(
              children: [
                bottomButton(
                  press: () {
                    Function func = () {
                      RecruitInvite currRecruitInvite = recruitInviteController.getCurrRecruitInvite;

                      ApiProvider().post(
                          '/Matching/Response/TeamMemberRecruit',
                          jsonEncode({
                            "to": currRecruitInvite.inviteID,
                            "from": currRecruitInvite.targetID,
                            "tableIndex": currRecruitInvite.id,
                            "targetIndex": currRecruitInvite.index,
                            "teamIndex": globalTeamMemberRecruitList.singleWhere((element) => element.id == currRecruitInvite.index).id,
                            "response": INVITE_REFUSE,
                          }));

                      //dialog pop
                      Get.back();
                      //detail profile pop
                      Get.back();

                      recruitInviteController.removeRecruitInviteCurr(currRecruitInvite.id);
                    };

                    showSheepsCustomDialog(
                        title: Text(
                          "불합격\n처리 할까요?",
                          style: SheepsTextStyle.dialogTitle().copyWith(height: 1.2, fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        contents: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
                            children: [
                              TextSpan(text: '지원자에게 불합격 알림이 가고,\n'),
                              TextSpan(text: '지원자 리스트에서 삭제됩니다.'),
                            ],
                          ),
                        ),
                        okButtonColor: sheepsColorGreen,
                        okFunc: func);
                  },
                  text: '불합격',
                  color: sheepsColorRed,
                ),
                SizedBox(width: 8 * sizeUnit),
                bottomButton(
                  press: () {
                    RecruitInvite currRecruitInvite = recruitInviteController.getCurrRecruitInvite;

                    if (recruitInviteController.getCurrRecruitInvite.response == 0) {
                      Function func = () async {
                        //인터뷰 초대 합격
                        String roomName = getRoomName(currRecruitInvite.index, currRecruitInvite.targetID, ID3: currRecruitInvite.id, roomType: ROOM_TYPE_TEAM_MEMBER_RECRUIT);

                        ApiProvider().post(
                            '/Matching/Response/TeamMemberRecruit',
                            jsonEncode({
                              "to": currRecruitInvite.inviteID,
                              "from": currRecruitInvite.targetID,
                              "tableIndex": currRecruitInvite.id,
                              "targetIndex": currRecruitInvite.index,
                              "teamIndex": globalTeamMemberRecruitList.singleWhere((element) => element.id == currRecruitInvite.index).id,
                              "roomName": roomName,
                              "response": INVITE_ACCEPT,
                            }));

                        NotificationModel notificationmodel = NotificationModel();

                        notificationmodel.from = currRecruitInvite.targetID;
                        notificationmodel.to = currRecruitInvite.inviteID;
                        notificationmodel.targetIndex = currRecruitInvite.index;
                        notificationmodel.type = ROOM_TYPE_TEAM_MEMBER_RECRUIT;
                        notificationmodel.time = DateTime.now().toString();
                        notificationmodel.teamRoomName = roomName;

                        RoomInfo room = await SetRoomInfoData(notificationmodel, roomType: ROOM_TYPE_TEAM_MEMBER_RECRUIT);
                        if (false == ChatGlobal.IsAlreadyRoom(room)) {
                          ChatGlobal.roomInfoList.insert(0, room);
                        }

                        //dialog pop
                        Get.back();
                        //detail profile pop
                        Get.back();

                        currRecruitInvite.response = 1;
                        recruitInviteController.responseRecruitInviteCurr(currRecruitInvite.id, currRecruitInvite);
                      };

                      showSheepsCustomDialog(
                          title: Text(
                            "면접 채팅을 \n시작할까요?",
                            style: SheepsTextStyle.dialogTitle().copyWith(height: 1.2, fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                          contents: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
                              children: [
                                TextSpan(text: '면접을 위한 채팅방이 생성되고,\n'),
                                TextSpan(text: '면접 후 결정할 수 있어요!'),
                              ],
                            ),
                          ),
                          okButtonColor: sheepsColorBlue,
                          okFunc: func);
                    } else {
                      Function func = () async {
                        //팀 초대 합격
                        int teamID = globalTeamMemberRecruitList.singleWhere((element) => element.id == currRecruitInvite.index).teamId;
                        String roomName = getRoomName(teamID, GlobalProfile.loggedInUser!.userID, roomType: ROOM_TYPE_TEAM);

                        ApiProvider().post(
                            '/Team/Pass/Interview',
                            jsonEncode({
                              "to": currRecruitInvite.inviteID,
                              "from": currRecruitInvite.targetID,
                              "tableIndex": currRecruitInvite.id,
                              "targetIndex": currRecruitInvite.index,
                              "teamIndex": teamID,
                              "roomName": roomName,
                              "response": INVITE_ACCEPT,
                              "isRecruit": true
                            }));

                        //팀 전역에 상대방 등록
                        GlobalProfile.teamProfile.forEach((element) {
                          if (element.id == teamID) {
                            element.userList.add(currRecruitInvite.targetID);
                          }
                        });

                        if (false == ChatGlobal.IsAlreadyRoomByRoomName(roomName)) {
                          NotificationModel notificationmodel = NotificationModel();

                          notificationmodel.from = currRecruitInvite.targetID;
                          notificationmodel.to = currRecruitInvite.inviteID;
                          notificationmodel.targetIndex = currRecruitInvite.index;
                          notificationmodel.type = ROOM_TYPE_TEAM;
                          notificationmodel.time = DateTime.now().toString();
                          notificationmodel.teamRoomName = roomName;

                          RoomInfo room = await SetRoomInfoData(notificationmodel, roomType: ROOM_TYPE_TEAM);

                          ChatGlobal.roomInfoList.insert(0, room);
                        } else {
                          ChatGlobal.AddTeamMember(currRecruitInvite.targetID, roomName);
                        }

                        //dialog pop
                        Get.back();

                        //합격하면 초대장 삭제?
                        currRecruitInvite.response = 2;
                        recruitInviteController.responseRecruitInviteCurr(currRecruitInvite.id, currRecruitInvite);

                        setState(() {});
                      };

                      showSheepsCustomDialog(
                          title: Text(
                            "합격 처리 할까요?",
                            style: SheepsTextStyle.dialogTitle().copyWith(height: 1.2, fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                          contents: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
                              children: [
                                TextSpan(text: '지원자에게 합격 알림이 가고,\n'),
                                TextSpan(text: '팀원으로 자동 등록됩니다.'),
                              ],
                            ),
                          ),
                          okButtonColor: sheepsColorBlue,
                          okFunc: func);
                    }
                  },
                  text: recruitInviteController.getCurrRecruitInvite.response == 0 ? '면접 시작' : '합격',
                  color: recruitInviteController.getCurrRecruitInvite.response == 0 ? sheepsColorBlue : sheepsColorGreen,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Positioned BottomButtons(BuildContext context, SocketProvider socket) {
    return Positioned(
      bottom: 0,
      child: IgnorePointer(
        ignoring: isShrink ? false : true,
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 100),
          opacity: isShrink ? 1 : 0,
          child: Container(
              padding: EdgeInsets.all(16 * sizeUnit),
              width: 360 * sizeUnit,
              height: 86 * sizeUnit,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24 * sizeUnit)),
                boxShadow: [
                  bottomButtonBoxShadow(),
                ],
              ),
              child: Row(
                children: [
                  bottomButton(
                    press: () {
                      if (personal_invite_status == PERSONAL_INVITE_STATUS.WAITING) return;

                      if (personal_invite_status == PERSONAL_INVITE_STATUS.POSSIBLE) {
                        Function okFunc = () async {
                          var res = await ApiProvider()
                              .post('/Room/Invite/Insert', jsonEncode({"userID": GlobalProfile.loggedInUser!.userID, "inviteID": _user.userID, "userName": GlobalProfile.loggedInUser!.name}));

                          if (res['res'] == 0) return;

                          if (res['res'] == 1) {
                            setState(() {
                              personal_invite_status = PERSONAL_INVITE_STATUS.RECEIVE;
                              leftButtonWord = "채팅 수락";
                              rightButtonWord = "채팅 거절";
                              leftButtonColor = sheepsColorBlue;
                              rightButtonColor = sheepsColorRed;
                              inviteID = res['recruitID'];
                            });
                          } else {
                            setState(() {
                              personal_invite_status = PERSONAL_INVITE_STATUS.WAITING;
                              leftButtonWord = '채팅 요청중...';
                              rightButtonWord = '구직 공고 보기';
                              leftButtonColor = sheepsColorLightGrey;
                              rightButtonColor = sheepsColorBlue;
                              inviteID = 0;
                            });
                          }

                          Get.back();
                        };

                        showSheepsDialog(
                          context: context,
                          title: '채팅 요청',
                          description: '마음에 드시는 분을 만나셨군요.\n채팅 초대 요청을 보내볼까요?',
                          okText: '보낼래요',
                          okFunc: okFunc,
                          cancelText: '좀 더 생각해볼게요',
                        );
                      } else if (personal_invite_status == PERSONAL_INVITE_STATUS.ALREADY) {
                        List<UserData> userList = [];
                        userList.add(_user);

                        _socket.setRoomStatus(ROOM_STATUS_CHAT);
                        Navigator.push(
                            context, // 기본 파라미터, SecondRoute로 전달
                            CupertinoPageRoute(
                                builder: (context) => ChatPage(
                                      roomName: roomName,
                                      titleName: _user.name,
                                      isNeedCallPop: true,
                                      chatUserList: userList,
                                      targetID: _user.userID,
                                      leaderID: -1,
                                    ))).then((value) {
                          setState(() {
                            if(ChatGlobal.willRemoveRoom != null) {
                              ChatGlobal.roomInfoList.remove(ChatGlobal.willRemoveRoom);
                              ChatGlobal.willRemoveRoom = null;
                              personal_invite_status = PERSONAL_INVITE_STATUS.POSSIBLE;
                              leftButtonWord = "채팅 요청";
                              leftButtonColor = sheepsColorGreen;
                            }
                            socket.setRoomStatus(ROOM_STATUS_ETC);
                          });
                        });
                      } else if (personal_invite_status == PERSONAL_INVITE_STATUS.RECEIVE) {
                        Function okFunc = () async {
                          await ApiProvider().post(
                              '/Room/Invite/Response',
                              jsonEncode({
                                "to": GlobalProfile.loggedInUser!.userID,
                                "from": _user.userID,
                                "tableIndex": inviteID,
                                "userName": GlobalProfile.loggedInUser!.name,
                                "response": 1,
                                "roomName": roomName
                              }));

                          NotificationModel notificationmodel = NotificationModel();

                          notificationmodel.from = _user.userID;
                          notificationmodel.to = GlobalProfile.loggedInUser!.userID;
                          notificationmodel.type = ROOM_TYPE_PERSONAL;
                          notificationmodel.time = DateTime.now().toString();
                          notificationmodel.teamRoomName = getRoomName(GlobalProfile.loggedInUser!.userID, _user.userID);

                          RoomInfo room = await SetRoomInfoData(notificationmodel);

                          if (false == ChatGlobal.IsAlreadyRoom(room)) {
                            ChatGlobal.roomInfoList.insert(0, room);
                          }else{
                            ChatGlobal.roomInfoList.forEach((element) async {
                              if(element.roomName == roomName){
                                await ApiProvider().post('/Room/Info/Select', jsonEncode({
                                  "userID" : GlobalProfile.loggedInUser!.userID,
                                  "roomName" : roomName
                                })).then((value) => {
                                  if(value != null){
                                    element.roomInfoID = value['RoomID'],
                                    element.roomUserID = value['RoomUsers'][0]['id'] as int,
                                    element.isAlarm = 1,
                                    element.lastMessage = "채팅방이 다시 활성화 되었습니다.",
                                    element.date = notificationmodel.time
                                  }
                                });
                              }
                            });
                          }

                          setState(() {
                            personal_invite_status = PERSONAL_INVITE_STATUS.ALREADY;
                            leftButtonWord = '채팅방 가기';
                            rightButtonWord = '구직 공고 보기';
                            leftButtonColor = sheepsColorGreen;
                            rightButtonColor = sheepsColorBlue;
                          });

                          Get.back();
                        };

                        showSheepsDialog(
                          context: context,
                          title: '채팅 초대 응답',
                          description: '상대방이 마음에 드시는군요.\n초대 수락을 보내볼까요?',
                          okText: '수락하기',
                          okFunc: okFunc,
                          okColor: sheepsColorBlue,
                          cancelText: '취소하기',
                        );
                      }
                    },
                    text: leftButtonWord,
                    color: leftButtonColor,
                  ),
                  SizedBox(width: 8 * sizeUnit),
                  bottomButton(
                    text: rightButtonWord,
                    color: rightButtonColor,
                    press: () async {
                      if (personal_invite_status == PERSONAL_INVITE_STATUS.WAITING || personal_invite_status == PERSONAL_INVITE_STATUS.POSSIBLE || personal_invite_status == PERSONAL_INVITE_STATUS.ALREADY) {
                        DialogBuilder(context).showLoadingIndicator();

                        List<PersonalSeekTeam> seekList = [];

                        var res = await ApiProvider().post(
                            '/Matching/Select/PersonalSeekTeamByUserID',
                            jsonEncode({
                              'userID': _user.userID,
                            }));

                        if (res != null) {
                          for (int i = 0; i < res.length; i++) {
                            PersonalSeekTeam tmpSeek = PersonalSeekTeam.fromJson(res[i]);
                            seekList.add(tmpSeek);
                            GlobalProfile.getFutureUserByUserID(tmpSeek.userId);
                          }
                        }

                        DialogBuilder(context).hideOpenDialog();

                        Get.to(() => SpecificUserRecruitPage(
                              isRecruit: false,
                              mySeekList: seekList,
                              appBarTitle: '구직공고 리스트',
                            ));
                      } else if (personal_invite_status == PERSONAL_INVITE_STATUS.RECEIVE) {
                        Function okFunc = () async {
                          await ApiProvider().post(
                              '/Room/Invite/Response',
                              jsonEncode({
                                "to": GlobalProfile.loggedInUser!.userID,
                                "from": _user.userID,
                                "tableIndex": inviteID,
                                "userName": GlobalProfile.loggedInUser!.name,
                                "response": 2,
                                "roomName": roomName
                              }));

                          setState(() {
                            personal_invite_status = PERSONAL_INVITE_STATUS.POSSIBLE;
                            leftButtonWord = "채팅 요청";
                            rightButtonWord = "구직 공고 보기";
                            leftButtonColor = sheepsColorGreen;
                            rightButtonColor = sheepsColorBlue;
                          });

                          Get.back();
                        };

                        showSheepsDialog(
                          context: context,
                          title: '채팅 초대 응답',
                          description: '상대방과 채팅을 하고 싶지 않으시군요.\n초대 거절을 보낼까요?',
                          okText: '거절하기',
                          okFunc: okFunc,
                          okColor: sheepsColorRed,
                          cancelText: '취소하기',
                        );
                      }
                    },
                  ),
                ],
              )),
        ),
      ),
    );
  }

  GestureDetector bottomButton({required Function press, required String text, required Color color}) {
    return GestureDetector(
      onTap: () => press(),
      child: Container(
        width: 160 * sizeUnit,
        height: 54 * sizeUnit,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12 * sizeUnit),
          color: color,
        ),
        child: Center(
          child: Text(
            text,
            style: SheepsTextStyle.button1(),
          ),
        ),
      ),
    );
  }

  Positioned bottomOpacity(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 0),
        width: 360 * sizeUnit,
        height: 72 * sizeUnit,
        decoration: BoxDecoration(
          gradient: isShrink2
              ? LinearGradient(colors: [Colors.transparent, Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter)
              : LinearGradient(colors: [
                  Color.fromARGB(255, 255, 255, 255),
                  Color.fromARGB(128, 255, 255, 255),
                  Color.fromARGB(64, 255, 255, 255),
                  Color.fromARGB(20, 255, 255, 255),
                ], stops: [
                  0,
                  0.15,
                  0.4,
                  1
                ], begin: Alignment.bottomCenter, end: Alignment.topCenter),
        ),
      ),
    );
  }

  InkWell appbarBackButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.back();
      },
      child: Padding(
        padding: EdgeInsets.all(12 * sizeUnit),
        child: SvgPicture.asset(
          svgWhiteBackArrow,
          color: isShrink ? Colors.black : Colors.white,
          width: 28 * sizeUnit,
          height: 28 * sizeUnit,
        ),
      ),
    );
  }

  AnimatedContainer buildDot({required int index}) {
    return AnimatedContainer(
      duration: kAnimationDuration,
      margin: EdgeInsets.only(right: 4 * sizeUnit),
      height: 4 * sizeUnit,
      width: currentPage == index ? 12 * sizeUnit : 4 * sizeUnit,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2 * sizeUnit),
      ),
    );
  }

  Widget changeProfileWidget() {
    switch (_profileStatus) {
      case PROFILE_STATUS.MyProfile: // myProfile 일때
        return GestureDetector(
          onTap: () {
            Get.to(() => MyProfileModify())?.then((value) => setState(() {
                  _user = GlobalProfile.loggedInUser!;
                }));
          },
          child: SvgPicture.asset(
            svgSetting,
            color: sheepsColorDarkGrey,
            width: 28 * sizeUnit,
            height: 28 * sizeUnit,
          ),
        );
      default:
        {
          ModelLikes? modelLikes;
          globalPersonalLikeList.forEach((element) {
            if (element.TargetID == _user.userID) modelLikes = element;
          });

          return GestureDetector(
              onTap: () async {
                if (isCanTapLike) {
                  isCanTapLike = false;

                  var res = await ApiProvider().post(
                      '/Personal/Insert/Like',
                      jsonEncode({
                        "userID": GlobalProfile.loggedInUser!.userID,
                        "targetID": _user.userID,
                      }));

                  if (res['created']) {
                    modelLikes = ModelLikes.fromJson(res['item']);

                    globalPersonalLikeList.add(modelLikes!);
                  } else {
                    globalPersonalLikeList.removeWhere((element) => element.TargetID == _user.userID);
                  }

                  setState(() {
                    Future.delayed(Duration(milliseconds: tapLikeDelayMilliseconds), () {
                      isCanTapLike = true;
                    });
                  });
                }
              },
              child: SvgPicture.asset(
                modelLikes == null ? svgBookMarkIcon : svgFillBookMarkIcon,
                color: modelLikes == null ? null : sheepsColorGreen,
                width: 28 * sizeUnit,
                height: 28 * sizeUnit,
              ));
        }
        break;
    }
  }

  void sharePersonalProfile() async {
    DialogBuilder(context).showLoadingIndicator();
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://sheepsapp.page.link',
        link: Uri.parse('https://sheepsapp.page.link/profile_person?id=${_user.userID}'),
        androidParameters: AndroidParameters(
          packageName: 'kr.noteasy.sheeps_app',
          minimumVersion: 1, //실행 가능 최소 버전
        ),
        iosParameters: IOSParameters(
          bundleId: 'kr.noteasy.sheepsApp',
          minimumVersion: '1.0',
          appStoreId: '1558625011',
        ));

    // final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    // final Uri shortUrl = shortDynamicLink.shortUrl;
    final Uri shortUrl = parameters.link;

    String name = _user.name;

    DialogBuilder(context).hideOpenDialog();
    Share.share('$name님 프로필 보기\n$shortUrl', subject: '스타트업 필수 앱! 쉽스!\n');
  }
}
