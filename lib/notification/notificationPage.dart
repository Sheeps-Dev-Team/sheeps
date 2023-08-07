import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:badges/badges.dart' as badges;

import 'package:extended_image/extended_image.dart';
import 'package:flutter_slidable/flutter_slidable.dart' ;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:sheeps_app/Badge/model/ModelBadge.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/NavigationNum.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/notification/models/NotiDatabase.dart';
import 'package:sheeps_app/notification/models/NotificationModel.dart';
import 'package:sheeps_app/profile/models/ProfileState.dart';
import 'package:sheeps_app/Recruit/Models/RecruitLikes.dart';
import 'package:sheeps_app/Recruit/Models/TeamMemberRecruit.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';

class TotalNotificationPage extends StatefulWidget {
  @override
  _TotalNotificationPageState createState() => _TotalNotificationPageState();
}

class _TotalNotificationPageState extends State<TotalNotificationPage> {
  final RecruitInviteController recruitInviteController = Get.put(RecruitInviteController());
  final NavigationNum navigationNum = Get.put(NavigationNum());
  Animation<double>? _rotationAnimation;
  Color _fabColor = Colors.blue;

  ProfileState? profileState;

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {
    setState(() {
      _rotationAnimation = slideAnimation;
    });
  }

  void handleSlideIsOpenChanged(bool isOpen) {
    setState(() {
      _fabColor = isOpen ? Colors.green : Colors.blue;
    });
  }

  @override
  void initState() {
    super.initState();

    profileState = Get.put(ProfileState());

  }

