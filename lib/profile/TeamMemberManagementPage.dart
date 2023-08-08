import 'dart:convert';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/chat/models/Room.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';
import 'package:transparent_image/transparent_image.dart';

class TeamMemberManagementPage extends StatefulWidget {
  final Team team;
  final List<int> teamMemberList;
  final bool byChat;

  const TeamMemberManagementPage({Key? key, required this.team, required this.teamMemberList, required this.byChat}) : super(key: key);

  @override
  _TeamMemberManagementPageState createState() => _TeamMemberManagementPageState();
}

class _TeamMemberManagementPageState extends State<TeamMemberManagementPage> {
  int? selectedId;
  List<int> teamMemberList = [];

  @override
  void initState() {
    super.initState();
    teamMemberList = widget.teamMemberList;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: null,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시,
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Scaffold(
                appBar: SheepsAppBar(context, '팀 관리하기 (총 ${teamMemberList.length}명)'),
                body: Column(
                  children: [
                    Divider(color: sheepsColorGrey, height: 1 * sizeUnit),
                    buildGridView(),
                    if(teamMemberList.length < 2)...[
                      deleteTeamButton(), // 삭제하기
                    ] else...[
                      exileButton(), // 추방하기
                    ],
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

  // 삭제하기 버튼
  Widget deleteTeamButton(){
    return SheepsBottomButton(
      context: context,
      text: '삭제하기',
      color: sheepsColorRed,
      function: () {
        showSheepsCustomDialog(
          title: Text(
            widget.team.name + '팀을(를)\n삭제하시겠어요?',
            style: SheepsTextStyle.h5(),
            textAlign: TextAlign.center,
          ),
          contents: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '해당 팀 삭제 시\n다시 '),
                TextSpan(
                  text: '복구할 수 없습니다.',
                  style: SheepsTextStyle.b3().copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            style: SheepsTextStyle.b3(),
            textAlign: TextAlign.center,
          ),
          okText: '삭제하기',
          okButtonColor: sheepsColorRed,
          okFunc: () async {

            var recruitPostRes = await ApiProvider().post('/Matching/Select/TeamMemberRecruitByTeamID', jsonEncode({
              "teamID" : widget.team.id
            }));

            if(recruitPostRes != null && recruitPostRes.length != 0){

              //다이얼로그
              Get.back();

              showSheepsCustomDialog(
                title: Text(
                  "삭제할 수 없음",
                  style: SheepsTextStyle.dialogTitle().copyWith(height: 1.2, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                contents: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
                    children: [
                      TextSpan(text: '해당하는 팀의 팀원모집 게시글이 있으면,\n'),
                      TextSpan(text: '삭제할 수 없습니다.')
                    ],
                  ),
                ),
                okButtonColor: sheepsColorGreen,
              );
            }else{
              await ApiProvider().post('/Team/Delete', jsonEncode({
                "id" : widget.team.id,
              }));

              Fluttertoast.showToast(msg: '팀 : ' + widget.team.name + " 이 해체되었어요.", toastLength: Toast.LENGTH_SHORT);

              //전역데이터 삭제
              GlobalProfile.teamProfile.removeWhere((element) => element.id == widget.team.id);

              //다이얼로그
              Get.back();

              //팀 관리하기
              Get.back();

              //디테일 팀 프로필
              Get.back();
            }
          },
          isCancelButton: true,
        );
      }
    );
  }

  // 추방하기 버튼
  Widget exileButton() {
    return SheepsBottomButton(
      context: context,
      text: '추방하기',
      isOK: selectedId == null ? false : true,
      function: () {
        if (selectedId != null) {
          showSheepsCustomDialog(
            title: Text(
              GlobalProfile.getUserByUserID(selectedId!).name + '을(를)\n추방하시겠어요?',
              style: SheepsTextStyle.h5(),
              textAlign: TextAlign.center,
            ),
            contents: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '해당 팀원 추방 시\n'),
                  TextSpan(
                    text: '팀 채팅방',
                    style: SheepsTextStyle.b3().copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: '에서 자동 추방됩니다.'),
                ],
              ),
              style: SheepsTextStyle.b3(),
              textAlign: TextAlign.center,
            ),
            okText: '추방하기',
            okButtonColor: sheepsColorBlue,
            okFunc: () async {
              var roomName = getRoomName(widget.team.id, widget.team.leaderID, roomType: ROOM_TYPE_TEAM);

              await ApiProvider().post(
                  '/Team/KickOut/TeamMember',
                  jsonEncode({
                    "userID": GlobalProfile.loggedInUser!.userID,
                    "targetID": selectedId,
                    "teamID": widget.team.id,
                    "teamName": widget.team.name,
                    "userName": GlobalProfile.personalProfile.singleWhere((element) => element.userID == selectedId).name,
                    "roomName": roomName
                  }));

              //채팅방에서 팀원이 없으면 삭제
              if (widget.byChat) {
                ChatGlobal.kickOutTeamMemberInRoom(roomName, selectedId!);
              } else {
                ChatGlobal.roomInfoList.removeWhere((element) => element.roomName == roomName);
              }

              //팀원 목록에서 삭제
              widget.teamMemberList.removeWhere((element) => element == selectedId);
              widget.team.userList.removeWhere((element) => element == selectedId);

              //전역 팀에서 팀원 목록 삭제
              GlobalProfile().removeTeamMember(widget.team.id, selectedId!);

              Get.back(); //다이얼로그 닫기

              setState(() {});
            },
            isCancelButton: true,
          );
        }
      },
    );
  }

  Widget buildGridView() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 16 * sizeUnit),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16 * sizeUnit,
          crossAxisSpacing: 16 * sizeUnit,
          childAspectRatio: 156 / 224,
          children: List.generate(widget.teamMemberList.length, (index) {
            return sheepsSelectTeamMemberCard(GlobalProfile.getUserByUserID(widget.teamMemberList[index]), index == 0);
          }),
        ),
      ),
    );
  }

  Widget sheepsSelectTeamMemberCard(UserData user, bool isLeader) {
    return Container(
      width: 156 * sizeUnit,
      child: GestureDetector(
        onTap: () {
          if (isLeader) return;
          if (selectedId == user.userID) {
            selectedId = null;
          } else {
            selectedId = user.userID;
          }
          setState(() {});
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            teamProfileImg(user),
            SizedBox(height: 8 * sizeUnit),
            Row(
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: isLeader ? 132 * sizeUnit : 156 * sizeUnit),
                  child: Text(
                    user.name,
                    style: SheepsTextStyle.h3(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isLeader) ...[
                  SizedBox(width: 4 * sizeUnit),
                  Container(
                    padding: EdgeInsets.all(4 * sizeUnit),
                    height: 17 * sizeUnit,
                    width: 17 * sizeUnit,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: sheepsColorGreen,
                    ),
                    child: SvgPicture.asset(
                      'assets/images/Profile/CrownIcon.svg',
                    ),
                  ),
                ]
              ],
            ),
            SizedBox(height: 4 * sizeUnit),
            Wrap(
              runSpacing: 4 * sizeUnit,
              spacing: 4 * sizeUnit,
              children: [
                if (user.part != null && user.part.isNotEmpty) profileSmallWrapItem(user.part),
                if (user.subPart != null && user.subPart.isNotEmpty) profileSmallWrapItem(user.subPart),
                if (user.location != null && user.location.isNotEmpty) profileSmallWrapItem(user.location),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget teamProfileImg(UserData user) {
    return Stack(
      children: [
        Container(
          width: 156 * sizeUnit,
          height: 156 * sizeUnit,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28 * sizeUnit),
            border: Border.all(width: 0.5 * sizeUnit, color: sheepsColorGrey),
          ),
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
              if (user.profileImgList[0].imgUrl != 'BasicImage') ...[
                SizedBox(
                  width: 156 * sizeUnit,
                  height: 156 * sizeUnit,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28 * sizeUnit),
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: getOptimizeImageURL(user.profileImgList[0].imgUrl, 60),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (selectedId == user.userID)
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
    );
  }
}
