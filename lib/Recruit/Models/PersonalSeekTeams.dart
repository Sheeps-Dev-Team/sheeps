import 'dart:convert';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/network/ApiProvider.dart';

// 팀 찾기
class PersonalSeekTeam {
  int id;
  int userId;
  String title;
  int seekingState;
  String selfInfo;
  String category;
  String seekingFieldPart;
  String abilityContents;
  String education;
  String career;
  String workFormFirst;
  String workFormSecond;
  String workDayOfWeek;
  String workTime;
  String welfare;
  String needWorkConditionContents;
  String location;
  String subLocation;
  bool isShow;
  String createdAt;
  String updateAt;
  String seekingFieldSubPart;

  PersonalSeekTeam({
    required this.id,
    required this.userId,
    required this.title,
    required this.seekingState,
    required this.selfInfo,
    required this.category,
    required this.seekingFieldPart,
    required this.abilityContents,
    required this.education,
    required this.career,
    required this.workFormFirst,
    required this.workFormSecond,
    required this.workDayOfWeek,
    required this.workTime,
    required this.welfare,
    required this.needWorkConditionContents,
    required this.location,
    required this.subLocation,
    required this.isShow,
    required this.createdAt,
    required this.updateAt,
    required this.seekingFieldSubPart,
  });

  factory PersonalSeekTeam.fromJson(Map<String, dynamic> json) {
    return PersonalSeekTeam(
      id: json['id'] as int,
      userId: json['UserID'] as int,
      title: json['Title'] as String,
      seekingState: json['SeekingState'] as int,
      selfInfo: json['SelfInfo'] as String,
      category: json['Category'] as String,
      seekingFieldPart: json['SeekingFieldPart'] as String,
      abilityContents: json['AbilityContents'] as String,
      education: json['Education'] as String,
      career: json['Career'] as String,
      workFormFirst: json['WorkFormFirst'] as String,
      workFormSecond: json['WorkFormSecond'] as String,
      workDayOfWeek: json['WorkDayOfWeek'] as String,
      workTime: json['WorkTime'] as String,
      welfare: json['Welfare'] as String,
      needWorkConditionContents: json['NeedWorkConditionContents'] as String,
      location: json['Location'] as String,
      subLocation: json['SubLocation'] as String,
      isShow: json['IsShow'] as bool,
      createdAt: replaceUTCDate(json['createdAt'] as String),
      updateAt: replaceUTCDate(json['updatedAt'] as String),
      seekingFieldSubPart: json['SeekingFieldSubPart'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        // 'id': id,
        'userID': userId,
        'title': title,
        'seekingState': seekingState,
        'selfInfo': selfInfo,
        'category': category,
        'seekingFieldPart': seekingFieldPart,
        'abilityContents': abilityContents,
        'education': education,
        'career': career,
        'workFormFirst': workFormFirst,
        'workFormSecond': workFormSecond,
        'workDayOfWeek': workDayOfWeek,
        'workTime': workTime,
        'welfare': welfare,
        'needWorkConditionContents': needWorkConditionContents,
        'location': location,
        'subLocation': subLocation,
        // 'isShow': isShow,
        'createdAt': createdAt,
        'updateAt': updateAt,
        'seekingFieldSubPart ': seekingFieldSubPart,
      };
}

List<PersonalSeekTeam> globalPersonalSeekTeamList = [];

Future<PersonalSeekTeam> getFuturePersonalSeekTeam(int id) async {
  PersonalSeekTeam? personalSeekTeam;
  globalPersonalSeekTeamList.forEach((element) {
    if (element.id == id) {
      personalSeekTeam = element;
    }
  });

  if (personalSeekTeam == null) {
    var res = await ApiProvider().post('/Matching/Select/PersonalSeekTeam', jsonEncode({"id": id}));
    if (res == null || res['IsShow'] == false) return Future.value(null);

    personalSeekTeam = PersonalSeekTeam.fromJson(res);
    globalPersonalSeekTeamList.add(personalSeekTeam!);

    return Future.value(personalSeekTeam);
  } else {
    return Future.value(personalSeekTeam);
  }
}
