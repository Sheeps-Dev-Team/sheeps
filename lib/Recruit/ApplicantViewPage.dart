import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:get/get.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/profile/DetailProfile.dart';
import 'package:sheeps_app/profile/DetailTeamProfile.dart';
import 'package:sheeps_app/Recruit/Models/RecruitLikes.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';

class ApplicantViewPage extends StatefulWidget {
  final bool teamView;

  const ApplicantViewPage({Key key, this.teamView = false}) : super(key: key);

  @override
  _ApplicantViewPageState createState() => _ApplicantViewPageState();
}

class _ApplicantViewPageState extends State<ApplicantViewPage> {
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
                appBar: SheepsAppBar(context, widget.teamView ? '제안한 팀 보기' : '지원자 보기'),
                body: Column(
                  children: [
                    Divider(color: sheepsColorGrey, height: 1 * sizeUnit),
                    SizedBox(height: 16 * sizeUnit),
                    GetBuilder(builder: (RecruitInviteController recruitInviteController) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit),
                          child: recruitInviteController.currRecritInviteList.isEmpty
                              ? noSearchResultsPage(null)
                              : GridView.count(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 8 * sizeUnit,
                                  crossAxisSpacing: 8 * sizeUnit,
                                  childAspectRatio: 160 / 284,
                                  children: List.generate(recruitInviteController.currRecritInviteList.length, (index) {
                                    if (widget.teamView) {
                                      Team team = GlobalProfile.getTeamByID(recruitInviteController.currRecritInviteList[index].targetID);

                                      return SheepsTeamProfileCard(
                                        context,
                                        team,
                                        index,
                                        proposedTeam: true,
                                        onTap: () async {
                                          RecruitInviteController recruitInviteController = Get.put(RecruitInviteController());
                                          recruitInviteController.setCurrRecruitInvite(index);

                                          var getData = await ApiProvider().post('/Team/Profile/SelectID', jsonEncode({"id": team.id, "updatedAt": team.updatedAt}));

                                          Team resTeam = team;
                                          if (getData != null) {
                                            Team resTeam = Team.fromJson(getData);

                                            GlobalProfile.teamProfile[index] = resTeam;
                                          }

                                          Get.to(() => DetailTeamProfile(index: index, team: resTeam, proposedTeam: true)).then((value) => setState(() {}));
                                        },
                                      );
                                    } else {
                                      UserData person = GlobalProfile.getUserByUserID(recruitInviteController.currRecritInviteList[index].targetID);

                                      return SheepsPersonalProfileCard(
                                        context,
                                        person,
                                        index,
                                        onTap: () async {
                                          var getData = await ApiProvider().post('/Personal/Select/ModifyUser', jsonEncode({"userID": person.userID, "updatedAt": person.updatedAt}));

                                          RecruitInviteController recruitInviteController = Get.put(RecruitInviteController());
                                          recruitInviteController.setCurrRecruitInvite(index);

                                          UserData user = person;
                                          if (getData != null) {
                                            user = UserData.fromJson(getData);
                                            GlobalProfile.personalProfile[index] = user; //개인 프로필 바뀐 데이터로 전역 데이터 세팅
                                          }

                                          Get.to(() => DetailProfile(index: 0, user: user, profileStatus: PROFILE_STATUS.Applicant)).then((value) => setState(() {}));
                                        },
                                      );
                                    }
                                  })),
                        ),
                      );
                    }),
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
