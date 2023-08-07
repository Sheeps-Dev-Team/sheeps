import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:get/get.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/profile/DetailProfile.dart';
import 'package:sheeps_app/profile/DetailTeamProfile.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';

class ViewMyAppliedPage extends StatefulWidget {
  final bool isRecruit;
  final List<Team> teamList;
  final List<UserData> userList;

  const ViewMyAppliedPage({Key key, this.isRecruit = true, this.teamList, this.userList}) : super(key: key);

  @override
  _ViewMyAppliedPageState createState() => _ViewMyAppliedPageState();
}

class _ViewMyAppliedPageState extends State<ViewMyAppliedPage> {
  List resultList = [];

  @override
  void initState() {
    super.initState();
    resultList = widget.isRecruit ? widget.teamList : widget.userList;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: null,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), // 사용자 스케일팩터 무시,
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Scaffold(
                appBar: SheepsAppBar(context, widget.isRecruit ? '내가 지원한 팀' : '내가 제안한 구직자'),
                body: Column(
                  children: [
                    SizedBox(height: 16 * sizeUnit),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit),
                        child: resultList.isEmpty
                            ? noSearchResultsPage(widget.isRecruit ? '아직 지원한 팀이 없어요!' : '아직 제안한 구직자가 없어요!')
                            : GridView.count(
                                crossAxisCount: 2,
                                mainAxisSpacing: 8 * sizeUnit,
                                crossAxisSpacing: 8 * sizeUnit,
                                childAspectRatio: 160 / 284,
                                children: List.generate(resultList.length, (index) {
                                  // currRecruitInvite = recruitInviteList[index];

                                  if (widget.isRecruit) {
                                    Team team = resultList[index];

                                    return SheepsTeamProfileCard(
                                      context,
                                      team,
                                      index,
                                      onTap: () async {
                                        var getData = await ApiProvider().post('/Team/Profile/SelectID', jsonEncode({"id": team.id, "updatedAt": team.updatedAt}));

                                        Team resTeam = team;
                                        if (getData != null) {
                                          Team resTeam = Team.fromJson(getData);

                                          GlobalProfile.teamProfile[index] = resTeam;
                                        }

                                        Get.to(() => DetailTeamProfile(index: index, team: resTeam)).then((value) => setState(() {}));
                                      },
                                    );
                                  } else {
                                    UserData person = resultList[index];

                                    return SheepsPersonalProfileCard(
                                      context,
                                      person,
                                      index,
                                      basicImgColor: sheepsColorBlue,
                                      onTap: () async {
                                        var getData = await ApiProvider().post('/Personal/Select/ModifyUser', jsonEncode({"userID": person.userID, "updatedAt": person.updatedAt}));

                                        UserData user = person;
                                        if (getData != null) {
                                          user = UserData.fromJson(getData);
                                          GlobalProfile.personalProfile[index] = user; //개인 프로필 바뀐 데이터로 전역 데이터 세팅
                                        }

                                        Get.to(() => DetailProfile(index: 0, user: user, profileStatus: PROFILE_STATUS.OtherProfile)).then((value) => setState(() {}));
                                      },
                                    );
                                  }
                                })),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
