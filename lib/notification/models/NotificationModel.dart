import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';

import 'package:sheeps_app/Community/CommunityMainDetail.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/Recruit/Controller/RecruitController.dart';
import 'package:sheeps_app/Recruit/Models/PersonalSeekTeams.dart';
import 'package:sheeps_app/Recruit/Models/RecruitLikes.dart';
import 'package:sheeps_app/Recruit/Models/TeamMemberRecruit.dart';
import 'package:sheeps_app/Recruit/PersonalSeekTeamsEditPage.dart';
import 'package:sheeps_app/Recruit/RecruitDetailPage.dart';
import 'package:sheeps_app/Recruit/ExpandableFab.dart';
import 'package:sheeps_app/Recruit/RecruitTeamSelectionPage.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/chat/models/ChatDatabase.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/chat/models/ChatRecvMessageModel.dart';
import 'package:sheeps_app/chat/models/Room.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/NavigationNum.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/notification/models/NotiDatabase.dart';
import 'package:sheeps_app/profile/DetailProfile.dart';
import 'package:sheeps_app/profile/DetailTeamProfile.dart';
import 'package:sheeps_app/profile/MyTeamProfile.dart';
import 'package:sheeps_app/profile/models/ProfileState.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';

class NotificationModel {
  int id;
  int from;
  int to;
  int type;
  int tableIndex;
  int targetIndex;
  int teamIndex;
  String time;
  String teamRoomName;
  int isRead;
  int isSend;
  String createdAt;
  String updatedAt;
  bool isLoad;

