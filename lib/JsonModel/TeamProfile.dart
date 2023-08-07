import 'package:flutter/material.dart';

class TeamProfile with ChangeNotifier {

  bool ing = false;

  //최근 접속
  //신규 창설

  String TeamName = null;
  String TeamCategory = null;
  String TeamField = null;
  String TeamArea = null;
  bool IfSupportTeam = false;
  String TeamIntroduce;

  List<String> TeamBadgeList = [];
  //인증


  //수상경력
  String TeamAwardName = null;
  String TeamAwardGrade = null;
  String TeamAwardAgency = null;
  String TeamAwardTime =null;
  bool IfAddAwardUploadComplte = false;
  bool IfAddAwardClear = false;

  List<String> TeamAwardList = [];

  //리스트
  //팀원 리스트
  //사진 리스트
}