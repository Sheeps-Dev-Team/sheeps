import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'package:sheeps_app/Badge/model/ModelBadge.dart';
import 'package:sheeps_app/Community/CommunityMainDetail.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/Recruit/Controller/FilterController.dart';
import 'package:sheeps_app/Recruit/Controller/RecruitController.dart';
import 'package:sheeps_app/Recruit/Models/RecruitLikes.dart';
import 'package:sheeps_app/config/NavigationNum.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/Recruit/Models/PersonalSeekTeams.dart';
import 'package:sheeps_app/Recruit/Models/TeamMemberRecruit.dart';
import 'package:sheeps_app/Recruit/RecruitDetailPage.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/profile/DetailProfile.dart';
import 'package:sheeps_app/chat/models/ChatDatabase.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/chat/models/ChatRecvMessageModel.dart';
import 'package:sheeps_app/chat/models/Room.dart';
import 'package:sheeps_app/config/LoadingUI.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/FirebaseNotification.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/notification/models/LocalNotificationController.dart';
import 'package:sheeps_app/notification/models/NotiDatabase.dart';
import 'package:sheeps_app/notification/models/NotificationModel.dart';
import 'package:sheeps_app/profile/DetailTeamProfile.dart';
import 'package:sheeps_app/profile/models/ModelLikes.dart';
import 'package:sheeps_app/registration/LoginSelectPage.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';

////////////////////////////공통변수는 여기에 추가//////////////////////////////////
double sizeUnit = 1.0;
bool AllNotification = true;
bool isNewMember = false;
bool isRecvData = false;
String globalNotificationType = 'NOTIFICATION';
String applicationDocumentsDirectory = '';

bool isCanDynamicLink = false; //로그인 후 다이나믹 링크 보내기 위함
bool myReleaseMode = kReleaseMode;

const int MAX_PREV_CHAT_MESSAGE = 20;
const int ROOM_STATUS_ROOM = 0;
const int ROOM_STATUS_CHAT = 1;
const int ROOM_STATUS_ETC = 2;

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