  NotificationModel(
      {
        this.id = 0,
      this.from = 0,
      this.to = 0,
      this.type = 0,
      this.tableIndex = 0,
      this.targetIndex = 0,
      this.teamIndex = 0,
      this.time = '',
      this.teamRoomName = '',
      this.isRead = 0,
      this.isSend = 0,
      this.createdAt = '',
      this.updatedAt = '',
      this.isLoad = false});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
        id: json['id'] as int,
        from: json['UserID'] as int,
        to: json['TargetID'] as int,
        type: GetType(json['Type'] as String),
        tableIndex: json['TableIndex'] as int,
        targetIndex: json['TargetIndex'] as int,
        teamIndex: json['TeamIndex'] as int,
        time: json['Time'] as String,
        isRead: 0,
        isSend: 0,
        createdAt: replaceUTCDate(json["createdAt"] as String),
        updatedAt: replaceUTCDate(json["updatedAt"] as String),
        teamRoomName: '');
  }

  Map<String, dynamic> toJson(String roomName, int response) => {
        'id': id,
        'from': from,
        'to': to,
        'type': type,
        'tableIndex': tableIndex,
        'targetIndex': targetIndex,
        'teamIndex': teamIndex,
        'time': time,
        'isRead': isRead,
        'isSend': isSend,
        'roomName': roomName,
        'response': response,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

List<NotificationModel> notiList = [];

Future SetHandLoginNotificationListByEvent() async {
  var notiListGet = await ApiProvider().post(
      '/Notification/HandLoginSelect',
      jsonEncode({
        "userID": GlobalProfile.loggedInUser!.userID,
      }));

  if (null != notiListGet) {
    for (int i = 0; i < notiListGet.length; ++i) {
      NotificationModel noti = NotificationModel.fromJson(notiListGet[i]);
      notiList.add(noti);
      await NotiDBHelper().createData(noti);
    }
  }

  notiList = notiList.reversed.toList();
}

Future SetNotificationListByEvent() async {
  var notiListGet = await ApiProvider().post(
      '/Notification/UnSendSelect',
      jsonEncode({
        "userID": GlobalProfile.loggedInUser!.userID,
      }));

  if (null != notiListGet) {
    for (int i = 0; i < notiListGet.length; ++i) {
      NotificationModel noti = NotificationModel.fromJson(notiListGet[i]);
      notiList.add(noti);
      await NotiDBHelper().createData(noti);
    }
  }
}

Future setTeamIDAtNotiTeamRoomName() async {
  for (int i = 0; i < notiList.length; ++i) {
    switch (notiList[i].type) {
      case NOTI_EVENT_TEAM_AUTH_AUTH_UPDATE:
        var res = await ApiProvider().post('/Team/Select/Auth', jsonEncode({"id": notiList[i].tableIndex}));

        if (res != null) {
          TeamAuth teamAuth = TeamAuth.fromJson(res);
          notiList[i].teamRoomName = teamAuth.teamID.toString();
        }
        break;
      case NOTI_EVENT_TEAM_PERFORMANCE_AUTH_UPDATE:
        var res = await ApiProvider().post('/Team/Select/Performance', jsonEncode({"id": notiList[i].tableIndex}));

        if (res != null) {
          TeamPerformances teamPerformances = TeamPerformances.fromJson(res);
          notiList[i].teamRoomName = teamPerformances.teamID.toString();
        }
        break;
      case NOTI_EVENT_TEAM_WIN_AUTH_UPDATE:
        var res = await ApiProvider().post('/Team/Select/Win', jsonEncode({"id": notiList[i].tableIndex}));

        if (res != null) {
          TeamWins teamWins = TeamWins.fromJson(res);
          notiList[i].teamRoomName = teamWins.teamID.toString();
        }
        break;
      default:
        break;
    }
  }
}

//로컬에서 알림 추가할 때
addLocalNotification(int type, {required int teamIndex}) {
  NotificationModel notification = NotificationModel(
    type: type,
    from: -1,
    teamIndex: teamIndex,
    time: replacLocalUTCDate(DateTime.now().toUtc().toString()),
    updatedAt: replacLocalUTCDate(DateTime.now().toUtc().toString()),
    createdAt: replacLocalUTCDate(DateTime.now().toUtc().toString()),
  );
  notification.isRead = 0;
  notification.isSend = 0;
  notification.isLoad = true;

  notiList.add(notification);
}

const int INVITE_ACCEPT = 1;
const int INVITE_REFUSE = 2;

const int NOTI_EVENT_INVITE = 1; //채팅 초
const int NOTI_EVENT_INVITE_ACCEPT = 2; //채팅 초대 수락
const int NOTI_EVENT_INVITE_REFUSE = 3; //채팅 초대 거절
const int NOTI_EVENT_TEAM_INVITE = 4; //팀 초대(사용안함) -- recruite로 merge
const int NOTI_EVENT_TEAM_INVITE_ACCEPT = 5; //팀 초대 수락
const int NOTI_EVENT_TEAM_INVITE_REFUSE = 6; //팀 초대 거절(사용안함) -- recruite로 merge
const int NOTI_EVENT_TEAM_REQUEST = 7; //팀이 초대(사용안함) -- recruite로 merge
const int NOTI_EVENT_TEAM_REQUEST_ACCEPT = 8; //팀이 초대 수락(사용안함) -- recruite로 merge
const int NOTI_EVENT_TEAM_REQUEST_REFUSE = 9; //팀이 초대 거절(사용안함) -- recruite로 merge
const int NOTI_EVENT_TEAM_MEMBER_KICKED_OUT = 10; //팀원 추방하기
const int NOTI_EVENT_TEAM_MEMBER_LEAVE = 11; //팀원 나가기
const int NOTI_EVENT_ROOM_LEAVE = 12; //채팅방 나가기
const int NOTI_EVENT_PROFILE_LIKE = 13; //개인 프로필 좋아요(사용안함)
const int NOTI_EVENT_TEAM_LIKE = 14; //팀 프로필 좋아요(사용안함)
const int NOTI_EVENT_POST_LIKE = 15; //게시글 좋아요
const int NOTI_EVENT_POST_REPLY = 16; //댓글
const int NOTI_EVENT_POST_REPLY_LIKE = 17; //댓글 좋아요(사용안함)
const int NOTI_EVENT_POST_REPLY_REPLY = 18; //대댓글
const int NOTI_EVENT_POST_REPLY_REPLY_LIKE = 19; //대댓글 좋아요(사용안함)
const int NOTI_EVENT_TEAM_MEMBER_ADD = 20; //팀원 추가
const int NOTI_EVENT_PERSONAL_UNIV_AUTH_UPDATE = 21; //개인 학력 인증 update
const int NOTI_EVENT_PERSONAL_GRADUATE_AUTH_UPDATE = 22; //개인 학력이랑 merge됨(사용안함)
const int NOTI_EVENT_PERSONAL_CAREER_AUTH_UPDATE = 23; //개인 경력 인증 update
const int NOTI_EVENT_PERSONAL_LICENSE_AUTH_UPDATE = 24; //개인 자격증 인증 update
const int NOTI_EVENT_PERSONAL_WIN_AUTH_UPDATE = 25; //개인 수상 인증 update
const int NOTI_EVENT_TEAM_AUTH_AUTH_UPDATE = 26; //팀 인증 인증 update
const int NOTI_EVENT_TEAM_PERFORMANCE_AUTH_UPDATE = 27; //팀 수행내역 인증 update
const int NOTI_EVENT_TEAM_WIN_AUTH_UPDATE = 28; //팀 수상 인증 update
const int NOTI_EVENT_PERSONAL_GET_BADGE = 29; //개인 뱃지 획득
const int NOTI_EVENT_TEAM_GET_BADGE = 30; //팀 뱃지 획득
const int NOTI_EVENT_INVITE_PERSONALSEEKTEAM = 31; //팀 찾기 리쿠르트 초대
const int NOTI_EVENT_INVITE_PERSONALSEEKTEAM_ACCEPT = 32; //팀 찾기 리쿠르트 수락
const int NOTI_EVENT_INVITE_PERSONALSEEKTEAM_REFUSE = 33; //팀 찾기 리쿠르트 거절
const int NOTI_EVENT_INVITE_TEAMMEMBERRECRUIT = 34; //팀 루크르트 초대
const int NOTI_EVENT_INVITE_TEAMMEMBERRECRUIT_ACCEPT = 35; //팀 리쿠르트 초대 수락
const int NOTI_EVENT_INVITE_TEAMMEMBERRECRUIT_REFUSE = 36; //팀 리쿠르트 초대 거절
const int NOTI_EVENT_DELETE_PERSONALSEEKTEAM_POST = 37; //팀원 찾기 리쿠르트 삭제
const int NOTI_EVENT_DELETE_TEAMMEMBERRECRUIT_POST = 38; //팀 찾기 리쿠르트 삭제

//내부 알림들
const int NOTI_EVENT_INTERNAL_PERSON_PROFILE_1 = 101; //개인프로필 분야 정보 없을 때
const int NOTI_EVENT_INTERNAL_PERSON_PROFILE_2 = 102; //프로필사진 없을 때
const int NOTI_EVENT_INTERNAL_PERSON_PROFILE_3 = 103; //이력 없을 때
const int NOTI_EVENT_INTERNAL_PERSON_COMMUNITY = 104; //커뮤니티 활동 기록이 없을 때..?
const int NOTI_EVENT_INTERNAL_PERSON_RECRUIT_WRITE = 105; //개인 리쿠르트를 써보세요.
const int NOTI_EVENT_INTERNAL_PERSON_RECRUIT_READ = 106; //팀 리쿠르트에서 팀을 찾아보세요.

const int NOTI_EVENT_INTERNAL_TEAM_PROFILE_1 = 111; //팀이 하나도 없을 때?
const int NOTI_EVENT_INTERNAL_TEAM_PROFILE_2 = 112; //팀장인 팀이 프로필사진이 없을 때
const int NOTI_EVENT_INTERNAL_TEAM_PROFILE_3 = 113; //팀장인 팀이 이력이 없을 때? 처음 만들자마자 이력이 없는게 당연한데 매번 띄우나?
const int NOTI_EVENT_INTERNAL_TEAM_RECRUIT_WRITE = 115; //팀 리투르트를 써보세요.
const int NOTI_EVENT_INTERNAL_TEAM_RECRUIT_READ = 116; //개인 리쿠르트에서 멤버를 영입해보세요.

const int NOTI_EVENT_INTERNAL_REMIND_INVITE = 121; //채팅요청 응답 리마인드
const int NOTI_EVENT_INTERNAL_REMIND_INVITE_PERSONALSEEKTEAM = 122; //개인 리쿠르트 면접 요청 응답 리마인드
const int NOTI_EVENT_INTERNAL_REMIND_INVITE_TEAMMEMBERRECRUIT = 123; //팀 리쿠르트 면접 요청 응답 리마인드
const int NOTI_EVENT_INTERNAL_REMIND_INVITE_PERSONALSEEKTEAM_ACCEPT = 124; //개인 리쿠르트 응답 리마인드(합격 불합격)
const int NOTI_EVENT_INTERNAL_REMIND_INVITE_TEAMMEMBERRECRUIT_ACCEPT = 125; //팀 리쿠르트 응답 리마인드(합격 불합격)

int GetType(String typeStr) {
  int type = 0;
  switch (typeStr) {
    case "INVITE":
      type = NOTI_EVENT_INVITE;
      break;
    case "INVITE_ACCEPT":
      type = NOTI_EVENT_INVITE_ACCEPT;
      break;
    case "INVITE_REFUSE":
      type = NOTI_EVENT_INVITE_REFUSE;
      break;
    case "TEAM_INVITE":
      type = NOTI_EVENT_TEAM_INVITE;
      break;
    case "TEAM_INVITE_ACCEPT":
      type = NOTI_EVENT_TEAM_INVITE_ACCEPT;
      break;
    case "TEAM_INVITE_REFUSE":
      type = NOTI_EVENT_TEAM_INVITE_REFUSE;
      break;
    case "TEAM_REQUEST":
      type = NOTI_EVENT_TEAM_REQUEST;
      break;
    case "TEAM_REQUEST_ACCEPT":
      type = NOTI_EVENT_TEAM_REQUEST_ACCEPT;
      break;
    case "TEAM_REQUEST_REFUSE":
      type = NOTI_EVENT_TEAM_REQUEST_REFUSE;
      break;
    case "TEAM_MEMBER_KICKED_OUT":
      type = NOTI_EVENT_TEAM_MEMBER_KICKED_OUT;
      break;
    case "TEAM_MEMBER_LEAVE":
      type = NOTI_EVENT_TEAM_MEMBER_LEAVE;
      break;
    case "ROOM_LEAVE":
      type = NOTI_EVENT_ROOM_LEAVE;
      break;
    case "PROFILE_LIKE":
      type = NOTI_EVENT_PROFILE_LIKE;
      break;
    case "TEAM_LIKE":
      type = NOTI_EVENT_TEAM_LIKE;
      break;
    case "POST_LIKE":
      type = NOTI_EVENT_POST_LIKE;
      break;
    case "POST_REPLY":
      type = NOTI_EVENT_POST_REPLY;
      break;
    case "POST_REPLY_LIKE":
      type = NOTI_EVENT_POST_REPLY_LIKE;
      break;
    case "POST_REPLY_REPLY":
      type = NOTI_EVENT_POST_REPLY_REPLY;
      break;
    case "POST_REPLY_REPLY_LIKE":
      type = NOTI_EVENT_POST_REPLY_REPLY_LIKE;
      break;
    case "TEAM_MEMBER_ADD":
      type = NOTI_EVENT_TEAM_MEMBER_ADD;
      break;
    case "PERSONAL_UNIV_AUTH_UPDATE":
      type = NOTI_EVENT_PERSONAL_UNIV_AUTH_UPDATE;
      break;
    case "PERSONAL_GRADUATE_AUTH_UPDATE":
      type = NOTI_EVENT_PERSONAL_GRADUATE_AUTH_UPDATE;
      break;
    case "PERSONAL_CAREER_AUTH_UPDATE":
      type = NOTI_EVENT_PERSONAL_CAREER_AUTH_UPDATE;
      break;
    case "PERSONAL_LICENSE_AUTH_UPDATE":
      type = NOTI_EVENT_PERSONAL_LICENSE_AUTH_UPDATE;
      break;
    case "PERSONAL_WIN_AUTH_UPDATE":
      type = NOTI_EVENT_PERSONAL_WIN_AUTH_UPDATE;
      break;
    case "TEAM_AUTH_AUTH_UPDATE":
      type = NOTI_EVENT_TEAM_AUTH_AUTH_UPDATE;
      break;
    case "TEAM_PERFORMANCE_AUTH_UPDATE":
      type = NOTI_EVENT_TEAM_PERFORMANCE_AUTH_UPDATE;
      break;
    case "TEAM_WIN_AUTH_UPDATE":
      type = NOTI_EVENT_TEAM_WIN_AUTH_UPDATE;
      break;
    case "PERSONAL_GET_BADGE":
      type = NOTI_EVENT_PERSONAL_GET_BADGE;
      break;
    case "TEAM_GET_BADGE":
      type = NOTI_EVENT_TEAM_GET_BADGE;
      break;
    case "INVITE_PERSONALSEEKTEAM":
      type = NOTI_EVENT_INVITE_PERSONALSEEKTEAM;
      break;
    case "INVITE_PERSONALSEEKTEAM_ACCEPT":
      type = NOTI_EVENT_INVITE_PERSONALSEEKTEAM_ACCEPT;
      break;
    case "INVITE_PERSONALSEEKTEAM_REFUSE":
      type = NOTI_EVENT_INVITE_PERSONALSEEKTEAM_REFUSE;
      break;
    case "INVITE_TEAMMEMBERRECRUIT":
      type = NOTI_EVENT_INVITE_TEAMMEMBERRECRUIT;
      break;
    case "INVITE_TEAMMEMBERRECRUIT_ACCEPT":
      type = NOTI_EVENT_INVITE_TEAMMEMBERRECRUIT_ACCEPT;
      break;
    case "INVITE_TEAMMEMBERRECRUIT_REFUSE":
      type = NOTI_EVENT_INVITE_TEAMMEMBERRECRUIT_REFUSE;
      break;
    case "DELETE_PERSONALSEEKTEAM_POST":
      type = NOTI_EVENT_DELETE_PERSONALSEEKTEAM_POST;
      break;
    case "DELETE_TEAMMEMBERRECRUIT_POST":
      type = NOTI_EVENT_DELETE_TEAMMEMBERRECRUIT_POST;
      break;
    default:
      type = 0;
      break;
  }

  return type;
}

bool isPersonalNotification(int type) {
  bool res = false;
  switch (type) {
    case NOTI_EVENT_INVITE:
    case NOTI_EVENT_INVITE_ACCEPT:
    case NOTI_EVENT_INVITE_REFUSE:
    case NOTI_EVENT_POST_REPLY:
    case NOTI_EVENT_POST_REPLY_REPLY:
    case NOTI_EVENT_POST_LIKE:
    case NOTI_EVENT_POST_REPLY_LIKE:
    case NOTI_EVENT_POST_REPLY_REPLY_LIKE:
    case NOTI_EVENT_PROFILE_LIKE:
    case NOTI_EVENT_TEAM_INVITE_ACCEPT:
    case NOTI_EVENT_TEAM_INVITE_REFUSE:
    case NOTI_EVENT_TEAM_REQUEST:
    case NOTI_EVENT_TEAM_LIKE:
    case NOTI_EVENT_TEAM_MEMBER_KICKED_OUT:
    case NOTI_EVENT_TEAM_MEMBER_LEAVE:
    case NOTI_EVENT_ROOM_LEAVE:
    case NOTI_EVENT_TEAM_MEMBER_ADD:
    case NOTI_EVENT_PERSONAL_UNIV_AUTH_UPDATE:
    case NOTI_EVENT_PERSONAL_GRADUATE_AUTH_UPDATE:
    case NOTI_EVENT_PERSONAL_CAREER_AUTH_UPDATE:
    case NOTI_EVENT_PERSONAL_LICENSE_AUTH_UPDATE:
    case NOTI_EVENT_PERSONAL_WIN_AUTH_UPDATE:
    case NOTI_EVENT_TEAM_AUTH_AUTH_UPDATE:
    case NOTI_EVENT_TEAM_WIN_AUTH_UPDATE:
    case NOTI_EVENT_TEAM_PERFORMANCE_AUTH_UPDATE:
    case NOTI_EVENT_PERSONAL_GET_BADGE:
    case NOTI_EVENT_TEAM_GET_BADGE:
    case NOTI_EVENT_INVITE_PERSONALSEEKTEAM:
    case NOTI_EVENT_INVITE_PERSONALSEEKTEAM_ACCEPT:
    case NOTI_EVENT_INVITE_PERSONALSEEKTEAM_REFUSE:
    case NOTI_EVENT_INVITE_TEAMMEMBERRECRUIT:
    case NOTI_EVENT_INVITE_TEAMMEMBERRECRUIT_ACCEPT:
    case NOTI_EVENT_INVITE_TEAMMEMBERRECRUIT_REFUSE:
    case NOTI_EVENT_DELETE_PERSONALSEEKTEAM_POST:
    case NOTI_EVENT_DELETE_TEAMMEMBERRECRUIT_POST:
      res = true;
      break;
    case NOTI_EVENT_TEAM_INVITE:
    case NOTI_EVENT_TEAM_REQUEST_ACCEPT:
    case NOTI_EVENT_TEAM_REQUEST_REFUSE:
      res = false;
      break;
  }

  return res;
}

bool isSaveNoti(NotificationModel model) {
  bool isSave = true;

  if (model.type == NOTI_EVENT_ROOM_LEAVE) {
    isSave = false;
  }

  return isSave;
}

Future<NotificationModel> SetNotificationData(NotificationModel pModel, List<int> chatList) async {
  NotificationModel model = pModel;

  switch (model.type) {
    case NOTI_EVENT_INVITE_ACCEPT:
      RoomInfo room = await SetRoomInfoData(model);

      if (false == ChatGlobal.IsAlreadyRoom(room)) {
        ChatGlobal.roomInfoList.insert(0, room);
        if(ChatGlobal.currentRoomIndex != -1){
          ChatGlobal.currentRoomIndex += 1;
        }
      }
      break;
    case NOTI_EVENT_TEAM_INVITE_ACCEPT:
      bool isRoom = false;
      int index = 0;

      Team team;
      team = await GlobalProfile.getFutureTeamByID(model.teamIndex);
      model.teamRoomName = getRoomName(team.id, team.leaderID, roomType: ROOM_TYPE_TEAM);

      for (int i = 0; i < ChatGlobal.roomInfoList.length; ++i) {
        if (ChatGlobal.roomInfoList[i].roomName == model.teamRoomName) {
          ChatGlobal.roomInfoList[i].chatUserIDList.add(model.from);
          GlobalProfile.getTeamByRoomName(model.teamRoomName).userList.add(model.from);
          index = i;
          isRoom = true;
          break;
        }
      }

      if (false == isRoom) {
        ChatGlobal.roomInfoList.insert(0, await SetRoomInfoData(model, roomType: ROOM_TYPE_TEAM));
        if(ChatGlobal.currentRoomIndex != -1){
          ChatGlobal.currentRoomIndex += 1;
        }
      }

      if (chatList != null) {
        for (int i = 0; i < chatList.length; ++i) {
          ChatGlobal.roomInfoList[index].chatUserIDList.add(chatList[i]);
        }
      }

      GlobalProfile.AddTeamUser(model.teamIndex, model.from);

      break;
    case NOTI_EVENT_TEAM_REQUEST_ACCEPT:
      bool isRoom = false;
      int index = 0;

      for (int i = 0; i < ChatGlobal.roomInfoList.length; ++i) {
        if (ChatGlobal.roomInfoList[i].roomName == model.teamRoomName) {
          ChatGlobal.roomInfoList[i].chatUserIDList.add(model.from);
          GlobalProfile.getTeamByRoomName(model.teamRoomName).userList.add(model.from);
          isRoom = true;
          index = i;
          break;
        }
      }

      if (false == isRoom) {
        ChatGlobal.roomInfoList.insert(0, await SetRoomInfoData(model, roomType: ROOM_TYPE_TEAM));
      }

      if (chatList != null) {
        for (int i = 0; i < chatList.length; ++i) {
          ChatGlobal.roomInfoList[index].chatUserIDList.add(chatList[i]);
        }
      }

      GlobalProfile.AddTeamUser(model.teamIndex, model.from);

      break;
    case NOTI_EVENT_TEAM_MEMBER_KICKED_OUT:
      Team team = GlobalProfile.getTeamByID(model.teamIndex);
      var roomName = getRoomName(team.id, team.leaderID, roomType: ROOM_TYPE_TEAM);

      //채팅 방에서 나가기
      for (int i = 0; i < ChatGlobal.roomInfoList.length; ++i) {
        if (ChatGlobal.roomInfoList[i].roomName == roomName) {
          ChatGlobal.roomInfoList[i].chatUserIDList.removeWhere((element) => element == model.targetIndex);

          if (GlobalProfile.loggedInUser!.userID == model.targetIndex || ChatGlobal.roomInfoList[i].chatUserIDList.length == 0) {
            ChatGlobal.roomInfoList.removeAt(i);
            break;
          } else {
            Future.microtask(() async {
              UserData? user = await GlobalProfile.getFutureUserByUserID(model.targetIndex);

              ChatRecvMessageModel chatRecvMessageModel = ChatRecvMessageModel(
                to: CENTER_MESSAGE.toString(),
                from: CENTER_MESSAGE,
                roomName: ChatGlobal.roomInfoList[i].roomName,
                message: user!.name + " 이 팀을 나갔습니다.",
                isImage: 0,
                date: "",
                isRead: 1, chatId: 0,
              );
              chatRecvMessageModel.isContinue = true;
            });
          }
        }
      }

      //전역 팀 프로필에서 나가기
      GlobalProfile.teamProfile.forEach((element) {
        if (element.id == team.id) {
          element.userList.removeWhere((element) => element == model.targetIndex);
        }
      });
      break;
    case NOTI_EVENT_TEAM_MEMBER_LEAVE:
      {
        Team team = GlobalProfile.getTeamByID(model.teamIndex);
        var roomName = getRoomName(team.id, team.leaderID, roomType: ROOM_TYPE_TEAM);

        ChatGlobal.roomInfoList.forEach((element) {
          if (element.roomName == roomName) {
            element.chatUserIDList.removeWhere((element) => element == model.from);

            if (element.chatUserIDList.length == 0) {
              ChatGlobal.roomInfoList.remove(element);
            } else {
              Future.microtask(() async {
                UserData? user = await GlobalProfile.getFutureUserByUserID(model.from);

                ChatRecvMessageModel chatRecvMessageModel = ChatRecvMessageModel(
                  to: CENTER_MESSAGE.toString(),
                  from: CENTER_MESSAGE,
                  roomName: element.roomName,
                  message: user!.name + " 이 팀을 나갔습니다.",
                  isImage: 0,
                  date: "",
                  isRead: 1, chatId: 0,
                );
                chatRecvMessageModel.isContinue = true;

                ChatDBHelper().createData(chatRecvMessageModel);
              });
            }
          }
        });
      }
      break;
    case NOTI_EVENT_ROOM_LEAVE:
      {
        ChatGlobal.roomInfoList.forEach((element) {
          if (element.roomInfoID == model.targetIndex) {
            UserData user = GlobalProfile.getUserByUserID(model.from);

            //채팅 방을 나간 곳이 현재 대화를 나누던 중인 방이면 지역 초대장 초기화
            if(ChatGlobal.roomName == element.roomName){
              RecruitInviteController recruitInviteController = Get.put(RecruitInviteController());
              //recruitInviteController.currRecruitInvite = null;
            }

            ChatRecvMessageModel chatRecvMessageModel = ChatRecvMessageModel(
                to: CENTER_MESSAGE.toString(), from: CENTER_MESSAGE, roomName: element.roomName, message: user.name + " 이 채팅방을 나갔습니다.", isImage: 0, date: "", isRead: 1, updatedAt: model.updatedAt, chatId: 0);

            chatRecvMessageModel.isContinue = true;

            ChatDBHelper().createData(chatRecvMessageModel);

            element.chatList.add(chatRecvMessageModel); //채팅에 글 등록
            element.roomInfoID = -1;
            element.roomUserID = -1;
            element.isAlarm = 0;
            return;
          }
        });
      }
      break;
    case NOTI_EVENT_TEAM_MEMBER_ADD: //팀원 추가

      Team team = GlobalProfile.getTeamByID(model.teamIndex);
      String roomName = getRoomName(team.id, team.leaderID, roomType: ROOM_TYPE_TEAM);

      ChatGlobal.roomInfoList.forEach((element) {
        if (element.roomName == roomName) {
          element.chatUserIDList.add(model.from);

          UserData user = GlobalProfile.getUserByUserID(model.from);

          ChatRecvMessageModel chatRecvMessageModel = ChatRecvMessageModel(
            to: CENTER_MESSAGE.toString(),
            from: CENTER_MESSAGE,
            roomName: element.roomName,
            message: user.name + " 이 팀에 가입하였습니다.",
            isImage: 0,
            date: "",
            isRead: 1, chatId: 0,
          );
          chatRecvMessageModel.isContinue = true;

          element.chatList.add(chatRecvMessageModel);

          GlobalProfile.AddTeamUser(model.teamIndex, model.from);
        }
      });

      break;
    case NOTI_EVENT_PERSONAL_UNIV_AUTH_UPDATE:
      Future.microtask(() async {
        var res = await ApiProvider().post('/Personal/Select/Univ', jsonEncode({"id": model.tableIndex}));

        if (res != null) {
          UserEducation education = UserEducation.fromJson(res);

          int index = GlobalProfile.loggedInUser!.userEducationList.indexWhere((element) => element.id == education.id);

          GlobalProfile.loggedInUser!.userEducationList[index].auth = education.auth;
          model.tableIndex = education.id;
        }
      });
      break;
    case NOTI_EVENT_PERSONAL_CAREER_AUTH_UPDATE:
      Future.microtask(() async {
        var res = await ApiProvider().post('/Personal/Select/Career', jsonEncode({"id": model.tableIndex}));

        if (res != null) {
          UserCareer career = UserCareer.fromJson(res);

          int index = GlobalProfile.loggedInUser!.userCareerList.indexWhere((element) => element.id == career.id);

          GlobalProfile.loggedInUser!.userCareerList[index].auth = career.auth;
          model.tableIndex = career.id;
        }
      });

      break;
    case NOTI_EVENT_PERSONAL_LICENSE_AUTH_UPDATE:
      Future.microtask(() async {
        var res = await ApiProvider().post('/Personal/Select/License', jsonEncode({"id": model.tableIndex}));

        if (res != null) {
          UserLicense license = UserLicense.fromJson(res);

          int index = GlobalProfile.loggedInUser!.userLicenseList.indexWhere((element) => element.id == license.id);

          GlobalProfile.loggedInUser!.userLicenseList[index].auth = license.auth;
          model.tableIndex = license.id;
        }
      });
      break;
    case NOTI_EVENT_PERSONAL_WIN_AUTH_UPDATE:
      Future.microtask(() async {
        var res = await ApiProvider().post('/Personal/Select/Win', jsonEncode({"id": model.tableIndex}));

        if (res != null) {
          UserWin win = UserWin.fromJson(res);

          int index = GlobalProfile.loggedInUser!.userWinList.indexWhere((element) => element.id == win.id);

          GlobalProfile.loggedInUser!.userWinList[index].auth = win.auth;
          model.tableIndex = win.id;
          model.teamRoomName = index.toString();
        }
      });
      break;
    case NOTI_EVENT_TEAM_AUTH_AUTH_UPDATE:
      Future.microtask(() async {
        var res = await ApiProvider().post('/Team/Select/Auth', jsonEncode({"id": model.tableIndex}));

        if (res != null) {
          TeamAuth teamAuth = TeamAuth.fromJson(res);

          int index = GlobalProfile.teamProfile.indexWhere((element) => element.id == teamAuth.teamID);

          int authIndex = GlobalProfile.teamProfile[index].teamAuthList.indexWhere((element) => element.id == teamAuth.id);

          GlobalProfile.teamProfile[index].teamAuthList[authIndex].auth = teamAuth.auth;
          model.tableIndex = teamAuth.id;
          model.teamRoomName = index.toString();
        }
      });
      break;
    case NOTI_EVENT_TEAM_PERFORMANCE_AUTH_UPDATE:
      Future.microtask(() async {
        var res = await ApiProvider().post('/Team/Select/Performance', jsonEncode({"id": model.tableIndex}));

        if (res != null) {
          TeamPerformances teamPerformances = TeamPerformances.fromJson(res);

          int index = GlobalProfile.teamProfile.indexWhere((element) => element.id == teamPerformances.id);

          int performanceIndex = GlobalProfile.teamProfile[index].teamPerformList.indexWhere((element) => element.id == teamPerformances.id);

          GlobalProfile.teamProfile[index].teamPerformList[performanceIndex].auth = teamPerformances.auth;
          model.tableIndex = teamPerformances.id;
          model.teamRoomName = index.toString();
        }
      });
      break;
    case NOTI_EVENT_TEAM_WIN_AUTH_UPDATE:
      Future.microtask(() async {
        var res = await ApiProvider().post('/Team/Select/Win', jsonEncode({"id": model.tableIndex}));

        if (res != null) {
          TeamWins teamWins = TeamWins.fromJson(res);

          int index = GlobalProfile.teamProfile.indexWhere((element) => element.id == teamWins.id);

          int winIndex = GlobalProfile.teamProfile[index].teamWinList.indexWhere((element) => element.id == teamWins.id);

          GlobalProfile.teamProfile[index].teamWinList[winIndex].auth = teamWins.auth;
          model.tableIndex = teamWins.auth;
        }
      });
      break;
    case NOTI_EVENT_PERSONAL_GET_BADGE:
      {}
      break;
    case NOTI_EVENT_TEAM_GET_BADGE:
      {}
      break;
    case NOTI_EVENT_INVITE_PERSONALSEEKTEAM_ACCEPT:
      {
        RoomInfo room = await SetRoomInfoData(model, roomType: ROOM_TYPE_PERSONAL_SEEK_TEAM);

        if (false == ChatGlobal.IsAlreadyRoom(room)) {
          ChatGlobal.roomInfoList.insert(0, room);
          if(ChatGlobal.currentRoomIndex != -1){
            ChatGlobal.currentRoomIndex += 1;
          }
        }
      }
      break;
    case NOTI_EVENT_INVITE_TEAMMEMBERRECRUIT_ACCEPT:
      {
        RoomInfo room = await SetRoomInfoData(model, roomType: ROOM_TYPE_TEAM_MEMBER_RECRUIT);

        if (false == ChatGlobal.IsAlreadyRoom(room)) {
          ChatGlobal.roomInfoList.insert(0, room);
          if(ChatGlobal.currentRoomIndex != -1){
            ChatGlobal.currentRoomIndex += 1;
          }
        }
      }
      break;
    case NOTI_EVENT_DELETE_PERSONALSEEKTEAM_POST:
      {
        //채팅방 삭제
        ChatGlobal.roomInfoList.removeWhere((element) => element.roomName.contains("personalID" + model.targetIndex.toString()));

        //게시글 삭제
        globalTeamMemberRecruitList.removeWhere((element) => element.id == model.targetIndex);
      }
      break;
    case NOTI_EVENT_DELETE_TEAMMEMBERRECRUIT_POST:
      {
        //채팅방 삭제
        ChatGlobal.roomInfoList.removeWhere((element) => element.roomName.contains("teamMemberID" + model.targetIndex.toString()));

        //게시글 삭제
        globalTeamMemberRecruitList.removeWhere((element) => element.id == model.targetIndex);
      }
      break;
  }

  return model;
}

Future notiClickEvent(BuildContext context, NotificationModel notificationModel, ProfileState profileState, NavigationNum navigationNum, RecruitInviteController recruitInviteController) async {
  final navigationNum = Get.put(NavigationNum());
  final RecruitController recruitController = Get.put(RecruitController());

  switch (notificationModel.type) {
    case NOTI_EVENT_PROFILE_LIKE:
    case NOTI_EVENT_INVITE:
    case NOTI_EVENT_INVITE_ACCEPT:
    case NOTI_EVENT_INVITE_REFUSE:
    case NOTI_EVENT_TEAM_LIKE:
    case NOTI_EVENT_TEAM_REQUEST:
    case NOTI_EVENT_TEAM_INVITE_REFUSE:
    case NOTI_EVENT_TEAM_MEMBER_ADD:
      UserData user = GlobalProfile.getUserByUserID(notificationModel.from);

      if (user != null) {
        Get.to(()=>DetailProfile(index: 0, user: user));
      }
      break;

    case NOTI_EVENT_TEAM_INVITE_ACCEPT:
      NotificationModel model = notificationModel;
      Team team = await GlobalProfile.getFutureTeamByID(model.teamIndex);
      Get.to(()=>DetailTeamProfile(index: 0, team: team));
      break;
    case NOTI_EVENT_TEAM_REQUEST_ACCEPT:
    case NOTI_EVENT_TEAM_REQUEST_REFUSE:
    case NOTI_EVENT_TEAM_INVITE:
      Team team;
      if (notificationModel.teamRoomName != null && notificationModel.teamRoomName != 'null') {
        team = GlobalProfile.getTeamByRoomName(notificationModel.teamRoomName);
      } else {
        team = GlobalProfile.getTeamByID(notificationModel.teamIndex);
      }

      if (team != null) {
        Get.to(() => DetailTeamProfile(index: 0, team: team));
      }
      break;
    case NOTI_EVENT_POST_LIKE:
    case NOTI_EVENT_POST_REPLY:
    case NOTI_EVENT_POST_REPLY_LIKE:
    case NOTI_EVENT_POST_REPLY_REPLY:
    case NOTI_EVENT_POST_REPLY_REPLY_LIKE:
      var resCommunity = await ApiProvider().post('/CommunityPost/SelectID', jsonEncode({"id": notificationModel.tableIndex}));

      if (resCommunity != null) {
        Community community = Community.fromJson(resCommunity);

        var tmp = await ApiProvider().post('/CommunityPost/PostSelect', jsonEncode({"id": community.id}));

        if (tmp == null) return;

        GlobalProfile.communityReply = [];
        for (int i = 0; i < tmp.length; i++) {
          Map<String, dynamic> data = tmp[i];
          CommunityReply tmpReply = CommunityReply.fromJson(data);
          GlobalProfile.communityReply.add(tmpReply);
        }

        Navigator.push(
            navigatorKey.currentContext!, // 기본 파라미터, SecondRoute로 전달
            CupertinoPageRoute(builder: (context) => CommunityMainDetail(community)));
      }
      break;
    case NOTI_EVENT_PERSONAL_UNIV_AUTH_UPDATE:
      UserEducation education = GlobalProfile.loggedInUser!.userEducationList.singleWhere((element) => element.id == notificationModel.tableIndex);

      if (null == education) {
        debugPrint("PERSONAL UNIV AUTH DATA ERROR");
      } else {
        if (education.auth == 0 && notificationModel.isRead == 0) {
          showSheepsDialog(
            context: context,
            title: '반려 사유',
            description: '- 흔들림, 빛반사 등으로 인한 글씨판독 불가\n- 입력된 정보와 상이한 내용의 인증서류\n- 인증 유효기간 초과\n- 기타 유효하지 않은 인증서류\n\n'
                '위와 같은 이유로 반려되었습니다.\n삭제 후 다시 등록해주세요!',
            isCancelButton: false,
          );
        } else {
          Get.to(() => DetailProfile(index: 0, profileStatus: PROFILE_STATUS.MyProfile));
        }
      }
      break;
    case NOTI_EVENT_PERSONAL_CAREER_AUTH_UPDATE:
      UserCareer career = GlobalProfile.loggedInUser!.userCareerList.singleWhere((element) => element.id == notificationModel.tableIndex);

      if (null == career) {
        debugPrint("PERSONAL CAREER AUTH DATA ERROR");
      } else {
        if (career.auth == 0 && notificationModel.isRead == 0) {
          showSheepsDialog(
            context: context,
            title: '반려 사유',
            description: '- 흔들림, 빛반사 등으로 인한 글씨판독 불가\n- 입력된 정보와 상이한 내용의 인증서류\n- 인증 유효기간 초과\n- 기타 유효하지 않은 인증서류\n\n'
                '위와 같은 이유로 반려되었습니다.\n삭제 후 다시 등록해주세요!',
            isCancelButton: false,
          );
        } else {
          Get.to(() => DetailProfile(index: 0, profileStatus: PROFILE_STATUS.MyProfile));
        }
      }
      break;
    case NOTI_EVENT_PERSONAL_LICENSE_AUTH_UPDATE:
      UserLicense license = GlobalProfile.loggedInUser!.userLicenseList.singleWhere((element) => element.id == notificationModel.tableIndex);

      if (null == license) {
        debugPrint("PERSONAL LICENSE AUTH DATA ERROR");
      } else {
        if (license.auth == 0 && notificationModel.isRead == 0) {
          showSheepsDialog(
            context: context,
            title: '반려 사유',
            description: '- 흔들림, 빛반사 등으로 인한 글씨판독 불가\n- 입력된 정보와 상이한 내용의 인증서류\n- 인증 유효기간 초과\n- 기타 유효하지 않은 인증서류\n\n'
                '위와 같은 이유로 반려되었습니다.\n삭제 후 다시 등록해주세요!',
            isCancelButton: false,
          );
        } else {
          Get.to(() => DetailProfile(index: 0, profileStatus: PROFILE_STATUS.MyProfile));
        }
      }
      break;
    case NOTI_EVENT_PERSONAL_WIN_AUTH_UPDATE:
      UserWin win = GlobalProfile.loggedInUser!.userWinList.singleWhere((element) => element.id == notificationModel.tableIndex);

      if (null == win) {
        debugPrint("PERSONAL WIN AUTH DATA ERROR");
      } else {
        if (win.auth == 0 && notificationModel.isRead == 0) {
          showSheepsDialog(
            context: context,
            title: '반려 사유',
            description: '- 흔들림, 빛반사 등으로 인한 글씨판독 불가\n- 입력된 정보와 상이한 내용의 인증서류\n- 인증 유효기간 초과\n- 기타 유효하지 않은 인증서류\n\n'
                '위와 같은 이유로 반려되었습니다.\n삭제 후 다시 등록해주세요!',
            isCancelButton: false,
          );
        } else {
          Get.to(() => DetailProfile(index: 0, profileStatus: PROFILE_STATUS.MyProfile));
        }
      }
      break;
    case NOTI_EVENT_TEAM_AUTH_AUTH_UPDATE:
      Team team = GlobalProfile.teamProfile.singleWhere((element) => element.id == notificationModel.teamIndex);
      TeamAuth teamAuth = team.teamAuthList.singleWhere((element) => element.id == notificationModel.tableIndex);

      if (null == teamAuth) {
        debugPrint("PERSONAL WIN AUTH DATA ERROR");
      } else {
        if (teamAuth.auth == 0 && notificationModel.isRead == 0) {
          showSheepsDialog(
            context: context,
            title: '반려 사유',
            description: '- 흔들림, 빛반사 등으로 인한 글씨판독 불가\n- 입력된 정보와 상이한 내용의 인증서류\n- 인증 유효기간 초과\n- 기타 유효하지 않은 인증서류\n\n'
                '위와 같은 이유로 반려되었습니다.\n삭제 후 다시 등록해주세요!',
            isCancelButton: false,
          );
        } else {
          Get.to(() => DetailTeamProfile(
                index: 0,
                team: team,
              ));
        }
      }
      break;
    case NOTI_EVENT_TEAM_PERFORMANCE_AUTH_UPDATE:
      Team team = GlobalProfile.teamProfile.singleWhere((element) => element.id == notificationModel.teamIndex);
      TeamPerformances teamPerformances = team.teamPerformList.singleWhere((element) => element.id == notificationModel.tableIndex);

      if (null == teamPerformances) {
        debugPrint("PERSONAL WIN AUTH DATA ERROR");
      } else {
        if (teamPerformances.auth == 0 && notificationModel.isRead == 0) {
          showSheepsDialog(
            context: context,
            title: '반려 사유',
            description: '- 흔들림, 빛반사 등으로 인한 글씨판독 불가\n- 입력된 정보와 상이한 내용의 인증서류\n- 인증 유효기간 초과\n- 기타 유효하지 않은 인증서류\n\n'
                '위와 같은 이유로 반려되었습니다.\n삭제 후 다시 등록해주세요!',
            isCancelButton: false,
          );
        } else {
          Get.to(() => DetailTeamProfile(index: 0, team: team));
        }
      }
      break;
    case NOTI_EVENT_TEAM_WIN_AUTH_UPDATE:
      Team team = GlobalProfile.teamProfile.singleWhere((element) => element.id == notificationModel.teamIndex);
      TeamWins teamWins = team.teamWinList.singleWhere((element) => element.id == notificationModel.tableIndex);

      if (null == teamWins) {
        debugPrint("PERSONAL WIN AUTH DATA ERROR");
      } else {
        if (teamWins.auth == 0 && notificationModel.isRead == 0) {
          showSheepsDialog(
            context: context,
            title: '반려 사유',
            description: '- 흔들림, 빛반사 등으로 인한 글씨판독 불가\n- 입력된 정보와 상이한 내용의 인증서류\n- 인증 유효기간 초과\n- 기타 유효하지 않은 인증서류\n\n'
                '위와 같은 이유로 반려되었습니다.\n삭제 후 다시 등록해주세요!',
            isCancelButton: false,
          );
        } else {
          Get.to(() => DetailTeamProfile(index: 0, team: team));
        }
      }
      break;
    case NOTI_EVENT_PERSONAL_GET_BADGE:
      {
        showPersonalBadgeDialog(badgeID: notificationModel.targetIndex);
      }
      break;
    case NOTI_EVENT_TEAM_GET_BADGE:
      {
        showTeamBadgeDialog(badgeID: notificationModel.targetIndex);
      }
      break;
    case NOTI_EVENT_INVITE_PERSONALSEEKTEAM:
      {
        var res = await ApiProvider().post('/Matching/Select/InvitingPersonalSeekTeamUserByID', jsonEncode({"id": notificationModel.tableIndex}));

        if (res == null) {
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
        } else {
          Team team = GlobalProfile.getTeamByID(notificationModel.teamIndex);

          recruitInviteController.setCurrRecruitInvite(0, recruitInvite: RecruitInvite.fromJson(res, isUserID: false));

          if (null == team) {
            debugPrint("NOTI_EVENT_INVITE_PERSONALSEEKTEAM_ACCEPT DATA ERROR");
          } else {
            Get.to(() => DetailTeamProfile(
                  index: 0,
                  team: team,
                  proposedTeam: true,
                ));
          }
        }
      }
      break;
    case NOTI_EVENT_INVITE_PERSONALSEEKTEAM_ACCEPT:
      PersonalSeekTeam personalSeekTeam = globalPersonalSeekTeamList.singleWhere((element) => element.id == notificationModel.targetIndex);

      if (null == personalSeekTeam) {
        debugPrint("NOTI_EVENT_INVITE_PERSONALSEEKTEAM_ACCEPT DATA ERROR");
      } else {
        Get.to(() => RecruitDetailPage(isRecruit: false, data: personalSeekTeam));
      }

      break;
    case NOTI_EVENT_INVITE_TEAMMEMBERRECRUIT:
      {
        var res = await ApiProvider().post('/Matching/Select/InvitingTeamMemberRecruitByID', jsonEncode({"id": notificationModel.tableIndex}));

        if (res == null) {
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
        } else {
          UserData user = GlobalProfile.getUserByUserID(notificationModel.from);

          recruitInviteController.setCurrRecruitInvite(0, recruitInvite: RecruitInvite.fromJson(res));

          if (null == user) {
            debugPrint("NOTI_EVENT_INVITE_PERSONALSEEKTEAM_ACCEPT DATA ERROR");
          } else {
            Get.to(() => DetailProfile(
                  index: 0,
                  user: user,
                  profileStatus: PROFILE_STATUS.Applicant,
                ));
          }
        }
      }
      break;
    case NOTI_EVENT_INVITE_TEAMMEMBERRECRUIT_ACCEPT:
      TeamMemberRecruit teamMemberRecruit = globalTeamMemberRecruitList.singleWhere((element) => element.id == notificationModel.targetIndex);

      if (null == teamMemberRecruit) {
        debugPrint("NOTI_EVENT_INVITE_TEAMMEMBERRECRUIT_ACCEPT DATA ERROR");
      } else {
        Get.to(() => RecruitDetailPage(isRecruit: true, data: teamMemberRecruit));
      }

      break;
    case NOTI_EVENT_DELETE_PERSONALSEEKTEAM_POST:
      break;
    case NOTI_EVENT_INTERNAL_PERSON_PROFILE_1:
      Get.to(() => DetailProfile(index: 0, user: GlobalProfile.loggedInUser!));
      break;
    case NOTI_EVENT_INTERNAL_PERSON_PROFILE_2:
      Get.to(() => DetailProfile(index: 0, user: GlobalProfile.loggedInUser!));
      break;
    case NOTI_EVENT_INTERNAL_PERSON_PROFILE_3:
      Get.to(() => DetailProfile(index: 0, user: GlobalProfile.loggedInUser!));
      break;
    case NOTI_EVENT_INTERNAL_PERSON_COMMUNITY:
      Get.back();
      navigationNum.setNum(COMMUNITY_MAIN_PAGE);
      break;
    case NOTI_EVENT_INTERNAL_PERSON_RECRUIT_WRITE:
      Get.back();
      recruitController.isRecruit = false;
      navigationNum.setNum(TEAM_RECRUIT_PAGE);
      Get.dialog(
        ExpandableFab(isRecruit: false),
        barrierColor: Color.fromRGBO(136, 136, 136, 0.5),
      );
      Get.to(() => PersonalSeekTeamsEditPage());
      break;
    case NOTI_EVENT_INTERNAL_PERSON_RECRUIT_READ:
      Get.back();
      recruitController.isRecruit = true;
      navigationNum.setNum(TEAM_RECRUIT_PAGE);
      break;
    case NOTI_EVENT_INTERNAL_TEAM_PROFILE_1:
      Get.to(() => MyTeamProfile());
      break;
    case NOTI_EVENT_INTERNAL_TEAM_PROFILE_2:
      Team team = GlobalProfile.getTeamByID(notificationModel.teamIndex);
      Get.to(() => DetailTeamProfile(index: 0, team: team, proposedTeam: false));
      break;
    case NOTI_EVENT_INTERNAL_TEAM_PROFILE_3:
      Team team = GlobalProfile.getTeamByID(notificationModel.teamIndex);
      Get.to(() => DetailTeamProfile(index: 0, team: team, proposedTeam: false));
      break;
    case NOTI_EVENT_INTERNAL_TEAM_RECRUIT_WRITE:
      Get.back();
      recruitController.isRecruit = true;
      navigationNum.setNum(TEAM_RECRUIT_PAGE);
      Get.dialog(
        ExpandableFab(isRecruit: true),
        barrierColor: Color.fromRGBO(136, 136, 136, 0.5),
      );
      Get.to(RecruitTeamSelectionPage(isCreated: true));
      break;
    case NOTI_EVENT_INTERNAL_TEAM_RECRUIT_READ:
      Get.back();
      recruitController.isRecruit = false;
      navigationNum.setNum(TEAM_RECRUIT_PAGE);
      break;
  }

  return Future.value(true);
}

bool isHaveReadNoti() {
  bool res = false;
  for (int i = 0; i < notiList.length; ++i) {
    if (notiList[i].isRead == 0) {
      res = true;
      break;
    }
  }

  return res;
}

void setNotiListRead() {
  for (int i = 0; i < notiList.length; ++i) {
    if (notiList[i].isRead == 0) {
      notiList[i].isRead = 1;
      NotiDBHelper().updateDate(notiList[i].id, 1);
    }
  }
}

//내부 알림 세팅
void setInternalNotification() async {
  //개인프로필 정보 채우기 관련
  bool isHaveAuth = false;
  if (GlobalProfile.loggedInUser!.userCareerList.length > 0 ||
      GlobalProfile.loggedInUser!.userEducationList.length > 0 ||
      GlobalProfile.loggedInUser!.userLicenseList.length > 0 ||
      GlobalProfile.loggedInUser!.userWinList.length > 0) isHaveAuth = true;

  if (GlobalProfile.loggedInUser!.part.isEmpty) {
    addLocalNotification(NOTI_EVENT_INTERNAL_PERSON_PROFILE_1, teamIndex: 0);
  } else if (GlobalProfile.loggedInUser!.profileImgList[0].imgUrl == 'BasicImage') {
    addLocalNotification(NOTI_EVENT_INTERNAL_PERSON_PROFILE_2, teamIndex: 0);
  } else if (!isHaveAuth) {
    runOnProbability(0.3, () {
      addLocalNotification(NOTI_EVENT_INTERNAL_PERSON_PROFILE_3, teamIndex: 0);
    });
  }

  //커뮤니티 활동해보세요. 랜덤
  runOnProbability(0.1, () {
    addLocalNotification(NOTI_EVENT_INTERNAL_PERSON_COMMUNITY, teamIndex: 0);
  });

  //개인 리쿠르트 관련
  var res = await ApiProvider().post(
      '/Matching/Select/PersonalSeekTeamByUserID',
      jsonEncode({
        'userID': GlobalProfile.loggedInUser!.userID,
      }));
  if (res == null) {
    bool isRun = false;
    runOnProbability(0.2, () {
      runOnProbability(0.5, () {
        addLocalNotification(NOTI_EVENT_INTERNAL_PERSON_RECRUIT_WRITE, teamIndex: 0);
        isRun = true;
      });
      if (!isRun) {
        addLocalNotification(NOTI_EVENT_INTERNAL_PERSON_RECRUIT_READ, teamIndex: 0);
      }
    });
  }

  //팀프로필 관련
  bool isHaveNoTeam = false;
  List<Team> leaderTeamList = []; // 리더인 팀 리스트
  var leaderList = await ApiProvider().post('/Team/Profile/Leader', jsonEncode({"userID": GlobalProfile.loggedInUser!.userID}));
  if (leaderList != null) {
    for (int i = 0; i < leaderList.length; ++i) {
      leaderTeamList.add(Team.fromJson(leaderList[i]));
    }
  }

  var teamList = await ApiProvider().post('/Team/Profile/SelectUser', jsonEncode({"userID": GlobalProfile.loggedInUser!.userID}));
  if (leaderList == null && teamList == null) isHaveNoTeam = true;

  if (isHaveNoTeam) addLocalNotification(NOTI_EVENT_INTERNAL_TEAM_PROFILE_1, teamIndex: 0);

  for (int i = 0; i < leaderTeamList.length; i++) {
    bool isHaveTeamAuth = false;
    if (leaderTeamList[i].teamAuthList.length > 0 || leaderTeamList[i].teamPerformList.length > 0 || leaderTeamList[i].teamWinList.length > 0) isHaveTeamAuth = true;
    if (leaderTeamList[i].profileImgList[0].imgUrl == 'BasicImage') {
      addLocalNotification(NOTI_EVENT_INTERNAL_TEAM_PROFILE_2, teamIndex: leaderTeamList[i].id);
    } else if (!isHaveTeamAuth) {
      runOnProbability(0.3, () {
        addLocalNotification(NOTI_EVENT_INTERNAL_TEAM_PROFILE_3, teamIndex: leaderTeamList[i].id);
      });
    }
  }

  //팀 리쿠르트 관련
  if (leaderTeamList.length > 0) {
    //리더인 팀이 있을때만
    var resTeam = await ApiProvider().post(
        '/Matching/Select/TeamMemberRecruitByUserID',
        jsonEncode({
          'userID': GlobalProfile.loggedInUser!.userID,
        }));

    if (resTeam == null) {
      //작성한 리쿠르트 글이 없으면
      bool isRun = false;
      runOnProbability(0.2, () {
        runOnProbability(0.5, () {
          addLocalNotification(NOTI_EVENT_INTERNAL_TEAM_RECRUIT_WRITE, teamIndex: 0);
          isRun = true;
        });
        if (!isRun) {
          addLocalNotification(NOTI_EVENT_INTERNAL_TEAM_RECRUIT_READ, teamIndex: 0);
        }
      });
    }
  }
}

Future<bool> loadNotificationFutureData(NotificationModel notificationModel) async {
  await GlobalProfile.getFutureUserByUserID(notificationModel.from);

  //리쿠르트 관련 데이터 세팅
  if (notificationModel.type == NOTI_EVENT_INVITE_PERSONALSEEKTEAM ||
      notificationModel.type == NOTI_EVENT_INVITE_PERSONALSEEKTEAM_ACCEPT ||
      notificationModel.type == NOTI_EVENT_INVITE_PERSONALSEEKTEAM_REFUSE) {

    PersonalSeekTeam personalSeekTeam = await getFuturePersonalSeekTeam(notificationModel.targetIndex);
    if(personalSeekTeam != null) await GlobalProfile.getFutureTeamByID(notificationModel.teamIndex);
    else {
      //해당하는 데이터가 없거나, 게시물이 삭제되었을때
      notiList.remove(notificationModel);
      NotiDBHelper().deleteData(notificationModel.id);
      return Future.value(false);
    }
  } else if (notificationModel.type == NOTI_EVENT_INVITE_TEAMMEMBERRECRUIT ||
      notificationModel.type == NOTI_EVENT_INVITE_TEAMMEMBERRECRUIT_ACCEPT ||
      notificationModel.type == NOTI_EVENT_INVITE_TEAMMEMBERRECRUIT_REFUSE) {
    TeamMemberRecruit teamMemberRecruit = await getFutureTeamMemberRecruit(notificationModel.targetIndex);
    if(teamMemberRecruit != null) await GlobalProfile.getFutureTeamByID(teamMemberRecruit.teamId);
    else {
      //해당하는 데이터가 없거나, 게시물이 삭제되었을때
      notiList.remove(notificationModel);
      NotiDBHelper().deleteData(notificationModel.id);
      return Future.value(false);
    }
  } else if ( notificationModel.type == NOTI_EVENT_TEAM_MEMBER_ADD){
    await GlobalProfile.getFutureUserByUserID(notificationModel.targetIndex);
    await GlobalProfile.getFutureTeamByID(notificationModel.teamIndex);
  }

  if (notificationModel.type == NOTI_EVENT_POST_LIKE ||
      notificationModel.type == NOTI_EVENT_POST_REPLY ||
      notificationModel.type == NOTI_EVENT_POST_REPLY_LIKE ||
      notificationModel.type == NOTI_EVENT_POST_REPLY_REPLY ||
      notificationModel.type == NOTI_EVENT_POST_REPLY_REPLY_LIKE) {
    if (notificationModel.teamRoomName == null || notificationModel.teamRoomName == 'null') {
      var res = await ApiProvider().post('/CommunityPost/SelectID', jsonEncode({"id": notificationModel.tableIndex}));

      Community community = Community.fromJson(res);

      if (community.category == "비밀") {
        notificationModel.teamRoomName = "비밀";
      }
    }
  }

  return Future.value(true);
}