  @override
  Widget build(BuildContext context) {
    List<NotificationModel> unReadNotiList = notiList.where((element) => element.isRead == 0).toList();
    List<NotificationModel> readNotiList = notiList.where((element) => element.isRead == 1).toList();

    int SHOW_NOTI_MAX = 9;
    int UNREAD_NOTI_MAX = 4;
    int UNREAD_NOTI_CNT = unReadNotiList.length > UNREAD_NOTI_MAX ? UNREAD_NOTI_MAX : unReadNotiList.length;
    int READ_NOTI_CNT = readNotiList.length > SHOW_NOTI_MAX ? SHOW_NOTI_MAX : readNotiList.length;

    READ_NOTI_CNT = UNREAD_NOTI_CNT != 0 ? SHOW_NOTI_MAX - UNREAD_NOTI_CNT : SHOW_NOTI_MAX;

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
                appBar: SheepsAppBar(context, '전체 알림'),
                backgroundColor: Color(0xFFFAFAFA),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    badges.Badge(
                      badgeStyle: badges.BadgeStyle(
                        shape : badges.BadgeShape.circle,
                        badgeColor : sheepsColorRed,
                        elevation : 0,
                        padding : EdgeInsets.all(3 * sizeUnit),
                      ),
                      showBadge: unReadNotiList.length > 0,
                      position: badges.BadgePosition.topStart(top: 8 * sizeUnit, start: 92 * sizeUnit),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(16 * sizeUnit, 8 * sizeUnit, 0, 8 * sizeUnit),
                        color: Colors.white,
                        width: 360 * sizeUnit,
                        height: 30 * sizeUnit,
                        child: Text(
                          "읽지 않은 알림",
                          style: SheepsTextStyle.h4(),
                        ),
                      ),
                    ),
                    if (unReadNotiList.length == 0) ...[
                      SizedBox.shrink()
                    ] else ...[
                      SingleChildScrollView(
                        child: Container(
                          color: Colors.white,
                          height: (UNREAD_NOTI_CNT * 60 * sizeUnit) + (15 * sizeUnit),
                          child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: unReadNotiList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Slidable(
                                  key: Key(unReadNotiList[index].id.toString()),
                                  startActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    extentRatio: 0.20,
                                    dismissible: DismissiblePane(onDismissed: () {}),
                                    children: [
                                      SlidableAction(
                                        foregroundColor: Colors.grey.shade200,
                                        icon: Icons.check,
                                        onPressed: (BuildContext context) {
                                          setState(() {
                                            notiList[notiList.indexOf(unReadNotiList[index])].isRead = 1;
                                          });
                                          NotiDBHelper().updateDate(notiList[notiList.indexOf(unReadNotiList[index])].id, 1);
                                        },
                                      ),
                                    ],

                                  ),
                                  child: getNotificationListitem(unReadNotiList[index]),
                                );
                              }),
                        ),
                      ),
                    ],
                    Container(
                        width: 360 * sizeUnit,
                        height: 1,
                        decoration: BoxDecoration(
                          color: sheepsColorGrey,
                        )),
                    Container(
                      margin: EdgeInsets.fromLTRB(16 * sizeUnit, 12 * sizeUnit, 0, 8 * sizeUnit),
                      color: Color(0xFFFAFAFA),
                      child: Text(
                        "지난 알림",
                        style: SheepsTextStyle.h4(),
                      ),
                    ),
                    if (readNotiList.length == 0) ...[
                      SizedBox.shrink()
                    ] else ...[
                      Expanded(
                        child: SingleChildScrollView(
                          child: Container(
                            color: Color(0xFFFAFAFA),
                            height: (READ_NOTI_CNT * 60 * sizeUnit) + (15 * sizeUnit),
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: readNotiList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Slidable(
                                    key: Key(readNotiList[index].id.toString()),
                                    endActionPane: ActionPane(
                                      motion: const ScrollMotion(),
                                      extentRatio: 0.20,
                                      dismissible: DismissiblePane(onDismissed: () {}),
                                      children: [
                                        SlidableAction(
                                          foregroundColor: Colors.grey.shade200,
                                          icon: Icons.check,
                                          onPressed: (BuildContext context) {
                                            setState(() {
                                              notiList.remove(readNotiList[index]);
                                            });
                                            NotiDBHelper().deleteData(readNotiList[index].id);
                                          },
                                        ),
                                      ],
                                    ),
                                    child: getNotificationListitem(readNotiList[index], isRead: true),
                                  );
                                }),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getNotificationListitem(NotificationModel notificationModel, {isRead = false}) {
    return Container(
        height: 60 * sizeUnit,
        color: isRead == true ? Color(0xFFFAFAFA) : Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 72 * sizeUnit,
              child: Center(
                child: notificationModel.from == -1 || (GlobalProfile.getUserByUserID(notificationModel.type != NOTI_EVENT_TEAM_MEMBER_ADD ? notificationModel.from : notificationModel.targetIndex) == null)
                    ? Container(
                  //운영자 noti
                    width: 44 * sizeUnit,
                    height: 44 * sizeUnit,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: sheepsColorGrey),
                      borderRadius: new BorderRadius.circular(12 * sizeUnit),
                    ),
                    child: Center(
                        child: SvgPicture.asset(
                          svgSheepsBasicProfileImage,
                          width: 24 * sizeUnit,
                          height: 24 * sizeUnit,
                        )))
                    : GlobalProfile.getUserByUserID(notificationModel.type != NOTI_EVENT_TEAM_MEMBER_ADD ? notificationModel.from : notificationModel.targetIndex).profileImgList[0].imgUrl == 'BasicImage' ||
                    (notificationModel.type == NOTI_EVENT_POST_REPLY &&
                        GlobalProfile.globalCommunityList.singleWhere((element) => element.id == notificationModel.tableIndex).category == "비밀") ||
                    (notificationModel.type == NOTI_EVENT_POST_REPLY_REPLY &&
                        GlobalProfile.globalCommunityList.singleWhere((element) => element.id == notificationModel.tableIndex).category == "비밀")
                    ? Container(
                    width: 44 * sizeUnit,
                    height: 44 * sizeUnit,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: sheepsColorGrey),
                      borderRadius: new BorderRadius.circular(12 * sizeUnit),
                    ),
                    child: Center(
                        child: SvgPicture.asset(
                          svgSheepsBasicProfileImage,
                          color: sheepsColorBlue,
                          width: 24 * sizeUnit,
                          height: 24 * sizeUnit,
                        )))
                    : Container(
                  width: 44 * sizeUnit,
                  height: 44 * sizeUnit,
                  child: ClipRRect(
                      borderRadius: new BorderRadius.circular(12 * sizeUnit),
                      child: FittedBox(
                        child: ExtendedImage.network(getOptimizeImageURL(GlobalProfile.getUserByUserID(notificationModel.type != NOTI_EVENT_TEAM_MEMBER_ADD ? notificationModel.from : notificationModel.targetIndex).profileImgList[0].imgUrl, 120)),
                        fit: BoxFit.cover,
                      )),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8 * sizeUnit),
              child: Column(
                children: [
                  InkWell(
                    onTap: () async {
                      await notiClickEvent(context, notificationModel, profileState!, navigationNum, recruitInviteController).then((value) => {
                        setState(() {
                          notiList[notiList.indexOf(notificationModel)].isRead = 1;
                          NotiDBHelper().updateDate(notiList[notiList.indexOf(notificationModel)].id, 1);
                        })
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 20 * sizeUnit),
                      child: Container(
                        height: 52 * sizeUnit,
                        width: 264 * sizeUnit,
                        child: Align(alignment: Alignment.topLeft, child: getNotiInfoText(notificationModel)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget getNotiInfoText(NotificationModel notificationModel) {
    return RichText(
        text: TextSpan(children: [
          customTextSpan(notificationModel, 0),
          customTextSpan(notificationModel, 1),
          customTextSpan(notificationModel, 2),
          customTextSpan(notificationModel, 3),
          TextSpan(text: "  " + timeCheck(replaceDate(notificationModel.time)), style: SheepsTextStyle.bWriteDate())
        ]));
  }

  TextSpan customTextSpan(NotificationModel notificationModel, int index) {
    String info = '';
    TextStyle style = SheepsTextStyle.b3();

    UserData user = GlobalProfile.getUserByUserID(notificationModel.from);

    String part = notificationModel.from == -1 || user == null
        ? ''
        : user.part == ''
        ? ''
        : ' / ' + user.part;
    String location = notificationModel.from == -1 || user == null
        ? ''
        : user.location == ''
        ? ''
        : ' / ' + user.subLocation;

    String userInfo = user != null ? user.name + part + location : "탈주한 양 ";

    switch (notificationModel.type) {
      case NOTI_EVENT_INVITE:
        {
          switch (index) {
            case 0:
              {
                info = userInfo;
                style = SheepsTextStyle.h4();
              }
              break;
            case 1:
              {
                info = "님이 채팅 요청을 보냈습니다. 어떤 프로필인지 확인해 보세요!";
                style = SheepsTextStyle.b3();
              }
              break;
            case 2:
              {
                info = '';
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_INVITE_ACCEPT:
        {
          switch (index) {
            case 0:
              {
                info = userInfo;
                style = SheepsTextStyle.h4();
              }
              break;
            case 1:
              {
                info = "님이 채팅 요청을 수락했습니다!. 채팅으로 비즈니스를 시작해 보세요.";
                style = SheepsTextStyle.b3();
              }
              break;
            case 2:
              {
                info = '';
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_INVITE_REFUSE:
        {
          switch (index) {
            case 0:
              {
                info = userInfo;
                style = SheepsTextStyle.h4();
              }
              break;
            case 1:
              {
                info = "님이 채팅 요청을 거절했습니다. 프로필 완성도를 높이면 채팅 수락 확률을 올릴 수 있어요!";
                style = SheepsTextStyle.b3();
              }
              break;
            case 2:
              {
                info = '';
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_TEAM_INVITE_ACCEPT:
        {
          Team team = GlobalProfile.getTeamByID(notificationModel.teamIndex);

          String teamInfo = team != null ? team.name : "해체된";

          switch (index) {
            case 0:
              {
                info = teamInfo;
                style = SheepsTextStyle.h4();
              }
              break;
            case 1:
              {
                info = " 팀이 지원에 합격했어요! 팀원들과 반가운 첫 인사를 나누어 보세요.";
                style = SheepsTextStyle.b3();
              }
              break;
            case 2:
              {
                info = '';
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_TEAM_MEMBER_KICKED_OUT:
        {
          Team team = GlobalProfile.getTeamByID(notificationModel.teamIndex);

          String teamInfo = team != null ? team.name : "해체된";

          switch (index) {
            case 0:
              {
                info = teamInfo;
                style = SheepsTextStyle.h4();
              }
              break;
            case 1:
              {
                info = " 팀에서 추방되었습니다. 걱정하지 마세요! 쉽스에는 멋진 팀들이 계속 생겨난답니다!";
                style = SheepsTextStyle.b3();
              }
              break;
            case 2:
              {
                info = '';
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_TEAM_MEMBER_LEAVE:
        {
          switch (index) {
            case 0:
              {
                info = userInfo;
                style = SheepsTextStyle.h4();
              }
              break;
            case 1:
              {
                info = " 님이 팀에서 나갔습니다. 하지만, 실망하지 마세요! 쉽스에는 좋은 인재들이 많답니다.";
                style = SheepsTextStyle.b3();
              }
              break;
            case 2:
              {
                info = '';
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_POST_REPLY:
        {
          Community community = GlobalProfile.globalCommunityList.singleWhere((element) => element.id == notificationModel.tableIndex);

          switch (index) {
            case 0:
              {
                if (community.category == "비밀") {
                  info = "익명";
                } else {
                  info = userInfo;
                }

                style = SheepsTextStyle.h4();
              }
              break;
            case 1:
              {
                info = "님이 '" + community.title + "'";
                style = SheepsTextStyle.b3();
              }
              break;
            case 2:
              {
                info = "게시글에 댓글을 남겼습니다.";
                style = SheepsTextStyle.b3();
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_POST_REPLY_REPLY:
        {
          Community community = GlobalProfile.globalCommunityList.singleWhere((element) => element.id == notificationModel.tableIndex);

          switch (index) {
            case 0:
              {
                if (community.category == "비밀") {
                  info = "익명";
                } else {
                  info = userInfo;
                }

                style = SheepsTextStyle.h4();
              }
              break;
            case 1:
              {
                info = "님이 '" + community.title + "'";
                style = SheepsTextStyle.b3();
              }
              break;
            case 2:
              {
                info = "게시글에 대댓글을 남겼습니다.";
                style = SheepsTextStyle.b3();
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_TEAM_MEMBER_ADD:
        {
          UserData who = GlobalProfile.getUserByUserID(notificationModel.targetIndex);
          Team team = GlobalProfile.getTeamByID(notificationModel.teamIndex);

          part = who.part == ''
              ? ''
              : ' / ' + who.part;
          location = who.location == ''
              ? ''
              : ' / ' + who.subLocation;

          String whoInfo = who != null ? who.name + part + location : "탈주한 양 ";
          String teamInfo = team != null ? team.name : "해체된";

          switch (index) {
            case 0:
              {
                info = whoInfo;
                style = SheepsTextStyle.h4();
              }
              break;
            case 1:
              {
                info = "님이 팀 ";
                style = SheepsTextStyle.b3();
              }
              break;
            case 2:
              {
                info = " '" + teamInfo + "'";
                style = SheepsTextStyle.h4();
              }
              break;
            case 3:
              {
                info = '에 가입 했어요! 반가운 첫 인사를 나누어 보세요.';
                style = SheepsTextStyle.b3();
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_INVITE_PERSONALSEEKTEAM:
        {
          Team team = GlobalProfile.getTeamByID(notificationModel.teamIndex);
          String teamInfo = team != null ? team.name : "해체된";

          switch (index) {
            case 0:
              {
                info = teamInfo;
                style = SheepsTextStyle.h4();
              }
              break;
            case 1:
              {
                info = " 팀이 회원님께 제안을 요청했어요! 면접 채팅방을 열어 대화를 나누고, 서로 알아가 보세요.";
                style = SheepsTextStyle.b3();
              }
              break;
            case 2:
              {
                info = '';
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_INVITE_PERSONALSEEKTEAM_ACCEPT:
        {
          Team team = GlobalProfile.getTeamByID(notificationModel.teamIndex);
          String teamInfo = team != null ? team.name : "해체된";

          switch (index) {
            case 0:
              {
                info = userInfo;
                style = SheepsTextStyle.h4();
              }
              break;
            case 1:
              {
                info = "님이 ";
                style = SheepsTextStyle.b3();
              }
              break;
            case 2:
              {
                info = teamInfo;
                style = SheepsTextStyle.h4();
              }
              break;
            case 3:
              {
                info = " 팀의 제안을 수락했어요! 면접 채팅방에서 상대방과 대화를 나누어 보아요.";
                style = SheepsTextStyle.b3();
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_INVITE_PERSONALSEEKTEAM_REFUSE:
        {
          Team team = GlobalProfile.getTeamByID(globalTeamMemberRecruitList.singleWhere((element) => element.id == notificationModel.targetIndex).teamId);
          String teamInfo = team != null ? team.name : "해체된";

          switch (index) {
            case 0:
              {
                info = userInfo;
                style = SheepsTextStyle.h4();
              }
              break;
            case 1:
              {
                info = "님이 ";
                style = SheepsTextStyle.b3();
              }
              break;
            case 2:
              {
                info = teamInfo;
                style = SheepsTextStyle.h4();
              }
              break;
            case 3:
              {
                info = " 팀의 제안을 거절했어요. 하지만, 실망하지 마세요! 쉽스에는 좋은 인재들이 많답니다.";
                style = SheepsTextStyle.b3();
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_INVITE_TEAMMEMBERRECRUIT:
        {
          Team team = GlobalProfile.getTeamByID(globalTeamMemberRecruitList.singleWhere((element) => element.id == notificationModel.targetIndex).teamId);
          String teamInfo = team != null ? team.name : "해체된";

          switch (index) {
            case 0:
              {
                info = userInfo;
                style = SheepsTextStyle.h4();
              }
              break;
            case 1:
              {
                info = "님이 ";
                style = SheepsTextStyle.b3();
              }
              break;
            case 2:
              {
                info = teamInfo;
                style = SheepsTextStyle.h4();
              }
              break;
            case 3:
              {
                info = " 팀에 지원했어요! 면접 채팅방을 열어 대화를 나누고, 서로 알아가 보세요.";
                style = SheepsTextStyle.b3();
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_INVITE_TEAMMEMBERRECRUIT_ACCEPT:
        {
          Team team = GlobalProfile.getTeamByID(globalTeamMemberRecruitList.singleWhere((element) => element.id == notificationModel.teamIndex).teamId);
          String teamInfo = team != null ? team.name : "해체된";

          switch (index) {
            case 0:
              {
                info = teamInfo;
                style = SheepsTextStyle.h4();
              }
              break;
            case 1:
              {
                info = " 팀 지원에 합격했어요! 면접 채팅방에서 상대방과 대화를 나누어 보아요.";
                style = SheepsTextStyle.b3();
              }
              break;
            case 2:
              {
                info = '';
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_INVITE_TEAMMEMBERRECRUIT_REFUSE:
        {
          Team team = GlobalProfile.getTeamByID(globalTeamMemberRecruitList.singleWhere((element) => element.id == notificationModel.teamIndex).teamId);
          String teamInfo = team != null ? team.name : "해체된";

          switch (index) {
            case 0:
              {
                info = teamInfo;
                style = SheepsTextStyle.h4();
              }
              break;
            case 1:
              {
                info = " 팀 지원에 지원에 불합격했어요! 하지만, 실망하지마세요! 쉽스에는 멋진 팀들이 계속 생겨난답니다!";
                style = SheepsTextStyle.b3();
              }
              break;
            case 2:
              {
                info = '';
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_PERSONAL_UNIV_AUTH_UPDATE:
        {
          UserEducation education = GlobalProfile.loggedInUser.userEducationList.singleWhere((element) => element.id == notificationModel.tableIndex);

          //반려
          if (education.auth == 0) {
            switch (index) {
              case 0:
                {
                  info = "학력";
                  style = SheepsTextStyle.h4();
                }
                break;
              case 1:
                {
                  info = " 인증이 반려되었습니다. 반려 사유에 해당되는지 확인해 보세요!";
                  style = SheepsTextStyle.b3();
                }
                break;
              case 2:
                {
                  info = '';
                }
                break;
              case 3:
                {
                  info = '';
                }
                break;
            }
          } else {
            //승인
            switch (index) {
              case 0:
                {
                  info = "축하해요!";
                  style = SheepsTextStyle.b3();
                }
                break;
              case 1:
                {
                  info = "학력";
                  style = SheepsTextStyle.h4();
                }
                break;
              case 2:
                {
                  info = " 인증이 승인되었습니다.";
                  style = SheepsTextStyle.b3();
                }
                break;
              case 3:
                {
                  info = '';
                }
                break;
            }
          }
        }
        break;
      case NOTI_EVENT_PERSONAL_GRADUATE_AUTH_UPDATE:
        {}
        break;
      case NOTI_EVENT_PERSONAL_CAREER_AUTH_UPDATE:
        {
          UserCareer career = GlobalProfile.loggedInUser.userCareerList.singleWhere((element) => element.id == notificationModel.tableIndex);

          //반려
          if (career.auth == 0) {
            switch (index) {
              case 0:
                {
                  info = "경력";
                  style = SheepsTextStyle.h4();
                }
                break;
              case 1:
                {
                  info = " 인증이 반려되었습니다. 반려 사유에 해당되는지 확인해 보세요!";
                  style = SheepsTextStyle.b3();
                }
                break;
              case 2:
                {
                  info = '';
                }
                break;
              case 3:
                {
                  info = '';
                }
                break;
            }
          } else {
            //승인
            switch (index) {
              case 0:
                {
                  info = "축하해요!";
                  style = SheepsTextStyle.b3();
                }
                break;
              case 1:
                {
                  info = "경력";
                  style = SheepsTextStyle.h4();
                }
                break;
              case 2:
                {
                  info = " 인증이 승인되었습니다.";
                  style = SheepsTextStyle.b3();
                }
                break;
              case 3:
                {
                  info = '';
                }
                break;
            }
          }
        }
        break;
      case NOTI_EVENT_PERSONAL_LICENSE_AUTH_UPDATE:
        {
          UserLicense license = GlobalProfile.loggedInUser.userLicenseList.singleWhere((element) => element.id == notificationModel.tableIndex);

          //반려
          if (license.auth == 0) {
            switch (index) {
              case 0:
                {
                  info = "자격증";
                  style = SheepsTextStyle.h4();
                }
                break;
              case 1:
                {
                  info = " 인증이 반려되었습니다. 반려 사유에 해당되는지 확인해 보세요!";
                  style = SheepsTextStyle.b3();
                }
                break;
              case 2:
                {
                  info = '';
                }
                break;
              case 3:
                {
                  info = '';
                }
                break;
            }
          } else {
            //승인
            switch (index) {
              case 0:
                {
                  info = "축하해요!";
                  style = SheepsTextStyle.b3();
                }
                break;
              case 1:
                {
                  info = "자격증";
                  style = SheepsTextStyle.h4();
                }
                break;
              case 2:
                {
                  info = " 인증이 승인되었습니다.";
                  style = SheepsTextStyle.b3();
                }
                break;
              case 3:
                {
                  info = '';
                }
                break;
            }
          }
        }
        break;
      case NOTI_EVENT_PERSONAL_WIN_AUTH_UPDATE:
        {
          UserWin win = GlobalProfile.loggedInUser.userWinList.singleWhere((element) => element.id == notificationModel.tableIndex);

          //반려
          if (win.auth == 0) {
            switch (index) {
              case 0:
                {
                  info = "수상";
                  style = SheepsTextStyle.h4();
                }
                break;
              case 1:
                {
                  info = " 인증이 반려되었습니다. 반려 사유에 해당되는지 확인해 보세요!";
                  style = SheepsTextStyle.b3();
                }
                break;
              case 2:
                {
                  info = '';
                }
                break;
              case 3:
                {
                  info = '';
                }
                break;
            }
          } else {
            //승인
            switch (index) {
              case 0:
                {
                  info = "축하해요!";
                  style = SheepsTextStyle.b3();
                }
                break;
              case 1:
                {
                  info = "수상";
                  style = SheepsTextStyle.h4();
                }
                break;
              case 2:
                {
                  info = " 인증이 승인되었습니다.";
                  style = SheepsTextStyle.b3();
                }
                break;
              case 3:
                {
                  info = '';
                }
                break;
            }
          }
        }
        break;
      case NOTI_EVENT_TEAM_AUTH_AUTH_UPDATE:
        {
          TeamAuth teamAuth = GlobalProfile.teamProfile.singleWhere((element) => element.id == notificationModel.teamIndex).teamAuthList.singleWhere((element) => element.id == notificationModel.tableIndex);

          //반려
          if (teamAuth.auth == 0) {
            switch (index) {
              case 0:
                {
                  info = "팀";
                  style = SheepsTextStyle.h4();
                }
                break;
              case 1:
                {
                  info = " 인증이 반려되었습니다. 반려 사유에 해당되는지 확인해 보세요!";
                  style = SheepsTextStyle.b3();
                }
                break;
              case 2:
                {
                  info = '';
                }
                break;
              case 3:
                {
                  info = '';
                }
                break;
            }
          } else {
            //승인
            switch (index) {
              case 0:
                {
                  info = "축하해요!";
                  style = SheepsTextStyle.b3();
                }
                break;
              case 1:
                {
                  info = "팀";
                  style = SheepsTextStyle.h4();
                }
                break;
              case 2:
                {
                  info = " 인증이 승인되었습니다.";
                  style = SheepsTextStyle.b3();
                }
                break;
              case 3:
                {
                  info = '';
                }
                break;
            }
          }
        }
        break;
      case NOTI_EVENT_TEAM_WIN_AUTH_UPDATE:
        {
          TeamWins teamWins = GlobalProfile.teamProfile.singleWhere((element) => element.id == notificationModel.teamIndex).teamWinList.singleWhere((element) => element.id == notificationModel.tableIndex);

          //반려
          if (teamWins.auth == 0) {
            switch (index) {
              case 0:
                {
                  info = "팀 ";
                  style = SheepsTextStyle.b3();
                }
                break;
              case 1:
                {
                  info = " 수상 이력";
                  style = SheepsTextStyle.h4();
                }
                break;
              case 2:
                {
                  info = " 인증이 반려되었습니다. 반려 사유에 해당되는지 확인해 보세요!";
                  style = SheepsTextStyle.b3();
                }
                break;
              case 3:
                {
                  info = '';
                }
                break;
            }
          } else {
            //승인
            switch (index) {
              case 0:
                {
                  info = "축하해요! 팀 ";
                  style = SheepsTextStyle.b3();
                }
                break;
              case 1:
                {
                  info = "수상 이력";
                  style = SheepsTextStyle.h4();
                }
                break;
              case 2:
                {
                  info = " 인증이 승인되었습니다.";
                  style = SheepsTextStyle.b3();
                }
                break;
              case 3:
                {
                  info = '';
                }
                break;
            }
          }
        }
        break;
      case NOTI_EVENT_TEAM_PERFORMANCE_AUTH_UPDATE:
        {
          TeamPerformances teamPerformances = GlobalProfile.teamProfile.singleWhere((element) => element.id == notificationModel.teamIndex).teamPerformList.singleWhere((element) => element.id == notificationModel.tableIndex);

          //반려
          if (teamPerformances.auth == 0) {
            switch (index) {
              case 0:
                {
                  info = "팀 ";
                  style = SheepsTextStyle.b3();
                }
                break;
              case 1:
                {
                  info = "수행 내역";
                  style = SheepsTextStyle.h4();
                }
                break;
              case 2:
                {
                  info = " 인증이 반려되었습니다. 반려 사유에 해당되는지 확인해 보세요!";
                  style = SheepsTextStyle.b3();
                }
                break;
              case 3:
                {
                  info = '';
                }
                break;
            }
          } else {
            //승인
            switch (index) {
              case 0:
                {
                  info = "축하해요! 팀 ";
                  style = SheepsTextStyle.b3();
                }
                break;
              case 1:
                {
                  info = "수행 내역";
                  style = SheepsTextStyle.h4();
                }
                break;
              case 2:
                {
                  info = " 인증이 승인되었습니다.";
                  style = SheepsTextStyle.b3();
                }
                break;
              case 3:
                {
                  info = '';
                }
                break;
            }
          }
        }
        break;
      case NOTI_EVENT_PERSONAL_GET_BADGE:
        {
          switch (index) {
            case 0:
              {
                info = "축하해요! ";
                style = SheepsTextStyle.b3();
              }
              break;
            case 1:
              {
                info = PersonalBadgeDescriptionList[notificationModel.targetIndex].Title;
                style = SheepsTextStyle.h4();
              }
              break;
            case 2:
              {
                info = " 개인 뱃지를 받았습니다.";
                style = SheepsTextStyle.b3();
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_TEAM_GET_BADGE:
        {
          switch (index) {
            case 0:
              {
                info = "축하해요! ";
                style = SheepsTextStyle.b3();
              }
              break;
            case 1:
              {
                info = TeamBadgeDescriptionList[notificationModel.targetIndex].Title;
                style = SheepsTextStyle.h4();
              }
              break;
            case 2:
              {
                info = " 팀 뱃지를 받았습니다.";
                style = SheepsTextStyle.b3();
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_INTERNAL_PERSON_PROFILE_1:
        {
          switch (index) {
            case 0:
              {
                info = '쉽스에 오신걸 환영합니다! 간단히 프로필을 채우고, 사람들에게 주목을 받아보세요.';
                style = SheepsTextStyle.b3();
              }
              break;
            case 1:
              {
                info = '';
              }
              break;
            case 2:
              {
                info = '';
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_INTERNAL_PERSON_PROFILE_2:
        {
          switch (index) {
            case 0:
              {
                info = '프로필 사진을 등록하면, 더 멋진 창업가와 전문가를 만날 수 있어요.';
                style = SheepsTextStyle.b3();
              }
              break;
            case 1:
              {
                info = '';
              }
              break;
            case 2:
              {
                info = '';
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_INTERNAL_PERSON_PROFILE_3:
        {
          switch (index) {
            case 0:
              {
                info = '나의 이력정보를 올리고, 인증을 받아보세요! 미래의 유니콘에서 탑승을 제안할 지도 몰라요.';
                style = SheepsTextStyle.b3();
              }
              break;
            case 1:
              {
                info = '';
              }
              break;
            case 2:
              {
                info = '';
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_INTERNAL_PERSON_COMMUNITY:
        {
          switch (index) {
            case 0:
              {
                info = '쉽스 커뮤니티에서 스타트업에 관한 모든 이야기를 자유롭게 해보세요.';
                style = SheepsTextStyle.b3();
              }
              break;
            case 1:
              {
                info = '';
              }
              break;
            case 2:
              {
                info = '';
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_INTERNAL_PERSON_RECRUIT_WRITE:
        {
          switch (index) {
            case 0:
              {
                info = '팀이나 스타트업을 찾고 계신가요? 리쿠르트에서 팀 찾기 글을 올리고, 러브콜을 받아보세요.';
                style = SheepsTextStyle.b3();
              }
              break;
            case 1:
              {
                info = '';
              }
              break;
            case 2:
              {
                info = '';
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_INTERNAL_PERSON_RECRUIT_READ:
        {
          switch (index) {
            case 0:
              {
                info = '일하고 싶은 스타트업을 찾고 계신가요? 리쿠르트에서 모집공고를 확인하고, 지원해 보세요.';
                style = SheepsTextStyle.b3();
              }
              break;
            case 1:
              {
                info = '';
              }
              break;
            case 2:
              {
                info = '';
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_INTERNAL_TEAM_PROFILE_1:
        {
          switch (index) {
            case 0:
              {
                info = '멋진 아이디어를 구현할 팀원이 필요한가요? 팀 프로필을 만들고 팀원을 모아보세요!';
                style = SheepsTextStyle.b3();
              }
              break;
            case 1:
              {
                info = '';
              }
              break;
            case 2:
              {
                info = '';
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_INTERNAL_TEAM_PROFILE_2:
        {
          Team team = GlobalProfile.getTeamByID(notificationModel.teamIndex);
          switch (index) {
            case 0:
              {
                info = team.name;
                style = SheepsTextStyle.h4();
              }
              break;
            case 1:
              {
                info = '팀 프로필에 사진이나 로고를 등록해서, 팀의 매력을 상승시켜보세요!';
                style = SheepsTextStyle.b3();
              }
              break;
            case 2:
              {
                info = '';
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_INTERNAL_TEAM_PROFILE_3:
        {
          Team team = GlobalProfile.getTeamByID(notificationModel.teamIndex);
          switch (index) {
            case 0:
              {
                info = team.name;
                style = SheepsTextStyle.h4();
              }
              break;
            case 1:
              {
                info = '팀의 이력을 올리고, 인증을 받아보세요! 능력있는 팀원들이 우르르 몰려올거에요.';
                style = SheepsTextStyle.b3();
              }
              break;
            case 2:
              {
                info = '';
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_INTERNAL_TEAM_RECRUIT_WRITE:
        {
          switch (index) {
            case 0:
              {
                info = '팀원을 찾고 계신가요? 리쿠르트에서 팀원모집 글을 올려보세요.';
                style = SheepsTextStyle.b3();
              }
              break;
            case 1:
              {
                info = '';
              }
              break;
            case 2:
              {
                info = '';
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_INTERNAL_TEAM_RECRUIT_READ:
        {
          switch (index) {
            case 0:
              {
                info = '팀원을 찾고 계신가요? 리쿠르트에서 구직중인 프로필을 검토하고, 제안해 보세요.';
                style = SheepsTextStyle.b3();
              }
              break;
            case 1:
              {
                info = '';
              }
              break;
            case 2:
              {
                info = '';
              }
              break;
            case 3:
              {
                info = '';
              }
              break;
          }
        }
        break;
    }

    return TextSpan(text: info, style: style);
  }
}

