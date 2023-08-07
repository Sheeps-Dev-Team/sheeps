import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:get/get.dart';
import 'package:sheeps_app/Community/CommunityMainDetail.dart';
import 'package:sheeps_app/Community/CommunityReplyPage.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/chat/ChatPage.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/chat/models/ChatRecvMessageModel.dart';
import 'package:sheeps_app/chat/models/Room.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/SocketProvider.dart';

import 'package:sheeps_app/notification/models/LocalNotification.dart';
import 'package:sheeps_app/notification/models/LocalNotificationController.dart';
import 'package:sheeps_app/notification/models/NotiDatabase.dart';
import 'package:sheeps_app/notification/models/NotificationModel.dart';
import 'package:sheeps_app/notification/notificationPage.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';


bool isFirebaseCheck = false;
bool isLoadFirebase = false;
//Firebase관련 class
class FirebaseNotifications {
  static FirebaseMessaging _firebaseMessaging;
  static String _fcmToken = '';

  static bool isMarketing = false;
  static bool isChatting = false;
  static bool isTeam = false;
  static bool isCommunity = false;


  FirebaseMessaging get getFirebaseMessaging => _firebaseMessaging;
  SocketProvider socket;
  ChatGlobal _chatGlobal;
  LocalNotification localNotification;
  String get getFcmToken => _fcmToken;


  void setFcmToken (String token) {
    _fcmToken = token;
    isFirebaseCheck = false;
  }

  FirebaseNotifications(){
  }

  void setUpFirebase(BuildContext context) {
    if(isFirebaseCheck == false){
      isFirebaseCheck = true;
    }else{
      return;
    }

    localNotification = LocalNotificationController.to.localNotification;

    if(null == socket) socket = SocketProvider.to;
    if(null == _chatGlobal) _chatGlobal = ChatGlobal.to;

    Future.microtask(() async {

      await FirebaseMessaging.instance.requestPermission(sound: true, badge: true, alert: true, provisional: false);

      firebaseCloudMessaging_Listeners();
      return FirebaseMessaging.instance;
    }) .then((_) async{
      if(_fcmToken == ''){
        _fcmToken = await _.getToken();
        var res = await ApiProvider().post('/Fcm/Token/Save', jsonEncode({
          "userID" : GlobalProfile.loggedInUser.userID,
          "token" : _fcmToken,
        }));

        if(res != null){
          FirebaseNotifications.isMarketing = res['item']['Marketing'] == null ? true : res['item']['Marketing'];
          FirebaseNotifications.isChatting = res['item']['Chatting'] == null ? true : res['item']['Chatting'];
          FirebaseNotifications.isTeam = res['item']['Team'] == null ? true : res['item']['Team'];
          FirebaseNotifications.isCommunity = res['item']['Community'] == null ? true : res['item']['Community'];

          if(FirebaseNotifications.isMarketing){
            SetSubScriptionToTopic("SHEEPS_MARKETING");
          }else{
            SetUnSubScriptionToTopic("SHEEPS_MARKETING");
          }
        }
      }
      return;
    });
  }

