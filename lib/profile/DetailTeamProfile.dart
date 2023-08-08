import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheeps_app/Recruit/Models/TeamMemberRecruit.dart';
import 'package:sheeps_app/Recruit/SpecificUserRecruitPage.dart';
import 'package:sheeps_app/config/LoadingUI.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:sheeps_app/Recruit/Models/RecruitLikes.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/chat/models/Room.dart';
import 'package:sheeps_app/notification/models/NotificationModel.dart';
import 'package:sheeps_app/profile/models/DetailProfileController.dart';
import 'package:sheeps_app/profile/TeamMemberManagementPage.dart';
import 'package:sheeps_app/profile/models/ModelLikes.dart';
import 'package:sheeps_app/Badge/model/ModelBadge.dart';
import 'package:sheeps_app/TeamProfileManagement/TeamProfileManagementPage.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/profile/DetailProfile.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

import 'MyTeamProfile.dart';

class DetailTeamProfile extends StatefulWidget {
  final int index;
  final Team team;
  final bool proposedTeam;
  final bool showBottomButton;
  final bool byChat;

  DetailTeamProfile({Key? key, required this.index, required this.team, this.proposedTeam = false, this.showBottomButton = true, this.byChat = false}) : super(key: key);

  @override
  _DetailTeamProfileState createState() => _DetailTeamProfileState();
}

class _DetailTeamProfileState extends State<DetailTeamProfile> with SingleTickerProviderStateMixin {
  final DetailProfileController controller = DetailProfileController();
  final RecruitInviteController recruitInviteController = Get.put(RecruitInviteController());
  int currentPage = 0;
  bool lastStatus = true;
  bool lastStatus2 = true;

  int roomIndex = 0;
  bool isActiveChat = false;

  late SocketProvider _socket;
  late ScrollController _scrollController;
  late AnimationController extendedController;

  List<int> totalList = [];
  late Team modifyTeam;

  final String svgWhiteBackArrow = 'assets/images/Profile/WhiteBackArrow.svg';
  final String svgSetting = 'assets/images/ProfileModify/Setting.svg';
  String svgChatIcon = 'assets/images/Chat/chatSmallIcon.svg';
  final GreyXIcon = 'assets/images/Public/GreyXIcon.svg';

  String key = 'TeamLikesList';

  bool Likes = false;
  late bool showBottomButton; // 바텀 버튼 보여주기 여부

  bool isCanTapLike = true;
  int tapLikeDelayMilliseconds = 500;

  final double appBarHeight = Get.height * 0.45;

  bool isReady = true;
  late bool teamMemberLoading;
  bool showLastAccessTime = false;

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

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    modifyTeam = widget.team;

    modifyTeamInMyTeamProfile = null; //상세팀프로필에서 사용하는 팀 객체 비우기

    showBottomButton = widget.showBottomButton;

    totalList.add(widget.team.leaderID);

    teamMemberLoading = widget.team.userList.isEmpty ? false : true; // 팀에 혼자면 로딩 안함

    if (widget.team.userList != null && widget.team.userList.length != 0) {
      Future.microtask(() async {

        for (int i = 0; i < widget.team.userList.length; ++i) {
          if (widget.team.leaderID != widget.team.userList[i]) {
            totalList.add(widget.team.userList[i]);
            await GlobalProfile.getFutureUserByUserID(widget.team.userList[i]);
          }
        }

      }).then((value) {
        teamMemberLoading = false; // 로딩 끝
        setState(() {});
      });
    }

