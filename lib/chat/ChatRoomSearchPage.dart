import 'dart:convert';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheeps_app/Recruit/Models/PersonalSeekTeams.dart';
import 'package:sheeps_app/Recruit/Models/TeamMemberRecruit.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/chat/ChatPage.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/chat/models/Room.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/LoadingUI.dart';
import 'package:sheeps_app/config/NavigationNum.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/profile/DetailProfile.dart';
import 'package:sheeps_app/profile/DetailTeamProfile.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';

class ChatRoomSearchPage extends StatefulWidget {
  @override
  _ChatRoomSearchPageState createState() => _ChatRoomSearchPageState();
}

class _ChatRoomSearchPageState extends State<ChatRoomSearchPage> with SingleTickerProviderStateMixin {
  final searchController = TextEditingController();
  final NavigationNum navigationNum = Get.put(NavigationNum());
  AnimationController? extendedController;

  ChatGlobal? _chatGlobal;
  SocketProvider? _socket;

  List<RoomInfo> chatRoomList = [];

  String get svgGreyMyPageButton => 'assets/images/Public/GreyMyPageButton.svg';
  SharedPreferences? prefs;

  @override
  void initState() {
    extendedController = AnimationController(vsync: this, duration: const Duration(seconds: 1), lowerBound: 0.0, upperBound: 1.0);
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
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

    if(_chatGlobal == null) _chatGlobal = ChatGlobal.to;
    if (null == _socket) {
      _socket = SocketProvider.to;
      _socket!.setRoomStatus(ROOM_STATUS_ROOM);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: null,
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
                      topBar(),
                      SizedBox(height: 4 * sizeUnit,),
                      Container(
                        width: 360 * sizeUnit,
                        height: 1,
                        color: sheepsColorLightGrey,
                      ),

                      if(chatRoomList?.length != 0) ... [
                          ListView.separated(
                            separatorBuilder: (context, index) => Container(height: 0.5, width: double.infinity, color: sheepsColorLightGrey),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: chatRoomList.length,
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
                                        bool isPersonal = chatRoomList[index].isPersonal;

                                        if (isPersonal) {
                                          UserData alreadyUser = GlobalProfile.getUserByUserID(chatRoomList[index].chatUserIDList[0]);

                                          var user = await ApiProvider().post('/Personal/Select/ModifyUser', jsonEncode({"userID": chatRoomList[index].chatUserIDList[0], "updatedAt": alreadyUser.updatedAt}));

                                          if (user != null) {
                                            //개인 프로필 바뀐 데이터로 전역 데이터 세팅
                                            GlobalProfile.setModifyPersonalProfile(UserData.fromJson(user));
                                          }

                                          Get.to(() => DetailProfile(index: 0, user: GlobalProfile.getUserByUserID(chatRoomList[index].chatUserIDList[0])))?.then((value) {
                                            setState(() {
                                              _chatGlobal!.sortLocalRoomInfoList();
                                            });
                                          });
                                        } else {
                                          Team t = GlobalProfile.getTeamByRoomName(chatRoomList[index].roomName);

                                          var team = await ApiProvider().post('/Team/Profile/SelectID', jsonEncode({"id": t.id, "updatedAt": t.updatedAt}));

                                          if (team != null) {
                                            Team resTeam = Team.fromJson(team);

                                            GlobalProfile.setModifyTeamProfile(resTeam);
                                          }

                                          Get.to(() => DetailTeamProfile(index: 0, team: GlobalProfile.getTeamByRoomName(chatRoomList[index].roomName)))?.then((value) {
                                            setState(() {
                                              _chatGlobal!.sortLocalRoomInfoList();
                                            });
                                          });
                                        }
                                      },
                                      child: chatRoomList[index].profileImage == 'BasicImage'
                                          ?
                                      chatRoomList[index].type == ROOM_TYPE_TEAM_MEMBER_RECRUIT ||  chatRoomList[index].type == ROOM_TYPE_PERSONAL_SEEK_TEAM ?
                                      badges.Badge(
                                        badgeStyle: badges.BadgeStyle(
                                          shape : badges.BadgeShape.circle,
                                          badgeColor : chatRoomList[index].type == ROOM_TYPE_TEAM_MEMBER_RECRUIT ? sheepsColorGreen  : sheepsColorBlue,
                                          elevation : 0,
                                          padding : EdgeInsets.all(4 * sizeUnit),
                                        ),
                                        position: badges.BadgePosition.topStart(top: 32 * sizeUnit, start: 32 * sizeUnit),
                                        badgeContent: SvgPicture.asset(
                                          chatRoomList[index].type == ROOM_TYPE_TEAM_MEMBER_RECRUIT ? 'assets/images/NavigationBar/TeamRecruitIcon.svg' : svgSearchIcon,
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
                                              child: SvgPicture.asset(
                                                svgSheepsBasicProfileImage,
                                                color: sheepsColorGreen,
                                                width: 28*sizeUnit,
                                                height: 28*sizeUnit,
                                              )),
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
                                              color: chatRoomList[index].type == ROOM_TYPE_TEAM_MEMBER_RECRUIT ? sheepsColorBlue : sheepsColorGreen,
                                              width: 28*sizeUnit,
                                              height: 28*sizeUnit,
                                            )
                                        ),
                                      )
                                      :
                                      chatRoomList[index].type == ROOM_TYPE_TEAM_MEMBER_RECRUIT ||  chatRoomList[index].type == ROOM_TYPE_PERSONAL_SEEK_TEAM ?
                                      badges.Badge(
                                        badgeStyle: badges.BadgeStyle(
                                          shape : badges.BadgeShape.circle,
                                          badgeColor : chatRoomList[index].type == ROOM_TYPE_TEAM_MEMBER_RECRUIT ? sheepsColorGreen  : sheepsColorBlue,
                                          elevation : 0,
                                          padding : EdgeInsets.all(4 * sizeUnit),
                                        ),
                                        position: badges.BadgePosition.topStart(top: 32 * sizeUnit, start: 32 * sizeUnit),
                                        badgeContent: SvgPicture.asset(
                                          chatRoomList[index].type == ROOM_TYPE_TEAM_MEMBER_RECRUIT ? 'assets/images/NavigationBar/TeamRecruitIcon.svg' : svgSearchIcon,
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
                                                child: getExtendedImage(chatRoomList[index].profileImage, 60, extendedController!),
                                                fit: BoxFit.cover,
                                              )),
                                        ),
                                      ):
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
                                              child: getExtendedImage(chatRoomList[index].profileImage, 60, extendedController!),
                                              fit: BoxFit.cover,
                                            )),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 12 * sizeUnit),
                                      child: InkWell(
                                        onTap: () async {
                                          switch (chatRoomList[index].type) {
                                            case ROOM_TYPE_PERSONAL:
                                            case ROOM_TYPE_TEAM:
                                              {
                                                _socket!.setRoomStatus(ROOM_STATUS_CHAT);
                                                bool isChange = false;

                                                DialogBuilder(context).showLoadingIndicator();

                                                for (int i = 0; i < chatRoomList[index].chatUserIDList.length; ++i) {
                                                  UserData? alreadyUser = await GlobalProfile.getFutureUserByUserID(chatRoomList[index].chatUserIDList[i]);

                                                  var user = await ApiProvider().post('/Personal/Select/ModifyUser', jsonEncode({"userID": chatRoomList[index].chatUserIDList[i], "updatedAt": alreadyUser!.updatedAt}));

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
                                                if (chatRoomList[index].isPersonal) {
                                                  //개인 프로필 방 바뀐 사진이미지로 채팅방 세팅

                                                  UserData tempUser = GlobalProfile.getUserByUserID(chatRoomList[index].chatUserIDList[0]);
                                                  if (isChange) {
                                                    chatRoomList[index].profileImage = tempUser.profileImgList[0].imgUrl;
                                                    chatRoomList[index].name = tempUser.name;
                                                  }
                                                  targetID = tempUser.userID;
                                                } else {
                                                  //팀 채팅 처리
                                                  Team tempTeam = GlobalProfile.getTeamByRoomName(chatRoomList[index].roomName);

                                                  var team = await ApiProvider().post('/Team/Profile/SelectID', jsonEncode({"id": tempTeam.id, "updatedAt": tempTeam.updatedAt}));

                                                  if (team != null) {
                                                    Team resTeam = Team.fromJson(team);

                                                    GlobalProfile.setModifyTeamProfile(resTeam);

                                                    chatRoomList[index].profileImage = resTeam.profileImgList[0].imgUrl;
                                                    chatRoomList[index].name = resTeam.name;
                                                    leaderID = resTeam.leaderID;
                                                    targetID = tempTeam.id;
                                                  }
                                                }
                                                DialogBuilder(context).hideOpenDialog();

                                                Get.to(() => ChatPage(
                                                  roomName: chatRoomList[index].roomName,
                                                  titleName: chatRoomList[index].name,
                                                  chatUserList: GlobalProfile.getUserListByUserIDList(chatRoomList[index].chatUserIDList),
                                                  targetID: targetID,
                                                  leaderID: leaderID, isNeedCallPop: false,
                                                ))?.then((value) {
                                                  setState(() {
                                                    ChatGlobal.sortRoomInfoList();
                                                    ChatGlobal.currentRoomIndex = -1;
                                                    ChatGlobal.removeUserList.clear();
                                                    navigationNum.setNum(CHATROOM_PAGE);

                                                    if(ChatGlobal.willRemoveRoom != null) {
                                                      ChatGlobal.roomInfoList.remove(ChatGlobal.willRemoveRoom);
                                                      ChatGlobal.willRemoveRoom = null;
                                                    }

                                                    _socket!.setRoomStatus(ROOM_STATUS_ROOM);
                                                  });
                                                });
                                              }
                                              break;
                                            case ROOM_TYPE_PERSONAL_SEEK_TEAM:
                                            case ROOM_TYPE_TEAM_MEMBER_RECRUIT:
                                              {
                                                _socket!.setRoomStatus(ROOM_STATUS_CHAT);
                                                bool isChange = false;

                                                DialogBuilder(context).showLoadingIndicator();

                                                for (int i = 0; i < chatRoomList[index].chatUserIDList.length; ++i) {
                                                  UserData? alreadyUser = await GlobalProfile.getFutureUserByUserID(chatRoomList[index].chatUserIDList[i]);

                                                  var user = await ApiProvider().post('/Personal/Select/ModifyUser', jsonEncode({"userID": chatRoomList[index].chatUserIDList[i], "updatedAt": alreadyUser!.updatedAt}));

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
                                                UserData u = GlobalProfile.getUserByUserID(chatRoomList[index].chatUserIDList[0]);
                                                if (isChange) {
                                                  chatRoomList[index].profileImage = u.profileImgList[0].imgUrl;
                                                  chatRoomList[index].name = u.name;
                                                }
                                                targetID = u.userID;


                                                if(chatRoomList[index].type == ROOM_TYPE_PERSONAL_SEEK_TEAM){
                                                  int firstIndex = "personalID".length;
                                                  int lastIndex = chatRoomList[index].roomName.lastIndexOf('userID');

                                                  String sub = chatRoomList[index].roomName.substring(firstIndex,lastIndex);

                                                  PersonalSeekTeam personalSeekTeam = await getFuturePersonalSeekTeam(int.parse(sub));
                                                  await GlobalProfile.getFutureUserByUserID(personalSeekTeam.userId);
                                                }else{
                                                  int firstIndex = "teamMemberID".length;
                                                  int lastIndex = chatRoomList[index].roomName.lastIndexOf('userID');

                                                  String sub = chatRoomList[index].roomName.substring(firstIndex,lastIndex);

                                                  TeamMemberRecruit teamMemberRecruit = await getFutureTeamMemberRecruit(int.parse(sub));
                                                  await GlobalProfile.getFutureTeamByID(teamMemberRecruit.teamId);
                                                }

                                                DialogBuilder(context).hideOpenDialog();

                                                Get.to(() => ChatPage(
                                                  roomName: chatRoomList[index].roomName,
                                                  titleName: chatRoomList[index].name,
                                                  chatUserList: GlobalProfile.getUserListByUserIDList(chatRoomList[index].chatUserIDList),
                                                  targetID: targetID,
                                                  leaderID: leaderID, isNeedCallPop: false,
                                                ))?.then((value) {
                                                  setState(() {
                                                    ChatGlobal.sortRoomInfoList();
                                                    ChatGlobal.currentRoomIndex = -1;
                                                    ChatGlobal.removeUserList.clear();
                                                    navigationNum.setNum(CHATROOM_PAGE);

                                                    if(ChatGlobal.willRemoveRoom != null) {
                                                      ChatGlobal.roomInfoList.remove(ChatGlobal.willRemoveRoom);
                                                      ChatGlobal.willRemoveRoom = null;
                                                    }

                                                    _socket!.setRoomStatus(ROOM_STATUS_ROOM);
                                                  });
                                                });
                                              }
                                              break;
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
                                                      chatRoomList[index].name,
                                                      style: SheepsTextStyle.h3(),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    if (chatRoomList[index].type == ROOM_TYPE_TEAM && chatRoomList[index].isPersonal == false) ...[
                                                      SizedBox(width: 4 * sizeUnit),
                                                      Text(
                                                        (chatRoomList[index].chatUserIDList.length + 1).toString(),
                                                        style: SheepsTextStyle.appBar().copyWith(color: sheepsColorGrey),
                                                      ),
                                                    ],
                                                    if (chatRoomList[index].isAlarm == 0) ...[
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
                                                cutStringEnterMessage(chatRoomList[index].lastMessage),
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
                                            chatRoomList[index].date,
                                            style: TextStyle(
                                              color: sheepsColorGrey,
                                              fontSize: 12 * sizeUnit,
                                              height: 1.5,
                                            ),
                                            overflow: TextOverflow.visible,
                                          ),
                                          SizedBox(height: 8 * sizeUnit),
                                          _chatBubble(chatRoomList[index].messageCount),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ] else ... [
                        Expanded(
                          child: noSearchResultsPage('검색하신 채팅방을 찾을 수 없습니다.\n팀 매칭을 통해 원하는 상대와\n채팅방을 만들어보아요!')
                        )
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

  Widget topBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.white,
          width: double.infinity,
          height: 44 * sizeUnit,
          child: Row(
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit),
                  child: Container(
                    width: 296 * sizeUnit,
                    height: 32 * sizeUnit,
                    decoration: BoxDecoration(
                      borderRadius: new BorderRadius.circular(8 * sizeUnit),
                      color: sheepsColorLightGrey,
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8 * sizeUnit),
                          child: SvgPicture.asset(
                            svgGreyMagnifyingGlass,
                            width: 16 * sizeUnit,
                            height: 16 * sizeUnit,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: 242 * sizeUnit,
                            child: TextField(
                              onSubmitted: (val) {

                                chatRoomList = _chatGlobal!.getRoomInfoList.where((element) => element.name.camelCase!.contains(val.camelCase as Pattern)).toList();
                                setState(() {

                                });
                              },
                              textAlign: TextAlign.left,
                              controller: searchController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '채팅방 검색',
                                hintStyle: SheepsTextStyle.info1(),
                              ),
                              style: SheepsTextStyle.b3(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 6 * sizeUnit),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                searchController.clear();
                                FocusScope.of(context).unfocus();
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
                  )),
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Text(
                  "취소",
                  style: TextStyle(
                    color: sheepsColorDarkGrey,
                    fontSize: 12 * sizeUnit,
                  ),
                ),
              ),
              SizedBox(width: 12 * sizeUnit),
            ],
          ),
        )
      ],
    );
  }
}