  void firebaseCloudMessaging_Listeners() {

    if(isLoadFirebase == false){
      isLoadFirebase = true;
    }else{
      return;
    }

    FirebaseMessaging.instance.getToken().then((token) {
      debugPrint(token);

    });

    FirebaseMessaging.instance.getAPNSToken().then((value) =>
        debugPrint(value)
    );

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage message) {
      if(message != null){
        debugPrint(message.data.toString());
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint("firebase onMessage Call");
      List<String> strList = (message.data['body'] as String).split('|');

      NotificationModel notificationModel = NotificationModel(
        id:  int.parse(strList[0]),
        from: int.parse(strList[1]),
        to: int.parse(strList[2]),
        type: GetType(strList[3]),
        tableIndex: int.parse(strList[4]),
        targetIndex: int.parse(strList[5]),
        teamIndex: int.parse(strList[6]),
        time: strList[7],
        isRead: 0,
      );
      notificationModel.isSend = 0;

      //이미 해당하는 알림을 가지고 있으면
      //if(notiList.where((element) => element.id == notificationModel.id) != null) return;

      if(notificationModel.type == NOTI_EVENT_TEAM_INVITE || notificationModel.type == NOTI_EVENT_TEAM_INVITE_ACCEPT ||
          notificationModel.type == NOTI_EVENT_TEAM_REQUEST || notificationModel.type == NOTI_EVENT_TEAM_REQUEST_ACCEPT ||
          notificationModel.type == NOTI_EVENT_TEAM_REQUEST_REFUSE || notificationModel.type == NOTI_EVENT_TEAM_MEMBER_ADD
      ){
        notificationModel.teamRoomName = strList[8];

        if(strList[8] != null && strList[8] == 'null'){
          notificationModel.teamRoomName = null;
        }
      }

      NotificationModel replaceModel;
      if(notificationModel.type == NOTI_EVENT_TEAM_INVITE_ACCEPT){
        Team team;
        if(notificationModel.teamRoomName != null){
          team = GlobalProfile.getTeamByRoomName(notificationModel.teamRoomName);
        }
        else{
          team = GlobalProfile.getTeamByID(notificationModel.teamIndex);
        }

        var res = await ApiProvider().post('/Team/WithoutTeamList', jsonEncode(
            {
              "to" : notificationModel.to,
              "from" : notificationModel.from,
              "teamID" : team.id
            }
        ));

        List<int> chatList = [];

        if(res != null){
          for(int i = 0 ; i < res.length; ++i){
            chatList.add(res[i]['UserID']);
          }
        }
        replaceModel = await SetNotificationData(notificationModel, chatList);
      }
      else{
        replaceModel = await SetNotificationData(notificationModel, null);
      }

      if(isSaveNoti(replaceModel)){
        var id = await NotiDBHelper().createData(replaceModel);
        replaceModel.id = id;
        notiList.insert(0, replaceModel);

        globalNotificationType = message.data['screen'];

        if(isPossibleAlarm(notificationModel.type)){
          String payload = notificationModel.type == NOTI_EVENT_POST_REPLY_REPLY ? notificationModel.tableIndex.toString() + '|' + notificationModel.targetIndex.toString() : notificationModel.tableIndex.toString();

          await localNotification.showNoti(title: message.data['title'], des: message.data['notibody'], payload: payload);
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      debugPrint("firebase onMessageOpenedApp Call");
      FlutterAppBadger.removeBadge();

      if(isRecvData == false){
        isRecvData = true;
      }
      //lifecycle에서 는 데이터를 가져오지 않음.
      Future.microtask(() async {
        var notiListGet = await ApiProvider().post('/Notification/UnSendSelect', jsonEncode(
            {
              "userID": GlobalProfile.loggedInUser.userID,
            }
        ));

        if (null != notiListGet) {
          for (int i = 0; i < notiListGet.length; ++i) {
            NotificationModel notificationModel = NotificationModel.fromJson(notiListGet[i]);

            //알림 이벤트 가져오기 필요함
            NotificationModel replaceModel;
            if (notificationModel.type == NOTI_EVENT_TEAM_REQUEST_ACCEPT) {
              Team team = await GlobalProfile.getFutureTeamByID(notificationModel.teamIndex);

              var res = await ApiProvider().post('/Team/WithoutTeamList', jsonEncode(
                  {
                    "to": notificationModel.to,
                    "from": notificationModel.from,
                    "teamID": team.id
                  }
              ));

              List<int> chatList = [];

              if (res != null) {
                for (int i = 0; i < res.length; ++i) {
                  chatList.add(res[i]['UserID']);
                }
              }
              replaceModel = await SetNotificationData(notificationModel, chatList);
            }
            else {
              replaceModel = await SetNotificationData(notificationModel, null);
            }

            if(isSaveNoti(replaceModel)){
              var id = await NotiDBHelper().createData(replaceModel);
              replaceModel.id = id;
              notiList.insert(0,replaceModel);
            }
          }

          //채팅 가져오기 필요함
          var chatLogList = await ApiProvider().post('/ChatLog/UnSendSelect', jsonEncode(
              {
                "userID" : GlobalProfile.loggedInUser.userID
              }
          ));

          if(chatLogList != null){
            for(int i = 0 ; i < chatLogList.length; ++i){
              ChatRecvMessageModel message = ChatRecvMessageModel(
                chatId: chatLogList[i]['id'],
                roomName: chatLogList[i]['roomName'],
                to: chatLogList[i]['to'].toString(),
                from : chatLogList[i]['from'],
                message: chatLogList[i]['message'],
                date: chatLogList[i]['date'],
                isRead: 0,
                isImage: chatLogList[i]['isImage'],
                updatedAt: replaceUTCDate(chatLogList[i]['updatedAt']),
                createdAt: replaceUTCDate(chatLogList[i]['createdAt']),
              );

              if(message.isImage != 0){
                var getImageData = await ApiProvider().post('/ChatLog/SelectImageData', jsonEncode({"id": message.isImage}));

                if (getImageData != null) {
                  message.message = getImageData['Data'];

                  for(int i = 0 ; i < ChatGlobal.roomInfoList.length; ++i){
                    if(ChatGlobal.roomInfoList[i].roomName == message.roomName){
                      message.isRead = 0;
                      bool DoSort = true;
                      if(socket.getRoomStatus == ROOM_STATUS_CHAT){
                        DoSort = false;
                        if(ChatGlobal.currentRoomIndex == i){
                          message.isRead = 1;
                        }
                      }
                      message.isContinue = true;
                      await _chatGlobal.addChatRecvMessage(message, i, doSort: DoSort);

                      int prevIndex = ChatGlobal.roomInfoList[i].chatList.length > 2 ? ChatGlobal.roomInfoList[i].chatList.length - 2 : 0;

                      _chatGlobal.setContinue(message, prevIndex, i);
                      _chatGlobal.chatListScrollToBottom();

                    }
                  }
                }else{
                  message.isImage = 0;
                  message.message = "로드 할 수 없는 이미지 입니다.";
                }
              }else{
                for(int i = 0 ; i < ChatGlobal.roomInfoList.length; ++i){
                  if(ChatGlobal.roomInfoList[i].roomName == message.roomName){
                    message.isRead = 0;
                    bool DoSort = true;
                    if(socket.getRoomStatus == ROOM_STATUS_CHAT){
                      DoSort = false;
                      if(ChatGlobal.currentRoomIndex == i){
                        message.isRead = 1;
                      }
                    }
                    message.isContinue = true;
                    await _chatGlobal.addChatRecvMessage(message, i, doSort: DoSort);

                    int prevIndex = ChatGlobal.roomInfoList[i].chatList.length > 2 ? ChatGlobal.roomInfoList[i].chatList.length - 2 : 0;

                    _chatGlobal.setContinue(message, prevIndex, i);
                    _chatGlobal.chatListScrollToBottom();

                  }
                }
              }
            }
          }

          Get.appUpdate();
        }

        await screenControllFunc(message.data);
      });
    });
  }

  Future screenControllFunc(Map<String, dynamic> message) async {
    var screen = 'NOTIFICATION';
    List<String> list = [];

    screen = message['screen'] as String;

    socket.socket.emit('resumed',[{
      "userID" : GlobalProfile.loggedInUser.userID.toString(),
      "roomStatus" : ROOM_STATUS_ETC,
    }] );

    if(screen == 'CHATROOM'){
      var roomName = message['body'];

      socket.setRoomStatus(ROOM_STATUS_CHAT);

      for(int i = 0; i < ChatGlobal.roomInfoList.length; ++i){
        if(roomName == ChatGlobal.roomInfoList[i].roomName){

          if(ChatGlobal.currentRoomIndex != i){
            RoomInfo roomInfo = ChatGlobal.roomInfoList[i];

            Navigator.push(
                navigatorKey.currentContext,
                MaterialPageRoute(
                    builder: (context) => new ChatPage(
                        roomName: roomInfo.roomName,
                        titleName: roomInfo.name,
                        chatUserList: GlobalProfile.getUserListByUserIDList(roomInfo.chatUserIDList)))).then((value){
              socket.setPrevStatus();
            });
            break;
          }else if(ChatGlobal.currentRoomIndex == i){

          }
        }
      }
    }else{
      list = (message['body'] as String).split('|');

      NotificationModel notificationModel = NotificationModel(
        id:  int.parse(list[0]),
        from: int.parse(list[1]),
        to: int.parse(list[2]),
        type: GetType(list[3]),
        tableIndex: int.parse(list[4]),
        targetIndex: int.parse(list[5]),
        teamIndex: int.parse(list[6]),
        time: list[7],
        isRead: 0,
      );

      await loadNotificationFutureData(notificationModel);

      switch(screen){
        case "NOTIFICATION":
          {
            Navigator.push(
                navigatorKey.currentContext,
                // 기본 파라미터, SecondRoute로 전달
                MaterialPageRoute(
                    builder: (context) =>
                        TotalNotificationPage()));
          }
          break;
        case "COMMUNITY":
          {
            debugPrint('on COMMUNITY $list');

            var resCommunity = await ApiProvider().post('/CommunityPost/SelectID', jsonEncode({
              "id" : list[4]
            }));

            Community community = Community.fromJson(resCommunity);

            var tmp = await ApiProvider().post('/CommunityPost/PostSelect',jsonEncode({
              "id" : list[4],
            }));

            if (tmp == null) return;

            GlobalProfile.communityReply = [];
            for (int i = 0; i < tmp.length; i++) {
              Map<String, dynamic> data = tmp[i];
              CommunityReply tmpReply = CommunityReply.fromJson(data);
              await GlobalProfile.getFutureUserByUserID(tmpReply.userID);
              GlobalProfile.communityReply.add(tmpReply);
            }

            Navigator.push(
                navigatorKey.currentContext, // 기본 파라미터, SecondRoute로 전달
                MaterialPageRoute(
                    builder: (context) =>
                        CommunityMainDetail(community)));
          }
          break;
        case "COMMUNITY_REPLY":
          {
            debugPrint('on COMMUNITY $list');

            var resCommunity = await ApiProvider().post('/CommunityPost/SelectID', jsonEncode({
              "id" : list[4]
            }));

            Community community = Community.fromJson(resCommunity);

            var tmp = await ApiProvider().post('/CommunityPost/PostSelect',jsonEncode({
              "id" : list[4],
            }));

            if (tmp == null) return;

            GlobalProfile.communityReply = [];
            CommunityReply reply;
            for (int i = 0; i < tmp.length; i++) {
              Map<String, dynamic> data = tmp[i];
              CommunityReply tmpReply = CommunityReply.fromJson(data);
              await GlobalProfile.getFutureUserByUserID(tmpReply.userID);
              GlobalProfile.communityReply.add(tmpReply);
              if(int.parse(list[5]) == tmpReply.id) reply = tmpReply;
            }

            Get.to(() => CommunityReplyPage(communityReply: reply, community: community));
          }
          break;
      }
    }


  }

  showNotification(Map<String, dynamic> msg){
  }

  void SetSubScriptionToTopic(String topic){
    FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  void SetUnSubScriptionToTopic(String topic){
    FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }

  static void setSubScriptionToTopicClear(){
    FirebaseNotifications.isMarketing = false;
    FirebaseNotifications.isChatting = false;
    FirebaseNotifications.isTeam = false;
    FirebaseNotifications.isCommunity = false;

    FirebaseNotifications.globalSetUnSubScriptionToTopic("SHEEPS_MARKETING");


  }

  static void globalSetSubScriptionToTopic(String topic){
    FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  static void globalSetUnSubScriptionToTopic(String topic){
    FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }

  bool isPossibleAlarm(int type){
    bool isAlarm = true;
    switch(type){
      case NOTI_EVENT_INVITE:
      case NOTI_EVENT_INVITE_ACCEPT:
      case NOTI_EVENT_INVITE_REFUSE:
      case NOTI_EVENT_PROFILE_LIKE:
      case NOTI_EVENT_ROOM_LEAVE:
      case NOTI_EVENT_PERSONAL_UNIV_AUTH_UPDATE:
      case NOTI_EVENT_PERSONAL_GRADUATE_AUTH_UPDATE:
      case NOTI_EVENT_PERSONAL_CAREER_AUTH_UPDATE:
      case NOTI_EVENT_PERSONAL_WIN_AUTH_UPDATE:
      case NOTI_EVENT_PERSONAL_LICENSE_AUTH_UPDATE:
      case NOTI_EVENT_PERSONAL_GET_BADGE:
        {
          if(FirebaseNotifications.isChatting == false) isAlarm = false;
        }
        break;
      case NOTI_EVENT_TEAM_INVITE:
      case NOTI_EVENT_TEAM_INVITE_ACCEPT:
      case NOTI_EVENT_TEAM_INVITE_REFUSE:
      case NOTI_EVENT_TEAM_REQUEST:
      case NOTI_EVENT_TEAM_REQUEST_ACCEPT:
      case NOTI_EVENT_TEAM_REQUEST_REFUSE:
      case NOTI_EVENT_TEAM_MEMBER_KICKED_OUT:
      case NOTI_EVENT_TEAM_MEMBER_LEAVE:
      case NOTI_EVENT_TEAM_LIKE:
      case NOTI_EVENT_TEAM_MEMBER_ADD:
      case NOTI_EVENT_INVITE_PERSONALSEEKTEAM:
      case NOTI_EVENT_INVITE_PERSONALSEEKTEAM_ACCEPT:
      case NOTI_EVENT_INVITE_PERSONALSEEKTEAM_REFUSE:
      case NOTI_EVENT_INVITE_TEAMMEMBERRECRUIT:
      case NOTI_EVENT_INVITE_TEAMMEMBERRECRUIT_ACCEPT:
      case NOTI_EVENT_INVITE_TEAMMEMBERRECRUIT_REFUSE:
      case NOTI_EVENT_TEAM_AUTH_AUTH_UPDATE:
      case NOTI_EVENT_TEAM_PERFORMANCE_AUTH_UPDATE:
      case NOTI_EVENT_TEAM_WIN_AUTH_UPDATE:
      case NOTI_EVENT_TEAM_GET_BADGE:
        {
            if(FirebaseNotifications.isTeam == false) isAlarm = false;
        }
        break;
      case NOTI_EVENT_POST_LIKE:
      case NOTI_EVENT_POST_REPLY:
      case NOTI_EVENT_POST_REPLY_LIKE:
      case NOTI_EVENT_POST_REPLY_REPLY:
      case NOTI_EVENT_POST_REPLY_REPLY_LIKE:
        {
          if(FirebaseNotifications.isCommunity == false) isAlarm = false;
        }
        break;
      default:
        {
          if(FirebaseNotifications.isMarketing == false) isAlarm = false;
        }
        break;

    }

    return isAlarm;
  }
}