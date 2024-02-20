import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:sheeps_app/Recruit/ApplicantViewPage.dart';
import 'package:sheeps_app/Recruit/Controller/RecruitDetailController.dart';
import 'package:sheeps_app/Recruit/Models/PersonalSeekTeams.dart';
import 'package:sheeps_app/Recruit/Models/RecruitLikes.dart';
import 'package:sheeps_app/Recruit/Models/TeamMemberRecruit.dart';
import 'package:sheeps_app/Recruit/PersonalSeekTeamsEditPage.dart';
import 'package:sheeps_app/Recruit/RecruitTeamSelectionPage.dart';
import 'package:sheeps_app/Recruit/TeamMemberRecruitEditPage.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/LoadingUI.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/profile/DetailProfile.dart';
import 'package:sheeps_app/profile/DetailTeamProfile.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';

class RecruitDetailPage extends StatefulWidget {
  final bool isRecruit;
  final data;
  final bool onlyShowSuggest;
  final List? dataList; // 리쿠르트 삭제하는거 반영하기 위해 받는 리스트

  const RecruitDetailPage({Key? key, required this.isRecruit, required this.data, this.onlyShowSuggest = false, this.dataList}) : super(key: key);

  @override
  _RecruitDetailPageState createState() => _RecruitDetailPageState();
}

class _RecruitDetailPageState extends State<RecruitDetailPage> {
  final RecruitDetailController controller = Get.put(RecruitDetailController());
  final RecruitInviteController inviteController = Get.put(RecruitInviteController());
  final ScrollController scrollController = ScrollController();
  final String svgWhiteBackArrow = 'assets/images/Profile/WhiteBackArrow.svg';
  final double appBarHeight = Get.height * 0.45;
  bool isPossibleInvite = false;
  bool isMe = false;
  late bool onlyShowSuggest; // 제안하기 버튼만 보여주기 여부
  String inviteButtonText = "지원하기";
  Color inviteButtonColor = sheepsColorBlue;

  late PersonalSeekTeam personalSeekTeam;
  late TeamMemberRecruit teamMemberRecruit;

  bool isReady = true;
  List dataList = [];  // 리쿠르트 삭제되는 거 반영하기 위한 리스트

