import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';

import '../models/ChatRecvMessageModel.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import './ChatDatabase.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import './Room.dart';
import 'package:sheeps_app/userdata/User.dart';


const int CENTER_MESSAGE = -1;
class ChatGlobal extends GetxController {
  static ChatGlobal get to => Get.find();

  // Single Chat - To Chat User
  static List<RoomInfo> roomInfoList = [RoomInfo()].obs;

  List<RoomInfo> get getRoomInfoList => roomInfoList;


  static UserData? toChatUser;
  static String? roomName;
  static bool bCheck = false;
  static int currentRoomIndex = -1;
  static SocketProvider? socket;
  static List<int> removeUserList = [];

  static RoomInfo? willRemoveRoom;

  static ScrollController? scrollController;

  Future<String> addChatRecvMessage(ChatRecvMessageModel chatRecvMessageModel, int index, {doSort = true}) async{
    if(chatRecvMessageModel.isRead.isOdd){
      roomInfoList[index].messageCount = 0;
    }else{
      roomInfoList[index].messageCount += 1;
    }

    String roomMessage = chatRecvMessageModel.message;

    if(chatRecvMessageModel.isImage != 0) roomMessage = "사진을 보냈습니다.";

    roomInfoList[index].date = setDateAmPm(chatRecvMessageModel.date, false, chatRecvMessageModel.updatedAt);
    roomInfoList[index].lastMessage = roomMessage;
    roomInfoList[index].updateAt = chatRecvMessageModel.updatedAt;
    roomInfoList[index].createdAt = chatRecvMessageModel.createdAt;
    chatRecvMessageModel.fileMessage = await ChatDBHelper().createData(chatRecvMessageModel);

    roomInfoList[index].chatList.add(chatRecvMessageModel);

    if(doSort){
      sortRoomInfoList();
    }

    return chatRecvMessageModel.message;
  }

  static sortRoomInfoList() {
    List<RoomInfo> list = roomInfoList;

    list.forEach((element) {
      if(element.updateAt == null){
        element.updateAt = getYearMonthDayByDate();
      }
    });

    list.sort((a,b) {
      return int.parse(b.updateAt).compareTo(int.parse(a.updateAt));
    });

    roomInfoList = list;
  }

  sortLocalRoomInfoList() {
    List<RoomInfo> list = roomInfoList;

    list.sort((a,b) => int.parse(b.updateAt).compareTo(int.parse(a.updateAt)));

    roomInfoList = list;
  }

  void setContinue(ChatRecvMessageModel chatRecvMessageModel, int prevIndex, int roomIndex){
    if(prevIndex > 0){
      if(chatRecvMessageModel.isContinue == false) return;
      if(roomInfoList[roomIndex].chatList[prevIndex].from != CENTER_MESSAGE){
        bool isContinue = (chatRecvMessageModel.from == roomInfoList[roomIndex].chatList[prevIndex].from) && (chatRecvMessageModel.date == roomInfoList[roomIndex].chatList[prevIndex].date);
        if(true == isContinue) {
          roomInfoList[roomIndex].chatList[prevIndex].isContinue = false;
        }
        else {
          roomInfoList[roomIndex].chatList[prevIndex].isContinue = true;
        }
      }
    }
  }

  int getMessageTotalCount(){
    int totalCnt = 0;

    for(int i = 0 ; i < roomInfoList.length; ++i){
      totalCnt += roomInfoList[i].messageCount;
    }

    return totalCnt;
  }

  static bool IsAlreadyRoom(RoomInfo room){
    for(int i = 0 ; i < roomInfoList.length; ++i){
      if(roomInfoList[i].roomName == room.roomName) return true;
    }

    return false;
  }

  static bool IsAlreadyRoomByRoomName(String roomName){
    bool isHave = false;
    roomInfoList.forEach((element) {
      if(element.roomName == roomName){
        isHave = true;
      }
    });

    return isHave;
  }

  static void AddTeamMember(int userID, String roomName){
    roomInfoList.forEach((element) {
      if(element.roomName == roomName){
        element.chatUserIDList.add(userID);
        return;
      }
    });
  }

  /// Scroll the Chat List when it goes to bottom
  void chatListScrollToBottom() {
    if(scrollController == null) return;

    Future.delayed(const Duration(milliseconds: 100), () {
      if(scrollController!.hasClients){
        scrollController!.jumpTo(scrollController!.position.maxScrollExtent);
      }
    });
  }

  static void kickOutTeamMemberInRoom(String roomName, int userID){

    RoomInfo? roomInfo;
    //방 찾아서, 팀원삭제하고 대화 인원이 없으면 방 폭파!
    roomInfoList.forEach((element) {
      if(element.roomName == roomName){
        element.chatUserIDList.removeWhere((element) => element == userID);
        if(element.chatUserIDList.length == 0 || GlobalProfile.loggedInUser.userID == userID){
          roomInfo = element;
        }
      }
    });

    if(roomInfo != null ){
      willRemoveRoom = roomInfo!;
    }

    removeUserList.add(userID);
  }

  void insertChatDateData(int index, String roomCreateDate, {int chatIndex = 0}){
    ChatRecvMessageModel roomCreateTime = ChatRecvMessageModel(
        to: CENTER_MESSAGE.toString(),
        from: CENTER_MESSAGE,
        roomName: "DATE_CHAT",
        message: roomCreateDate[0] + roomCreateDate[1] + roomCreateDate[2] + roomCreateDate[3] + "년 " + roomCreateDate[4] + roomCreateDate[5] + "월 " + roomCreateDate[6] + roomCreateDate[7] + "일",
        isImage: 0,
        date: '',
        isRead: 1,
        updatedAt: roomCreateDate, chatId: 0
    );

    roomInfoList[index].chatList.insert(chatIndex, roomCreateTime);
  }

  String getRoomChatDate(String updateAt){
    if(updateAt == null) {
      String now = DateTime.now().toString();
      return now[0] + now[1] + now[2] + now[3] + "년 " + now[5] + now[6] + "월 " + now[8] + now[9] + "일";
    }

    return updateAt[0] + updateAt[1] + updateAt[2] + updateAt[3] + "년 " + updateAt[4] + updateAt[5] + "월 " + updateAt[6] + updateAt[7] + "일";
  }

  int getMessageCountByList(List<RoomInfo> list){
    int cnt = 0;

    list.forEach((element) {cnt += element.messageCount;});

    return cnt;
  }
}

Future<String> base64ToFileURL(String base, String id) async {
  try {
    final decodedBytes = base64Decode(base);

    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    String name = DateFormat('yyyyMMddHHmmss').format(DateTime.now().toLocal());

    var file = File(documentsDirectory.path + '/' +  name + "_" + id + ".png");
    await file.writeAsBytes(decodedBytes);

    var fileUrl = file.path;
    return fileUrl;
  } catch (e) {
    return '';
  }
}