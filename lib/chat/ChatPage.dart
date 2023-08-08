import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:badges/badges.dart' as badges;
import 'package:extended_image/extended_image.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sheeps_app/Recruit/Models/PersonalSeekTeams.dart';
import 'package:sheeps_app/Recruit/Models/RecruitLikes.dart';
import 'package:sheeps_app/Recruit/Models/TeamMemberRecruit.dart';
import 'package:sheeps_app/Recruit/RecruitDetailPage.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/chat/models/Room.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/NavigationNum.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/profile/DetailProfile.dart';
import 'package:sheeps_app/profile/DetailTeamProfile.dart';
import '../notification/models/LocalNotification.dart';
import './models/ChatItem.dart';
import './models/ChatRecvMessageModel.dart';
import './models/ChatGlobal.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './models/ChatDatabase.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/Setting/PageReport.dart';
import 'package:sheeps_app/config/constants.dart';

class ChatPage extends StatefulWidget {
  String roomName;
  String titleName;
  bool isNeedCallPop;
  List<UserData> chatUserList;
  int targetID;
  int leaderID;

  ChatPage({Key? key,required this.roomName,required this.titleName,required this.isNeedCallPop,required this.chatUserList,required this.targetID,required this.leaderID}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  NavigationNum navigationNum = Get.put(NavigationNum());
  LocalNotification? _localNotification;
  SocketProvider? _socket;
  ChatGlobal? _chatGlobal;
  final RecruitInviteController recruitInviteController = Get.put(RecruitInviteController());

  bool isMain = false;
  int chatStartIndex = 0;
  ScrollController? _chatLVController;
  TextEditingController? _chatTfController;
  FocusNode _focusNode = FocusNode();

  bool isToggleButton = false;
  GlobalKey<RefreshIndicatorState>? refreshKey;

  String get svgMeIcon => "assets/images/Chat/me.svg";

  String get svgDeclare => "assets/images/Chat/declare.svg";

  String get svgProfile => "assets/images/Chat/profile.svg";

  String get svgLeader => "assets/images/Chat/leader.svg";

  String svgAlarm = "assets/images/Chat/alarmOn.svg";
  String alarmText = "알림끄기";

  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<UserData> chatSettingUserList = [];
  List<UserData> chatUserList = [];
  int personalInviteRecruitID = 0;

  @override
  void initState() {
    super.initState();

    debugPrint(widget.roomName);


    _chatTfController = TextEditingController();

    ChatGlobal.roomName = widget.roomName;

    chatStartIndex = 0;

    _chatGlobal = ChatGlobal.to;

    if (widget.isNeedCallPop == null) widget.isNeedCallPop = false;

    chatSettingUserList.add(GlobalProfile.loggedInUser!);

    for (int i = 0; i < widget.chatUserList.length; ++i) {
      chatSettingUserList.add(widget.chatUserList[i]);
    }

    chatUserList = widget.chatUserList;

    for (int i = 0; i < _chatGlobal!.getRoomInfoList.length; ++i) {
      if (widget.roomName != _chatGlobal!.getRoomInfoList[i].roomName) continue;
      ChatGlobal.currentRoomIndex = i;

      if(_chatGlobal!.getRoomInfoList[i].roomInfoID == null || _chatGlobal!.getRoomInfoList[i].roomInfoID == -1){
        Future.microtask(() async {
          await ApiProvider().post('/Room/Info/Select', jsonEncode({
            "userID" : GlobalProfile.loggedInUser!.userID,
            "roomName" : widget.roomName
          })).then((value) => {
            if(value != null){
              _chatGlobal!.getRoomInfoList[i].roomInfoID = value['RoomID'],
            }
          });

        });
      }

      break;
    }

    _chatLVController = ScrollController(initialScrollOffset: _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList.length * 40 * sizeUnit);
    ChatGlobal.scrollController = _chatLVController;
  }

  @override
  void dispose() {
    ChatGlobal.scrollController = null;
    _chatLVController!.dispose();
    _chatTfController!.dispose();
    super.dispose();
  }

  void needCallPopFunc(){
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    if (null == _localNotification) {
      _localNotification = LocalNotification();
      _initMessageData();
    }

    if (_socket == null) _socket = SocketProvider.to;

    final isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;

    if(isKeyboard){
      _chatListScrollToBottom();
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Container(
        color: Colors.white,
        child: WillPopScope(
          onWillPop: null,
          child: SafeArea(
            child: RefreshIndicator(
              backgroundColor: sheepsColorGreen,
              color: Colors.white,
              key: refreshKey,
              onRefresh: () async {
                Future.delayed(Duration(milliseconds: 500), () async {
                  int cnt = 0;

                  List<ChatRecvMessageModel> chatList = (await ChatDBHelper().getRoomData(widget.roomName, offset: getRealMessageCount())).cast<ChatRecvMessageModel>();

                  if (chatList.length == 0) {
                    showSheepsToast(context: context, text: "더 이상 불러올 데이터가 없습니다.");
                  }else{
                    for (int i = 0; i < chatList.length; ++i) {
                      ChatRecvMessageModel chatRecvMessageModel = chatList[i];
                      chatRecvMessageModel.isContinue = true;

                      if (chatRecvMessageModel.isImage != 0) {
                        chatRecvMessageModel.fileMessage = chatRecvMessageModel.message;
                      }

                      if (cnt != 0) {
                        bool isContinue = (chatRecvMessageModel.from == _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList[cnt - 1].from) &&
                            (chatRecvMessageModel.date == _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList[cnt - 1].date);
                        if (true == isContinue) {
                          _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList[cnt - 1].isContinue = false;
                        } else {
                          _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList[cnt - 1].isContinue = true;
                        }
                      }
                      _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList.insert(0 + cnt++, chatRecvMessageModel);
                    }

                    //날짜 데이터 모두 삭제
                    for(int i = 0 ; i < _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList.length ; ++i){
                      if(_chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList[i].roomName == 'DATE_CHAT'){
                        _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList.removeAt(i);
                      }
                    }

                    //날짜 데이터 다시 세팅
                    for(int i = 0 ; i < _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList.length ; ++i){
                      ChatRecvMessageModel message = _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList[i];
                      ChatRecvMessageModel? next = (i + 1) <= (_chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList.length -1 ) ? _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList[i + 1] : null;

                      //맨 처음 데이터의 날짜
                      if (message.from != CENTER_MESSAGE && i == 0) {
                        _chatGlobal!.insertChatDateData(ChatGlobal.currentRoomIndex, message.updatedAt);
                        continue;
                      }

                      //다른 데이터면 날짜 표시
                      if(message.roomName != 'DATE_CHAT' && next != null && next.roomName != 'DATE_CHAT') {
                        if(message.updatedAt != null && next.updatedAt != null){
                          if (ChatGlobal().getRoomChatDate(message.updatedAt) != ChatGlobal().getRoomChatDate(next.updatedAt)) {
                            i += 1;
                            _chatGlobal!.insertChatDateData(ChatGlobal.currentRoomIndex, next.updatedAt, chatIndex: i);
                          }
                        }
                      }
                    }
                  }
                }).then((value) {
                  setState(() {});
                });
              },
              child: GestureDetector(
                onTap: () {
                  unFocus(context);
                },
                child: Scaffold(
                    key: scaffoldKey,
                    appBar: chatUserList.length <= 1 && ChatGlobal.currentRoomIndex >= 0 && _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].type != ROOM_TYPE_TEAM ?
                    SheepsAppBar(
                      context,
                      widget.titleName,
                      backFunc: () {
                        needCallPopFunc();
                      },
                      actions: [
                        if (alarmText == "알림켜기") ...[
                          SvgPicture.asset(
                            'assets/images/Chat/darkGreyAlarm.svg',
                            width: 28 * sizeUnit,
                            height: 28 * sizeUnit,
                          ),
                          SizedBox(
                            width: 4 * sizeUnit,
                          )
                        ],
                        GestureDetector(
                          onTap: () {
                            scaffoldKey.currentState!.openEndDrawer();
                            unFocus(context);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 12 * sizeUnit),
                            child: SvgPicture.asset(
                              'assets/images/Community/Grey3dot.svg',
                              width: 28 * sizeUnit,
                              height: 28 * sizeUnit,
                            ),
                          ),
                        ),
                      ],
                    )
                        :

                    SheepsAppBar(
                      context,
                      widget.titleName + ' ',
                      subText: (chatUserList.length + 1).toString(),
                      backFunc: () {
                        needCallPopFunc();
                      },
                      actions: [
                        if (alarmText == "알림켜기") ...[
                          SvgPicture.asset(
                            'assets/images/Chat/darkGreyAlarm.svg',
                            width: 28 * sizeUnit,
                            height: 28 * sizeUnit,
                          ),
                          SizedBox(
                            width: 4 * sizeUnit,
                          )
                        ],
                        GestureDetector(
                          onTap: () {
                            scaffoldKey.currentState!.openEndDrawer();
                            unFocus(context);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 12 * sizeUnit),
                            child: SvgPicture.asset(
                              'assets/images/Community/Grey3dot.svg',
                              width: 28 * sizeUnit,
                              height: 28 * sizeUnit,
                            ),
                          ),
                        ),
                      ],
                    ),
                    endDrawer: Container(
                      width: 260 * sizeUnit,
                      child: Drawer(
                        child: Padding(
                          padding: EdgeInsets.only(left: 16 * sizeUnit, top: 16 * sizeUnit, right: 16 * sizeUnit, bottom: 16 * sizeUnit),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '채팅방 설정',
                                style: SheepsTextStyle.h3(),
                              ),
                              SizedBox(
                                height: 8 * sizeUnit,
                              ),
                              Container(
                                  width: 360 * sizeUnit,
                                  height: 1,
                                  decoration: BoxDecoration(
                                    color: sheepsColorLightGrey,
                                  )),
                              SizedBox(
                                height: 20 * sizeUnit,
                              ),
                              Text(
                                widget.leaderID == -1 ? "대화상대" : '팀원 (' + chatSettingUserList.length.toString() + '명)',
                                style: SheepsTextStyle.h4(),
                              ),
                              SizedBox(
                                height: 12 * sizeUnit,
                              ),
                              Expanded(
                                  child: ListView.builder(
                                    itemCount: chatSettingUserList.length,
                                    itemBuilder: (context, index) {
                                      return settingProfile(chatSettingUserList[index], isMe: chatSettingUserList[index].userID == GlobalProfile.loggedInUser!.userID);
                                    },
                                  )),
                              SizedBox(
                                height: 20 * sizeUnit,
                              ),
                              Container(
                                  width: 360 * sizeUnit,
                                  height: 1,
                                  decoration: BoxDecoration(
                                    color: sheepsColorLightGrey,
                                  )),
                              SizedBox(
                                height: 12 * sizeUnit,
                              ),
                              settingColumn(
                                  svgDeclare,
                                  "신고하기",
                                      () => {
                                    {
                                      Get.to(() => PageReport(
                                        userID: GlobalProfile.loggedInUser!.userID,
                                        classification: 'ChatRoom',
                                        reportedID: widget.roomName,
                                      ))
                                    }
                                  }),
                              SizedBox(
                                height: 12 * sizeUnit,
                              ),
                              Container(
                                  width: 360 * sizeUnit,
                                  height: 1,
                                  decoration: BoxDecoration(
                                    color: sheepsColorLightGrey,
                                  )),
                              SizedBox(
                                height: 12 * sizeUnit,
                              ),
                              settingColumn(
                                  svgAlarm,
                                  alarmText,
                                      () => {
                                    {
                                      setState(() {
                                        if (alarmText == "알림끄기") {
                                          svgAlarm = "assets/images/Chat/alarmOff.svg";
                                          alarmText = "알림켜기";
                                          _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].isAlarm = 0;
                                          ApiProvider().post('/Room/Update/Alarm', jsonEncode({
                                            "id" : _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].roomUserID,
                                            "alarm" : 0
                                          }));
                                        } else {
                                          svgAlarm = "assets/images/Chat/alarmOn.svg";
                                          alarmText = "알림끄기";
                                          _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].isAlarm = 1;
                                          ApiProvider().post('/Room/Update/Alarm', jsonEncode({
                                            "id" : _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].roomUserID,
                                            "alarm" : 1
                                          }));
                                        }
                                      })
                                    }
                                  }),
                              SizedBox(
                                height: 12 * sizeUnit,
                              ),
                              Container(
                                  width: 360 * sizeUnit,
                                  height: 1,
                                  decoration: BoxDecoration(
                                    color: sheepsColorLightGrey,
                                  )),
                              SizedBox(
                                height: 12 * sizeUnit,
                              ),
                              settingColumn(
                                  svgProfile,
                                  "프로필 가기",
                                      () => {
                                    {
                                      //개인 프로필
                                      if (widget.leaderID == -1)
                                        {Get.to(() => DetailProfile(index: 0, user: GlobalProfile.getUserByUserID(widget.targetID)))}
                                      else
                                        {Get.to(() => DetailTeamProfile(index: 0, team: GlobalProfile.getTeamByID(widget.targetID), byChat: true,))?.then((value) => {
                                          if(ChatGlobal.removeUserList.length != 0 && (ChatGlobal.removeUserList[0] == GlobalProfile.loggedInUser!.userID)){
                                            needCallPopFunc(), Get.back()
                                          }
                                          else{
                                            for(int i = 0 ; i < ChatGlobal.removeUserList.length; ++i){
                                              for(int j = 0 ; j < chatUserList.length; ++j){
                                                if(chatUserList[j].userID == ChatGlobal.removeUserList[i]){
                                                  chatUserList.removeAt(j),                                                //채팅 유저 목록에서 삭제
                                                  chatSettingUserList.removeAt(j+1)                                        //세팅 유저 목록에서 삭제
                                                }
                                              }
                                            },
                                            setState(() {})
                                          }
                                        })
                                        }
                                    }
                                  }),
                              if(ChatGlobal.currentRoomIndex != -1 && _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].type != ROOM_TYPE_TEAM  ) ... [
                                if(isMain) ... [
                                  if(recruitInviteController.getCurrRecruitInvite == null) ... [
                                    SizedBox(
                                      height: 12 * sizeUnit,
                                    ),
                                    Container(
                                        width: 360 * sizeUnit,
                                        height: 1,
                                        decoration: BoxDecoration(
                                          color: sheepsColorLightGrey,
                                        )),
                                    SizedBox(
                                      height: 12 * sizeUnit,
                                    ),
                                    settingColumn(
                                        'assets/images/Chat/chatExitIcon.svg',
                                        "채팅방 나가기",
                                            () {
                                          {
                                            Function func = () {
                                              ApiProvider().post('/Room/Leave', jsonEncode({
                                                "userID" : GlobalProfile.loggedInUser!.userID,
                                                "roomID" : _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].roomInfoID,
                                                "userName" : GlobalProfile.loggedInUser!.name,
                                                "recruitID" : -1, //게시글의 주인일경우 초대장인 이미 파괴
                                                "type" : _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].type
                                              }));

                                              ChatGlobal.willRemoveRoom = _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex];

                                              ChatDBHelper().deleteDataByRoomName(widget.roomName);

                                              //다이얼로그 닫기
                                              Get.back();

                                              //채팅방 나가기기
                                              needCallPopFunc();

                                              Get.back();
                                            };

                                            showSheepsCustomDialog(
                                                title: Text(
                                                  "채팅방을 나가시겠어요?",
                                                  style: SheepsTextStyle.dialogTitle().copyWith(height: 1.2, fontWeight: FontWeight.w700),
                                                  textAlign: TextAlign.center,
                                                ),
                                                contents: RichText(
                                                  textAlign: TextAlign.center,
                                                  text: TextSpan(
                                                    style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
                                                    children: [
                                                      TextSpan(text: '더 이상 해당 채팅에 대한 알림을,\n'),
                                                      TextSpan(text: '받을 수 없습니다.'),
                                                    ],
                                                  ),
                                                ),
                                                okButtonColor: sheepsColorBlue,
                                                okFunc: func,
                                                isCancelButton: true);
                                          }
                                        }),
                                  ]
                                ]else ... [
                                  SizedBox(
                                    height: 12 * sizeUnit,
                                  ),
                                  Container(
                                      width: 360 * sizeUnit,
                                      height: 1,
                                      decoration: BoxDecoration(
                                        color: sheepsColorLightGrey,
                                      )),
                                  SizedBox(
                                    height: 12 * sizeUnit,
                                  ),
                                  settingColumn(
                                      'assets/images/Chat/chatExitIcon.svg',
                                      "채팅방 나가기",
                                          () {
                                        {
                                          Function func = () {
                                            ApiProvider().post('/Room/Leave', jsonEncode({
                                              "userID" : GlobalProfile.loggedInUser!.userID,
                                              "roomID" : _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].roomInfoID,
                                              "userName" : GlobalProfile.loggedInUser!.name,
                                              "recruitID" : _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].type == ROOM_TYPE_PERSONAL ? personalInviteRecruitID : recruitInviteController.getCurrRecruitInvite == null ? -1 : recruitInviteController.getCurrRecruitInvite.id,
                                              "type" : _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].type
                                            }));

                                            ChatGlobal.willRemoveRoom = _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex];

                                            ChatDBHelper().deleteDataByRoomName(widget.roomName);

                                            //다이얼로그 닫기
                                            Get.back();

                                            //채팅방 나가기기
                                            needCallPopFunc();

                                            Get.back();
                                          };

                                          showSheepsCustomDialog(
                                              title: Text(
                                                "채팅방을 나가시겠어요?",
                                                style: SheepsTextStyle.dialogTitle().copyWith(height: 1.2, fontWeight: FontWeight.w700),
                                                textAlign: TextAlign.center,
                                              ),
                                              contents: RichText(
                                                textAlign: TextAlign.center,
                                                text: TextSpan(
                                                  style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
                                                  children: [
                                                    TextSpan(text: '더 이상 해당 채팅에 대한 알림을,\n'),
                                                    TextSpan(text: '받을 수 없습니다.'),
                                                  ],
                                                ),
                                              ),
                                              okButtonColor: sheepsColorBlue,
                                              okFunc: func,
                                              isCancelButton: true
                                          );
                                        }
                                      }
                                  ),
                                ]
                              ]
                            ],
                          ),
                        ),
                      ),
                    ),
                    body: SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(width: 360 * sizeUnit, height: 0.5, decoration: BoxDecoration(color: sheepsColorGrey)),
                            if (ChatGlobal.currentRoomIndex != -1 && _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].type == ROOM_TYPE_TEAM_MEMBER_RECRUIT) ...[
                              _interviewBanner(true)
                            ] else if (ChatGlobal.currentRoomIndex != -1 && _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].type == ROOM_TYPE_PERSONAL_SEEK_TEAM) ...[
                              _interviewBanner(false)
                            ],
                            _chatList(),
                            if(ChatGlobal.currentRoomIndex != -1 && _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].roomUserID != -1) ...[
                              Container(width: 360 * sizeUnit, height: 0.5, decoration: BoxDecoration(color: sheepsColorGrey)),
                              _bottomChatArea(),
                            ]
                          ],
                        ))),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _initMessageData() async {
    if (_chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].isAlarm == 0) {
      svgAlarm = "assets/images/Chat/alarmOff.svg";
      alarmText = "알림켜기";
    } else {
      svgAlarm = "assets/images/Chat/alarmOn.svg";
      alarmText = "알림끄기";
    }

    if (null != _chatGlobal!.getRoomInfoList) {
      for (int i = 0; i < _chatGlobal!.getRoomInfoList.length; ++i) {
        if (widget.roomName != _chatGlobal!.getRoomInfoList[i].roomName) continue;
        if (null == _chatGlobal!.getRoomInfoList[i].chatList) return;

        _chatGlobal!.getRoomInfoList[i].messageCount = 0;

        bool isReadPoint = false;
        bool isRebuild = false;

        for (int j = _chatGlobal!.getRoomInfoList[i].chatList.length - 1; j >= 0; --j) {
          if (_chatGlobal!.getRoomInfoList[i].chatList[j].message == "여기까지 읽었습니다.") {
            _chatGlobal!.getRoomInfoList[i].chatList.removeAt(j);
            break;
          }
        }

        await ChatDBHelper().updateRoomData(widget.roomName, 1);

        for (int j = 0; j < _chatGlobal!.getRoomInfoList[i].chatList.length; ++j) {
          ChatRecvMessageModel message = _chatGlobal!.getRoomInfoList[i].chatList[j];
          ChatRecvMessageModel? next = (j + 1) <= (_chatGlobal!.getRoomInfoList[i].chatList.length -1 ) ? _chatGlobal!.getRoomInfoList[i].chatList[j + 1] : null;

          //맨 처음 데이터의 날짜
          if (message.from != CENTER_MESSAGE && message.roomName != 'DATE_CHAT' && j == 0) {
            _chatGlobal!.insertChatDateData(i, message.updatedAt);
            continue;
          }
          //다른 데이터면 날짜 표시
          bool isAddDATE = false;
          if(message.roomName != 'DATE_CHAT' && next != null && next.roomName != 'DATE_CHAT'){
            if(message.updatedAt != null && next.updatedAt != null){
              if( ChatGlobal().getRoomChatDate(message.updatedAt) != ChatGlobal().getRoomChatDate(next.updatedAt)){
                j += 1;
                isAddDATE = true;
                _chatGlobal!.insertChatDateData(i, next.updatedAt, chatIndex: j);
              }
            }
          }

          if ((_chatGlobal!.getRoomInfoList[i].chatList.length - 1) == j) isRebuild = true;

          //안읽은 데이터 체크
          if (message.isRead == 0 && j != 0) {
            _chatGlobal!.getRoomInfoList[i].chatList[j].isRead = 1;

            if (false == isReadPoint) {
              chatStartIndex = j;
              if(isAddDATE) chatStartIndex -= 1;
              isReadPoint = true;
            }
          }

          if (j != 0) setContinue(message, j - 1, isRebuild);
        }

        //읽은 중단 점 표시
        if (isReadPoint) {
          ChatRecvMessageModel chatRecvMessageModel = ChatRecvMessageModel(to: CENTER_MESSAGE.toString(), from: CENTER_MESSAGE, roomName: widget.roomName, message: "여기까지 읽었습니다.", isImage: 0, date: "00:00", isRead: 1, chatId: 0);

          _addRecvMessage(0, chatRecvMessageModel, chatStartIndex, true);
        }
        break;
      }
    }

    if (_chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].type == ROOM_TYPE_TEAM_MEMBER_RECRUIT) {
      var res = await ApiProvider().post('/Matching/Select/InvitingTeamMemberRecruitByID', jsonEncode({
        "id": widget.roomName.substring(widget.roomName.lastIndexOf('D') + 1, widget.roomName.length)
      }));

      if(res != null){
        RecruitInvite recruitInvite = RecruitInvite.fromJson(res);

        recruitInviteController.setCurrRecruitInvite(0, recruitInvite: recruitInvite);
      }else{
        //recruitInviteController.currRecruitInvite = null;
      }
    }else if(_chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].type == ROOM_TYPE_PERSONAL_SEEK_TEAM) {
      var res = await ApiProvider().post('/Matching/Select/InvitingPersonalSeekTeamUserByID', jsonEncode({
        "id" : widget.roomName.substring(widget.roomName.lastIndexOf('D') + 1, widget.roomName.length)
      }));

      if(res != null){
        RecruitInvite recruitInvite = RecruitInvite.fromJson(res, isUserID: false);

        recruitInviteController.setCurrRecruitInvite(0, recruitInvite: recruitInvite);
      }else{
        //recruitInviteController.currRecruitInvite = null;
      }
    }else if(_chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].type == ROOM_TYPE_PERSONAL){
      var res = await ApiProvider().post('/Room/Invite/TargetSelect', jsonEncode({"userID": GlobalProfile.loggedInUser!.userID, "inviteID": chatUserList[0].userID}));

      if (res != null || res['res'] != 0){
        personalInviteRecruitID = res['recruitID'];
      }else{
        //recruitInviteController.currRecruitInvite = null;
      }
    }

    setState(() {});
  }

  _chatList() {
    return GetBuilder(builder: (SocketProvider socket) {
      if(ChatGlobal.currentRoomIndex == -1) return Container();

      return Expanded(
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                image : AssetImage("assets/images/Chat/chatBackGroundImage.png"),
              )
          ),
          child: ListView.builder(
            cacheExtent: 100,
            controller: _chatLVController,
            reverse: false,
            shrinkWrap: true,
            primary: false,
            padding: EdgeInsets.all(10 * sizeUnit),
            itemCount: null == socket.getChatGlobal.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList ? 0 : socket.getChatGlobal.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList.length,
            itemBuilder: (context, index) {
              if(ChatGlobal.currentRoomIndex == -1) return Container();

              ChatRecvMessageModel chatMessage = socket.getChatGlobal.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList[index];
              bool isContinue = index == 0
                  ? false
                  : (socket.getChatGlobal.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList[index - 1].from == socket.getChatGlobal.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList[index].from) &&
                  (socket.getChatGlobal.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList[index - 1].date == socket.getChatGlobal.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList[index].date);
              return Container(
                padding: EdgeInsets.symmetric(vertical: 4 * sizeUnit),
                child: ChatItem(
                  message: chatMessage,
                  isContinue: isContinue,
                  isImage: chatMessage.from == CENTER_MESSAGE ? false : chatMessage.isImage.isOdd,
                  chatIconName: GlobalProfile.getUserByUserID(socket.getChatGlobal.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList[index].from) == null
                      ? ''
                      : GlobalProfile.getUserByUserID(socket.getChatGlobal.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList[index].from).profileImgList[0].imgUrl, key: null,
                ),
              );
            },
          ),
        ),
      );
    });
  }

  _bottomChatArea() {
    return Container(
      color: Colors.white,
      height: 52 * sizeUnit,
      child: Row(
        children: [
          SizedBox(width: 8 * sizeUnit),
          GestureDetector(
            onTap: () async {
              SheepsBottomSheetForImg(
                context,
                cameraFunc: () async {
                  Get.back();
                  final ImagePicker picker = ImagePicker();
                  late final XFile? selectedImage;

                  selectedImage = await picker.pickImage(source: ImageSource.gallery);

                  _socket!.socket!.emit('resumed',[{
                    "userID" : GlobalProfile.loggedInUser!.userID.toString(),
                    "roomStatus" : ROOM_STATUS_CHAT,
                  }] );

                  if (selectedImage == null) return;

                  var imageID = await ApiProvider().get('/ChatLog/Count/Image');

                  File file = File(selectedImage.path);
                  List<int> imageBytes = await file.readAsBytes();

                  if (isBigFile(imageBytes.length)) {
                    return;
                  }

                  String base64Image = base64Encode(imageBytes);

                  var dateUtc = DateTime.now().toUtc();
                  String date = dateUtc.toLocal().hour.toString() + ":" + ((dateUtc.toLocal().minute < 10) ? "0" + dateUtc.toLocal().minute.toString() : dateUtc.toLocal().minute.toString());

                  String userListStr = '';
                  for (int i = 0; i < chatUserList.length; ++i) {
                    if (i != 0) userListStr += '|';

                    userListStr += chatUserList[i].userID.toString();
                  }

                  String dateTimeString = replacLocalUTCDate(DateTime.now().toUtc().toString());

                  //보내는 날짜가 다르면
                  if(_chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList.length != 0){
                    if( ChatGlobal().getRoomChatDate(_chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList[_chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList.length - 1].updatedAt) !=
                        ChatGlobal().getRoomChatDate(dateTimeString)){
                      _chatGlobal!.insertChatDateData(ChatGlobal.currentRoomIndex, dateTimeString, chatIndex: _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList.length);
                    }
                  }

                  ChatRecvMessageModel chatRecvMessageModel = ChatRecvMessageModel(
                      to: userListStr,
                      from: GlobalProfile.loggedInUser!.userID,
                      fromName: GlobalProfile.loggedInUser!.name,
                      roomName: widget.roomName,
                      message: base64Image,
                      date: date,
                      isImage: imageID['id'] + 1,
                      updatedAt: dateTimeString,
                      createdAt: dateTimeString,
                      roomId: _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].roomInfoID, chatId: 0
                  );
                  chatRecvMessageModel.isRead = 1;

                  _socket!..socket!.emit("roomChatMessage", [chatRecvMessageModel.toJson()]);

                  chatRecvMessageModel.date = dateUtc.toLocal().hour.toString() + ":" + dateUtc.toLocal().minute.toString();

                  _addRecvMessage(0, chatRecvMessageModel, _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList.length - 1, true);
                  unFocus(context);
                },
                galleryFunc: () async {
                  Get.back();
                  final ImagePicker picker = ImagePicker();
                  late final XFile? selectedImage;

                  selectedImage = await picker.pickImage(source: ImageSource.gallery);

                  _socket!.socket!.emit('resumed',[{
                    "userID" : GlobalProfile.loggedInUser!.userID.toString(),
                    "roomStatus" : ROOM_STATUS_CHAT,
                  }] );

                  if (selectedImage == null) return;

                  var imageID = await ApiProvider().get('/ChatLog/Count/Image');

                  File file = File(selectedImage.path);
                  List<int> imageBytes = await file.readAsBytes();

                  if (isBigFile(imageBytes.length)) {
                    return;
                  }

                  String base64Image = base64Encode(imageBytes);

                  var dateUtc = DateTime.now().toUtc();
                  String date = dateUtc.toLocal().hour.toString() + ":" + ((dateUtc.toLocal().minute < 10) ? "0" + dateUtc.toLocal().minute.toString() : dateUtc.toLocal().minute.toString());

                  String userListStr = '';
                  for (int i = 0; i < chatUserList.length; ++i) {
                    if (i != 0) userListStr += '|';

                    userListStr += chatUserList[i].userID.toString();
                  }

                  String dateTimeString = replacLocalUTCDate(DateTime.now().toUtc().toString());

                  //보내는 날짜가 다르면
                  if(_chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList.length != 0){
                    if( ChatGlobal().getRoomChatDate(_chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList[_chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList.length - 1].updatedAt) !=
                        ChatGlobal().getRoomChatDate(dateTimeString)){
                      _chatGlobal!.insertChatDateData(ChatGlobal.currentRoomIndex, dateTimeString, chatIndex: _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList.length);
                    }
                  }

                  ChatRecvMessageModel chatRecvMessageModel = ChatRecvMessageModel(
                      to: userListStr,
                      from: GlobalProfile.loggedInUser!.userID,
                      fromName: GlobalProfile.loggedInUser!.name,
                      roomName: widget.roomName,
                      message: base64Image,
                      date: date,
                      isImage: imageID['id'] + 1,
                      updatedAt: dateTimeString,
                      createdAt: dateTimeString,
                      roomId: _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].roomInfoID, chatId: 0
                  );
                  chatRecvMessageModel.isRead = 1;

                  _socket!..socket!.emit("roomChatMessage", [chatRecvMessageModel.toJson()]);

                  chatRecvMessageModel.date = dateUtc.toLocal().hour.toString() + ":" + dateUtc.toLocal().minute.toString();

                  _addRecvMessage(0, chatRecvMessageModel, _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList.length - 1, true);
                  unFocus(context);
                },
              );

              return;
            },
            child: SvgPicture.asset(
              svgSelectPicture,
              width: 28 * sizeUnit,
              height: 28 * sizeUnit,
            ),
          ),
          SizedBox(width: 4 * sizeUnit),
          Container(
              width: 308 * sizeUnit,
              height: 38 * sizeUnit,
              decoration: BoxDecoration(
                border: Border.all(
                  color: sheepsColorDarkGrey,
                ),
                borderRadius: BorderRadius.circular(24 * sizeUnit),
              ),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      style: SheepsTextStyle.b3().copyWith(fontSize: 14 * sizeUnit),
                      controller: _chatTfController,
                      focusNode: _focusNode,
                      textAlign: TextAlign.left,
                      textAlignVertical: TextAlignVertical.top,
                      textInputAction: TextInputAction.newline,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: "채팅 내용을 입력해주세요",
                        hintStyle: TextStyle(
                          color: sheepsColorGrey,
                          fontSize: 14 * sizeUnit,
                          fontWeight: FontWeight.normal,
                          height: 1.2,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.only(left: 12 * sizeUnit, bottom: 8 * sizeUnit, top: 8 * sizeUnit, right: 8 * sizeUnit),
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                      onChanged: (value){
                        setState(() {});
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      _sendButtonTap();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28 * sizeUnit),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 4 * sizeUnit, right: 4 * sizeUnit, top: 4 * sizeUnit, bottom: 4 * sizeUnit),
                        child: Container(
                          width: 28 * sizeUnit,
                          height: 28 * sizeUnit,
                          decoration: BoxDecoration(
                            color: _chatTfController!.text.length > 0 ? sheepsColorGreen : sheepsColorGrey,
                            borderRadius: BorderRadius.circular(20 * sizeUnit),
                          ),
                          child: Icon(
                            Icons.arrow_upward_rounded,
                            size: 24 * sizeUnit,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  int getRealMessageCount() {
    int realCnt = _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList.length;

    for (int i = 0; i < _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList.length; ++i) {
      if (_chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList[i].from == CENTER_MESSAGE) {
        realCnt -= 1;
      }
    }

    return realCnt;
  }

  _sendButtonTap() async {
    if (_chatTfController!.text.isEmpty) {
      return;
    }

    var dateUtc = DateTime.now().toUtc();
    String date = dateUtc.toLocal().hour.toString() + ":" + ((dateUtc.toLocal().minute < 10) ? "0" + dateUtc.toLocal().minute.toString() : dateUtc.toLocal().minute.toString());

    String userListStr = '';
    for (int i = 0; i < chatUserList.length; ++i) {
      if (i != 0) userListStr += '|';

      userListStr += chatUserList[i].userID.toString();
    }

    String dateTimeString = replacLocalUTCDate(DateTime.now().toUtc().toString());

    //보내는 날짜가 다르면
    if(_chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList.length != 0){
      if( ChatGlobal().getRoomChatDate(_chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList[_chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList.length - 1].updatedAt) !=
          ChatGlobal().getRoomChatDate(dateTimeString)){
        _chatGlobal!.insertChatDateData(ChatGlobal.currentRoomIndex, dateTimeString, chatIndex: _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList.length);
      }
    }

    //채팅고유값필요
    ChatRecvMessageModel chatRecvMessageModel = ChatRecvMessageModel(
        to: userListStr,
        from: GlobalProfile.loggedInUser!.userID,
        fromName: GlobalProfile.loggedInUser!.name,
        roomName: widget.roomName,
        message: _chatTfController!.text,
        isImage: 0,
        date: date,
        updatedAt: dateTimeString,
        createdAt: dateTimeString,
        roomId: _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].roomInfoID, chatId: 0
    );

    chatRecvMessageModel.isRead = 1;

    _socket!..socket!.emit("roomChatMessage", [chatRecvMessageModel.toJson()]);

    chatRecvMessageModel.date = dateUtc.toLocal().hour.toString() + ":" + dateUtc.toLocal().minute.toString();

    _addRecvMessage(0, chatRecvMessageModel, _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList.length - 1, true);
    _clearMessage();
  }

  _clearMessage() {
    _chatTfController!.text = '';
  }

  _addRecvMessage(id, ChatRecvMessageModel chatRecvMessageModel, int prevIndex, isRebuild) async {
    if (!kReleaseMode) print('Adding Message to UI ${chatRecvMessageModel.message}');

    chatRecvMessageModel.isContinue = chatRecvMessageModel.from == CENTER_MESSAGE ? false : true;

    if (chatRecvMessageModel.from == CENTER_MESSAGE) {
      _chatGlobal!.getRoomInfoList[ChatGlobal.currentRoomIndex].chatList.insert(prevIndex, chatRecvMessageModel);
    } else {
      await _chatGlobal!.addChatRecvMessage(chatRecvMessageModel, ChatGlobal.currentRoomIndex, doSort: false);
    }

    setContinue(chatRecvMessageModel, prevIndex, isRebuild);
  }

  void setContinue(ChatRecvMessageModel chatRecvMessageModel, int prevIndex, bool isRebuild) {
    _chatGlobal!.setContinue(chatRecvMessageModel, prevIndex, ChatGlobal.currentRoomIndex);

    if (this.mounted && isRebuild) {
      setState(() {});
    }

    if (isRebuild) {
      _chatListScrollToBottom();
    }
  }

  /// Scroll the Chat List when it goes to bottom
  _chatListScrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if(_chatLVController!.hasClients){
        _chatLVController!.jumpTo(_chatLVController!.position.maxScrollExtent);
      }
    });
  }

  Widget settingProfile(UserData user, {bool isMe = false}) {
    String name = user.name;

    bool bMajor = user.part == null || user.part == '';
    bool bLocation = user.location == null || user.location == '';

    if (!bMajor && !bLocation) {
      name = name + ' ( ' + user.part + ' / ' + user.location + ' )';
    } else if (!bMajor && bLocation) {
      name = name + ' ( ' + user.part + ' )';
    } else if (bMajor && !bLocation) {
      name = name + ' ( ' + user.location + ' )';
    }

    return Container(
      height: 48 * sizeUnit,
      child: Row(
        children: [
          if (user.profileImgList[0].imgUrl == "BasicImage") ...[
            if (widget.leaderID == user.userID) ...[
              GestureDetector(
                onTap: () {
                  Get.to(() => DetailProfile(index: 0, user: user));
                },
                child: badges.Badge(
                    badgeStyle: badges.BadgeStyle(
                      shape : badges.BadgeShape.circle,
                      badgeColor : sheepsColorGreen,
                      elevation : 0,
                      padding : EdgeInsets.all(1 * sizeUnit),
                    ),
                    position: badges.BadgePosition.topStart(top: 26 * sizeUnit, start: 26 * sizeUnit),
                    badgeContent: SvgPicture.asset(
                      svgLeader,
                    ),
                    child: Container(
                      width: 40 * sizeUnit,
                      height: 40 * sizeUnit,
                      decoration: BoxDecoration(
                        border: Border.all(color: sheepsColorLightGrey),
                        color:  Colors.white,
                        borderRadius: BorderRadius.circular(12*sizeUnit),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          svgSheepsBasicProfileImage,
                          width: 24 * sizeUnit,
                          height: 24 * sizeUnit,
                          color: sheepsColorBlue,
                        ),
                      ),
                    )
                ),
              )
            ] else ...[
              GestureDetector(
                onTap: () {
                  Get.to(() => DetailProfile(index: 0, user: user));
                },
                child:
                Container(
                    width: 40 * sizeUnit,
                    height: 40 * sizeUnit,
                    decoration: BoxDecoration(
                      border: Border.all(color: sheepsColorLightGrey),
                      color:  Colors.white,
                      borderRadius: BorderRadius.circular(12*sizeUnit),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        svgSheepsBasicProfileImage,
                        width: 24 * sizeUnit,
                        height: 24 * sizeUnit,
                        color: sheepsColorBlue,
                      ),
                    )
                ),
              ),
            ]
          ] else ...[
            if (widget.leaderID == user.userID) ...[
              GestureDetector(
                onTap: () {
                  Get.to(() => DetailProfile(index: 0, user: user));
                },
                child: badges.Badge(
                  badgeStyle: badges.BadgeStyle(
                    shape : badges.BadgeShape.circle,
                    badgeColor : sheepsColorGreen,
                    elevation : 0,
                    padding : EdgeInsets.all(1 * sizeUnit),
                  ),
                  position: badges.BadgePosition.topStart(top: 28 * sizeUnit, start: 28 * sizeUnit),
                  badgeContent: SvgPicture.asset(
                    svgLeader,
                  ),
                  child: Container(
                    width: 40 * sizeUnit,
                    height: 40 * sizeUnit,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(12 * sizeUnit),
                      child: FittedBox(
                        child: ExtendedImage.network(getOptimizeImageURL(user.profileImgList[0].imgUrl, 60)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              GestureDetector(
                onTap: () {
                  Get.to(() => DetailProfile(index: 0, user: user));
                },
                child: Container(
                  width: 40 * sizeUnit,
                  height: 40 * sizeUnit,
                  child: ClipRRect(
                    borderRadius: new BorderRadius.circular(12 * sizeUnit),
                    child: FittedBox(
                      child: ExtendedImage.network(getOptimizeImageURL(user.profileImgList[0].imgUrl, 60)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ]
          ],
          SizedBox(width: 8 * sizeUnit),
          if (isMe) ...[
            Container(
              width: 180 * sizeUnit,
              child: Row(
                children: [
                  SvgPicture.asset(
                    svgMeIcon,
                    width: 14 * sizeUnit,
                    height: 14 * sizeUnit,
                  ),
                  SizedBox(
                    width: 4 * sizeUnit,
                  ),
                  Text(
                    user.name,
                    style: SheepsTextStyle.b3(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              width: 180 * sizeUnit,
              child: Text(
                name,
                style: SheepsTextStyle.b3(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget settingColumn(String svg, String text, Function func) {
    return GestureDetector(
      onTap: () => func,
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: 360 * sizeUnit,
        height: 20 * sizeUnit,
        child: Row(
          children: [
            SvgPicture.asset(
              svg,
              width: 24 * sizeUnit,
              height: 24 * sizeUnit,
            ),
            SizedBox(
              width: 8 * sizeUnit,
            ),
            Text(text, style: SheepsTextStyle.b3()),
          ],
        ),
      ),
    );
  }

  // 리쿠르트 포스트 카드
  Widget _interviewBanner(bool isRecruit) {
    String title;
    List<String> firstWrapList = [];
    List<String> secondWrapList = [];
    String state;
    String contents;
    String photoURL;
    PersonalSeekTeam? personalSeekTeam;
    TeamMemberRecruit? teamMemberRecruit;

    if (isRecruit) {
      int firstIndex = "teamMemberID".length;
      int lastIndex = widget.roomName.lastIndexOf('userID');

      String sub = widget.roomName.substring(firstIndex, lastIndex);

      teamMemberRecruit = globalTeamMemberRecruitList.singleWhere((element) => element.id == int.parse(sub));
      Team team = GlobalProfile.getTeamByID(teamMemberRecruit.teamId);

      title = teamMemberRecruit.title.substring(0,teamMemberRecruit.title.lastIndexOf('||'));
      state = setPeriodState(teamMemberRecruit.recruitPeriodEnd);
      isMain = team.leaderID == GlobalProfile.loggedInUser!.userID ? true : false;
      firstWrapList.add(team.part);
      firstWrapList.add(team.location);
      firstWrapList.add(teamMemberRecruit.category);
      contents = teamMemberRecruit.recruitInfo;
      secondWrapList.add(teamMemberRecruit.recruitField);
      secondWrapList.add(teamMemberRecruit.education);
      secondWrapList.add(teamMemberRecruit.career);
      photoURL = team.profileImgList[0].imgUrl;
    } else {
      int firstIndex = "personalID".length;
      int lastIndex = widget.roomName.lastIndexOf('userID');

      String sub = widget.roomName.substring(firstIndex, lastIndex);

      personalSeekTeam = globalPersonalSeekTeamList.singleWhere((element) => element.id == int.parse(sub));
      UserData user = GlobalProfile.getUserByUserID(personalSeekTeam.userId);

      title = personalSeekTeam.title.substring(0, personalSeekTeam.title.lastIndexOf('||'));
      state = personalSeekTeam.seekingState == 1 ? "구직 중" : "구직완료";
      isMain = personalSeekTeam.userId == GlobalProfile.loggedInUser!.userID ? true : false;
      firstWrapList.add(user.part);
      firstWrapList.add(user.subPart);
      firstWrapList.add(user.location);
      contents = personalSeekTeam.selfInfo;

      String workFormFirst = personalSeekTeam.workFormFirst == '협의' ? '직급협의': personalSeekTeam.workFormFirst;
      secondWrapList.add(workFormFirst);
      String workDayOfWeek = personalSeekTeam.workDayOfWeek == '협의' ? '근무일협의' : personalSeekTeam.workDayOfWeek;
      secondWrapList.add(workDayOfWeek);
      String workTime = personalSeekTeam.workTime;
      if(workTime == '자율') workTime = '자율출퇴근';
      if(workTime == '협의') workTime = '근무시간협의';
      secondWrapList.add(workTime);
      photoURL = user.profileImgList[0].imgUrl;
    }

    return GestureDetector(
      onTap: () => Get.to(() => RecruitDetailPage(isRecruit: isRecruit, data: isRecruit ? teamMemberRecruit : personalSeekTeam,)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
        width: 360 * sizeUnit,
        height: isMain ? 148 * sizeUnit : 112 * sizeUnit,
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: sheepsColorGrey, width: 0.5))),
        child: Column(
          children: [
            SizedBox(height: 12 * sizeUnit,),
            Row(
              children: [
                if (photoURL == "BasicImage") ...[
                  Container(
                    width: 68 * sizeUnit,
                    height: 68 * sizeUnit,
                    decoration: BoxDecoration(
                      border: Border.all(color: sheepsColorGrey, width: 0.5),
                      borderRadius: BorderRadius.circular(16 * sizeUnit),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        svgSheepsBasicProfileImage,
                        width: 36 * sizeUnit,
                        height: 36 * sizeUnit,
                        color: isRecruit ? sheepsColorGreen : sheepsColorBlue,
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    width: 68 * sizeUnit,
                    height: 68 * sizeUnit,
                    decoration: BoxDecoration(
                      borderRadius: new BorderRadius.circular(8 * sizeUnit),
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: ClipRRect(
                        borderRadius: new BorderRadius.circular(8 * sizeUnit),
                        child: FittedBox(
                          child: ExtendedImage.network(getOptimizeImageURL(photoURL, 60)),
                          fit: BoxFit.cover,
                        )),
                  ),
                ],
                SizedBox(width: 20 * sizeUnit),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 194 * sizeUnit,
                            child: Text(
                              title,
                              style: SheepsTextStyle.h3(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            state,
                            style: SheepsTextStyle.bWriter().copyWith(
                              color: state == '모집마감' || state == '구직완료' ? sheepsColorGrey : isRecruit ? sheepsColorGreen : sheepsColorBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4 * sizeUnit),
                      Wrap(
                        runSpacing: 4 * sizeUnit,
                        spacing: 4 * sizeUnit,
                        children: [
                          wrapItem(firstWrapList[0], isRecruit: isRecruit, isColor: !isRecruit),
                          wrapItem(firstWrapList[1]),
                          wrapItem(firstWrapList[2]),
                        ],
                      ),
                      SizedBox(height: 6 * sizeUnit),
                      Container(
                        width: 194 * sizeUnit,
                        child: Text(
                          cutStringEnterMessage(contents),
                          overflow: TextOverflow.ellipsis,
                          style: SheepsTextStyle.b3().copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 6 * sizeUnit),
                      Wrap(
                        runSpacing: 4 * sizeUnit,
                        spacing: 4 * sizeUnit,
                        children: [
                          wrapItem(secondWrapList[0], isRecruit: isRecruit, isColor: isRecruit),
                          wrapItem(secondWrapList[1]),
                          wrapItem(secondWrapList[2]),
                        ],
                      ),

                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * sizeUnit,),
            if( isMain ) ... [
              GestureDetector(
                onTap: () async {
                  if(isRecruit){
                    if(recruitInviteController.getCurrRecruitInvite == null){
                      showSheepsCustomDialog(
                        title: Text(
                          "이미 응답한 인터뷰",
                          style: SheepsTextStyle.dialogTitle().copyWith(height: 1.2, fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        contents: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
                            children: [
                              TextSpan(text: '지원을 새로 해주시길 바랍니다.\n'),
                            ],
                          ),
                        ),
                        okButtonColor: sheepsColorGreen,
                      );
                    }else{
                      UserData? inviteUser = await GlobalProfile.getFutureUserByUserID(recruitInviteController.getCurrRecruitInvite.targetID);

                      if(inviteUser != null) {
                        Get.to(() => DetailProfile(index: 0, user: inviteUser, profileStatus: PROFILE_STATUS.Applicant,));
                      } else {
                        if(kDebugMode) print('userData null');
                      }
                    }
                  }else{
                    if(recruitInviteController.getCurrRecruitInvite == null){
                      showSheepsCustomDialog(
                        title: Text(
                          "이미 응답한 인터뷰",
                          style: SheepsTextStyle.dialogTitle().copyWith(height: 1.2, fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        contents: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
                            children: [
                              TextSpan(text: '지원을 새로 해주시길 바랍니다.\n'),
                            ],
                          ),
                        ),
                        okButtonColor: sheepsColorBlue,
                      );
                    }else{
                      Team invitingTeam = await GlobalProfile.getFutureTeamByID(recruitInviteController.getCurrRecruitInvite.targetID);

                      Get.to(() => DetailTeamProfile(index: 0, team: invitingTeam, proposedTeam: true,));
                    }
                  }
                },
                child: Container(
                  width: 328 * sizeUnit,
                  height: 32 * sizeUnit,
                  decoration: BoxDecoration(
                    color: isRecruit ? sheepsColorGreen : sheepsColorBlue,
                    borderRadius: new BorderRadius.circular(12*sizeUnit),
                  ),
                  child: Center(
                    child: Text(
                      "지원자 보기",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14*sizeUnit,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget wrapItem(String text, {bool isRecruit = true, bool isColor = false}) {
    if (text == null) return SizedBox.shrink();

    return Container(
      height: 16 * sizeUnit,
      padding: EdgeInsets.symmetric(horizontal: 4 * sizeUnit),
      decoration: BoxDecoration(
        color: isColor
            ? isRecruit
            ? sheepsColorGreen
            : sheepsColorBlue
            : sheepsColorLightGrey,
        borderRadius: BorderRadius.circular(6 * sizeUnit),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: SheepsTextStyle.bWriter().copyWith(color: isColor ? Colors.white : sheepsColorBlack),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
