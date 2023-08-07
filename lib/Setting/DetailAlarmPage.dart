import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/FirebaseNotification.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/AppConfig.dart';

class DetailAlarmPage extends StatefulWidget {
  @override
  _DetailAlarmPageState createState() => _DetailAlarmPageState();
}

class _DetailAlarmPageState extends State<DetailAlarmPage> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: null,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Scaffold(
                appBar: SheepsAppBar(context,'푸시 알림 설정'),
                body: Container(
                  color: Color(0xFFF8F8F8),
                  child: Column(
                    children: [
                      Container(
                        color: Colors.white,
                        height: 48*sizeUnit,
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 12*sizeUnit),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '채팅 알림',
                                    style: SheepsTextStyle.b1(),
                                  ),
                                  Text(
                                    FirebaseNotifications.isChatting
                                      ? '중요한 채팅을 놓치지 않도록 알려드릴게요!'
                                      : '채팅을 보낸 사람과 채팅 내용이 푸시됩니다.',
                                    style: SheepsTextStyle.info2(),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Transform.scale(
                              scale: 0.8,
                              child: CupertinoSwitch(
                                value: FirebaseNotifications.isChatting,
                                onChanged: (bool value) async {
                                  FirebaseNotifications.isChatting = value;
                                  await ApiProvider().post('/Fcm/DetailAlarmSetting', jsonEncode(
                                      {
                                        "userID" : GlobalProfile.loggedInUser.userID,
                                        "marketing" : FirebaseNotifications.isMarketing,
                                        "chatting" : FirebaseNotifications.isChatting,
                                        "team" : FirebaseNotifications.isTeam,
                                        "community" : FirebaseNotifications.isCommunity
                                      }
                                  ));
                                  setState(() {

                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 4*sizeUnit),
                          ],
                        ),
                      ),
                      SizedBox(height: 1*sizeUnit),
                      Container(
                        color: Colors.white,
                        height: 48*sizeUnit,
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 12*sizeUnit),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '팀 초대 알림',
                                    style: SheepsTextStyle.b1(),
                                  ),
                                  Text(
                                    FirebaseNotifications.isTeam
                                      ? '새로운 팀 초대가 오면 바로 알려드릴게요!'
                                      : '팀 초대에 대한 알림이 푸시됩니다.',
                                    style: SheepsTextStyle.info2(),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Transform.scale(
                              scale: 0.8,
                              child: CupertinoSwitch(
                                value: FirebaseNotifications.isTeam,
                                onChanged: (bool value) async {
                                  FirebaseNotifications.isTeam = value;
                                  await ApiProvider().post('/Fcm/DetailAlarmSetting', jsonEncode(
                                      {
                                        "userID" : GlobalProfile.loggedInUser.userID,
                                        "marketing" : FirebaseNotifications.isMarketing,
                                        "chatting" : FirebaseNotifications.isChatting,
                                        "team" : FirebaseNotifications.isTeam,
                                        "community" : FirebaseNotifications.isCommunity
                                      }
                                  ));
                                  setState(() {

                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 4*sizeUnit),
                          ],
                        ),
                      ),
                      SizedBox(height: 1*sizeUnit),
                      Container(
                        color: Colors.white,
                        height: 48*sizeUnit,
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 12*sizeUnit),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '커뮤니티 알림',
                                    style: SheepsTextStyle.b1(),
                                  ),
                                  Text(
                                    FirebaseNotifications.isCommunity
                                      ? '게시글에 대한 반응을 바로 확인하세요!'
                                      : '\'내가 쓴 글\'에 대한 좋아요, 댓글, 대댓글이 푸시됩니다.',
                                    style: SheepsTextStyle.info2(),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Transform.scale(
                              scale: 0.8,
                              child: CupertinoSwitch(
                                value: FirebaseNotifications.isCommunity,
                                onChanged: (bool value) async {
                                  FirebaseNotifications.isCommunity = value;
                                  await ApiProvider().post('/Fcm/DetailAlarmSetting', jsonEncode(
                                      {
                                        "userID" : GlobalProfile.loggedInUser.userID,
                                        "marketing" : FirebaseNotifications.isMarketing,
                                        "chatting" : FirebaseNotifications.isChatting,
                                        "team" : FirebaseNotifications.isTeam,
                                        "community" : FirebaseNotifications.isCommunity
                                      }
                                  ));
                                  setState(() {

                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 4*sizeUnit),
                          ],
                        ),
                      ),
                      SizedBox(height: 1*sizeUnit),
                      Container(
                        color: Colors.white,
                        height: 48*sizeUnit,
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 12*sizeUnit),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '마케팅 알림',
                                    style: SheepsTextStyle.b1(),
                                  ),
                                  Text(
                                    GlobalProfile.loggedInUser.marketingAgree
                                      ? '마케팅 수신동의 일자 : ' + GlobalProfile.loggedInUser.marketingAgreeTime
                                      : '중요한 이벤트와 혜택을 놓치지 않도록, 동의는 필수!',
                                    style: SheepsTextStyle.info2(),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Transform.scale(
                              scale: 0.8,
                              child: CupertinoSwitch(
                                value: GlobalProfile.loggedInUser.marketingAgree,
                                onChanged: (bool value) async {
                                  GlobalProfile.loggedInUser.marketingAgree = value;
                                  GlobalProfile.loggedInUser.marketingAgreeTime = DateTime.now().toString().substring(0,19);
                                  FirebaseNotifications.isMarketing = value;
                                  await ApiProvider().post('/Personal/Update/Marketing', jsonEncode({
                                    "id" : GlobalProfile.loggedInUser.id,
                                    "marketingAgree" : GlobalProfile.loggedInUser.marketingAgree,
                                  }));
                                  await ApiProvider().post('/Fcm/DetailAlarmSetting', jsonEncode(
                                      {
                                        "userID" : GlobalProfile.loggedInUser.userID,
                                        "marketing" : FirebaseNotifications.isMarketing,
                                        "chatting" : FirebaseNotifications.isChatting,
                                        "team" : FirebaseNotifications.isTeam,
                                        "community" : FirebaseNotifications.isCommunity
                                      }
                                  ));

                                  setState(() {
                                    if(FirebaseNotifications.isMarketing){
                                      FirebaseNotifications.globalSetSubScriptionToTopic("SHEEPS_MARKETING");
                                    }else {
                                      FirebaseNotifications.globalSetUnSubScriptionToTopic("SHEEPS_MARKETING");
                                    }
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 4*sizeUnit),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
