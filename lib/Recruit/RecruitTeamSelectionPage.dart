import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/Recruit/Controller/RecruitDetailController.dart';
import 'package:sheeps_app/TeamProfileManagement/TeamProfileManagementPage.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'TeamMemberRecruitEditPage.dart';

class RecruitTeamSelectionPage extends StatefulWidget {
  final bool isCreated;
  final bool isMyPageRecruit; // 마이페이지에서 왔으면 true

  const RecruitTeamSelectionPage({Key key, this.isCreated = true, this.isMyPageRecruit = false}) : super(key: key);

  @override
  _RecruitTeamSelectionPageState createState() => _RecruitTeamSelectionPageState();
}

class _RecruitTeamSelectionPageState extends State<RecruitTeamSelectionPage> {
  final RecruitDetailController controller = Get.put(RecruitDetailController());
  List<Team> myTeamList = [];
  int selectedTeamId;
  bool loading = true;

  void backFunc(){
    Get.back();
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      var leaderList = await ApiProvider().post('/Team/Profile/Leader', jsonEncode({"userID": GlobalProfile.loggedInUser.userID}));

      if (leaderList != null) {
        for (int i = 0; i < leaderList.length; ++i) {
          myTeamList.add(Team.fromJson(leaderList[i]));
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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        backFunc();
        return Future.value(true);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시,
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Scaffold(
                appBar: SheepsAppBar(
                  context,
                  widget.isCreated ? '모집할 팀 선택' : '제안하는 팀 선택',
                  backFunc: backFunc,
                ),
                body: Column(
                  children: [
                    Divider(color: sheepsColorGrey, height: 1 * sizeUnit),
                    buildGridView(),
                    SheepsBottomButton(
                      context: context,
                      text: '다음',
                      isOK: selectedTeamId != null ? true : false,
                      function: () async {
                        if (selectedTeamId == null) return;

                        if (widget.isCreated) {
                          if(widget.isMyPageRecruit) {
                            // 마이페이지에서 setState 돌아야하기 때문에
                            Get.to(() => TeamMemberRecruitEditPage(team: GlobalProfile.getTeamByID(selectedTeamId), isMyPageRecruit: widget.isMyPageRecruit));
                          } else {
                            // ExpandedFab 에서 setState 돌아야하기 때문에
                            Get.off(() => TeamMemberRecruitEditPage(team: GlobalProfile.getTeamByID(selectedTeamId), isMyPageRecruit: widget.isMyPageRecruit));
                          }
                        } else {
                          var checkMemberResult = await ApiProvider().post(
                              '/Team/Profile/Check/Member',
                              jsonEncode({
                                "teamID": selectedTeamId,
                                "userID": controller.targetID,
                              }));

                          //팀원 체크
                          if (checkMemberResult == null) {
                            var res = await ApiProvider().post(
                                '/Matching/Select/Target/PersonalSeekTeam',
                                jsonEncode({
                                  "teamID": selectedTeamId,
                                  "inviteID": controller.targetID,
                                  "id": controller.id,
                                }));

                            if (res == null) {
                              await ApiProvider().post(
                                  '/Matching/Invite/PersonalSeekTeam',
                                  jsonEncode({
                                    "userID": GlobalProfile.loggedInUser.userID,
                                    "teamID": selectedTeamId,
                                    "inviteID": controller.targetID,
                                    "id": controller.id,
                                  }));

                              showSheepsCustomDialog(
                                title: Text(
                                  "'" + controller.name + "'\n님에게 제안했어요!",
                                  style: SheepsTextStyle.dialogTitle().copyWith(height: 1.2, fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.center,
                                ),
                                contents: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
                                    children: [
                                      TextSpan(text: '상대가 수락하면 '),
                                      TextSpan(text: '면접 채팅방', style: SheepsTextStyle.b3().copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: '이 생기고,\n서로 이야기를 나눠볼 수 있어요.'),
                                    ],
                                  ),
                                ),
                                okButtonColor: sheepsColorGreen,
                              );
                            } else {
                              showSheepsCustomDialog(
                                title: Text(
                                  "'" + controller.name + "'\n은 이미 제안한 팀 찾기 글이예요",
                                  style: SheepsTextStyle.dialogTitle().copyWith(height: 1.2, fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.center,
                                ),
                                contents: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
                                    children: [
                                      TextSpan(text: '다른 '),
                                      TextSpan(text: '팀 찾기 ', style: SheepsTextStyle.b3().copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: '글을 찾아봐요.'),
                                    ],
                                  ),
                                ),
                                okButtonColor: sheepsColorGreen,
                              );
                            }
                          } else {
                            showSheepsCustomDialog(
                              title: Text(
                                "'" + controller.name + "'\n은 이미 해당 팀의 팀원이예요.",
                                style: SheepsTextStyle.dialogTitle().copyWith(height: 1.2, fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center,
                              ),
                              contents: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
                                  children: [
                                    TextSpan(text: '다른 팀에 '),
                                    TextSpan(text: '초대', style: SheepsTextStyle.b3().copyWith(fontWeight: FontWeight.bold)),
                                    TextSpan(text: '해봐요.'),
                                  ],
                                ),
                              ),
                              okButtonColor: sheepsColorGreen,
                            );
                          }
                        }
                      },
                    ),
                    SizedBox(height: 20 * sizeUnit),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGridView() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 19 * sizeUnit),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16 * sizeUnit,
          crossAxisSpacing: 16 * sizeUnit,
          childAspectRatio: 156 / 204,
          children: List.generate(myTeamList.length + 1, (index) {
            if (index == myTeamList.length) return customCreateTeamCard();
            return sheepsSelectTeamProfileCard(myTeamList[index]);
          }),
        ),
      ),
    );
  }

  Widget sheepsSelectTeamProfileCard(Team team) {
    return Container(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (selectedTeamId == team.id)
              selectedTeamId = null;
            else
              selectedTeamId = team.id;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            teamProfileImg(team),
            SizedBox(height: 8 * sizeUnit),
            Text(team.name, style: SheepsTextStyle.h3()),
            SizedBox(height: 4 * sizeUnit),
            Wrap(
              runSpacing: 4 * sizeUnit,
              spacing: 4 * sizeUnit,
              children: [
                if (team.category != null && team.category.isNotEmpty) wrapItem(team.category),
                if (team.location != null && team.location.isNotEmpty) wrapItem(abbreviateForLocation(team.location)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget teamProfileImg(Team team) {
    return Container(
      width: 156 * sizeUnit,
      height: 156 * sizeUnit,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(28 * sizeUnit), border: Border.all(width: 0.5 * sizeUnit, color: sheepsColorGrey)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            width: 156 * sizeUnit,
            height: 156 * sizeUnit,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28 * sizeUnit),
            ),
            child: SvgPicture.asset(svgSheepsBasicProfileImage, height: 80 * sizeUnit),
          ),
          if (team.profileImgList[0].imgUrl != 'BasicImage') ...[
            SizedBox(
              width: 156 * sizeUnit,
              height: 156 * sizeUnit,
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
          ],
          if (team.id == selectedTeamId)
            Positioned(
              top: 9 * sizeUnit,
              right: 9 * sizeUnit,
              child: SvgPicture.asset(
                svgCheckInCircle,
                width: 26 * sizeUnit,
                height: 26 * sizeUnit,
              ),
            ),
        ],
      ),
    );
  }

  Widget wrapItem(String text) {
    return Container(
      height: 16 * sizeUnit,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4 * sizeUnit),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: SheepsTextStyle.cat1(),
            ),
          ],
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: new BorderRadius.circular(6 * sizeUnit),
        color: sheepsColorLightGrey,
      ),
    );
  }

  Widget customCreateTeamCard() {
    return Opacity(
      opacity: loading ? 0 : 1,
      child: createTeamCard(
        shortCard: true,
        press: () {
          if (myTeamList.length >= MAX_CREATE_TEAM_LENGTH) {
            fullTeamDialog(myTeamList.length);
          } else {
            Get.to(() => TeamProfileManagementPage(isAdd: true, team: Team())).then((value) {
              if (value != null) {
                setState(() {
                  myTeamList.add(value[0]);
                });
              }
            });
          }
        }
      ),
    );
  }
}
