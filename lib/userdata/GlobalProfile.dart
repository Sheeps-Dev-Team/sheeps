import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/User.dart';

import '../config/constants.dart';

class GlobalProfile {
  static bool personalFiltered = false;
  static List<UserData> personalProfile = [];
  static List<UserData> personalProfileFiltered = [];

  static List<SampleUser> personalSampleProfile = [];
  static List<SampleTeam> teamSampleProfile = [];

  static bool teamFiltered = false;
  static List<Team> teamProfile = [];
  static List<Team> teamProfileFiltered = [];

  //커뮤니티 전체글
  static List<Community> globalCommunityList = [];

  //커뮤니티 공지게시글
  static List<Community> noticeCommunityList = [];

  //커뮤니티 인기게시글
  static List<Community> popularCommunityList = [];

  //커뮤니티 핫 게시글
  static List<Community> hotCommunityList = [];

  //커뮤니티 카테고리 게시글
  static List<Community> filteredCommunityList = [];

  //커뮤니티 검색 게시글
  static List<Community> searchedCommunityList = [];

  //커뮤니티 내 게시글
  static List<Community> myCommunityList = [];

  //커뮤니티 댓글
  static List<CommunityReply> communityReply = [];

  static UserData? loggedInUser;
  static UserData nullUser = UserData(userID: nullInt);
  static String? accessToken;
  static String? refreshToken;
  static String? accessTokenExpiredAt;

  static Future<UserData?> getFutureUserByUserID(int userID) async {
    if (loggedInUser!.userID == userID) return Future.value(loggedInUser);

    for (int i = 0; i < personalProfile.length; ++i) {
      if (personalProfile[i].userID == userID) {
        return Future.value(personalProfile[i]);
      }
    }

    var res = await ApiProvider().post('/Personal/Select/User', jsonEncode({"userID": userID}));

    if (res == null) return null;

    UserData user = UserData.fromJson(res);

    personalProfile.add(user);

    return Future.value(user);
  }

  static UserData getUserByUserID(int userID) {
    if (loggedInUser!.userID == userID) return loggedInUser!;

    UserData? user;
    for (int i = 0; i < personalProfile.length; ++i) {
      if (personalProfile[i].userID == userID) {
        user = personalProfile[i];
      }
    }

    //받아온 데이터 중에서 없으면
    if (null == user) {
      if (loggedInUser!.userID == userID) {
        user = loggedInUser;
      } else {
        Future.microtask(() async => {user = await GlobalProfile().selectAndAddUser(userID)});
      }
    }

    return user!;
  }

  static UserData getUserByUserIDAndloggedInUser(int userID) {
    UserData? user;
    user = getUserByUserID(userID);

    if (null == user && loggedInUser!.userID == userID) {
      user = loggedInUser;
    }

    return user!;
  }

  //데이터를 받아와 저장함
  Future<UserData?> selectAndAddUser(int userID) async {
    var res = await ApiProvider().post('/Personal/Select/User', jsonEncode({"userID": userID}));

    if (res == null) {
      return null;
    }

    UserData user = UserData.fromJson(res);
    personalProfile.add(user);

    return user;
  }

  static List<UserData> getUserListByUserIDList(List<int> userIDList) {
    List<UserData> userList = [];

    personalProfile.forEach((element) {
      for (int j = 0; j < userIDList.length; ++j) {
        if (element.userID == userIDList[j]) {
          userList.add(element);
        }
      }
    });

    return userList;
  }

  static CommunityReply? getReplyByIndex(int index) {
    if (index >= communityReply.length) return null;

    return communityReply[index];
  }

  static Future<Team> getFutureTeamByRoomName(String roomName) async {
    String teamIDWord = roomName.replaceRange(0, 6, '');
    String teamID = '';
    //48은 ASCI CODE 값
    for (int i = 0; i < teamIDWord.length; ++i) {
      if ((teamIDWord.codeUnitAt(i) - 48) < 10) {
        teamID += (teamIDWord.codeUnitAt(i) - 48).toString();
      } else {
        break;
      }
    }

    return await getFutureTeamByID(int.parse(teamID));
  }

  static Team getTeamByRoomName(String roomName) {
    String teamIDWord = roomName.replaceRange(0, 6, '');
    String teamID = '';
    //48은 ASCI CODE 값
    for (int i = 0; i < teamIDWord.length; ++i) {
      if ((teamIDWord.codeUnitAt(i) - 48) < 10) {
        teamID += (teamIDWord.codeUnitAt(i) - 48).toString();
      } else {
        break;
      }
    }

    return getTeamByID(int.parse(teamID));
  }