    extendedController = AnimationController(vsync: this, duration: const Duration(seconds: 3), lowerBound: 0.0, upperBound: 1.0);
    controller.teamProfileDataSet(modifyTeam);
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: WillPopScope(
              onWillPop: null,
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
                            modifyTeam.name,
                            textAlign: TextAlign.center,
                            style: SheepsTextStyle.appBar().copyWith(
                              color: isShrink ? Colors.black : Colors.transparent,
                            ),
                          ),
                          leading: InkWell(
                            onTap: () {
                              setState(() {
                                Likes = false;
                              });
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
                                  if(isReady){
                                    isReady = false;
                                    Future.delayed(Duration(milliseconds: 800), () => isReady = true);
                                    shareTeamProfile();
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
                              ), //
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
                                tag: 'teamProfile${modifyTeam.id}',
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    PageView.builder(
                                      onPageChanged: (value) {
                                        setState(() {
                                          currentPage = value;
                                        });
                                      },
                                      itemCount: modifyTeam.profileImgList.length, //추후 이미지 여러개 부분 수정 필요
                                      itemBuilder: (context, index) => Stack(
                                        children: [
                                          modifyTeam.profileImgList[0].imgUrl == 'BasicImage'
                                              ? Center(
                                                  child: SvgPicture.asset(
                                                    svgSheepsBasicProfileImage,
                                                    width: 180 * sizeUnit,
                                                    color: sheepsColorGreen,
                                                  ),
                                                )
                                              : Positioned(
                                                  left: 0,
                                                  top: 0,
                                                  child: Container(
                                                      width: 360 * sizeUnit,
                                                      height: 360 * sizeUnit,
                                                      child: FittedBox(
                                                        child: getExtendedImage(modifyTeam.profileImgList[index].imgUrl, 60, extendedController, isRounded: false),
                                                        fit: BoxFit.cover,
                                                      )),
                                                ),
                                          modifyTeam.profileImgList[0].imgUrl != 'BasicImage'
                                              ? Positioned(
                                                  left: 0,
                                                  top: 0,
                                                  child: Container(
                                                    width: 360 * sizeUnit,
                                                    height: 360 * sizeUnit,
                                                    child: FittedBox(
                                                      fit: BoxFit.cover,
                                                      child: FadeInImage.memoryNetwork(
                                                        placeholder: kTransparentImage,
                                                        image: getOptimizeImageURL(modifyTeam.profileImgList[index].imgUrl, 0),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : SizedBox.shrink(),
                                          Container(
                                            //프로필 위 아래 그라데이션
                                            width: 360 * sizeUnit,
                                            height: 360 * sizeUnit,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Color.fromRGBO(0, 0, 0, 0.2),
                                                  Color.fromRGBO(0, 0, 0, 0.08),
                                                  Color.fromRGBO(0, 0, 0, 0),
                                                  Color.fromRGBO(0, 0, 0, 0),
                                                  Color.fromRGBO(0, 0, 0, 0),
                                                  Color.fromRGBO(0, 0, 0, 0),
                                                  Color.fromRGBO(0, 0, 0, 0),
                                                  Color.fromRGBO(0, 0, 0, 0),
                                                  Color.fromRGBO(0, 0, 0, 0),
                                                  Color.fromRGBO(0, 0, 0, 0),
                                                  Color.fromRGBO(0, 0, 0, 0),
                                                  Color.fromRGBO(0, 0, 0, 0),
                                                  Color.fromRGBO(0, 0, 0, 0),
                                                  Color.fromRGBO(0, 0, 0, 0.03),
                                                  Color.fromRGBO(0, 0, 0, 0.08)
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      left: 12 * sizeUnit,
                                      bottom: 12 * sizeUnit,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(
                                          modifyTeam.profileImgList.length,
                                          (index) => buildDot(index: index),
                                        ),
                                      ),
                                    ),
                                    modifyTeam.badge1 != 0
                                        ? Positioned(
                                            right: 12 * sizeUnit,
                                            bottom: 12 * sizeUnit,
                                            child: GestureDetector(
                                              onTap: () {
                                                showTeamBadgeDialog(badgeID: modifyTeam.badge1);
                                              },
                                              child: Container(
                                                width: 48 * sizeUnit,
                                                height: 48 * sizeUnit,
                                                child: ClipRRect(
                                                  borderRadius: new BorderRadius.circular(8 * sizeUnit),
                                                  child: FittedBox(
                                                    child: SvgPicture.asset(
                                                      ReturnTeamBadgeSVG(modifyTeam.badge1),
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    modifyTeam.badge2 != 0
                                        ? Positioned(
                                            right: 60 * sizeUnit,
                                            bottom: 12 * sizeUnit,
                                            child: GestureDetector(
                                              onTap: () {
                                                showTeamBadgeDialog(badgeID: modifyTeam.badge2);
                                              },
                                              child: Container(
                                                width: 48 * sizeUnit,
                                                height: 48 * sizeUnit,
                                                child: ClipRRect(
                                                  borderRadius: new BorderRadius.circular(8 * sizeUnit),
                                                  child: FittedBox(
                                                    child: SvgPicture.asset(
                                                      ReturnTeamBadgeSVG(modifyTeam.badge2),
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    modifyTeam.badge3 != 0
                                        ? Positioned(
                                            right: 108 * sizeUnit,
                                            bottom: 12 * sizeUnit,
                                            child: GestureDetector(
                                              onTap: () {
                                                showTeamBadgeDialog(badgeID: modifyTeam.badge3);
                                              },
                                              child: Container(
                                                width: 48 * sizeUnit,
                                                height: 48 * sizeUnit,
                                                child: ClipRRect(
                                                  borderRadius: new BorderRadius.circular(8 * sizeUnit),
                                                  child: FittedBox(
                                                    child: SvgPicture.asset(
                                                      ReturnTeamBadgeSVG(modifyTeam.badge3),
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
                                        modifyTeam.name,
                                        style: SheepsTextStyle.h1().copyWith(fontSize: 24 * sizeUnit),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Spacer(),
                                      if (!isShrink) ...[
                                        //공유
                                        GestureDetector(
                                          onTap: () {
                                            if(isReady){
                                              isReady = false;
                                              Future.delayed(Duration(milliseconds: 800), () => isReady = true);
                                              shareTeamProfile();
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
                                        ), //
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
                                            profileBigWrapItem(modifyTeam.category),
                                            profileBigWrapItem(modifyTeam.part),
                                            profileBigWrapItem(modifyTeam.location + " " + (modifyTeam.subLocation == null ? '' : modifyTeam.subLocation)),
                                          ],
                                        ),
                                        SizedBox(height: 12 * sizeUnit),
                                        Text(
                                          modifyTeam.information,
                                          style: SheepsTextStyle.b3(),
                                        ),
                                        SizedBox(height: 16 * sizeUnit),
                                        profileAuthWidget(
                                          title: '인증',
                                          description: '인증을 추가해 보세요',
                                          list: controller.teamAuthList,
                                        ),
                                        profileAuthWidget(
                                          title: '수행 내역',
                                          description: '수행 내역을 추가해 보세요',
                                          list: controller.teamPerformList,
                                        ),
                                        profileAuthWidget(
                                          title: '수상 이력',
                                          description: '수상 이력을 추가해 보세요',
                                          list: controller.teamWinList,
                                        ),
                                        if (controller.showTeamUrl) ...[
                                          Text(
                                            '팀 정보 링크',
                                            style: SheepsTextStyle.h3(),
                                          ),
                                          SizedBox(height: 12 * sizeUnit),
                                          Wrap(
                                            spacing: 12 * sizeUnit,
                                            runSpacing: 8 * sizeUnit,
                                            children: [
                                              if (modifyTeam.teamLink.siteUrl.isNotEmpty) linkItem(title: 'Site', linkUrl: modifyTeam.teamLink.siteUrl),
                                              if (modifyTeam.teamLink.recruitUrl.isNotEmpty) linkItem(title: '채용페이지', linkUrl: modifyTeam.teamLink.recruitUrl),
                                              if (modifyTeam.teamLink.instagramUrl.isNotEmpty) linkItem(title: 'Instagram', linkUrl: modifyTeam.teamLink.instagramUrl, color: Color(0xFFDF3666)),
                                              if (modifyTeam.teamLink.facebookUrl.isNotEmpty) linkItem(title: 'Facebook', linkUrl: modifyTeam.teamLink.facebookUrl, color: Color(0xFF006AEA)),
                                            ],
                                          ),
                                        ] else ...[
                                          if (modifyTeam.leaderID == GlobalProfile.loggedInUser!.userID) ...[
                                            Text(
                                              '팀 정보 링크',
                                              style: SheepsTextStyle.h3(),
                                            ),
                                            SizedBox(height: 8 * sizeUnit),
                                            Row(
                                              children: [
                                                Text('・ ', style: SheepsTextStyle.b3()),
                                                Text('팀 정보 링크를 추가해 보세요', style: SheepsTextStyle.error()),
                                              ],
                                            ),
                                          ]
                                        ],
                                        SizedBox(height: 32 * sizeUnit),
                                        AnimatedOpacity(
                                          opacity: teamMemberLoading ? 0 : 1,
                                          duration: Duration(milliseconds: 300),
                                          child: Row(
                                            children: [
                                              Text(
                                                '팀원 정보(총 ${totalList.length}명)',
                                                style: SheepsTextStyle.h3().copyWith(height: 1.35),
                                              ),
                                              SizedBox(width: 16 * sizeUnit),
                                              if (controller.isTeamMember) ...[
                                                myTeamButton(
                                                  press: () => showSheepsCustomDialog(
                                                    title: Text(
                                                      '소속 팀을\n나가시겠어요?',
                                                      style: SheepsTextStyle.h5(),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    contents: Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(text: '현재 소속 된 팀을 나가실 경우\n'),
                                                          TextSpan(
                                                            text: '팀 채팅방',
                                                            style: SheepsTextStyle.b3().copyWith(fontWeight: FontWeight.bold),
                                                          ),
                                                          TextSpan(text: '도 함께 삭제 됩니다.'),
                                                        ],
                                                      ),
                                                      style: SheepsTextStyle.b3(),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    okText: '나가기',
                                                    okButtonColor: sheepsColorBlue,
                                                    okFunc: () async {
                                                      var roomName = getRoomName(modifyTeam.id, modifyTeam.leaderID, roomType: ROOM_TYPE_TEAM);

                                                      await ApiProvider().post(
                                                          '/Team/Leave',
                                                          jsonEncode({
                                                            "userID": GlobalProfile.loggedInUser!.userID,
                                                            "targetID": modifyTeam.leaderID,
                                                            "teamID": modifyTeam.id,
                                                            "userName": GlobalProfile.loggedInUser!.name,
                                                            "roomName": roomName
                                                          }));

                                                      //채팅방 삭제
                                                      if(widget.byChat){
                                                        ChatGlobal.kickOutTeamMemberInRoom(roomName, GlobalProfile.loggedInUser!.userID);
                                                      }else{
                                                        ChatGlobal.roomInfoList.removeWhere((element) => element.roomName == roomName);
                                                      }


                                                      //팀원 목록에서 삭제
                                                      totalList.removeWhere((element) => element == GlobalProfile.loggedInUser!.userID);
                                                      modifyTeam.userList.removeWhere((element) => element == GlobalProfile.loggedInUser!.userID);

                                                      //전역 팀에서 팀원 목록 삭제
                                                      GlobalProfile().removeTeamMember(modifyTeam.id, GlobalProfile.loggedInUser!.userID);

                                                      //나가기 버튼 삭제
                                                      controller.isTeamMember = false;
                                                      modifyTeam.isTeamMemberChange = true;

                                                      modifyTeamInMyTeamProfile = modifyTeam;//상세팀프로필에서 사용하는 팀 객체 수정

                                                      Get.back(); //다이얼로그 닫기

                                                      setState(() {});
                                                    },
                                                    isCancelButton: true,
                                                  ),
                                                  text: '나가기',
                                                ),
                                              ],
                                              if (GlobalProfile.loggedInUser!.userID == modifyTeam.leaderID) ...[
                                                myTeamButton(
                                                  press: () {
                                                    Get.to(() => TeamMemberManagementPage(team: modifyTeam, teamMemberList: totalList, byChat: widget.byChat,))?.then((value){
                                                      modifyTeamInMyTeamProfile = modifyTeam;//상세팀프로필에서 사용하는 팀 객체 수정
                                                    });
                                                  },
                                                  text: '관리하기',
                                                ),
                                              ]
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 8 * sizeUnit),
                                      ],
                                    ),
                                  ),
                                  buildTeamMemberInfoProfiles(), // 팀원 정보
                                  SizedBox(height: 95 * sizeUnit),
                                  if (!totalList.contains(GlobalProfile.loggedInUser!.userID)) SizedBox(height: 70 * sizeUnit), // 최근 활동 시간 뜰 때
                                ],
                              ),
                            ),
                          ]),
                        ),
                      ],
                    ),
                    bottomOpacity(context),
                    // 내가 속한 팀이 아닐 때
                    if (!totalList.contains(GlobalProfile.loggedInUser!.userID)) lastAccessTime(), // 최근 활동시간
                    if( widget.proposedTeam ) ... [
                      if( recruitInviteController.getCurrRecruitInvite.response == 2 ) ... [
                        responseDoneButton()
                      ] else ... [
                        proposedTeamBottomButtons()
                      ]
                    ] else if(showBottomButton) ... [
                      BottomButtons(context, _socket)
                    ] else ... [
                      Container()
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
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
              )
          ),
        ),
      ),
    );
  }

  Widget myTeamButton({required Function press, required String text}) {
    return GestureDetector(
      onTap: () => press(),
      child: Container(
        height: 20 * sizeUnit,
        padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit),
        decoration: BoxDecoration(
          color: sheepsColorGreen,
          borderRadius: BorderRadius.circular(16 * sizeUnit),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, style: SheepsTextStyle.bProfile()),
          ],
        ),
      ),
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
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('최근 활동 시간', style: SheepsTextStyle.b3()),
                  Text(timeCheck(GlobalProfile.getUserByUserID(modifyTeam.leaderID).updatedAt), style: SheepsTextStyle.b3().copyWith(color: sheepsColorGreen)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column profileAuthWidget({required String title, required String description, required List list}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // MyProfile 이면 텍스트 무조건 나오기
        if (modifyTeam.leaderID == GlobalProfile.loggedInUser!.userID) ...[
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
          // MyProfile 아니면 빈 값이 아닐 때 텍스트 나오기
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
              child: authItem(list[index].contents, list[index].auth),
            );
          },
        ),
        if (modifyTeam.leaderID == GlobalProfile.loggedInUser!.userID || list.isNotEmpty) SizedBox(height: 16 * sizeUnit),
      ],
    );
  }

  Widget buildTeamMemberInfoProfiles() {
    return AnimatedOpacity(
      opacity: teamMemberLoading ? 0 : 1,
      duration: Duration(milliseconds: 300),
      child: Container(
        padding: EdgeInsets.only(left: 16 * sizeUnit),
        height: 190 * sizeUnit,
        color: Colors.white,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            cacheExtent: 30,
            reverse: false,
            shrinkWrap: true,
            itemCount: totalList.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (totalList[index] == GlobalProfile.loggedInUser!.userID) {
                          Get.to(()=>DetailProfile(index: 0, user: GlobalProfile.loggedInUser!, profileStatus: PROFILE_STATUS.MyProfile));
                        } else {
                          Get.to(()=>DetailProfile(index: 0, user: GlobalProfile.getUserByUserID(totalList[index])));
                        }
                      },
                      child: Stack(
                        children: [
                          if (GlobalProfile.getUserByUserID(totalList[index]).profileImgList[0].imgUrl == 'BasicImage') ...[
                            Container(
                              width: 132 * sizeUnit,
                              height: 132 * sizeUnit,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24 * sizeUnit),
                                border: Border.all(width: 0.5 * sizeUnit, color: sheepsColorGrey),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  svgSheepsBasicProfileImage,
                                  height: 63 * sizeUnit,
                                  color: sheepsColorBlue,
                                ),
                              ),
                            )
                          ] else ...[
                            Container(
                              width: 132 * sizeUnit,
                              height: 132 * sizeUnit,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(166, 125, 130, 0.2),
                                    blurRadius: 4,
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24 * sizeUnit),
                                child: FittedBox(
                                  child: getExtendedImage(GlobalProfile.getUserByUserID(totalList[index]).profileImgList[0].imgUrl, 60, extendedController),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                          if (index == 0) ...[
                            Positioned(
                              top: 7 * sizeUnit,
                              left: 8 * sizeUnit,
                              child: Container(
                                padding: EdgeInsets.all(4.5 * sizeUnit),
                                height: 20 * sizeUnit,
                                width: 20 * sizeUnit,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: sheepsColorGreen,
                                ),
                                child: SvgPicture.asset(svgCircleLeaderIcon),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 6 * sizeUnit),
                    Text(
                      GlobalProfile.getUserByUserID(totalList[index]).name,
                      style: SheepsTextStyle.h4(),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4 * sizeUnit),
                    Wrap(
                      spacing: 6 * sizeUnit,
                      runSpacing: 6 * sizeUnit,
                      children: [
                        if (GlobalProfile.getUserByUserID(totalList[index]).part != null && GlobalProfile.getUserByUserID(totalList[index]).part.isNotEmpty)
                          profileSmallWrapItem(GlobalProfile.getUserByUserID(totalList[index]).part),
                        if (GlobalProfile.getUserByUserID(totalList[index]).location != null && GlobalProfile.getUserByUserID(totalList[index]).location.isNotEmpty)
                          profileSmallWrapItem(GlobalProfile.getUserByUserID(totalList[index]).location),
                      ],
                    )
                  ],
                ),
              );
            }),
      ),
    );
  }

  Positioned proposedTeamBottomButtons() {
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
                  GestureDetector(
                    onTap: () {
                      Function func = () {
                        RecruitInviteController recruitInviteController = Get.put(RecruitInviteController());

                        ApiProvider().post(
                            '/Matching/Response/PersonalSeekTeam',
                            jsonEncode({
                              "to": GlobalProfile.loggedInUser!.userID,
                              "from": widget.team.leaderID,
                              "tableIndex": recruitInviteController.getCurrRecruitInvite.id,
                              "targetIndex": recruitInviteController.getCurrRecruitInvite.index,
                              "teamIndex": widget.team.id,
                              "response": INVITE_REFUSE,
                            }));

                        //dialog pop
                        Get.back();
                        //detail profile pop
                        Get.back();

                        recruitInviteController.removeRecruitInviteCurr(recruitInviteController.getCurrRecruitInvite.id);
                        setState(() {});
                      };

                      showSheepsCustomDialog(
                          title: Text(
                            "제안을\n거절 할까요?",
                            style: SheepsTextStyle.dialogTitle().copyWith(height: 1.2, fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                          contents: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
                              children: [
                                TextSpan(text: '제안 팀에게 거절 알림이 가고,\n'),
                                TextSpan(text: '제안한 팀 리스트에서 삭제됩니다.'),
                              ],
                            ),
                          ),
                          okButtonColor: sheepsColorGreen,
                          okFunc: func);
                    },
                    child: Container(
                      width: 160 * sizeUnit,
                      height: 54 * sizeUnit,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12 * sizeUnit),
                        color: sheepsColorRed,
                      ),
                      child: Center(
                        child: Text(
                          '제안 거절',
                          style: SheepsTextStyle.button1(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8 * sizeUnit),
                  GestureDetector(
                    onTap: () {
                      RecruitInvite currRecruitInvite = recruitInviteController.getCurrRecruitInvite;

                      if (recruitInviteController.getCurrRecruitInvite.response == 0) {
                        Function func = () async {
                          String roomName = getRoomName(recruitInviteController.getCurrRecruitInvite.index, recruitInviteController.getCurrRecruitInvite.inviteID, ID3: currRecruitInvite.id, roomType: ROOM_TYPE_PERSONAL_SEEK_TEAM);

                          ApiProvider().post(
                              '/Matching/Response/PersonalSeekTeam',
                              jsonEncode({
                                "to": GlobalProfile.loggedInUser!.userID,
                                "from": widget.team.leaderID,
                                "tableIndex": currRecruitInvite.id,
                                "targetIndex": currRecruitInvite.index,
                                "teamIndex": widget.team.id,
                                "roomName": roomName,
                                "response": INVITE_ACCEPT,
                              }));

                          NotificationModel notificationmodel = NotificationModel();

                          notificationmodel.from = widget.team.leaderID;
                          notificationmodel.to = GlobalProfile.loggedInUser!.userID;
                          notificationmodel.targetIndex = recruitInviteController.getCurrRecruitInvite.index;
                          notificationmodel.type = ROOM_TYPE_TEAM_MEMBER_RECRUIT;
                          notificationmodel.time = DateTime.now().toString();
                          notificationmodel.teamRoomName = roomName;
                          notificationmodel.teamIndex = widget.team.id;

                          RoomInfo room = await SetRoomInfoData(notificationmodel, roomType: ROOM_TYPE_PERSONAL_SEEK_TEAM);
                          if (false == ChatGlobal.IsAlreadyRoom(room)) {
                            ChatGlobal.roomInfoList.insert(0, room);
                          }

                          //dialog pop
                          Get.back();
                          //detail profile pop
                          Get.back();

                          currRecruitInvite.response = 1;
                          recruitInviteController.responseRecruitInviteCurr(currRecruitInvite.id, currRecruitInvite);
                          setState(() {});
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
                            okButtonColor: sheepsColorGreen,
                            okFunc: func);
                      } else {
                        //팀 제안 수락
                        Function func = () async {
                          String roomName = getRoomName(widget.team.id, widget.team.leaderID, roomType: ROOM_TYPE_TEAM);

                          ApiProvider().post(
                              '/Team/Pass/Interview',
                              jsonEncode({
                                "to": GlobalProfile.loggedInUser!.userID,
                                "from": widget.team.leaderID,
                                "tableIndex": currRecruitInvite.id,
                                "targetIndex": currRecruitInvite.index,
                                "teamIndex": widget.team.id,
                                "roomName": roomName,
                                "response": INVITE_ACCEPT,
                                "isRecruit": false
                              }));

                          //이미 채팅방이 있으면 그거가 에러
                          if(false == ChatGlobal.IsAlreadyRoomByRoomName(roomName)){
                            //채팅방 생성
                            NotificationModel notificationmodel = NotificationModel();

                            notificationmodel.from = widget.team.leaderID;
                            notificationmodel.to = GlobalProfile.loggedInUser!.userID;
                            notificationmodel.targetIndex = currRecruitInvite.index;
                            notificationmodel.type = ROOM_TYPE_TEAM;
                            notificationmodel.time = DateTime.now().toString();
                            notificationmodel.teamRoomName = roomName;

                            RoomInfo room = await SetRoomInfoData(notificationmodel, roomType: ROOM_TYPE_TEAM);

                            //채팅방 인원 등록
                            for (int i = 0; i < widget.team.userList.length; ++i) {
                              room.chatUserIDList.add(widget.team.userList[i]);
                            }

                            ChatGlobal.roomInfoList.insert(0, room);

                            //팀 전역에 나를 등록
                            GlobalProfile.teamProfile.forEach((element) {
                              if(element.id == widget.team.id){
                                element.userList.add(GlobalProfile.loggedInUser!.userID);
                              }
                            });
                          }else{
                            debugPrint('Already Have Chat Room');
                          }

                          //dialog pop
                          Get.back();

                          currRecruitInvite.response = 2;
                          recruitInviteController.responseRecruitInviteCurr(currRecruitInvite.id, currRecruitInvite);
                          setState(() {});
                        };

                        showSheepsCustomDialog(
                            title: Text(
                              "제안을 수락할까요?",
                              style: SheepsTextStyle.dialogTitle().copyWith(height: 1.2, fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                            contents: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
                                children: [
                                  TextSpan(text: '제안 팀에게 수락 알림이 가고,\n'),
                                  TextSpan(text: '팀원으로 자동 등록됩니다!'),
                                ],
                              ),
                            ),
                            okButtonColor: sheepsColorGreen,
                            okFunc: func);
                      }
                    },
                    child: Container(
                      width: 160 * sizeUnit,
                      height: 54 * sizeUnit,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12 * sizeUnit),
                        color: recruitInviteController.currRecruitInvite.response == 0 ? sheepsColorBlue : sheepsColorGreen,
                      ),
                      child: Center(
                        child: Text(
                          recruitInviteController.currRecruitInvite.response == 0 ? '면접 시작' :  "제안 수락" ,
                          style: SheepsTextStyle.button1(),
                        ),
                      ),
                    ),
                  )
                ],
              )),
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
              child: GestureDetector(
                onTap: () async {
                  DialogBuilder(context).showLoadingIndicator();

                  List<TeamMemberRecruit> recruitList = [];

                  var res = await ApiProvider().post(
                      '/Matching/Select/TeamMemberRecruitByTeamID',
                      jsonEncode({
                        'teamID': modifyTeam.id,
                      }));

                  if (res != null) {
                    for (int i = 0; i < res.length; i++) {
                      TeamMemberRecruit tmpRecruit = TeamMemberRecruit.fromJson(res[i]);
                      recruitList.add(tmpRecruit);
                      GlobalProfile.getFutureTeamByID(tmpRecruit.teamId);
                    }
                  }

                  DialogBuilder(context).hideOpenDialog();

                  Get.to(
                    () => SpecificUserRecruitPage(
                      isRecruit: true,
                      myRecruitList: recruitList,
                      appBarTitle: '모집공고 리스트',
                    ),
                  );
                },
                child: Container(
                  width: 328 * sizeUnit,
                  height: 54 * sizeUnit,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12 * sizeUnit),
                    color: sheepsColorGreen,
                  ),
                  child: Text(
                    '모집공고 보기',
                    style: SheepsTextStyle.button1(),
                  ),
                ),
              )),
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
        height: 120 * sizeUnit,
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
    ModelLikes? modelLikes;
    globalTeamLikeList.forEach((element) {
      if (element.TargetID == widget.team.id) modelLikes = element;
    });

    return GestureDetector(
      onTap: () async {
        if (modifyTeam.leaderID == GlobalProfile.loggedInUser!.userID) {
          Get.to(() => TeamProfileManagementPage(team: modifyTeam))?.then((value) {
            if (value != null) {
              setState(() {
                modifyTeam = value[0];
                modifyTeamInMyTeamProfile = modifyTeam;//상세팀프로필에서 사용하는 팀 객체 수정
                controller.teamProfileDataSet(modifyTeam);
              });
            }
          });
        } else {
          if (isCanTapLike) {
            isCanTapLike = false;

            var res = await ApiProvider().post(
                '/Team/InsertLike',
                jsonEncode({
                  "userID": GlobalProfile.loggedInUser!.userID,
                  "targetID": widget.team.id,
                }));

            if (res['created']) {
              modelLikes = ModelLikes.fromJson(res['item']);

              globalTeamLikeList.add(modelLikes!);
            } else {
              globalTeamLikeList.removeWhere((element) => element.TargetID == widget.team.id);
            }

            setState(() {
              Future.delayed(Duration(milliseconds: tapLikeDelayMilliseconds), () {
                isCanTapLike = true;
              });
            });
          }
        }
      },
      child: modifyTeam.leaderID == GlobalProfile.loggedInUser!.userID
          ? SvgPicture.asset(
              svgSetting,
              color: sheepsColorDarkGrey,
              width: 28 * sizeUnit,
              height: 28 * sizeUnit,
            )
          : SvgPicture.asset(
              modelLikes == null ? svgBookMarkIcon : svgFillBookMarkIcon,
              color: modelLikes == null ? null : sheepsColorBlue,
              width: 28 * sizeUnit,
              height: 28 * sizeUnit,
            ),
    );
  }

  void shareTeamProfile() async {
    DialogBuilder(context).showLoadingIndicator();
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://sheepsapp.page.link',
        link: Uri.parse('https://sheepsapp.page.link/profile_team?id=${modifyTeam.id}'),
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

    String name = modifyTeam.name;

    DialogBuilder(context).hideOpenDialog();
    Share.share('$name 팀 프로필 보기\n$shortUrl', subject: '스타트업 필수 앱! 쉽스!\n');
  }
}
