import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:sheeps_app/Badge/model/ModelBadge.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/profile/DetailTeamProfile.dart';
import 'package:sheeps_app/TeamProfileManagement/TeamProfileManagementPage.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';

class MyTeamProfile extends StatefulWidget {
  @override
  _MyTeamProfileState createState() => _MyTeamProfileState();
}

Team modifyTeamInMyTeamProfile;

class _MyTeamProfileState extends State<MyTeamProfile> with SingleTickerProviderStateMixin {
  final String svgAddTeamIcon = 'assets/images/Profile/AddTeamIcon.svg';

  List<Team> myTeamList = []; // 팀 전체 리스트
  List<Team> leaderTeamList = []; // 리더인 팀 리스트
  ScrollController _scrollController = ScrollController();
  bool loading = true;

  @override
  void initState() {
    super.initState();

    //내 팀 리스트를 만들어야하는데, 리더리스트랑 팀리스트랑 더해야하나 고민되네
    Future.microtask(() async {
      loading = true;

      var leaderList = await ApiProvider().post('/Team/Profile/Leader', jsonEncode({"userID": GlobalProfile.loggedInUser.userID}));

      if (leaderList != null) {
        for (int i = 0; i < leaderList.length; ++i) {
          leaderTeamList.add(Team.fromJson(leaderList[i]));
          myTeamList.add(Team.fromJson(leaderList[i]));
        }
      }

      var teamList = await ApiProvider().post('/Team/Profile/SelectUser', jsonEncode({"userID": GlobalProfile.loggedInUser.userID}));

      if (teamList != null) {
        for (int i = 0; i < teamList.length; ++i) {
          myTeamList.add(await GlobalProfile.getFutureTeamByID(teamList[i]['TeamID']));
        }
      }
    }).then((value) {
      if (mounted) {
        loading = false;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: null,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Scaffold(
                floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
                appBar: SheepsAppBar(context, '나의 팀 프로필'),
                body: Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(
                      top: 20 * sizeUnit,
                      left: 12 * sizeUnit,
                      right: 12 * sizeUnit,
                    ),
                    child: GridView.count(
                      //primary: false,
                      controller: _scrollController,
                      mainAxisSpacing: 16 * sizeUnit,
                      crossAxisSpacing: 16 * sizeUnit,
                      crossAxisCount: 2,
                      childAspectRatio: 160 / 292,
                      //각 그리드뷰 비율 조정
                      children: List.generate(myTeamList.length + 1, (index) {
                        if (index == myTeamList.length) {
                          return AnimatedOpacity(
                            opacity: loading ? 0 : 1,
                            duration: Duration(milliseconds: 300),
                            child: createTeamCard(
                              press: () {
                                if (leaderTeamList.length >= MAX_CREATE_TEAM_LENGTH) {
                                  fullTeamDialog(leaderTeamList.length);
                                } else {
                                  Get.to(() => TeamProfileManagementPage(isAdd: true, team: Team())).then((value) {
                                    setState(() {
                                      if (value != null) {
                                        myTeamList.insert(0, value[0]);

                                        if(value[0].leaderID == GlobalProfile.loggedInUser.userID) {
                                          leaderTeamList.insert(0, value[0]);
                                        }
                                      }

                                      _scrollController.jumpTo(0);
                                    });
                                  });
                                }
                              },
                            ),
                          );
                        }
                        //todo : 나의 팀 리스트에서 지워줘야하므로 밖으로 뺌
                        //return SheepsTeamProfileCard(context, myTeamList[index], index);

                        Team team = myTeamList[index];

                        team.location = abbreviateForLocation(team.location); //지명약어화 함수
                        return GestureDetector(
                          onTap: () async {
                            var getData = await ApiProvider().post('/Team/Profile/SelectID', jsonEncode({"id": team.id, "updatedAt": team.updatedAt}));

                            Team resTeam = team;
                            if (getData != null) {
                              Team resTeam = Team.fromJson(getData);

                              GlobalProfile.teamProfile.forEach((element) {
                                if (element.id == resTeam.id) {
                                  element = resTeam;
                                }
                              });
                            }

                            Get.to(() => DetailTeamProfile(index: index, team: resTeam, proposedTeam: false)).then((value) async {
                              if (modifyTeamInMyTeamProfile == null) {
                                var leaderList = await ApiProvider().post('/Team/Profile/Leader', jsonEncode({"userID": GlobalProfile.loggedInUser.userID}));

                                //자신이 리더인 팀이 없으면
                                if (leaderList == null) {
                                  leaderTeamList.removeWhere((element) => element.leaderID == GlobalProfile.loggedInUser.userID);
                                } else {
                                  //리더인 팀 목록에 변화가 있으면
                                  if (leaderList.length != leaderTeamList.length) {
                                    List<Team> tempList = [...leaderTeamList];

                                    for (int i = 0; i < leaderList.length; ++i) {
                                      tempList.removeWhere((element) => element.id == leaderList[i]['id']);
                                    }

                                    setState(() {
                                      for (int i = 0; i < tempList.length; ++i) {
                                        leaderTeamList.removeWhere((element) => element.id == tempList[i].id);
                                        myTeamList.removeWhere((element) => element.id == tempList[i].id);
                                      }
                                    });
                                  }
                                }
                              } else {
                                for (int i = 0; i < myTeamList.length; i++) {
                                  if (myTeamList[i].id == modifyTeamInMyTeamProfile.id) {
                                    myTeamList[i] = modifyTeamInMyTeamProfile;
                                  }
                                }
                                if (modifyTeamInMyTeamProfile.isTeamMemberChange) {
                                  myTeamList.removeWhere((element) => element.id == modifyTeamInMyTeamProfile.id);
                                }
                                setState(() {});
                              }
                            });
                          },
                          child: Container(
                            width: 160 * sizeUnit,
                            padding: EdgeInsets.only(top: 8 * sizeUnit, left: 4 * sizeUnit, right: 4 * sizeUnit),
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Hero(
                                  tag: team.id,
                                  child: Container(
                                    width: 156 * sizeUnit,
                                    height: 156 * sizeUnit,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          child: Container(
                                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28 * sizeUnit), border: Border.all(color: sheepsColorGrey, width: 0.5)),
                                            child: Center(
                                                child: SvgPicture.asset(
                                              svgSheepsBasicProfileImage,
                                              width: 88 * sizeUnit,
                                            )),
                                          ),
                                        ),
                                        if (team.profileImgList[0].imgUrl != 'BasicImage') ...[
                                          Positioned(
                                            child: Container(
                                              width: 156 * sizeUnit,
                                              height: 156 * sizeUnit,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(28 * sizeUnit),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color.fromRGBO(116, 125, 130, 0.1),
                                                    offset: Offset(1 * sizeUnit, 1 * sizeUnit),
                                                    blurRadius: 2 * sizeUnit,
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(28 * sizeUnit),
                                                child: FittedBox(
                                                  fit: BoxFit.cover,
                                                  child: FadeInImage.memoryNetwork(
                                                    placeholder: kTransparentImage,
                                                    image: getOptimizeImageURL(team.profileImgList[0].imgUrl, 60),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                        if (team.badge1 != 0) ...[
                                          Positioned(
                                            right: 8 * sizeUnit,
                                            bottom: 8 * sizeUnit,
                                            child: Container(
                                              width: 32 * sizeUnit,
                                              height: 32 * sizeUnit,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8 * sizeUnit),
                                                child: FittedBox(
                                                  child: SvgPicture.asset(
                                                    ReturnTeamBadgeSVG(team.badge1),
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                        if (team.badge2 != 0) ...[
                                          Positioned(
                                            right: 40 * sizeUnit,
                                            bottom: 8 * sizeUnit,
                                            child: Container(
                                              width: 32 * sizeUnit,
                                              height: 32 * sizeUnit,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8 * sizeUnit),
                                                child: FittedBox(
                                                  child: SvgPicture.asset(
                                                    ReturnTeamBadgeSVG(team.badge2),
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                        if (team.badge3 != 0) ...[
                                          Positioned(
                                            right: 72 * sizeUnit,
                                            bottom: 8 * sizeUnit,
                                            child: Container(
                                              width: 32 * sizeUnit,
                                              height: 32 * sizeUnit,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8 * sizeUnit),
                                                child: FittedBox(
                                                  child: SvgPicture.asset(
                                                    ReturnTeamBadgeSVG(team.badge3),
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                        if (myTeamList[index].leaderID == GlobalProfile.loggedInUser.userID) ...[
                                          Positioned(
                                            top: 9 * sizeUnit,
                                            left: 9 * sizeUnit,
                                            child: Container(
                                              padding: EdgeInsets.all(4.5 * sizeUnit),
                                              height: 20 * sizeUnit,
                                              width: 20 * sizeUnit,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: sheepsColorBlue,
                                              ),
                                              child: SvgPicture.asset(svgCircleLeaderIcon),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8 * sizeUnit),
                                Container(
                                  height: 22 * sizeUnit,
                                  width: 160 * sizeUnit,
                                  child: Text(
                                    team.name,
                                    style: SheepsTextStyle.h3(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: 4 * sizeUnit),
                                Wrap(
                                  runSpacing: 4 * sizeUnit,
                                  spacing: 4 * sizeUnit,
                                  children: [
                                    if (team.category != null && team.category.isNotEmpty) profileSmallWrapItem(team.category),
                                    if (team.location != null && team.location.isNotEmpty) profileSmallWrapItem(team.location),
                                  ],
                                ),
                                SizedBox(height: 8 * sizeUnit),
                                Container(
                                  height: 48 * sizeUnit,
                                  child: Text(
                                    team.information,
                                    maxLines: 3,
                                    style: SheepsTextStyle.b4().copyWith(height: 1.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    )),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Positioned Badge3(BuildContext context, int index) {
    return Positioned(
      right: 72 * sizeUnit,
      bottom: 8 * sizeUnit,
      child: Container(
        width: 32 * sizeUnit,
        height: 32 * sizeUnit,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8 * sizeUnit),
          child: FittedBox(
            child: SvgPicture.asset(
              ReturnTeamBadgeSVG(myTeamList[index].badge3),
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Positioned Badge2(BuildContext context, int index) {
    return Positioned(
      right: 40 * sizeUnit,
      bottom: 8 * sizeUnit,
      child: Container(
        width: 32 * sizeUnit,
        height: 32 * sizeUnit,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8 * sizeUnit),
          child: FittedBox(
            child: SvgPicture.asset(
              ReturnTeamBadgeSVG(myTeamList[index].badge2),
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Positioned Badge1(BuildContext context, int index) {
    return Positioned(
      right: 8 * sizeUnit,
      bottom: 8 * sizeUnit,
      child: Container(
        width: 32 * sizeUnit,
        height: 32 * sizeUnit,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8 * sizeUnit),
          child: FittedBox(
            child: SvgPicture.asset(
              ReturnTeamBadgeSVG(myTeamList[index].badge1),
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Container Tag3(BuildContext context, int index) {
    return Container(
      height: 18 * sizeUnit,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              myTeamList[index].category,
              style: SheepsTextStyle.cat1(),
            ),
          ],
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0 * sizeUnit),
        color: sheepsColorGrey,
      ),
    );
  }

  Container Tag2(BuildContext context, int index) {
    String location = (myTeamList[index].location == null || myTeamList[index].location == '') ? '' : myTeamList[index].location;
    String subLocation = (myTeamList[index].subLocation == null || myTeamList[index].subLocation == '') ? '' : myTeamList[index].subLocation;

    return Container(
      height: 18 * sizeUnit,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              location + ' ' + subLocation,
              style: SheepsTextStyle.cat1(),
            ),
          ],
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4 * sizeUnit),
        color: sheepsColorGrey,
      ),
    );
  }

  Container Tag1(BuildContext context, int index) {
    return Container(
      height: 18 * sizeUnit,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              myTeamList[index].part,
              style: SheepsTextStyle.cat1(),
            ),
          ],
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4 * sizeUnit),
        color: sheepsColorGrey,
      ),
    );
  }
}