  static Future<Team> getFutureTeamByID(int id) async {
    for (int i = 0; i < teamProfile.length; ++i) {
      if (teamProfile[i].id == id) {
        return Future.value(teamProfile[i]);
      }
    }

    var res = await ApiProvider().post('/Team/Profile/SelectID', jsonEncode({"id": id}));

    if (res == null) return Future.value(null);

    Team team = Team.fromJson(res);
    teamProfile.add(team);

    return Future.value(team);
  }

  static Team getTeamByID(int id) {
    Team? team;

    for (int i = 0; i < teamProfile.length; ++i) {
      if (teamProfile[i].id == id) {
        team = teamProfile[i];
        break;
      }
    }

    if (null == team) {
      GlobalProfile().selectAndAddTeam(id).then((value) {
        return value;
      });
    }

    return team!;
  }

  static void setModifyPersonalProfile(UserData user) {
    //찾았는데 있으면 대체
    for (int i = 0; i < GlobalProfile.personalProfile.length; ++i) {
      if (GlobalProfile.personalProfile[i].userID == user.userID) {
        GlobalProfile.personalProfile[i] = user;
        return;
      }
    }

    //없으면 추가
    GlobalProfile.personalProfile.add(user);
  }

  static void setModifyTeamProfile(Team team) {
    //찾았는데 있으면 대체
    for (int i = 0; i < GlobalProfile.teamProfile.length; ++i) {
      if (GlobalProfile.teamProfile[i].id == team.id) {
        GlobalProfile.teamProfile[i] = team;
        return;
      }
    }

    //없으면 추가
    GlobalProfile.teamProfile.add(team);
  }

  //데이터를 받아와 저장함
  Future<Team?> selectAndAddTeam(int id) async {
    await ApiProvider().post('/Team/Profile/SelectID', jsonEncode({"id": id})).then((value) {
      if (value == null) return null;

      Team team = Team.fromJson(value);
      teamProfile.add(team);

      return team;
    });

    return null;
  }

  Future<Team> selectAndAddFutureTeam(int id) async {
    var res = await ApiProvider().post('/Team/Profile/SelectID', jsonEncode({"id": id}));

    return res;
  }

  void removeTeamMember(int teamID, int userID) {
    teamProfile.forEach((element) {
      if (element.id == teamID) {
        element.userList.removeWhere((element) => element == userID);
      }
    });
    teamProfileFiltered.forEach((element) {
      if (element.id == teamID) {
        element.userList.removeWhere((element) => element == userID);
      }
    });
  }

  static void AddTeamUser(int index, int from) {
    for (int i = 0; i < teamProfile.length; ++i) {
      if (teamProfile[i].id == index) {
        teamProfile[i].userList.add(from);
      }
    }
    teamProfileFiltered.forEach((element) {
      if (element.id == index) {
        element.userList.add(from);
      }
    });
  }

  static void profileSort({bool isTeam = false}) {
    if(isTeam){
      teamProfile.sort((a, b) {
        return int.parse(b.updatedAt).compareTo(int.parse(a.updatedAt));
      });
    }else{
      personalProfile.sort((a, b) {
        return int.parse(b.updatedAt).compareTo(int.parse(a.updatedAt));
      });
    }
  }

  static void accessTokenCheck() {
    Timer.periodic(Duration(minutes: 5), (timer) {
      debugPrint("call acessToken Expired timer");
      if(ChatGlobal.socket != null && ChatGlobal.socket!.stopCheck != true){
        ChatGlobal.socket!.socket!.emit('resumed',[{
          "userID" : GlobalProfile.loggedInUser!.userID.toString(),
          "roomStatus" : ChatGlobal.socket!.roomStatus,
        }]);
      }
      if (int.parse(accessTokenExpiredAt!) < int.parse(DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10))) {
        Future.microtask(() async {
          var res = await ApiProvider().post('/Personal/Select/Login/Token', jsonEncode({"userID": loggedInUser!.userID, "refreshToken": refreshToken}));

          if (res != null) {
            accessToken = res['AccessToken'] as String;
            accessTokenExpiredAt = (res['AccessTokenExpiredAt'] as int).toString();
          }
        });
      }
    });
  }

  static Future<Community> getFutureCommunityByID(int id) async {
    Community community = globalCommunityList.singleWhere((element) => element.id == id);

    if (community == null) {
      var res = await ApiProvider().post('/CommunityPost/SelectID', jsonEncode({"id": id}));

      if (res == null) return Future.value(null);

      community = Community.fromJson(res);
      globalCommunityList.add(community);

      return Future.value(community);
    } else {
      return Future.value(community);
    }
  }
}
