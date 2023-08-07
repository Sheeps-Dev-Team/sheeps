import 'dart:convert';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/network/ApiProvider.dart';

// 팀원 모집
class TeamMemberRecruit {
  int id;
  int teamId;
  String title;
  String recruitPeriodStart;
  String recruitPeriodEnd;
  int ordinary;
  String recruitInfo;
  String category;
  String servicePart;
  String location;
  String subLocation;
  String recruitField;
  String recruitSubField;
  String roleContents;
  String education;
  String career;
  String detailVolunteerQualification;
  String preferenceInfo;
  String detailPreferenceInfoContents;
  String workFormFirst;
  String workFormSecond;
  String workDayOfWeek;
  String workTime;
  String welfare;
  String detailWorkCondition;
  bool isShow;
  String createdAt;
  String updateAt;

  TeamMemberRecruit({this.id, this.teamId, this.title, this.recruitPeriodStart, this.recruitPeriodEnd, this.ordinary,
    this.recruitInfo, this.category, this.servicePart, this.location, this.subLocation, this.recruitField, this.recruitSubField, this.roleContents, this.education, this.career, this.detailVolunteerQualification,
    this.preferenceInfo, this.detailPreferenceInfoContents, this.workFormFirst, this.workFormSecond, this.workDayOfWeek, this.workTime, this.welfare, this.detailWorkCondition,
    this.isShow, this.createdAt, this.updateAt});

  factory TeamMemberRecruit.fromJson(Map<String, dynamic> json){
    return TeamMemberRecruit(
      id: json['id'] as int,
      teamId: json['TeamID'] as int,
      title: json['Title'] as String,
      recruitPeriodStart: json['RecruitPeriodStart'] as String,
      recruitPeriodEnd: json['RecruitPeriodEnd'] as String,
      ordinary: json['Ordinary'] as int,
      recruitInfo: json['RecruitInfo'] as String,
      category: json['Category'] as String,
      servicePart: json['ServicePart'] as String,
      location: json['Location'] as String,
      subLocation: json['SubLocation'] as String,
      recruitField: json['RecruitField'] as String,
      recruitSubField: json['RecruitSubField'] as String,
      roleContents: json['RoleContents'] as String,
      education: json['Education'] as String,
      career: json['Career'] as String,
      detailVolunteerQualification: json['DetailVolunteerQualification'] as String,
      preferenceInfo: json['PreferenceInfo'] as String,
      detailPreferenceInfoContents: json['DetailPreferenceInfoContents'] as String,
      workFormFirst: json['WorkFormFirst'] as String,
      workFormSecond: json['WorkFormSecond'] as String,
      workDayOfWeek: json['WorkDayOfWeek'] as String,
      workTime: json['WorkTime'] as String,
      welfare: json['Welfare'] as String,
      detailWorkCondition: json['DetailWorkCondition'] as String,
      isShow: json['IsShow'] as bool,
      createdAt: replaceUTCDate(json['createdAt'] as String),
      updateAt: replaceUTCDate(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
  // 'id': id,
  'teamID': teamId,
  'title': title,
  'recruitPeriodStart': recruitPeriodStart,
  'recruitPeriodEnd': recruitPeriodEnd,
  'ordinary': ordinary,
  'recruitInfo': recruitInfo,
  'category': category,
  'servicePart' : servicePart,
  'location' : location,
  'subLocation' : subLocation,
  'recruitField': recruitField,
  'recruitSubField' : recruitSubField,
  'roleContents': roleContents,
  'education': education,
  'career': career,
  'detailVolunteerQualification': detailVolunteerQualification,
  'preferenceInfo': preferenceInfo,
  'detailPreferenceInfoContents': detailPreferenceInfoContents,
    'workFormFirst': workFormFirst,
    'workFormSecond' : workFormSecond,
  'workDayOfWeek': workDayOfWeek,
  'workTime': workTime,
  'welfare': welfare,
  'detailWorkCondition': detailWorkCondition,
  // 'isShow': isShow,
  'createdAt': createdAt,
  'updateAt': updateAt,
  };
}

List<TeamMemberRecruit> globalTeamMemberRecruitList = [];

Future<TeamMemberRecruit> getFutureTeamMemberRecruit(int id) async {

  TeamMemberRecruit teamMemberRecruit;
  globalTeamMemberRecruitList.forEach((element) {
    if(element.id == id) {
      teamMemberRecruit = element;
    }
  });

  if(teamMemberRecruit == null){
    var res = await ApiProvider().post('/Matching/Select/TeamMemberRecruitByID', jsonEncode({
      "id" : id
    }));

    if(res == null || res['IsShow'] == false) return Future.value(null);

    teamMemberRecruit = TeamMemberRecruit.fromJson(res);
    globalTeamMemberRecruitList.add(teamMemberRecruit);

    return Future.value(teamMemberRecruit);

  }else{
    return Future.value(teamMemberRecruit);
  }
}