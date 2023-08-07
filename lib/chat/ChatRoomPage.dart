import 'dart:convert';

import 'package:badges/badges.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sheeps_app/Recruit/Models/PersonalSeekTeams.dart';
import 'package:sheeps_app/Recruit/Models/TeamMemberRecruit.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/chat/ChatRoomSearchPage.dart';
import 'package:sheeps_app/chat/models/ChatRoomState.dart';
import 'package:sheeps_app/chat/models/Room.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/NavigationNum.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/profile/DetailTeamProfile.dart';
import 'package:sheeps_app/userdata/User.dart';
import '../notification/models/LocalNotification.dart';
import 'package:sheeps_app/profile/DetailProfile.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/chat/ChatPage.dart';
import './models/ChatGlobal.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/dashboard/MyPage.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/LoadingUI.dart';

class ChatRoomPage extends StatefulWidget {
  @override
  _ChatRoomPageState createState() => new _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> with SingleTickerProviderStateMixin {
  ChatGlobal _chatGlobal;
  final NavigationNum navigationNum = Get.put(NavigationNum());
  String teamIconName = "assets/images/Chat/teamIcon.svg";

  AnimationController extendedController;
  LocalNotification _localNotification;
  SocketProvider _socket;

  int barIndex = 0;
  ChatRoomState chatRoomState;
  PageController pageController;

  String get svgGreyMyPageButton => 'assets/images/Public/GreyMyPageButton.svg';

  bool isReady = true;

  @override
  void initState() {
    super.initState();
    _chatGlobal = Get.put(ChatGlobal());
    chatRoomState = Get.put(ChatRoomState());
    extendedController = AnimationController(vsync: this, duration: const Duration(seconds: 1), lowerBound: 0.0, upperBound: 1.0);
    pageController = PageController(initialPage: chatRoomState.getState);
    initShared();
  }

  Future initShared() async {
    setState(() {});
    return true;
  }

  int getDigit(int num) {
    int i = 1;
    int cnt = 0;

    while (num >= i) {
      i *= 10;
      cnt++;
    }

    return cnt;
  }

  @override
  void dispose() {
    _socket.setRoomStatus(ROOM_STATUS_ETC);
    extendedController.dispose();
    pageController.dispose();
    super.dispose();
  }

  _chatBubble(int messageCount) {

    String messageCountText = messageCount.toString();
    if (messageCount >= 100) messageCountText = "99+";

    if (messageCount == 0) return Container();

    return Container(
      constraints: BoxConstraints(minWidth: 16 * sizeUnit),
      decoration: BoxDecoration(
        color: sheepsColorRed,
        borderRadius: BorderRadius.circular(8*sizeUnit),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric( vertical: 1*sizeUnit),
            child: Text(
              messageCountText,
              style: SheepsTextStyle.bProfile(),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    if (null == _localNotification) _localNotification = LocalNotification();

    if (null == _socket) {
      _socket = SocketProvider.to;
      _socket.setRoomStatus(ROOM_STATUS_ROOM);
    }

    if (barIndex != chatRoomState.getState) {
      barIndex = chatRoomState.getState;
    }

    return WillPopScope(
      onWillPop: () {
        _socket.setRoomStatus(ROOM_STATUS_ETC);
        Get.back();
        return;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Scaffold(
                  body: Column(
                children: [
                  chatRoomPageTopBar(context, chatRoomState),
                  Expanded(
                    child: PageView(
                      controller: pageController,
                      onPageChanged: (index) {
                        barIndex = index;
                        chatRoomState.setState(index);
                        switch (chatRoomState.getState) {
                          case ChatRoomState.PERSON_AND_TEAM:
                            {
                              setState(() {
                                if (chatRoomState.getState != ChatRoomState.PERSON_AND_TEAM) {
                                  chatRoomState.setState(ChatRoomState.PERSON_AND_TEAM);
                                }
                              });
                            }
                            break;
                          case ChatRoomState.INTERVIEW:
                            {
                              setState(() {
                                if (chatRoomState.getState != ChatRoomState.INTERVIEW) {
                                  chatRoomState.setState(ChatRoomState.INTERVIEW);
                                }
                              });
                            }
                            break;
                          case ChatRoomState.EXPERT:
                            {
                              setState(() {
                                if (chatRoomState.getState != ChatRoomState.EXPERT) {
                                  chatRoomState.setState(ChatRoomState.EXPERT);
                                }
                              });
                            }
                            break;
                        }
                      },
                      children: [
                        Obx(() => divideRoomList(_chatGlobal.getRoomInfoList.where((element) => (element.type == ROOM_TYPE_PERSONAL) || (element.type == ROOM_TYPE_TEAM) ).toList(), (RoomInfo room) async {
                              bool isPersonal = room.isPersonal;

                              if (isPersonal) {
                                UserData alreadyUser = GlobalProfile.getUserByUserID(room.chatUserIDList[0]);

                                var user = await ApiProvider().post('/Personal/Select/ModifyUser', jsonEncode({"userID": room.chatUserIDList[0], "updatedAt": alreadyUser.updatedAt}));

                                if (user != null) {
                                  //개인 프로필 바뀐 데이터로 전역 데이터 세팅
                                  GlobalProfile.setModifyPersonalProfile(UserData.fromJson(user));
                                }

                                Get.to(() => DetailProfile(index: 0, user: GlobalProfile.getUserByUserID(room.chatUserIDList[0]))).then((value) {
                                  setState(() {
                                    _chatGlobal.sortLocalRoomInfoList();
                                  });
                                });
                              } else {
                                Team t = GlobalProfile.getTeamByRoomName(room.roomName);

                                var team = await ApiProvider().post('/Team/Profile/SelectID', jsonEncode({"id": t.id, "updatedAt": t.updatedAt}));

                                if (team != null) {
                                  Team resTeam = Team.fromJson(team);

                                  GlobalProfile.setModifyTeamProfile(resTeam);
                                }

                                Get.to(() => DetailTeamProfile(index: 0, team: GlobalProfile.getTeamByRoomName(room.roomName))).then((value) {
                                  setState(() {
                                    _chatGlobal.sortLocalRoomInfoList();
                                  });
                                });
                              }

                              return Future.value(null);
                            }, (RoomInfo room) async {
                              _socket.setRoomStatus(ROOM_STATUS_CHAT);
                              bool isChange = false;

                              DialogBuilder(context).showLoadingIndicator();

                              for (int i = 0; i < room.chatUserIDList.length; ++i) {
                                UserData alreadyUser = await GlobalProfile.getFutureUserByUserID(room.chatUserIDList[i]);

                                var user = await ApiProvider().post('/Personal/Select/ModifyUser', jsonEncode({"userID": room.chatUserIDList[i], "updatedAt": alreadyUser.updatedAt}));

                                if (user != null) {
                                  //개인 프로필 바뀐 데이터로 전역 데이터 세팅
                                  GlobalProfile.setModifyPersonalProfile(UserData.fromJson(user));

                                  if (i == 0) {
                                    isChange = true;
                                  }
                                }
                              }

                              int leaderID = -1;
                              int targetID = -1;

                              if (room.isPersonal) {
                                //개인 프로필 방 바뀐 사진이미지로 채팅방 세팅

                                UserData u = GlobalProfile.getUserByUserID(room.chatUserIDList[0]);
                                if (isChange) {
                                  room.profileImage = u.profileImgList[0].imgUrl;
                                  room.name = u.name;
                                }
                                targetID = u.userID;
                              } else {
                                //팀 채팅 처리
                                Team t = GlobalProfile.getTeamByRoomName(room.roomName);

                                var team = await ApiProvider().post('/Team/Profile/SelectID', jsonEncode({"id": t.id, "updatedAt": t.updatedAt}));

                                if (team != null) {
                                  Team resTeam = Team.fromJson(team);

                                  GlobalProfile.setModifyTeamProfile(resTeam);

                                  room.profileImage = resTeam.profileImgList[0].imgUrl;
                                  room.name = resTeam.name;
                                  leaderID = resTeam.leaderID;
                                  targetID = t.id;
                                }
                              }

                              DialogBuilder(context).hideOpenDialog();

                              Get.to(() => ChatPage(
                                roomName: room.roomName,
                                titleName: room.name,
                                chatUserList: GlobalProfile.getUserListByUserIDList(room.chatUserIDList),
                                targetID: targetID,
                                leaderID: leaderID,
                              )).then((value) {
                                setState(() {
                                  ChatGlobal.sortRoomInfoList();
                                  ChatGlobal.currentRoomIndex = -1;
                                  ChatGlobal.removeUserList.clear();
                                  navigationNum.setNum(CHATROOM_PAGE);

                                  if(ChatGlobal.willRemoveRoom != null) {
                                    ChatGlobal.roomInfoList.remove(ChatGlobal.willRemoveRoom);
                                    ChatGlobal.willRemoveRoom = null;
                                  }
                                  _socket.setRoomStatus(ROOM_STATUS_ROOM);
                                });
                              });

                              return Future.value(null);
                            })),
                        Obx(
                          () => divideRoomList(_chatGlobal.getRoomInfoList.where((element) => (element.type == ROOM_TYPE_PERSONAL_SEEK_TEAM) || (element.type == ROOM_TYPE_TEAM_MEMBER_RECRUIT) ).toList(), (RoomInfo room) async {
                            UserData alreadyUser = GlobalProfile.getUserByUserID(room.chatUserIDList[0]);

                            var user = await ApiProvider().post('/Personal/Select/ModifyUser', jsonEncode({"userID": room.chatUserIDList[0], "updatedAt": alreadyUser.updatedAt}));

                            if (user != null) {
                              //개인 프로필 바뀐 데이터로 전역 데이터 세팅
                              GlobalProfile.setModifyPersonalProfile(UserData.fromJson(user));
                            }

                            Navigator.push(
                                context, // 기본 파라미터, SecondRoute로 전달
                                CupertinoPageRoute(builder: (context) => DetailProfile(index: 0, user: GlobalProfile.getUserByUserID(room.chatUserIDList[0])))).then((value) {
                              setState(() {
                                _chatGlobal.sortLocalRoomInfoList();
                              });
                            });

                            return Future.value(null);
                          }, (RoomInfo room) async {
                            _socket.setRoomStatus(ROOM_STATUS_CHAT);
                            bool isChange = false;

                            DialogBuilder(context).showLoadingIndicator();

                            for (int i = 0; i < room.chatUserIDList.length; ++i) {
                              UserData alreadyUser = await GlobalProfile.getFutureUserByUserID(room.chatUserIDList[i]);

                              var user = await ApiProvider().post('/Personal/Select/ModifyUser', jsonEncode({"userID": room.chatUserIDList[i], "updatedAt": alreadyUser.updatedAt}));

                              if (user != null) {
                                //개인 프로필 바뀐 데이터로 전역 데이터 세팅
                                GlobalProfile.setModifyPersonalProfile(UserData.fromJson(user));

                                if (i == 0) {
                                  isChange = true;
                                }
                              }
                            }

                            int leaderID = -1;
                            int targetID = -1;
                            if(room.chatUserIDList.length > 0){
                              UserData u = GlobalProfile.getUserByUserID(room.chatUserIDList[0]);
                              if (isChange) {
                                room.profileImage = u.profileImgList[0].imgUrl;
                                room.name = u.name;
                              }
                              targetID = u.userID;
                            }

                            if(room.type == ROOM_TYPE_PERSONAL_SEEK_TEAM){
                              int firstIndex = "personalID".length;
                              int lastIndex = room.roomName.lastIndexOf('userID');

                              String sub = room.roomName.substring(firstIndex,lastIndex);

                              PersonalSeekTeam personalSeekTeam = await getFuturePersonalSeekTeam(int.parse(sub));
                              await GlobalProfile.getFutureUserByUserID(personalSeekTeam.userId);
                            }else{
                              int firstIndex = "teamMemberID".length;
                              int lastIndex = room.roomName.lastIndexOf('userID');

                              String sub = room.roomName.substring(firstIndex,lastIndex);

                              TeamMemberRecruit teamMemberRecruit = await getFutureTeamMemberRecruit(int.parse(sub));
                              await GlobalProfile.getFutureTeamByID(teamMemberRecruit.teamId);
                            }

                            DialogBuilder(context).hideOpenDialog();

                            Get.to(() => ChatPage(
                              roomName: room.roomName,
                              titleName: room.name,
                              chatUserList: GlobalProfile.getUserListByUserIDList(room.chatUserIDList),
                              targetID: targetID,
                              leaderID: leaderID,
                            )).then((value) {
                              setState(() {
                                ChatGlobal.sortRoomInfoList();
                                ChatGlobal.currentRoomIndex = -1;
                                ChatGlobal.removeUserList.clear();
                                navigationNum.setNum(CHATROOM_PAGE);

                                if(ChatGlobal.willRemoveRoom != null) {
                                  ChatGlobal.roomInfoList.remove(ChatGlobal.willRemoveRoom);
                                  ChatGlobal.willRemoveRoom = null;
                                }

                                _socket.setRoomStatus(ROOM_STATUS_ROOM);
                              });
                            });

                            return Future.value(null);
                          })),
                        noSearchResultsPage('전문가 서비스는 개발 중입니다.\n추후 업데이트를 기다려 주세요!') //전문가
                      ],
                    ),
                  ),
                ],
              )),
            ),
          ),
        ),
      ),
    );
  }

  Widget chatRoomPageTopBar(BuildContext context, ChatRoomState chatRoomState) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          width: double.infinity,
          height: 44 * sizeUnit,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16 * sizeUnit),
                child: Text('채팅', style: SheepsTextStyle.h2()),
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  //채팅방 검색 페이지 열기
                  Get.to(() => ChatRoomSearchPage());
                },
                child: SvgPicture.asset(
                  svgGreyMagnifyingGlass,
                  color: sheepsColorDarkGrey,
                  width: 28 * sizeUnit,
                  height: 28 * sizeUnit,
                ),
              ),
              SizedBox(
                width: 12 * sizeUnit,
              ),
              GestureDetector(
                onTap: () {
                  Get.to(() => MyPage()).then((value) {
                    setState(() {

                    });
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
        ),
        Padding(
          padding: EdgeInsets.only(left: 16 * sizeUnit),
          child: SheepsAnimatedTabBar(
            pageController: pageController,
            barIndex: barIndex,
            insidePadding: 22 * sizeUnit,
            listTabItemTitle: ['개인・팀', '인터뷰', '전문가'],
            listTabItemWidth: [62 * sizeUnit, 46 * sizeUnit, 46 * sizeUnit],
            listTabItemBoolean: [
              _chatGlobal.getMessageCountByList(_chatGlobal.getRoomInfoList.where((element) => (element.type == ROOM_TYPE_PERSONAL) || (element.type == ROOM_TYPE_TEAM) ).toList()) == 0 ? false : true,
              _chatGlobal.getMessageCountByList(_chatGlobal.getRoomInfoList.where((element) => (element.type == ROOM_TYPE_PERSONAL_SEEK_TEAM) || (element.type == ROOM_TYPE_TEAM_MEMBER_RECRUIT) ).toList()) == 0 ? false : true,
              false],
          ),
        ),
        Container(
          width: 360 * sizeUnit,
          height: 1,
          color: sheepsColorLightGrey,
        ),
      ],
    );
  }

  Widget divideRoomList(List<RoomInfo> pRoomList, Function profileClickFunc, Function chatRoomClickFunc) {
    List<RoomInfo> roomList = pRoomList;

    return roomList.length > 0 ?
      SingleChildScrollView(
      child: ListView.separated(
        separatorBuilder: (context, index) => Container(height: 0.5, width: double.infinity, color: sheepsColorLightGrey),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: roomList.length,
        itemBuilder: (BuildContext context, int index) => Container(
          width: 360 * sizeUnit,
          height: 70 * sizeUnit,
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(left: 12 * sizeUnit, right: 16 * sizeUnit, top: 8 * sizeUnit, bottom: 8 * sizeUnit),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    await profileClickFunc(roomList[index]);
                  },
                  child: roomList[index].profileImage == 'BasicImage'
                      ?
                  roomList[index].type == ROOM_TYPE_TEAM_MEMBER_RECRUIT ||  roomList[index].type == ROOM_TYPE_PERSONAL_SEEK_TEAM ?
                  Badge(
                    shape: BadgeShape.circle,
                    position: BadgePosition.topStart(top: 32 * sizeUnit, start: 32 * sizeUnit),
                    badgeColor: roomList[index].type == ROOM_TYPE_TEAM_MEMBER_RECRUIT ? sheepsColorGreen  : sheepsColorBlue,
                    padding: EdgeInsets.all(4),
                    toAnimate: false,
                    badgeContent: SvgPicture.asset(
                      roomList[index].type == ROOM_TYPE_TEAM_MEMBER_RECRUIT ? 'assets/images/NavigationBar/TeamRecruitIcon.svg' : svgSearchIcon,
                      width: 8 * sizeUnit,
                      height: 8 * sizeUnit,
                      color: Colors.white,
                    ),
                    child: Container(
                      width: 48 * sizeUnit,
                      height: 48 * sizeUnit,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: sheepsColorGrey),
                        borderRadius: new BorderRadius.circular(12*sizeUnit),
                      ),
                      child: Center(
                          child:  SvgPicture.asset(
                            svgSheepsBasicProfileImage,
                            color: roomList[index].type == ROOM_TYPE_TEAM_MEMBER_RECRUIT ? sheepsColorBlue : sheepsColorGreen,
                            width:28*sizeUnit,
                            height: 28*sizeUnit,
                          )
                      ),
                    ),
                  )
                      :
                  Container(
                    width: 48 * sizeUnit,
                    height: 48 * sizeUnit,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: sheepsColorGrey),
                      borderRadius: new BorderRadius.circular(12*sizeUnit),
                    ),
                    child: Center(
                        child:  SvgPicture.asset(
                          svgSheepsBasicProfileImage,
                          color: roomList[index].type  == ROOM_TYPE_PERSONAL ? sheepsColorBlue : sheepsColorGreen,
                          width:28*sizeUnit,
                          height: 28*sizeUnit,
                        )
                    ),
                  )
                      :
                  roomList[index].type == ROOM_TYPE_TEAM_MEMBER_RECRUIT ||  roomList[index].type == ROOM_TYPE_PERSONAL_SEEK_TEAM ?
                  Badge(
                    shape: BadgeShape.circle,
                    position: BadgePosition.topStart(top: 32 * sizeUnit, start: 32 * sizeUnit),
                    badgeColor: roomList[index].type == ROOM_TYPE_TEAM_MEMBER_RECRUIT ? sheepsColorGreen  : sheepsColorBlue,
                    padding: EdgeInsets.all(4),
                    toAnimate: false,
                    badgeContent: SvgPicture.asset(
                      roomList[index].type == ROOM_TYPE_TEAM_MEMBER_RECRUIT ? 'assets/images/NavigationBar/TeamRecruitIcon.svg' : svgSearchIcon,
                      width: 8 * sizeUnit,
                      height: 8 * sizeUnit,
                      color: Colors.white,
                    ),
                    child: Container(
                      width: 48 * sizeUnit,
                      height: 48 * sizeUnit,
                      decoration: BoxDecoration(
                        borderRadius: new BorderRadius.circular(12 * sizeUnit),
                        border: Border.all(color: Colors.transparent),
                      ),
                      child: ClipRRect(
                          borderRadius: new BorderRadius.circular(12 * sizeUnit),
                          child: FittedBox(
                            child: getExtendedImage(roomList[index].profileImage, 60, extendedController),
                            fit: BoxFit.cover,
                          )),
                    ),
                  )
                      :

                  Container(
                    width: 48 * sizeUnit,
                    height: 48 * sizeUnit,
                    decoration: BoxDecoration(
                      borderRadius: new BorderRadius.circular(12 * sizeUnit),
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: ClipRRect(
                        borderRadius: new BorderRadius.circular(12 * sizeUnit),
                        child: FittedBox(
                          child: getExtendedImage(roomList[index].profileImage, 60, extendedController),
                          fit: BoxFit.cover,
                        )),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 12 * sizeUnit),
                  child: InkWell(
                    onTap: () async {
                      if(isReady){
                        isReady = false;
                        await chatRoomClickFunc(roomList[index]);
                        Future.delayed(Duration(milliseconds: 700),() => isReady = true);
                      }
                    },
                    child: Container(
                      width: 200 * sizeUnit,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4 * sizeUnit),
                          Container(
                            height: 22 * sizeUnit,
                            child: Row(
                              children: [
                                Text(
                                  roomList[index].name,
                                  style: SheepsTextStyle.h3(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (roomList[index].type == ROOM_TYPE_TEAM && roomList[index].isPersonal == false) ...[
                                  SizedBox(width: 4 * sizeUnit),
                                  Text(
                                    (roomList[index].chatUserIDList.length + 1).toString(),
                                    style: SheepsTextStyle.appBar().copyWith(color: sheepsColorGrey),
                                  ),
                                ],
                                if (roomList[index].isAlarm == 0) ...[
                                  SizedBox(width: 4 * sizeUnit),
                                  SvgPicture.asset(
                                    "assets/images/Chat/GreyAlarm.svg",
                                    width: 16 * sizeUnit,
                                    height: 16 * sizeUnit,
                                  )
                                ]
                              ],
                            ),
                          ),
                          SizedBox(height: 6 * sizeUnit),
                          Text(
                            cutStringEnterMessage(roomList[index].lastMessage),
                            style: TextStyle(
                              color: sheepsColorDarkGrey,
                              fontSize: 14 * sizeUnit,
                              height: 1.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  width: 60 * sizeUnit,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          SizedBox(height: 8 * sizeUnit),
                        ],
                      ),
                      Text(
                        roomList[index].date,
                        style: TextStyle(
                          color: sheepsColorGrey,
                          fontSize: 12 * sizeUnit,
                          height: 1.5,
                        ),
                        overflow: TextOverflow.visible,
                      ),
                      SizedBox(height: 8 * sizeUnit),
                      _chatBubble(roomList[index].messageCount),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    )

    : noSearchResultsPage('진행중인 채팅이 없습니다.\n프로필에서 채팅을 보내 보세요!');
  }
}
