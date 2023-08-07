import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:sheeps_app/Recruit/Models/RecruitLikes.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/notification/models/NotificationModel.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';

import 'ChatRecvMessageModel.dart';

class Room {
  String roomName;
  List<int> chatUserIDList;

  Room(String str, {this.roomName, this.chatUserIDList});
}

class RoomInfo {
  String name;
  String roomName;
  String lastMessage;
  String date;
  String profileImage;
  int messageCount;
  int type;
  int roomUserID;
  int roomInfoID;
  int isAlarm;
  bool isPersonal;
  List<ChatRecvMessageModel> chatList;
  List<int> chatUserIDList;
  String updateAt;
  String createdAt;

  RoomInfo({this.name, this.roomName, this.lastMessage, this.date, this.profileImage, this.messageCount, this.type, this.isPersonal, this.chatList, this.chatUserIDList, this.updateAt, this.createdAt});
}

Future<RoomInfo> SetPersonalSeekTeamRoomInfo(RoomInfo roomInfo) async {
  RoomInfo tempRoom = roomInfo;
  var res = await ApiProvider().post('/Matching/Select/InvitingPersonalSeekTeamUserByID', jsonEncode({
    "id" : roomInfo.roomName.substring(roomInfo.roomName.lastIndexOf('D') + 1, roomInfo.roomName.length)
  }));

  if(res == null) return Future.value(tempRoom);

  RecruitInvite recruitInvite = RecruitInvite.fromJson(res,isUserID: false);

  Team team = GlobalProfile.getTeamByID(recruitInvite.targetID,);

  tempRoom.name = team.name;
  tempRoom.profileImage = team.profileImgList[0].imgUrl;
  return Future.value(tempRoom);
}

Future<RoomInfo> SetRoomInfoData(NotificationModel model, {int roomType = 1}) async {
  List<int> chatList = [];
  chatList.add(model.from);

  RoomInfo roomInfo = RoomInfo();
  String updatedDate;

  if(roomType == ROOM_TYPE_TEAM){
    Team team;
    if(model.teamRoomName != null){
      team = await GlobalProfile.getFutureTeamByRoomName(model.teamRoomName);
    }
    else{
      team = await GlobalProfile.getFutureTeamByID(model.teamIndex);
    }

    updatedDate = model.time.replaceAll('-', '').replaceAll(':', '').replaceAll('.', '').replaceAll(' ', '');
    if(updatedDate.length > 14) updatedDate = updatedDate.substring(0, 14);

    roomInfo.name = team.name;
    roomInfo.roomName =  model.teamRoomName;
    roomInfo.date = setDateAmPm(updatedDate[8] + updatedDate[9] + ":" + updatedDate[10] + updatedDate[11], false, updatedDate);
    roomInfo.profileImage = team.profileImgList[0].imgUrl == null ? "BasicImage" : team.profileImgList[0].imgUrl;
    roomInfo.isPersonal = false;
  }else{
    DateTime date = new DateFormat("yyyy-MM-dd HH:mm:ss").parse( model.time, true);
    updatedDate = model.time.replaceAll('-', '').replaceAll(':', '').replaceAll('.', '').replaceAll(' ', '');

    //년월시간분초
    if(updatedDate.length > 14) updatedDate = updatedDate.substring(0, 14);

    roomInfo.name = GlobalProfile.getUserByUserID(model.from).name;
    int id1 = roomType == ROOM_TYPE_PERSONAL ? model.to : model.targetIndex;
    int id2 = roomType == ROOM_TYPE_TEAM_MEMBER_RECRUIT ? model.to : model.from;
    int id3 = model.tableIndex;

    roomInfo.roomName = model.teamRoomName == null ? getRoomName(id1, id2, ID3: id3, roomType: roomType) : model.teamRoomName;
    roomInfo.date = setDateAmPm(date.hour.toString() + ":" + date.minute.toString(), false, updatedDate);
    roomInfo.profileImage = GlobalProfile.getUserByUserID(model.from).profileImgList[0].imgUrl == null ? "BasicImage" : GlobalProfile.getUserByUserID(model.from).profileImgList[0].imgUrl;
    roomInfo.isPersonal = true;

    if(roomType == ROOM_TYPE_PERSONAL_SEEK_TEAM){
      Team team;
      team = await GlobalProfile.getFutureTeamByID(model.teamIndex);
      if(team != null){ //예외처리
        roomInfo.name = team.name;
        roomInfo.profileImage = team.profileImgList[0].imgUrl;
      }
    }
  }
  roomInfo.lastMessage = "";
  roomInfo.messageCount = 0;
  roomInfo.chatList = [];
  roomInfo.isAlarm = 1;
  roomInfo.type = roomType;
  roomInfo.chatUserIDList = chatList;
  roomInfo.updateAt = updatedDate;
  roomInfo.createdAt = updatedDate;
  
  await ApiProvider().post('/Room/Info/Select', jsonEncode({
    "userID" : GlobalProfile.loggedInUser.userID,
    "roomName" : roomInfo.roomName
  })).then((value) => {
    if(value != null){
      roomInfo.roomInfoID = value['RoomID'],
      roomInfo.roomUserID = value['RoomUsers'][0]['id'] as int
    }
  });

  return Future.value(roomInfo);
}

const int ROOM_TYPE_PERSONAL = 1;
const int ROOM_TYPE_TEAM = 2;
const int ROOM_TYPE_PERSONAL_SEEK_TEAM = 3;
const int ROOM_TYPE_TEAM_MEMBER_RECRUIT = 4;
const int ROOM_TYPE_EXPERT = 5;