////////////////////////////공통함수는 여기에 추가//////////////////////////////////
Size screenSize(BuildContext context) {
  return MediaQuery.of(context).size;
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

String GetWeekDay(String WeekDay) {
  if (WeekDay == 'Monday')
    return '월요일';
  else if (WeekDay == 'Tuesday')
    return '화요일';
  else if (WeekDay == 'Wednesday')
    return '수요일';
  else if (WeekDay == 'Thursday')
    return '목요일';
  else if (WeekDay == 'Friday')
    return '금요일';
  else if (WeekDay == 'Saturday')
    return '토요일';
  else if (WeekDay == 'Sunday')
    return '일요일';
  else
    return '';
}

String getYearMonthDayByString(String date) {
  return date[0] + date[1] + date[2] + date[3] + date[4] + date[5] + date[6] + date[7];
}

String getYearMonthDayByDate() {
  String year = DateTime.now().year.toString();
  String month = DateTime.now().month < 10 ? '0' + DateTime.now().month.toString() : DateTime.now().month.toString();
  String day = DateTime.now().day < 10 ? '0' + DateTime.now().day.toString() : DateTime.now().day.toString();

  return year + month + day;
}

String getPrevRoomDate(String date) {
  String year = DateTime.now().year.toString();
  String month = DateTime.now().month < 10 ? '0' + DateTime.now().month.toString() : DateTime.now().month.toString();
  String day = DateTime.now().day < 10 ? '0' + DateTime.now().day.toString() : DateTime.now().day.toString();

  String strYear = date[0] + date[1] + date[2] + date[3];
  String strMonth = date[4] + date[5];
  String strDay = date[6] + date[7];

  String res = year + month + day;

  //해가 다르면
  if (year != strYear) {
    res = year + ". " + month + ". " + day + ".";
  } else if ((int.parse(month + day) - int.parse(strMonth + strDay)) > 1) {
    res = strMonth + "월 " + strDay + "일";
  } else {
    res = "어제";
  }

  return res;
}

String setDateAmPm(String date, bool isAmPM, String updatedAt) {
  if (date.isEmpty) return '';

  int index = date.indexOf(":");
  int sub = int.parse(date.substring(0, index));
  String subRest = date.substring(index + 1, date.length);
  String AmOrPM = "오전 ";

  if (true == isAmPM) {
    sub = sub + 9;
  }

  if (sub >= 12) {
    AmOrPM = "오후 ";
    sub = sub - 12;

    if (sub == 0) sub = 12;
  }

  if (updatedAt.isEmpty) {
    if (subRest.length < 2) subRest = '0' + subRest;

    return AmOrPM + sub.toString() + ":" + subRest;
  }

  if (int.parse(getYearMonthDayByString(updatedAt)) == int.parse(getYearMonthDayByDate())) {
    if (subRest.length < 2) subRest = '0' + subRest;

    return AmOrPM + sub.toString() + ":" + subRest;
  }

  return getPrevRoomDate(updatedAt);
}

String getRoomName(int ID1, int ID2, {int ID3 = 0, int roomType = ROOM_TYPE_PERSONAL}) {
  int lowNum = ID1;
  int bigNum = ID2;

  String header = "userID";

  if (roomType == 1 && (lowNum > bigNum)) {
    int temp = lowNum;
    lowNum = bigNum;
    bigNum = temp;
  }

  switch (roomType) {
    case ROOM_TYPE_PERSONAL:
      {
        return header + lowNum.toString() + "userID" + bigNum.toString();
      }
    case ROOM_TYPE_TEAM:
      {
        header = "teamID";
        return header + lowNum.toString() + "userID" + bigNum.toString();
      }
    case ROOM_TYPE_PERSONAL_SEEK_TEAM:
      {
        header = "personalID";
        return header + lowNum.toString() + "userID" + bigNum.toString() + "inviteID" + ID3.toString();
      }
    case ROOM_TYPE_TEAM_MEMBER_RECRUIT:
      {
        header = "teamMemberID";
        return header + lowNum.toString() + "userID" + bigNum.toString() + "inviteID" + ID3.toString();
      }
  }

  return header + lowNum.toString() + "userID" + bigNum.toString();
}

String replaceDate(String date) {
  int index = date.lastIndexOf('.') == -1 ? date.length : date.lastIndexOf('.');

  String replaceStr = date.substring(0, index);
  return replaceStr.replaceAll('T', ' ').replaceAll('-', '').replaceAll(':', '').replaceAll(' ', '');
}

String replaceDateToShow(String dateStr) {
  DateTime date = new DateFormat("yyyy-MM-ddTHH:mm:ssZ").parse(dateStr, true);

  return (date.hour + 9).toString() + ":" + date.minute.toString();
}

String replaceUTCDate(String dateStr) {
  DateTime date = new DateFormat("yyyy-MM-ddTHH:mm:ssZ").parse(dateStr, true);
  date = date.add(Duration(hours: 9));

  int index = date.toString().lastIndexOf('.') == -1 ? date.toString().length : date.toString().lastIndexOf('.');

  String replaceStr = date.toString().substring(0, index);

  return replaceStr.replaceAll('-', '').replaceAll(':', '').replaceAll('.', '').replaceAll(' ', '');
}

String replaceUTCDatetest(String dateStr) {
  DateTime date = new DateFormat("yyyy-MM-ddTHH:mm:ssZ").parse(dateStr, true);

  return date.toLocal().toString().replaceAll('-', '').replaceAll(':', '').replaceAll('.', '').replaceAll(' ', '');
}

String replacLocalUTCDate(String dateStr) {
  DateTime date = new DateFormat("yyyy-MM-dd HH:mm:ssZ").parse(dateStr, true);
  date = date.add(Duration(hours: 9));

  String d = date.toString().substring(0, date.toString().indexOf('.'));

  return d.replaceAll('-', '').replaceAll(':', '').replaceAll('.', '').replaceAll(' ', '');
}

Future<String> getFileURL() async {
  Directory documentsDirectory = await getTemporaryDirectory();
  return documentsDirectory.path + '/' + DateFormat('yyyyMMddHHmmss"').format(DateTime.now().toLocal()) + ".png";
}

String getOptimizeImageURL(String name, int size) {
  if (size == 0) return name;

  String strHead = name.substring(0, name.lastIndexOf('.'));
  String strTail = name.substring(name.lastIndexOf('.'), name.length);

  return strHead + '_' + size.toString() + strTail;
}

String timeCheck(String tmp) {
  int year = int.parse(tmp[0] + tmp[1] + tmp[2] + tmp[3]);
  int month = int.parse(tmp[4] + tmp[5]);
  int day = int.parse(tmp[6] + tmp[7]);
  int hour = int.parse(tmp[8] + tmp[9]);
  int minute = int.parse(tmp[10] + tmp[11]);
  int second = int.parse(tmp[12] + tmp[13]);

  final date1 = DateTime(year, month, day, hour, minute, second);
  var date2 = DateTime.now();
  final differenceDays = date2.difference(date1).inDays;
  final differenceHours = date2.difference(date1).inHours;
  final differenceMinutes = date2.difference(date1).inMinutes;
  final differenceSeconds = date2.difference(date1).inSeconds;

  if (differenceDays > 13) {
    return "$month" + "월 " + "$day" + "일";
  } else if (differenceDays > 6) {
    return "일주일전";
  } else {
    if (differenceDays > 1) {
      return "$differenceDays" + "일전";
    } else if (differenceDays == 1) {
      return "하루전";
    } else {
      if (differenceHours >= 1) {
        return "$differenceHours" + "시간전";
      } else {
        if (differenceMinutes >= 1) {
          return "$differenceMinutes" + "분전";
        } else {
          if (differenceSeconds >= 0) {
            return "$differenceSeconds" + "초전";
          } else {
            return "방금";
          }
        }
      }
    }
  }
}

Future permissionRequest() async {
  Map<Permission, PermissionStatus> statuses = await [Permission.camera, Permission.notification].request();
}

Future<bool> getNotiByStatus() async {
  bool isNoti;
  var status = await Permission.notification.status;

  switch (status) {
    case PermissionStatus.denied:
      isNoti = false;
      break;
    case PermissionStatus.granted:
      isNoti = true;
      break;
    default:
      isNoti = false;
      break;
  }

  return isNoti;
}

String getFileName(int index, String filePath) {
  return GlobalProfile.loggedInUser!.userID.toString() + '_' + DateTime.now().millisecondsSinceEpoch.toString() + index.toString() + getMimeType(filePath);
}

String getMimeType(String file) {
  return file.substring(file.lastIndexOf('.'), file.length);
}

String getFileDirectory(String file) {
  return file.substring(0, file.lastIndexOf('/'));
}

String getFileRealName(String file) {
  return file.substring(file.lastIndexOf('/'), file.length);
}

String? validNameErrorText(String name) {
  if (name.isEmpty) return 'empty';

  int utf8Length = utf8.encode(name).length;

  RegExp regExp = RegExp(r'[$/!@#<>?":`~;[\]\\|=+)(*&^%\s-]'); //허용문자 _.

  if (regExp.hasMatch(name)) {
    return "특수문자가 들어갈 수 없어요.";
  }
  if (name.length < 2) {
    return "너무 짧아요. 2자 이상 작성해주세요.";
  }
  if (name.length > 15 || utf8Length > 30) {
    return "너무 길어요. 한글 10자 또는 영어 15자 이하로 작성해 주세요.";
  }

  return null;
}

String? validEmailErrorText(String email) {
  String? errMsg;
  if (email.isEmpty) return 'empty';

  RegExp regExp = RegExp(r'^[0-9a-zA-Z][0-9a-zA-Z\_\-\.\+]+[0-9a-zA-Z]@[0-9a-zA-Z][0-9a-zA-Z\_\-]*[0-9a-zA-Z](\.[a-zA-Z]{2,6}){1,2}$');

  if (email.length < 6) {
    errMsg = "최소 6글자 이상의 이메일이어야 해요.";
  } else if (regExp.hasMatch(email)) {
    errMsg = null;
  } else {
    errMsg = "올바른 이메일 형식으로 작성해주세요.";
  }
  return errMsg;
}

String? validPasswordErrorText(String password) {
  String? errMsg;
  if (password.isEmpty) return 'empty';

  RegExp exp = RegExp(r"^[A-Za-z\d$@$!%*#?&]{1,}$");

  if (!exp.hasMatch(password)) {
    errMsg = "영문, 숫자, 특수문자를 사용해주세요.";
  } else if (password.length < 8) {
    errMsg = '비밀번호가 너무 짧습니다.';
  }

  return errMsg;
}

String? validPasswordConfirmErrorText(String password, String passwordConfirm) {
  if (passwordConfirm == password) {
    return null;
  } else {
    return '비밀번호를 확인해주세요.';
  }
}

String? validRealNameErrorText(String name) {
  if (name.isEmpty) return 'empty';
  RegExp regExp = RegExp(r'(^[가-힣]{2,10}$)'); // 2 ~ 10개 한글 입력가능
  if (regExp.hasMatch(name)) {
    return null;
  } else {
    return '이름을 정확히 입력해주세요.';
  }
}

String? validPhoneNumErrorText(String number) {
  if (number.isEmpty) return 'empty'; // number 빈 값일 때 empty 리턴
  RegExp regExp = RegExp(r'^\d{10,11}$'); // 10 ~ 11개 숫자 입력가능
  if (regExp.hasMatch(number)) {
    return null;
  } else {
    return '휴대폰 번호를 정확히 입력해주세요.';
  }
}

//url 유효성 검사
String? urlCheckErrorText(String url) {
  if (url.isEmpty) {
    return null;
  }
  String testUrl = url;
  RegExp exp = RegExp(r"^(((http(s?))\:\/\/)?)([0-9a-zA-Z\-]+\.)+[a-zA-Z]{2,6}(\:[0-9]+)?(\/\S*)?");

  if (testUrl.split('://')[0] != 'http' && testUrl.split('://')[0] != 'https') {
    testUrl = 'http://' + testUrl;
  }
  if (exp.hasMatch(testUrl)) {
    return null;
  } else {
    return 'URL 형식이 올바르지 않습니다.';
  }
}

bool isBigFile(int fileSize) {
  //약 10mb
  if (fileSize >= 10500000) {
    Fluttertoast.showToast(msg: "용량이 10mb 이상인 파일은 전송할 수 없습니다.", toastLength: Toast.LENGTH_SHORT);
    return true;
  }

  return false;
}

//캐시 이미지용
Future<File> makeCacheImage(String url, String firstPath, String filePath) async {
  var uri = Uri.parse(url);
  var response = await get(uri);
  await Directory(firstPath).create(recursive: true);

  File file = new File(filePath);
  await file.writeAsBytes(response.bodyBytes);

  return Future.value(file);
}

Future globalLogin(BuildContext context, SocketProvider provider, dynamic result, {bool isHandLogin = true, bool isSplashLogin = false}) async {
  final FilterController recruitFilterController = Get.put(FilterController());
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  Get.put(RecruitController());

  try {
    if (false == isSplashLogin) {
      DialogBuilder(context).showLoadingIndicator("로그인 중...");
    }

    UserData user = UserData.fromJson(result['result']);
    GlobalProfile.loggedInUser = user;

    //기존 로그인 정보랑 다르면
    String prevID = prefs.getString('prevLoginID') ?? '';

    if (prevID != user.id) {
      ChatDBHelper().dropTable();
      NotiDBHelper().dropTable();
    }

    prefs.setString('prevLoginID', user.id);

    GlobalProfile.accessToken = result['AccessToken'];
    GlobalProfile.refreshToken = result['RefreshToken'];
    GlobalProfile.accessTokenExpiredAt = result['AccessTokenExpiredAt'];
    GlobalProfile.accessTokenCheck();

    //개인 프로필 좋아요 리스트
    globalPersonalSeekTeamList.clear();
    var personalLikeList = await ApiProvider().post('/Personal/Select/Like', jsonEncode({"userID": user.userID}));
    if (personalLikeList != null) {
      for (int i = 0; i < personalLikeList.length; ++i) {
        globalPersonalLikeList.add(ModelLikes.fromJson(personalLikeList[i]));
      }
    }

    //팀 프로필 좋아요 리스트
    globalTeamLikeList.clear();
    var teamLikeList = await ApiProvider().post('/Team/SelectLike', jsonEncode({"userID": user.userID}));
    if (teamLikeList != null) {
      for (int i = 0; i < teamLikeList.length; ++i) {
        globalTeamLikeList.add(ModelLikes.fromJson(teamLikeList[i]));
      }
    }

    //Personal Profile 데이터 get
    GlobalProfile.personalProfile.clear();
    var personalProfileList = await ApiProvider().post('/Personal/Select/UserList', jsonEncode({"userID": GlobalProfile.loggedInUser!.userID}));
    if (personalProfileList != null) {
      for (int i = 0; i < personalProfileList.length; i++) {
        UserData _userTmp = UserData.fromJson(personalProfileList[i]);
        GlobalProfile.personalProfile.add(_userTmp);
      }
    }

    GlobalProfile.teamProfile.clear();
    var teamProfileList = await ApiProvider().get('/Team/Profile/Select');
    if (teamProfileList != null) {
      for (int i = 0; i < teamProfileList.length; i++) {
        Team _userTmp = Team.fromJson(teamProfileList[i]);
        GlobalProfile.teamProfile.add(_userTmp);
      }
    }

    ChatGlobal.roomInfoList.clear();
    //join된 방들 List 받음
    var list = await ApiProvider().post('/Room/User/Select', jsonEncode({"userID": GlobalProfile.loggedInUser!.userID}));

    if (null != list) {
      //방 List 재조합
      for (int i = 0; i < list.length; ++i) {
        List<dynamic> temp = list[i];

        if (temp.isEmpty) continue;

        RoomInfo roomInfo = new RoomInfo();

        Map<String, dynamic> data = temp[0];
        String roomName = data['RoomName'];
        int type = data['Type'];
        List<dynamic> userListTemp = data['RoomUsers'];
        if (userListTemp.length == 0) continue;
        List<int> userList = [];

        if (userListTemp != null) {
          if (userListTemp.length == 1) {
            //상대방과 주고받은 데이터가 있을 때만 방 로딩
            var anotherUserData = await ChatDBHelper().getAnotherUserID(roomName, user.userID);
            if (anotherUserData != null && anotherUserData.length != 0) {
              userList.add(anotherUserData[0]['userId']);
            } else {
              if (anotherUserData.length == 0) await ChatDBHelper().deleteDataByRoomName(roomName);
              continue;
            }

            roomInfo.isAlarm = 0;
            roomInfo.roomUserID = -1;
            roomInfo.roomInfoID = data['RoomID'];
          } else {
            for (int j = 0; j < userListTemp.length; ++j) {
              if (userListTemp[j]['UserID'] != user.userID) {
                userList.add(userListTemp[j]['UserID']);
              } else {
                roomInfo.isAlarm = userListTemp[j]['Alarm'];
                roomInfo.roomUserID = userListTemp[j]['id'];
                roomInfo.roomInfoID = data['RoomID'];
              }
            }
          }
        }

        bool isPersonal = false;
        //개인인지 팀인지 따라 세팅을 여러가지 해야함 chatList 부터 방이름 등등
        if ((type == ROOM_TYPE_PERSONAL) || (type == ROOM_TYPE_TEAM)) {
          String roomNameSub = roomName.substring(0, 4);

          if (roomNameSub == 'user') isPersonal = true;

          if (isPersonal) {
            UserData? userData = await GlobalProfile.getFutureUserByUserID(userList[0]);

            roomInfo.name = userData!.name;
            roomInfo.profileImage = userData.profileImgList[0].imgUrl;
          } else {
            Team team = await GlobalProfile.getFutureTeamByRoomName(roomName);

            roomInfo.name = team.name;
            roomInfo.profileImage = team.profileImgList[0].imgUrl;
          }
        } else if ((type == ROOM_TYPE_PERSONAL_SEEK_TEAM) || (type == ROOM_TYPE_TEAM_MEMBER_RECRUIT)) {
          String roomNameSub = roomName.substring(0, 8);

          if (roomNameSub == 'personal') isPersonal = true; //INTERVIEW에서는 personal로 개인이 올린 글인지 확인할 것

          UserData? userData = await GlobalProfile.getFutureUserByUserID(userList[0]);

          roomInfo.name = userData!.name;
          roomInfo.profileImage = userData.profileImgList[0].imgUrl;
        } else {
          //전문가
        }

        List<ChatRecvMessageModel> chatList = (await ChatDBHelper().getRoomData(roomName)).cast<ChatRecvMessageModel>();

        if (chatList != null) {
          //이미지 파일 미리 생성하는 부분
          Future.microtask(() async {
            for (int i = 0; i < chatList.length; ++i) {
              if (chatList[i].isImage != 0) {
                chatList[i].fileMessage = chatList[i].message;
                if (await File(chatList[i].fileMessage).exists() == false) {
                  var getImageData = await ApiProvider().post('/ChatLog/SelectImageData', jsonEncode({"id": chatList[i].isImage}));

                  if (getImageData != null) {
                    chatList[i].message = getImageData['Data'];
                    chatList[i].fileMessage = await base64ToFileURL(chatList[i].message, chatList[i].isImage.toString());
                    await ChatDBHelper().updateImageData(chatList[i].fileMessage, chatList[i].isImage);
                  } else {
                    chatList[i].fileMessage = '';
                  }
                }
              }
            }
          });
        }

        int messageCount = 0;
        //이전에 있던 데이터들 읽음 체크
        if (chatList != null) {
          for (int j = 0; j < chatList.length; ++j) {
            if (0 == chatList[j].isRead) messageCount += 1;
          }
        }

        List chatLogList = await ApiProvider().post('/ChatLog/UnSendSelect', jsonEncode({"userID": user.userID, "roomName": roomName}));

        messageCount += chatLogList.length;

        int prevLength = 0;
        int prev_load_max = 20;
        //최적화를 위해 20개 먼저 처리
        if (chatLogList != null) {
          prevLength = chatLogList.length >= prev_load_max ? prev_load_max : chatLogList.length - 1;
          int startIndex = chatList.length;
          for (int i = chatLogList.length - 1; i > chatLogList.length - 1 - prevLength; --i) {
            ChatRecvMessageModel message = ChatRecvMessageModel(
              chatId: chatLogList[i]['id'],
              roomName: chatLogList[i]['roomName'],
              to: chatLogList[i]['to'].toString(),
              from: chatLogList[i]['from'],
              message: chatLogList[i]['message'],
              date: chatLogList[i]['date'],
              isRead: 0,
              isImage: chatLogList[i]['isImage'],
              updatedAt: replaceUTCDate(chatLogList[i]['updatedAt']),
              createdAt: replaceUTCDate(chatLogList[i]['createdAt']),
            );

            if (message.roomName == roomName) {
              //사진이미지 처리
              if (message.isImage != 0) {
                var getImageData = await ApiProvider().post('/ChatLog/SelectImageData', jsonEncode({"id": message.isImage}));

                if (getImageData != null) {
                  message.message = getImageData['Data'];
                  message.fileMessage = await base64ToFileURL(message.message, message.date);
                }
              }
              chatList.insert(startIndex, message);
            }
          }

          String message = chatList.length == 0 ? "" : chatList[chatList.length - 1].message;
          if (message != null && message.isNotEmpty) {
            if (chatList[chatList.length - 1].isImage != 0) {
              message = "사진을 보냈습니다.";
            }
          }

          String date = chatList.length == 0 ? "" : setDateAmPm(chatList[chatList.length - 1].date, false, chatList[chatList.length - 1].updatedAt);

          roomInfo.roomName = roomName;
          roomInfo.date = date;
          roomInfo.isPersonal = isPersonal;
          roomInfo.lastMessage = message;
          roomInfo.messageCount = messageCount;
          roomInfo.type = type;
          roomInfo.chatList = chatList;
          roomInfo.chatUserIDList = userList;
          roomInfo.updateAt = chatList.length == 0 ? replaceUTCDate(data['updatedAt']) : chatList[chatList.length - 1].updatedAt;
          roomInfo.createdAt = chatList.length == 0 ? replaceUTCDate(data['createdAt']) : chatList[chatList.length - 1].updatedAt;
          ChatGlobal.roomInfoList.add(roomInfo);
        }

        //나머지 데이터는 비동기로 처리
        if (chatLogList != null && chatLogList.length > 0) {
          Future.microtask(() async {
            int insertIndex = chatList.length - prevLength;
            for (int i = 0; i < chatLogList.length - prevLength; ++i) {
              ChatRecvMessageModel message = ChatRecvMessageModel(
                chatId: chatLogList[i]['id'],
                roomName: chatLogList[i]['roomName'],
                to: chatLogList[i]['to'].toString(),
                from: chatLogList[i]['from'],
                message: chatLogList[i]['message'],
                date: chatLogList[i]['date'],
                isRead: 0,
                isImage: chatLogList[i]['isImage'],
                updatedAt: replaceUTCDate(chatLogList[i]['updatedAt']),
                createdAt: replaceUTCDate(chatLogList[i]['createdAt']),
              );

              if (message.roomName == roomName) {
                ChatGlobal.roomInfoList.forEach((element) async {
                  if (element.roomName == roomName) {
                    //사진이미지 처리
                    if (message.isImage != 0) {
                      var getImageData = await ApiProvider().post('/ChatLog/SelectImageData', jsonEncode({"id": message.isImage}));

                      if (getImageData != null) {
                        message.message = getImageData['Data'];
                        message.fileMessage = await ChatDBHelper().createData(message);
                      }
                    } else {
                      await ChatDBHelper().createData(message);
                    }

                    element.chatList.insert(insertIndex + i, message);
                  }
                });
              }
            }

            //기존 로드했던거 로컬 데이터에 저장
            for (int i = chatList.length - prevLength; i < chatList.length; ++i) {
              await ChatDBHelper().createData(chatList[i], isCreated: true);
            }
          });
        }
      }
    }

    ChatGlobal.sortRoomInfoList();
    ChatGlobal.roomInfoList.forEach((element) async {
      if (element.type == ROOM_TYPE_PERSONAL_SEEK_TEAM) {
        element = await SetPersonalSeekTeamRoomInfo(element);
      }
    });

    notiList.clear();
    notiList = await NotiDBHelper().getAllData();

    //await setTeamIDAtNotiTeamRoomName();

    if (isHandLogin) await SetHandLoginNotificationListByEvent();
    await SetNotificationListByEvent();

    // 커뮤니티 카테고리 리스트 setting
    communityCategoryList = prefs.getStringList('communityCategoryList') ?? [...basicCommunityCategoryList];

    // 커뮤니티 공지 게시글 받아오는 곳
    Future.microtask(() async {
      GlobalProfile.noticeCommunityList.clear();
      await ApiProvider().get('/CommunityPost/Select/Notice').then((value) async {
        if (value != null) {
          for (int i = 0; i < value.length; i++) {
            Community community = Community.fromJson(value[i], isNotice: true);
            GlobalProfile.noticeCommunityList.add(community);
            await GlobalProfile.getFutureUserByUserID(community.userID);
          }
        }
      });
    });

    // 커뮤니티 핫 게시글 받아오는 곳
    Future.microtask(() async {
      GlobalProfile.hotCommunityList.clear();
      await ApiProvider().get('/CommunityPost/Select/Hot').then((value) async {
        if (value != null) {
          for (int i = 0; i < value.length; i++) {
            if (value[i]['community']['Category'] != '공지') {
              Community community = Community.fromJson(value[i], isHot: true);
              GlobalProfile.hotCommunityList.add(community);
              await GlobalProfile.getFutureUserByUserID(community.userID);
            }
          }
        }
      });
    });

    // 커뮤니티 전체 게시글 받아오는 곳
    Future.microtask(() async {
      GlobalProfile.globalCommunityList.clear();
      await ApiProvider().get('/CommunityPost/Select').then((value) async {
        if (value != null) {
          for (int i = 0; i < value.length; ++i) {
            if (value[i]['community']['Category'] != '공지') {
              Community community = Community.fromJson(value[i]);
              GlobalProfile.globalCommunityList.add(community);
              await GlobalProfile.getFutureUserByUserID(community.userID);
            }
          }
        }
      });
    });

    //커뮤니티 인기게시글 받아오는곳
    Future.microtask(() async {
      GlobalProfile.popularCommunityList.clear();
      await ApiProvider().get('/CommunityPost/Select/Popular').then((value) async {
        if (value != null) {
          for (int i = 0; i < value.length; i++) {
            if (value[i]['community']['Category'] != '공지') {
              Community community = Community.fromJson(value[i]);
              GlobalProfile.popularCommunityList.add(community);
              await GlobalProfile.getFutureUserByUserID(community.userID);
            }
          }
        }
      });
    });

    //팀 모집 리스트
    globalTeamMemberRecruitList.clear();
    await ApiProvider().get('/Matching/Select/TeamMemberRecruit').then((value) async {
      if (value != null) {
        for (int i = 0; i < value.length; ++i) {
          TeamMemberRecruit t = TeamMemberRecruit.fromJson(value[i]);
          await GlobalProfile.getFutureTeamByID(t.teamId);
          globalTeamMemberRecruitList.add(t);
        }
      }
    });

    // 팀 모집 좋아요 리스트
    recruitLikesList.clear();
    await ApiProvider()
        .post(
            '/Matching/Select/TeamMemberRecruitLike',
            jsonEncode({
              "userID": GlobalProfile.loggedInUser!.userID,
            }))
        .then((value) {
      if (value != null) {
        for (int i = 0; i < value.length; i++) {
          RecruitLikes temp = RecruitLikes.fromJson(value[i]);
          recruitLikesList.add(temp);
        }
      }
    });

    //팀 찾기 리스트
    globalPersonalSeekTeamList.clear();
    await ApiProvider().get('/Matching/Select/PersonalSeekTeam').then((value) async {
      if (value != null) {
        for (int i = 0; i < value.length; ++i) {
          PersonalSeekTeam p = PersonalSeekTeam.fromJson(value[i]);
          await GlobalProfile.getFutureUserByUserID(p.userId);
          globalPersonalSeekTeamList.add(p);
        }
      }
    });

    recruitFilterController.showRecruitmentOnly = prefs.getBool('showRecruitmentOnly') ?? false; // 모집중만 보기 불러오기 없으면 false
    recruitFilterController.tempShowRecruitmentOnly.value = prefs.getBool('showRecruitmentOnly') ?? false; // 모집중만 보기 불러오기 없으면 false
    recruitFilterController.showSeekingOnly = prefs.getBool('showSeekingOnly') ?? false; // 구직중만 보기 불러오기 없으면 false
    recruitFilterController.tempShowSeekingOnly.value = prefs.getBool('showSeekingOnly') ?? false; // 구직중만 보기 불러오기 없으면 false

    if (globalPersonalSeekTeamList.length != 0) await recruitFilterController.getRecommendPersonalSeek(); // 구직중인 프로필
    if (globalTeamMemberRecruitList.length != 0) await recruitFilterController.getRecommendRecruit(); // 추천 리쿠르트

    // 팀 찾기 좋아요 리스트
    personalSeekLikesList.clear();
    await ApiProvider()
        .post(
            '/Matching/Select/PersonalSeekTeamLike',
            jsonEncode({
              "userID": GlobalProfile.loggedInUser!.userID,
            }))
        .then((value) {
      if (value != null) {
        for (int i = 0; i < value.length; i++) {
          RecruitLikes temp = RecruitLikes.fromJson(value[i]);
          personalSeekLikesList.add(temp);
        }
      }
    });

    //내부 알림 세팅
    setInternalNotification();

    await provider.initSocket(user);
    FirebaseNotifications().setFcmToken('');
    ChatGlobal.socket = SocketProvider.to;
    LocalNotificationController localNotificationController = Get.put(LocalNotificationController());

    initAllBadge();

    prefs.setBool('IfNewUser', true);

    await bannerFileDownload();

    if (false == isSplashLogin) {
      DialogBuilder(context).hideOpenDialog();
    }

    Navigator.of(context).pushNamedAndRemoveUntil("/MainPage", (route) => false);
    Get.toNamed("/MainPage");
  } catch (e) {
    if (kReleaseMode) {
      Fluttertoast.showToast(msg: "로그인 정보가 올바르지 않습니다. 로그인 페이지로 이동합니다. : " + e.toString(), toastLength: Toast.LENGTH_SHORT);
      ChatDBHelper().dropTable();
      NotiDBHelper().dropTable();
      globalLogout(false, ChatGlobal.socket);
    } else {
      debugPrint(e.toString());
    }
  }
}

Future globalLogout(bool isSelf, socket) async {
  if (isSelf == true) {
    ApiProvider().post('/Personal/Logout', jsonEncode({"userID": GlobalProfile.loggedInUser!.userID, "isSelf": 1}));
  }

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.clear();
  prefs.setBool('autoLoginKey', false);
  prefs.setString('autoLoginId', '');
  prefs.setString('autoLoginPw', '');
  prefs.setString('prevLoginID', GlobalProfile.loggedInUser!.id);
  if (socket != null) socket.disconnect();

  final navigationNum = Get.put(NavigationNum());
  navigationNum.setNum(DASHBOARD_MAIN_PAGE);
  GlobalProfile.loggedInUser = null;
  Get.offAll(() => LoginSelectPage());
}

//서버로부터 banner txt file을 가져옴
Future bannerFileDownload() async {
  Directory dir = await getApplicationDocumentsDirectory();
  String path = '${dir.path}/txt/bannerFile.txt';
  double progress = 0.0;

  var dio = new Dio();
  dio.download(ApiProvider().getUrl + '/bannerFile.txt', path, onReceiveProgress: (rcv, total) {
    progress = ((rcv / total) * 100);
    debugPrint(progress.toString());
  }, deleteOnError: true).then((value) {
    debugPrint('call dio download done');
    debugPrint(progress.toString());
  });
}

//지명 약어화 함수
String abbreviateForLocation(String location) {
  switch (location) {
    case '서울특별시':
      return '서울';
    case '인천광역시':
      return '인천';
    case '경기도':
      return '경기';
    case '강원도':
      return '강원';
    case '충청남도':
      return '충남';
    case '충청북도':
      return '충북';
    case '세종시':
      return '세종';
    case '대전광역시':
      return '대전';
    case '경상북도':
      return '경북';
    case '경상남도':
      return '경남';
    case '대구광역시':
      return '대구';
    case '부산광역시':
      return '부산';
    case '전라북도':
      return '전북';
    case '전라남도':
      return '전남';
    case '광주광역시':
      return '광주';
    case '울산광역시':
      return '울산';
    case '제주특별자치도':
      return '제주';
  }
  return location;
}

//지명 약어화 해제 함수
String revertAbbreviateForLocation(String location) {
  switch (location) {
    case '서울':
      return '서울특별시';
    case '인천':
      return '인천광역시';
    case '경기':
      return '경기도';
    case '강원':
      return '강원도';
    case '충남':
      return '충청남도';
    case '충북':
      return '충청북도';
    case '세종':
      return '세종시';
    case '대전':
      return '대전광역시';
    case '경북':
      return '경상북도';
    case '경남':
      return '경상남도';
    case '대구':
      return '대구광역시';
    case '부산':
      return '부산광역시';
    case '전북':
      return '전라북도';
    case '전남':
      return '전라남도';
    case '광주':
      return '광주광역시';
    case '울산':
      return '울산광역시';
    case '제주':
      return '제주특별자치도';
  }
  return location;
}

//인증정보용 정보 String 제거 함수
String cutAuthInfo(String contents) {
  int index = contents.lastIndexOf('||');
  if (index == -1) {
    return contents;
  }
  return contents.substring(0, index);
}

//포커스 해제 함수
void unFocus(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();
}

//공백 제어 함수
String controlSpace(String text) {
  String result = text;
  while (result.contains('\t')) {
    result = result.replaceAll('\t', ' ');
  }
  while (result.contains('\n\n\n')) {
    result = result.replaceAll('\n\n\n', '\n\n');
  }
  while (result.contains('\n ')) {
    result = result.replaceAll('\n ', ' ');
  }
  while (result.contains('　')) {
    result = result.replaceAll('　', '  ');
  }
  while (result.contains('\u200B')) {
    result = result.replaceAll('\u200B', '');
  }
  while (result.contains('   ')) {
    result = result.replaceAll('   ', '  ');
  }
  return result;
}

//공백 제거 함수
String removeSpace(String text) {
  String result = text;
  result = result.replaceAll(' ', '');
  result = result.replaceAll('\n', '');
  result = result.replaceAll('　', '');
  result = result.replaceAll('\t', '');
  result = result..replaceAll('\u200B', '');

  return result;
}

//다이나믹링크 받는 함수
void initDynamicLinks() async {
  // FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData dynamicLink) async {
  //   Uri deepLink = dynamicLink?.link;
  //   if (deepLink != null && GlobalProfile.loggedInUser != null) {
  //     _handleDynamicLink(deepLink);
  //   }
  // }, onError: (OnLinkErrorException e) async {
  //   print('onLinkError');
  //   print(e.message);
  // });
  //
  // final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
  // final Uri deepLink = data?.link;
  //
  // if (deepLink != null && GlobalProfile.loggedInUser != null) {
  //   _handleDynamicLink(deepLink);
  // }
}

void _handleDynamicLink(Uri deepLink) async {
  switch (deepLink.path) {
    case '/profile_person':
      {
        int id = int.parse(deepLink.queryParameters['id']!);
        if (id == GlobalProfile.loggedInUser!.userID)
          Get.to(() => DetailProfile(index: 0, profileStatus: PROFILE_STATUS.MyProfile));
        else
          Get.to(() => DetailProfile(index: 0, user: GlobalProfile.getUserByUserID(id), profileStatus: PROFILE_STATUS.OtherProfile));
      }
      break;
    case '/profile_team':
      {
        int id = int.parse(deepLink.queryParameters['id']!);
        Get.to(() => DetailTeamProfile(index: 0, team: GlobalProfile.getTeamByID(id)));
      }
      break;
    case '/recruit_person':
      {
        int id = int.parse(deepLink.queryParameters['id']!);
        PersonalSeekTeam personalSeekTeam = await getFuturePersonalSeekTeam(id);
        Get.to(() => RecruitDetailPage(isRecruit: false, data: personalSeekTeam));
      }
      break;
    case '/recruit_team':
      {
        int id = int.parse(deepLink.queryParameters['id']!);
        TeamMemberRecruit teamMemberRecruit = await getFutureTeamMemberRecruit(id);
        Get.to(() => RecruitDetailPage(isRecruit: true, data: teamMemberRecruit));
      }
      break;
    case '/community':
      {
        int id = int.parse(deepLink.queryParameters['id']!);
        Community community = await GlobalProfile.getFutureCommunityByID(id);
        Get.to(() => CommunityMainDetail(community));
      }
      break;
  }
}

//커스텀 토스트
showSheepsToast({
  required BuildContext context,
  required String text,
}) {
  FToast fToast = FToast();
  fToast.init(context);
  Widget toast = Container(
    padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 9 * sizeUnit),
    decoration: BoxDecoration(
      color: sheepsColorBlack,
      borderRadius: BorderRadius.circular(20 * sizeUnit),
    ),
    child: Text(
      text,
      style: SheepsTextStyle.toast(),
      textAlign: TextAlign.center,
    ),
  );

  fToast.showToast(
      child: toast,
      toastDuration: Duration(seconds: 2),
      positionedToastBuilder: (context, child) {
        return Positioned(
          child: child,
          bottom: 76 * sizeUnit,
          left: 16 * sizeUnit,
          right: 16 * sizeUnit,
        );
      });
}

// 리쿠르트 상세 모집상태 set
String setPeriodState(String recruitPeriodEnd) {
  if (recruitPeriodEnd == '상시모집') {
    return '상시모집';
  } else {
    String periodEnd = recruitPeriodEnd;
    String now = DateTime.now().toString().replaceAll('-', '').replaceAll(' ', '').replaceAll(':', '').substring(0, 14);
    if (periodEnd.compareTo(now) == -1)
      return '모집마감';
    else
      return '모집중';
  }
}

//확률실행 함수
runOnProbability(double probability, Function function) {
  Random random = Random();
  if (random.nextDouble() <= probability) {
    function();
  }
}

String cutStringEnterMessage(String text) {
  return text.contains('\n') ? text.substring(0, text.indexOf('\n')) : text;
}
