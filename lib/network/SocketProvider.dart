import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/chat/models/ChatRecvMessageModel.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAbStractClass.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/FirebaseNotification.dart';
import 'package:sheeps_app/notification/models/LocalNotification.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketProvider extends GetxController with  StoppableService{
  static SocketProvider get to => Get.find();

  @override
  void start() {
    super.start();
    if(this._fromUser != null && stopCheck){
      socket!.emit('resumed',[{
        "userID" : GlobalProfile.loggedInUser.userID.toString(),
        "roomStatus" : roomStatus,
      }] );
      stopCheck = false;

      ApiProvider().post('/Fcm/BadgeCount/Reset', jsonEncode({
        "userID" : GlobalProfile.loggedInUser.userID
      }));
    }
  }

  @override
  void stop() {
    super.stop();
    if(this._fromUser != null){
      stopCheck = true;
      socket!.emit('paused',[{
        "userID" : GlobalProfile.loggedInUser.userID.toString(),
        "roomStatus" : roomStatus,
      }] );
    }
  }

  Socket? socket;

  UserData? _fromUser;

  int? roomStatus;
  int? prevRoomStatus;
  int get getRoomStatus => roomStatus!;

  bool stopCheck = false;

  ChatGlobal? _chatGlobal;
  ChatGlobal get getChatGlobal => _chatGlobal!;
  LocalNotification? _localNotification;
  SharedPreferences? prefs;

  static String _providerserverIP = 'ws://61.101.55.40';
  static int PROVIDER_SERVER_PORT = 20001;
  static String _connectUrl = '$_providerserverIP:$PROVIDER_SERVER_PORT';   //server와 연결

  static String ROOM_RECEIVED_EVENT = "room_list_receive_message";
  static String CHAT_RECEIVED_EVENT = "receive_message";
  static String ETC_RECEIVED_EVENT = "etc_receive_message";
  static String FORCE_LOGOUT_EVENT = "force_logout";

  initSocket(UserData fromUser) async {
    //async, await : 게으른 연산, 일단 함수가 실행되면 await로가서 처리를하고,
    // 데이터가 들어올때까지 기다리다가, 들어오면 또 처리, stream이 끝나거나 닫힐때 까지 반복

    debugPrint('Connecting user: ${fromUser.name}');
    this._fromUser = fromUser;
    await _init();
  }

  _init() async {
    socket = io(ApiProvider().getChatUrl,
        OptionBuilder()
            .setTransports(['websocket'])
            .setExtraHeaders({'from' : _fromUser!.userID}).build());

    socket!.connect();

    roomStatus = ROOM_STATUS_ETC;
    prevRoomStatus = roomStatus;
    prefs = await SharedPreferences.getInstance();

    setChatEvent();
  }

  setChatEvent(){
    socket!.on(SocketProvider.CHAT_RECEIVED_EVENT, (data) async {
      switch(roomStatus){ //ROOM_STATUS_ROOM
        case ROOM_STATUS_ROOM: //
          ChatRecvMessageModel chatRecvMessageModel = ChatRecvMessageModel.fromJson(data);

          if(chatRecvMessageModel.isImage != 0){
            if(data['isDirect'] == false){  //연결된 서버가 아니면
              var getImageData = await ApiProvider().post('/ChatLog/SelectImageData', jsonEncode({"id": chatRecvMessageModel.isImage}));

              if (getImageData != null) {
                chatRecvMessageModel.message = getImageData['Data'];
              }
            }
          }

          for(int i = 0 ; i < ChatGlobal.roomInfoList.length; ++i){
            if( ChatGlobal.roomInfoList[i].roomName == chatRecvMessageModel.roomName){
              chatRecvMessageModel.isRead = 0;
              await _chatGlobal!.addChatRecvMessage(chatRecvMessageModel, i);
              break;
            }
          }

          break;
        case ROOM_STATUS_CHAT: //ROOM_STATUS_CHAT
          ChatRecvMessageModel chatRecvMessageModel = ChatRecvMessageModel.fromJson(data);

          if(chatRecvMessageModel.isImage != 0){
            if(data['isDirect'] == false){  //연결된 서버가 아니면
              var getImageData = await ApiProvider().post('/ChatLog/SelectImageData', jsonEncode({"id": chatRecvMessageModel.isImage}));

              if (getImageData != null) {
                chatRecvMessageModel.message = getImageData['Data'];
              }
            }
          }

          for(int i = 0 ; i < ChatGlobal.roomInfoList.length; ++i){
            if( ChatGlobal.roomInfoList[i].roomName == chatRecvMessageModel.roomName){
              if(ChatGlobal.roomName == chatRecvMessageModel.roomName){
                chatRecvMessageModel.isRead = 1;
                _chatGlobal!.setContinue(chatRecvMessageModel, ChatGlobal.roomInfoList[i].chatList.length - 1, i);

                if(ChatGlobal.roomInfoList[i].chatList.length != 0){
                  if(ChatGlobal().getRoomChatDate(chatRecvMessageModel.updatedAt) != ChatGlobal().getRoomChatDate(ChatGlobal.roomInfoList[i].chatList[ChatGlobal.roomInfoList[i].chatList.length - 1].updatedAt)){
                    _chatGlobal!.insertChatDateData(ChatGlobal.currentRoomIndex, chatRecvMessageModel.updatedAt, chatIndex: ChatGlobal.roomInfoList[i].chatList.length );
                  }
                }

                await  _chatGlobal!.addChatRecvMessage(chatRecvMessageModel, i, doSort: false);
                _chatGlobal!.chatListScrollToBottom();
              }else{
                chatRecvMessageModel.isRead = 0;
                await  _chatGlobal!.addChatRecvMessage(chatRecvMessageModel, i, doSort: false);
                String notiMessage = chatRecvMessageModel.isImage != 0 ? "사진을 보냈습니다." : chatRecvMessageModel.message;

                globalNotificationType = "CHATROOM";

                if(FirebaseNotifications.isChatting == true && stopCheck == false && ChatGlobal.roomInfoList[i].isAlarm == 1){
                  Future.microtask(() async => await _localNotification!.showNoti(title: GlobalProfile.getUserByUserID(chatRecvMessageModel.from).name, des: notiMessage, payload: chatRecvMessageModel.roomName));
                }
              }
              break;
            }
          }
          break;

        case ROOM_STATUS_ETC: //ROOM_STATUS_ETC
          ChatRecvMessageModel chatRecvMessageModel = ChatRecvMessageModel.fromJson(data);

          if(chatRecvMessageModel.isImage != 0){
            if(data['isDirect'] == false){  //연결된 서버가 아니면
              var getImageData = await ApiProvider().post('/ChatLog/SelectImageData', jsonEncode({"id": chatRecvMessageModel.isImage}));

              if (getImageData != null) {
                chatRecvMessageModel.message = getImageData['Data'];
              }
            }
          }

          int roomIndex = 0;
          for(int i = 0 ; i < ChatGlobal.roomInfoList.length; ++i){
            if( ChatGlobal.roomInfoList[i].roomName == chatRecvMessageModel.roomName){
              chatRecvMessageModel.isRead = 0;
              roomIndex = i;
              await _chatGlobal!.addChatRecvMessage(chatRecvMessageModel, i);
              break;
            }
          }

          String notiMessage = chatRecvMessageModel.isImage != 0 ? "사진을 보냈습니다." : chatRecvMessageModel.message;

          globalNotificationType = "CHATROOM";

          //채팅 세팅 알람, background상태 체크, 해당 room 알림 체크
          if(FirebaseNotifications.isChatting == true && stopCheck == false && ChatGlobal.roomInfoList[roomIndex].isAlarm == 1){
            Future.microtask(() async => await _localNotification!.showNoti(title: GlobalProfile.getUserByUserID(chatRecvMessageModel.from).name, des: notiMessage,payload:  chatRecvMessageModel.roomName));
          }
          break;
      }

      update();

    });

    // socket.on(SocketProvider.FORCE_LOGOUT_EVENT, (data) async {
    //   await globalLogout(false, this.socket);
    //   return;
    // });

  }

  disconnect() async {
    this._fromUser = null;
    socket!.off(SocketProvider.CHAT_RECEIVED_EVENT);
    socket!.off(SocketProvider.FORCE_LOGOUT_EVENT);
    socket!.disconnect();
  }

  setRoomStatus(int status){
    prevRoomStatus = roomStatus;
    roomStatus = status;
  }

  setPrevStatus(){
    roomStatus = prevRoomStatus;
  }

  setLocalNotification(LocalNotification localNotification){
    _localNotification = localNotification;
  }

  setChatGlobal(ChatGlobal chatGlobal){
    _chatGlobal = chatGlobal;
  }
}