  @override
  void initState() {
    inviteButtonText = widget.isRecruit ? "지원하기" : "제안하기";
    inviteButtonColor = widget.isRecruit ? sheepsColorBlue : sheepsColorGreen;
    onlyShowSuggest = widget.onlyShowSuggest;

    if(widget.dataList != null) dataList = widget.dataList!;

    if (widget.isRecruit) {
      teamMemberRecruit = widget.data;
    } else {
      personalSeekTeam = widget.data;
    }

    scrollController.addListener(() => controller.scrollListenerEvent(scrollController));

    Future.microtask(() async {
      if (GlobalProfile.loggedInUser!.userID == controller.targetID) {
        isMe = true;
        setState(() {});
      } else {
        if (widget.isRecruit) {
          var teamListResult = await ApiProvider().post(
              '/Team/Profile/SelectUser',
              jsonEncode({
                "userID": GlobalProfile.loggedInUser!.userID,
              }));

          TeamMemberRecruit teamMemberRecruit = globalTeamMemberRecruitList.singleWhere((element) => element.id == controller.id);

          bool isMember = false;
          for (int i = 0; i < teamListResult.length; ++i) {
            if (teamListResult[i]['TeamID'] == teamMemberRecruit.teamId) {
              isMember = true;
            }
          }

          if (isMember) {
            inviteButtonText = "소속됨";
            inviteButtonColor = sheepsColorDarkGrey;
          } else {
            var res = await ApiProvider().post(
                '/Matching/Select/Target/TeamMemberRecruit',
                jsonEncode({
                  "userID": GlobalProfile.loggedInUser!.userID,
                  "inviteID": controller.targetID,
                  "id": controller.id,
                }));

            if (res != null) {
              //이미 인터뷰에 응함
              if (res['Response'] == 1) {
                inviteButtonText = "지원완료";
                inviteButtonColor = sheepsColorGrey;
              } else {
                inviteButtonText = "지원완료";
                inviteButtonColor = sheepsColorGrey;
              }
            }
          }
        }
      }
    });

    // 데이터 set
    if (widget.isRecruit) {
      controller.dataSet(true, teamMemberRecruit);
    } else {
      controller.dataSet(false, personalSeekTeam);
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Get.back(result: widget.isRecruit ? teamMemberRecruit : personalSeekTeam);
        return Future.value(true);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Scaffold(
                backgroundColor: Colors.white,
                body: Stack(
                  children: [
                    CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        customSliverAppBar(), // 앱 바
                        contentsSliverList(), // 컨텐츠 리스트
                      ],
                    ),
                    widget.isRecruit ? recruitBottomButtonSheet() : personalSeekBottomButtonSheet(), // 하단 버튼
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Positioned recruitBottomButtonSheet() {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Obx(() => IgnorePointer(
            ignoring: controller.shrinkState.value ? false : true,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 100),
              opacity: controller.shrinkState.value ? 1 : 0,
              child: Container(
                width: double.infinity,
                height: 86 * sizeUnit,
                padding: EdgeInsets.all(16 * sizeUnit),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    bottomButtonBoxShadow(),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isMe) ...[
                      bottomButton(
                          text: '지원자 보기',
                          color: widget.isRecruit ? sheepsColorGreen : sheepsColorBlue,
                          press: () async {
                            var res = await ApiProvider().post('/Matching/Select/Proposed/TeamMemberRecruit', jsonEncode({"userID": GlobalProfile.loggedInUser!.userID, "id": controller.id}));

                            inviteController.currRecritInviteList.clear();
                            if (res != null) {
                              for (int i = 0; i < res.length; ++i) {
                                inviteController.currRecritInviteList.add(RecruitInvite.fromJson(res[i]));
                              }
                            }

                            Get.to(() => ApplicantViewPage());
                          }),
                    ] else ...[
                      bottomButton(
                        text: '프로필 보기',
                        color: widget.isRecruit ? sheepsColorGreen : sheepsColorBlue,
                        press: () => Get.to(() => DetailTeamProfile(
                              index: 0,
                              team: GlobalProfile.getTeamByID(globalTeamMemberRecruitList.singleWhere((element) => element.id == controller.id).teamId),
                              showBottomButton: false, // 바텀 버튼 안보이게
                            )),
                      ),
                      SizedBox(width: 8 * sizeUnit),
                      bottomButton(
                        text: inviteButtonText,
                        color: inviteButtonColor,
                        press: () async {
                          if (inviteButtonText != "지원하기") return;

                          if(controller.state == '모집마감'){
                            showSheepsCustomDialog(
                              title: Text(
                                "모집마감",
                                style: SheepsTextStyle.dialogTitle().copyWith(height: 1.2, fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center,
                              ),
                              contents: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
                                  children: [
                                    TextSpan(text: '해당 게시글은 모집이 마감된 상태입니다.\n'),
                                    TextSpan(text: '다른 게시글을 찾아보세요.')
                                  ],
                                ),
                              ),
                              okButtonColor: sheepsColorGreen,
                            );
                          }else{
                            await ApiProvider()
                                .post('/Matching/Invite/TeamMemberRecruit', jsonEncode({"userID": GlobalProfile.loggedInUser!.userID, "inviteID": controller.targetID, "id": controller.id}))
                                .then((value) {
                              setState(() {
                                inviteButtonText = "지원 중...";
                                inviteButtonColor = sheepsColorGrey;
                              });

                              showSheepsCustomDialog(
                                title: Text(
                                  "'팀 " + controller.name + "'\n에 지원했어요!",
                                  style: SheepsTextStyle.dialogTitle().copyWith(height: 1.2, fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.center,
                                ),
                                contents: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
                                    children: [
                                      TextSpan(text: '팀장이 수락하면 '),
                                      TextSpan(text: '면접 채팅방', style: SheepsTextStyle.b3().copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: '이 생기고,\n서로 이야기를 나눠볼 수 있어요.'),
                                    ],
                                  ),
                                ),
                                okButtonColor: sheepsColorBlue,
                              );
                            });
                          }
                        },
                      ),
                    ]
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Positioned personalSeekBottomButtonSheet() {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Obx(() => IgnorePointer(
            ignoring: controller.shrinkState.value ? false : true,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 100),
              opacity: controller.shrinkState.value ? 1 : 0,
              child: Container(
                width: double.infinity,
                height: 86 * sizeUnit,
                padding: EdgeInsets.all(16 * sizeUnit),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    bottomButtonBoxShadow(),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isMe) ...[
                      bottomButton(
                          text: '제안한 팀 보기',
                          color: widget.isRecruit ? sheepsColorGreen : sheepsColorBlue,
                          press: () async {
                            var res = await ApiProvider().post('/Matching/Select/Applicant/PersonalSeekTeam', jsonEncode({"userID": GlobalProfile.loggedInUser!.userID, "id": controller.id}));

                            inviteController.currRecritInviteList.clear();
                            if (res != null) {
                              for (int i = 0; i < res.length; ++i) {
                                inviteController.currRecritInviteList.add(RecruitInvite.fromJson(res[i], isUserID: false));
                                await GlobalProfile.getFutureTeamByID(RecruitInvite.fromJson(res[i], isUserID: false).targetID);
                              }
                            }

                            Get.to(() => ApplicantViewPage(
                                  teamView: true,
                                ));
                          }),
                    ] else ...[
                      if(onlyShowSuggest)...[
                        SheepsBottomButton(
                          function: () {

                            if(controller.state == '구직완료'){
                              showSheepsCustomDialog(
                                title: Text(
                                  "구직완료",
                                  style: SheepsTextStyle.dialogTitle().copyWith(height: 1.2, fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.center,
                                ),
                                contents: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
                                    children: [
                                      TextSpan(text: '해당 게시글은 구직을 완료한 상태입니다.\n'),
                                      TextSpan(text: '다른 게시글을 찾아보세요.')
                                    ],
                                  ),
                                ),
                                okButtonColor: sheepsColorGreen,
                              );
                            }else{
                              Get.to(() => RecruitTeamSelectionPage(isCreated: false));
                            }
                          },
                          context: context,
                          text: '제안하기',
                          color: sheepsColorGreen,
                        ),
                      ] else...[
                        bottomButton(
                          text: '프로필 보기',
                          color: widget.isRecruit ? sheepsColorGreen : sheepsColorBlue,
                          press: () =>
                              Get.to(() => DetailProfile(index: 0, user: GlobalProfile.getUserByUserID(globalPersonalSeekTeamList.singleWhere((element) => element.id == controller.id).userId))),
                        ),
                        SizedBox(width: 8 * sizeUnit),
                        bottomButton(text: '제안하기', color: widget.isRecruit ? sheepsColorBlue : sheepsColorGreen,
                          press: () {
                            if(controller.state == '구직완료'){
                              showSheepsCustomDialog(
                                title: Text(
                                  "구직완료",
                                  style: SheepsTextStyle.dialogTitle().copyWith(height: 1.2, fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.center,
                                ),
                                contents: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
                                    children: [
                                      TextSpan(text: '해당 게시글은 구직이 완료된 상태입니다.\n'),
                                      TextSpan(text: '다른 게시글을 찾아보세요.')
                                    ],
                                  ),
                                ),
                                okButtonColor: sheepsColorGreen,
                              );
                            }else{
                              Get.to(RecruitTeamSelectionPage(isCreated: false));
                            }
                          }
                        ),
                      ],
                    ]
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget bottomButton({required String text, required Color color, required Function press}) {
    double meButton = isMe ? 328 : 160;

    return GestureDetector(
      onTap: () => press(),
      child: Container(
        width: meButton * sizeUnit,
        height: 54 * sizeUnit,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12 * sizeUnit),
          color: color,
        ),
        child: Text(text, style: SheepsTextStyle.button1()),
      ),
    );
  }

  // 컨텐츠 리스트
  SliverList contentsSliverList() {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            constraints: BoxConstraints(minHeight: Get.height - 40 * sizeUnit),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24 * sizeUnit)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8 * sizeUnit),
                Center(
                  child: Container(
                    width: 20 * sizeUnit,
                    height: 4 * sizeUnit,
                    decoration: BoxDecoration(color: sheepsColorLightGrey, borderRadius: BorderRadius.circular(8 * sizeUnit)),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(width: 16 * sizeUnit),
                    Expanded(
                      child: Container(
                        height: 36 * sizeUnit,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            controller.name,
                            style: SheepsTextStyle.h1().copyWith(fontSize: 24 * sizeUnit),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    Obx(() => !controller.shrinkState.value ? shareAndLikeButton() : Container()),
                  ],
                ),
                widget.isRecruit ? recruitContents() : seekContents(),
                SizedBox(height: 86 * sizeUnit),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding recruitContents() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12 * sizeUnit),
          Wrap(
            runSpacing: 8 * sizeUnit,
            spacing: 8 * sizeUnit,
            children: [
              if (controller.firstWrapList[0].isNotEmpty) wrapItem(controller.firstWrapList[0]),
              if (controller.firstWrapList[1].isNotEmpty) wrapItem(controller.firstWrapList[1]),
              if (controller.firstWrapList[2].isNotEmpty) wrapItem(controller.firstWrapList[2]),
            ],
          ),
          SizedBox(height: 12 * sizeUnit),
          Text(
            controller.title,
            style: SheepsTextStyle.h2().copyWith(height: 1.3),
          ),
          SizedBox(height: 12 * sizeUnit),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: controller.state,
                  style: SheepsTextStyle.infoStrong().copyWith(
                    color: controller.state == '모집마감' ? sheepsColorGrey : sheepsColorGreen,
                  ),
                ),
                if(Platform.isAndroid) TextSpan(text: '・${controller.periodStart} ')
                else if(Platform.isIOS) TextSpan(text: ' ・ ${controller.periodStart} '),
                TextSpan(text: '- ${controller.periodEnd}'),
              ],
              style: SheepsTextStyle.hint4Profile(),
            ),
          ),
          SizedBox(height: 12 * sizeUnit),
          Text(
            controller.contents,
            style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
          ),
          SizedBox(height: 20 * sizeUnit),
          Text('모집분야', style: SheepsTextStyle.h3()),
          SizedBox(height: 12 * sizeUnit),
          Wrap(
            runSpacing: 8 * sizeUnit,
            spacing: 8 * sizeUnit,
            children: [
              if (controller.secondWrapList[0].isNotEmpty) wrapItem(controller.secondWrapList[0], isColor: true),
              if (controller.secondWrapList[1].isNotEmpty) wrapItem(controller.secondWrapList[1]),
            ],
          ),
          SizedBox(height: 20 * sizeUnit),
          Text('역할', style: SheepsTextStyle.h3()),
          SizedBox(height: 12 * sizeUnit),
          Text(controller.roleContents, style: SheepsTextStyle.b3().copyWith(height: 16 / 12)),
          SizedBox(height: 20 * sizeUnit),
          Text('지원자격', style: SheepsTextStyle.h3()),
          if (controller.thirdWrapList[0].isNotEmpty && controller.thirdWrapList[1].isNotEmpty) SizedBox(height: 12 * sizeUnit),
          Wrap(
            runSpacing: 8 * sizeUnit,
            spacing: 8 * sizeUnit,
            children: [
              if (controller.thirdWrapList[0].isNotEmpty) wrapItem(controller.thirdWrapList[0]),
              if (controller.thirdWrapList[1].isNotEmpty) wrapItem(controller.thirdWrapList[1]),
            ],
          ),
          SizedBox(height: 12 * sizeUnit),
          Text(
            controller.volunteerQualification,
            style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
          ),
          if (controller.volunteerQualification.isNotEmpty) SizedBox(height: 20 * sizeUnit),
          if (controller.fourthWrapList.isNotEmpty || controller.preferenceInfo.isNotEmpty) ...[
            Text('우대사항', style: SheepsTextStyle.h3()),
            if (controller.fourthWrapList.isNotEmpty) SizedBox(height: 12 * sizeUnit),
            Wrap(
              runSpacing: 8 * sizeUnit,
              spacing: 8 * sizeUnit,
              children: List.generate(controller.fourthWrapList.length, (index) => wrapItem(controller.fourthWrapList[index])),
            ),
            if (controller.preferenceInfo.isNotEmpty) SizedBox(height: 12 * sizeUnit),
            Text(controller.preferenceInfo, style: SheepsTextStyle.b3().copyWith(height: 16 / 12)),
            SizedBox(height: 20 * sizeUnit),
          ] else ...[
            if (isMe) ...[
              Text('우대사항', style: SheepsTextStyle.h3()),
              SizedBox(height: 12 * sizeUnit),
              Row(
                children: [
                  Text('・ ', style: SheepsTextStyle.b3()),
                  Text('우대사항을 추가해 보세요', style: SheepsTextStyle.error()),
                ],
              ),
              SizedBox(height: 20 * sizeUnit),
            ]
          ],
          Text('근무조건', style: SheepsTextStyle.h3()),
          SizedBox(height: 12 * sizeUnit),
          Wrap(
            runSpacing: 8 * sizeUnit,
            spacing: 8 * sizeUnit,
            children: List.generate(controller.workConditionList.length, (index) => wrapItem(controller.workConditionList[index])),
          ),
          SizedBox(height: 12 * sizeUnit),
          Text(controller.workCondition, style: SheepsTextStyle.b3().copyWith(height: 16 / 12)),
          SizedBox(height: 20 * sizeUnit),
        ],
      ),
    );
  }

  Padding seekContents() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12 * sizeUnit),
          Wrap(
            runSpacing: 8 * sizeUnit,
            spacing: 8 * sizeUnit,
            children: [
              if (controller.firstWrapList[0].isNotEmpty) wrapItem(controller.firstWrapList[0], isColor: true),
              if (controller.firstWrapList[1].isNotEmpty) wrapItem(controller.firstWrapList[1]),
              if (controller.firstWrapList[2].isNotEmpty) wrapItem(controller.firstWrapList[2]),
            ],
          ),
          SizedBox(height: 12 * sizeUnit),
          Text(
            controller.title,
            style: SheepsTextStyle.h2().copyWith(height: 1.3),
          ),
          SizedBox(height: 12 * sizeUnit),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: controller.state,
                  style: SheepsTextStyle.infoStrong().copyWith(
                    color: controller.state == '구직완료' ? sheepsColorGrey : sheepsColorBlue,
                  ),
                ),
                if (controller.state == '구직중') ...[
                  if(Platform.isAndroid) TextSpan(text: '・최근 접속일자 ')
                  else if(Platform.isIOS) TextSpan(text: ' ・ 최근 접속일자 '),
                  TextSpan(text: '${controller.periodStart}'),
                ]
              ],
              style: SheepsTextStyle.hint4Profile(),
            ),
          ),
          SizedBox(height: 12 * sizeUnit),
          Text(
            controller.contents,
            style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
          ),
          SizedBox(height: 20 * sizeUnit),
          Text('구직분야', style: SheepsTextStyle.h3()),
          SizedBox(height: 12 * sizeUnit),
          Wrap(
            runSpacing: 8 * sizeUnit,
            spacing: 8 * sizeUnit,
            children: [
              if (controller.secondWrapList[0].isNotEmpty) wrapItem(controller.secondWrapList[0], isColor: true),
              if (controller.secondWrapList[1].isNotEmpty) wrapItem(controller.secondWrapList[1]),
            ],
          ),
          SizedBox(height: 20 * sizeUnit),
          Text('역량', style: SheepsTextStyle.h3()),
          SizedBox(height: 12 * sizeUnit),
          Text(controller.abilityContents, style: SheepsTextStyle.b3().copyWith(height: 16 / 12)),
          SizedBox(height: 20 * sizeUnit),
          if ((controller.thirdWrapList[0].isNotEmpty || controller.thirdWrapList[1].isNotEmpty) || controller.careerList.isNotEmpty) ...[
            Text('이력정보', style: SheepsTextStyle.h3()),
            if (controller.thirdWrapList[0].isNotEmpty || controller.thirdWrapList[1].isNotEmpty) SizedBox(height: 12 * sizeUnit),
            Wrap(
              runSpacing: 8 * sizeUnit,
              spacing: 8 * sizeUnit,
              children: [
                if (controller.thirdWrapList[0].isNotEmpty) wrapItem(controller.thirdWrapList[0]),
                if (controller.thirdWrapList[1].isNotEmpty) wrapItem(controller.thirdWrapList[1]),
              ],
            ),
            SizedBox(height: 12 * sizeUnit),
            Column(
              children: List.generate(controller.careerList.length, (index) {
                if (controller.careerList.isEmpty) return Container();
                return authItem(controller.careerList[index], controller.careerAuthList[index]);
              }),
            ),
            SizedBox(height: 20 * sizeUnit),
          ] else ...[
            if (isMe) ...[
              Text('이력정보', style: SheepsTextStyle.h3()),
              SizedBox(height: 12 * sizeUnit),
              Row(
                children: [
                  Text('・ ', style: SheepsTextStyle.b3()),
                  Text('이력정보를 추가해 보세요', style: SheepsTextStyle.error()),
                ],
              ),
              SizedBox(height: 20 * sizeUnit),
            ]
          ],
          Text('근무조건', style: SheepsTextStyle.h3()),
          SizedBox(height: 12 * sizeUnit),
          Wrap(
            runSpacing: 8 * sizeUnit,
            spacing: 8 * sizeUnit,
            children: List.generate(controller.workConditionList.length, (index) => wrapItem(controller.workConditionList[index])),
          ),
          SizedBox(height: 12 * sizeUnit),
          Text(controller.workCondition, style: SheepsTextStyle.b3().copyWith(height: 16 / 12)),
          SizedBox(height: 20 * sizeUnit),
        ],
      ),
    );
  }

  Row shareAndLikeButton() {
    return Row(
      children: [
        //공유
        GestureDetector(
          onTap: () {
            if(isReady){
              isReady = false;
              Future.delayed(Duration(milliseconds: 800), () => isReady = true);
              shareRecruit();
            }
          },
          child: SvgPicture.asset(
            svgShareBox,
            width: 21 * sizeUnit,
            height: 21 * sizeUnit,
          ),
        ),
        SizedBox(width: 15.5 * sizeUnit),
        if (isMe) ...[
          GestureDetector(
            onTap: () => Get.dialog(moreDialogWidget(), barrierColor: Color.fromRGBO(204, 204, 204, 0.5)),
            child: SvgPicture.asset(
              'assets/images/Recruit/moreHorizIcon.svg',
              width: 28 * sizeUnit,
              height: 28 * sizeUnit,
            ),
          ),
        ] else ...[
          Obx(() => GestureDetector(
                onTap: () => controller.likeFunc(widget.isRecruit, dataList: dataList),
                child: SvgPicture.asset(
                  controller.isLike.value ? svgFillBookMarkIcon : svgBookMarkIcon,
                  width: 28 * sizeUnit,
                  height: 28 * sizeUnit,
                  color: controller.isLike.value
                      ? widget.isRecruit
                          ? sheepsColorBlue
                          : sheepsColorGreen
                      : null,
                ),
              )),
        ],
        SizedBox(width: 14 * sizeUnit),
      ],
    );
  }

  Widget moreDialogWidget() {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SizedBox.expand(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8 * sizeUnit, horizontal: 12 * sizeUnit),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 32 * sizeUnit,
                    height: 32 * sizeUnit,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.clear,
                      size: 20 * sizeUnit,
                      color: sheepsColorDarkGrey,
                    ),
                  ),
                ),
                SizedBox(height: 19 * sizeUnit),
                customShapeButton(
                  press: () {
                    if (widget.isRecruit) {
                      Get.to(() => TeamMemberRecruitEditPage(team: GlobalProfile.getTeamByID(teamMemberRecruit.teamId), teamMemberRecruit: teamMemberRecruit))?.then((value) {
                        if (value != null) {
                          setState(() {
                            teamMemberRecruit = value[0];
                            controller.dataSet(true, value[0]);
                          });
                        }
                      });
                    } else {
                      Get.to(() => PersonalSeekTeamsEditPage(personalSeekTeam: personalSeekTeam))?.then((value) {
                        if (value != null) {
                          setState(() {
                            personalSeekTeam = value[0];
                            controller.dataSet(false, value[0]);
                          });
                        }
                      });
                    }
                  },
                  text: '수정하기',
                ),
                if (controller.state != '구직완료' && controller.state != '모집마감') ...[
                  SizedBox(height: 12 * sizeUnit),
                  customShapeButton(
                    press: () async {
                      String created = widget.data.createdAt;
                      String today = getYearMonthDayByDate();
                      String createdDay = created.substring(0, 8);
                      String toDayDay = today.substring(0, 8);

                      var diffDay = int.parse(toDayDay) - int.parse(createdDay);
                      if (diffDay > 3) {
                        if (widget.isRecruit) {
                          await ApiProvider()
                              .post(
                                  '/Matching/PullUpPost/TeamMemberRecruit',
                                  jsonEncode({
                                    'id': widget.data.id,
                                  }))
                              .then((value) {
                            for (int i = 0; i < globalTeamMemberRecruitList.length; i++) {
                              if (globalTeamMemberRecruitList[i].id == widget.data.id) {
                                var tmp = globalTeamMemberRecruitList[i];
                                tmp.createdAt = toDayDay;
                                globalTeamMemberRecruitList.removeAt(i);
                                globalTeamMemberRecruitList.insert(0, tmp);
                                break;
                              }
                            }
                            showSheepsDialog(
                                context: context,
                                title: '끌어올리기 성공!',
                                okFunc: () {
                                  Get.back();
                                  Get.back();
                                },
                                isCancelButton: false);
                          });
                        } else {
                          await ApiProvider()
                              .post(
                                  '/Matching/PullUpPost/PersonalSeekTeam',
                                  jsonEncode({
                                    'id': widget.data.id,
                                  }))
                              .then((value) {
                            for (int i = 0; i < globalPersonalSeekTeamList.length; i++) {
                              if (globalPersonalSeekTeamList[i].id == widget.data.id) {
                                var tmp = globalPersonalSeekTeamList[i];
                                tmp.createdAt = toDayDay;
                                globalPersonalSeekTeamList.removeAt(i);
                                globalPersonalSeekTeamList.insert(0, tmp);
                                break;
                              }
                            }
                            showSheepsDialog(
                                context: context,
                                title: '끌어올리기 성공!',
                                okFunc: () {
                                  Get.back();
                                  Get.back();
                                },
                                isCancelButton: false);
                          });
                        }
                      } else {
                        showSheepsDialog(
                            context: context,
                            title: '끌어올리기',
                            description: '"' + (3 - diffDay).toString() + '" 일 뒤에 끌어올릴 수 있어요.',
                            okFunc: () {
                              Get.back();
                              Get.back();
                            },
                            isCancelButton: false);
                      }
                    },
                    text: '끌어올리기',
                  ),
                  SizedBox(height: 12 * sizeUnit),
                  customShapeButton(
                    press: () async {
                      if (widget.isRecruit) {
                        showSheepsDialog(
                          context: context,
                          title: '모집상태 변경',
                          description: '모집상태를 모집마감으로 변경하시겠어요?',
                          okFunc: () async {
                            String now = DateTime.now().subtract(Duration(seconds: 10)).toString().replaceAll('-', '').replaceAll(' ', '').replaceAll(':', '').substring(0, 14); //10초 전
                            await ApiProvider()
                                .post(
                                    '/Matching/Update/TeamMemberRecruit',
                                    jsonEncode({
                                      'id': teamMemberRecruit.id,
                                      'teamID': teamMemberRecruit.teamId,
                                      'recruitPeriodEnd': now,
                                    }))
                                .then((value) {
                              for (int i = 0; i < globalTeamMemberRecruitList.length; i++) {
                                if (globalTeamMemberRecruitList[i].id == teamMemberRecruit.id) {
                                  globalTeamMemberRecruitList[i].recruitPeriodEnd = now;
                                  teamMemberRecruit.recruitPeriodEnd = now;

                                  setState(() {
                                    controller.periodEnd = controller.setDateTime(now);
                                    controller.state = '모집마감';
                                  });
                                  break;
                                }
                              }
                            });
                            Get.back();
                            Get.back();
                          },
                          cancelFunc: () {
                            Get.back();
                            Get.back();
                          },
                        );
                      } else {
                        showSheepsDialog(
                          context: context,
                          title: '구직완료 변경',
                          description: '구직상태를 구직완료로 변경하시겠어요?',
                          okFunc: () async {
                            await ApiProvider()
                                .post(
                                    '/Matching/Update/PersonalSeekTeam',
                                    jsonEncode({
                                      'id': personalSeekTeam.id,
                                      "userID": personalSeekTeam.userId,
                                      'seekingState': 0,
                                    }))
                                .then((value) {
                              for (int i = 0; i < globalPersonalSeekTeamList.length; i++) {
                                if (globalPersonalSeekTeamList[i].id == personalSeekTeam.id) {
                                  globalPersonalSeekTeamList[i].seekingState = 0;
                                  personalSeekTeam.seekingState = 0;

                                  setState(() {
                                    controller.state = '구직완료';
                                  });
                                  break;
                                }
                              }
                            });
                            Get.back();
                            Get.back();
                          },
                          cancelFunc: () {
                            Get.back();
                            Get.back();
                          },
                        );
                      }
                    },
                    text: widget.isRecruit ? '모집마감' : '구직완료',
                    color: widget.isRecruit ? sheepsColorGreen : sheepsColorBlue,
                  ),
                ],
                SizedBox(height: 12 * sizeUnit),
                customShapeButton(
                  press: () {
                    if (widget.isRecruit) {
                      showSheepsDialog(
                        context: context,
                        title: '삭제 확인',
                        description: '정말 팀원모집을 삭제하시겠어요?\n이 팀원모집과 연결된 인터뷰도 전부 삭제됩니다.',
                        okFunc: () async {
                          var roomName = "teamMemberID" + teamMemberRecruit.id.toString();

                          await ApiProvider()
                              .post(
                                  '/Matching/Delete/TeamMemberRecruit',
                                  jsonEncode({
                                    'id': teamMemberRecruit.id,
                                    "userID": GlobalProfile.loggedInUser!.userID,
                                    "teamName": GlobalProfile.getTeamByID(teamMemberRecruit.teamId).name,
                                    "roomName": roomName,
                                  }))
                              .then((value) {
                            for (int i = 0; i < globalTeamMemberRecruitList.length; i++) {
                              if (globalTeamMemberRecruitList[i].id == teamMemberRecruit.id) {
                                globalTeamMemberRecruitList.removeAt(i);
                                break;
                              }
                            }

                            ChatGlobal.roomInfoList.removeWhere((element) => element.roomName.contains(roomName));
                          });

                          if(dataList.isNotEmpty) dataList.removeWhere((element) => element.id == teamMemberRecruit.id); // 전 페이지에 삭제되는거 반영

                          Get.back();
                          Get.back();
                          Get.back();
                        },
                        cancelFunc: () {
                          Get.back();
                          Get.back();
                        },
                      );
                    } else {
                      showSheepsDialog(
                        context: context,
                        title: '삭제 확인',
                        description: '정말 팀 찾기를 삭제하시겠어요?\n이 팀 찾기와 연결된 인터뷰도 전부 삭제됩니다.',
                        okFunc: () async {
                          var roomName = "personalID" + personalSeekTeam.id.toString();

                          debugPrint("destroy roomname " + roomName);

                          await ApiProvider()
                              .post(
                                  '/Matching/Delete/PersonalSeekTeam',
                                  jsonEncode({
                                    'id': personalSeekTeam.id,
                                    "userID": GlobalProfile.loggedInUser!.userID,
                                    "userName": GlobalProfile.loggedInUser!.name,
                                    "roomName": roomName,
                                  }))
                              .then((value) {
                            for (int i = 0; i < globalPersonalSeekTeamList.length; i++) {
                              if (globalPersonalSeekTeamList[i].id == personalSeekTeam.id) {
                                globalPersonalSeekTeamList.removeAt(i);
                                break;
                              }
                            }

                            ChatGlobal.roomInfoList.removeWhere((element) => element.roomName.contains(roomName));
                          });

                          if(dataList.isNotEmpty) dataList.removeWhere((element) => element.id == personalSeekTeam.id); // 전 페이지에 삭제되는거 반영

                          Get.back();
                          Get.back();
                          Get.back();
                        },
                        cancelFunc: () {
                          Get.back();
                          Get.back();
                        },
                      );
                    }
                  },
                  text: '삭제하기',
                  color: sheepsColorRed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container wrapItem(String text, {bool isColor = false}) {
    return Container(
      height: 20 * sizeUnit,
      padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit),
      decoration: BoxDecoration(
        color: isColor
            ? widget.isRecruit
                ? sheepsColorGreen
                : sheepsColorBlue
            : sheepsColorLightGrey,
        borderRadius: BorderRadius.circular(16 * sizeUnit),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: SheepsTextStyle.b3().copyWith(color: isColor ? Colors.white : sheepsColorBlack),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 앱 바
  SliverAppBar customSliverAppBar() {
    return SliverAppBar(
      elevation: 0,
      expandedHeight: appBarHeight,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Obx(() => Text(
            controller.name,
            textAlign: TextAlign.center,
            style: SheepsTextStyle.appBar().copyWith(
              color: controller.shrinkState.value ? Colors.black : Colors.transparent,
            ),
          )),
      leading: InkWell(
        onTap: () {
          Get.back(result: widget.isRecruit ? teamMemberRecruit : personalSeekTeam);
        },
        child: Padding(
          padding: EdgeInsets.all(12 * sizeUnit),
          child: Obx(() => SvgPicture.asset(
                svgWhiteBackArrow,
                color: controller.shrinkState.value ? sheepsColorDarkGrey : Colors.white,
                width: 28 * sizeUnit,
                height: 28 * sizeUnit,
              )),
        ),
      ),
      actions: [
        Obx(() => controller.shrinkState.value ? shareAndLikeButton() : Container()),
      ],
      flexibleSpace: Obx(() => Container(
            decoration: BoxDecoration(
              border: controller.shrinkState.value
                  ? Border(
                      bottom: BorderSide(
                        color: sheepsColorGrey,
                        width: 0.5 * sizeUnit,
                      ),
                    )
                  : null,
            ),
            child: FlexibleSpaceBar(
              centerTitle: true,
              background: Hero(
                tag: widget.isRecruit ? 'teamMemberRecruit${controller.id}' : 'personalSeekTeam${controller.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      controller: controller.pageController,
                      itemCount: controller.photoUrlList.length,
                      onPageChanged: (index) => controller.pageChangeEvent(index),
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            if (controller.photoUrlList[0] == 'BasicImage') ...[
                              Center(
                                child: SvgPicture.asset(
                                  svgSheepsBasicProfileImage,
                                  width: 180 * sizeUnit,
                                  height: 164 * sizeUnit,
                                  color: widget.isRecruit ? sheepsColorGreen : sheepsColorBlue,
                                ),
                              ),
                            ] else ...[
                              SizedBox(
                                width: 360 * sizeUnit,
                                height: appBarHeight,
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: getOptimizeImageURL(controller.photoUrlList[index], 0),
                                  ),
                                ),
                              ),
                            ],
                            gradationBox(),
                          ],
                        );
                      },
                    ),
                    Positioned(
                      left: 12 * sizeUnit,
                      bottom: 12 * sizeUnit,
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(controller.photoUrlList.length, (index) => buildDot(index)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget buildDot(int index) {
    return Obx(
      () => AnimatedContainer(
        duration: kAnimationDuration,
        margin: EdgeInsets.only(right: 4 * sizeUnit),
        height: 4 * sizeUnit,
        width: controller.currentPage.value == index ? 12 * sizeUnit : 4 * sizeUnit,
        // width: index.isEven ? 12 * sizeUnit : 4 * sizeUnit,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2 * sizeUnit),
        ),
      ),
    );
  }

  void shareRecruit() async {
    if (widget.isRecruit) {
      DialogBuilder(context).showLoadingIndicator();
      final DynamicLinkParameters parameters = DynamicLinkParameters(
          uriPrefix: 'https://sheepsapp.page.link',
          link: Uri.parse('https://sheepsapp.page.link/recruit_team?id=${teamMemberRecruit.id}'),
          androidParameters: AndroidParameters(
            packageName: 'kr.noteasy.sheeps_app',
            minimumVersion: 1, //실행 가능 최소 버전
          ),
          iosParameters: IOSParameters(
            bundleId: 'kr.noteasy.sheepsApp',
            minimumVersion: '1.0',
            appStoreId: '1558625011',
          ));

      // final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
      // final Uri shortUrl = shortDynamicLink.shortUrl;
      final Uri shortUrl = parameters.link;

      String name = GlobalProfile.getTeamByID(teamMemberRecruit.teamId).name;
      String title = cutAuthInfo(teamMemberRecruit.title);

      DialogBuilder(context).hideOpenDialog();
      Share.share('$name 팀 팀원모집 보기\n$title\n$shortUrl', subject: '스타트업 필수 앱! 사담!\n');
    } else {
      DialogBuilder(context).showLoadingIndicator();
      final DynamicLinkParameters parameters = DynamicLinkParameters(
          uriPrefix: 'https://sheepsapp.page.link',
          link: Uri.parse('https://sheepsapp.page.link/recruit_person?id=${personalSeekTeam.id}'),
          androidParameters: AndroidParameters(
            packageName: 'kr.noteasy.sheeps_app',
            minimumVersion: 1, //실행 가능 최소 버전
          ),
          iosParameters: IOSParameters(
            bundleId: 'kr.noteasy.sheepsApp',
            minimumVersion: '1.0',
            appStoreId: '1558625011',
          ));

      // final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
      // final Uri shortUrl = shortDynamicLink.shortUrl;
      final Uri shortUrl = parameters.link;

      String name = GlobalProfile.getUserByUserID(personalSeekTeam.userId).name;
      String title = cutAuthInfo(personalSeekTeam.title);

      DialogBuilder(context).hideOpenDialog();
      Share.share('$name님 팀 찾기 보기\n$title\n$shortUrl', subject: '스타트업 필수 앱! 사담!\n');
    }
  }
}
