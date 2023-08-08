
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:sheeps_app/Badge/model/ModelBadge.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/TeamProfileManagement/model/TeamProfileManagementController.dart';
import 'package:sheeps_app/userdata/MyBadge.dart';

class AddTeamBadgePage extends StatefulWidget {
  final Team team;

  AddTeamBadgePage({Key? key, required this.team}) : super(key: key);

  @override
  _AddTeamBadgePageState createState() => _AddTeamBadgePageState();
}

class _AddTeamBadgePageState extends State<AddTeamBadgePage> {
  Team? team;
  TeamProfileManagementController controller = Get.put(TeamProfileManagementController());

  int barIndex = 0;
  PageController pageController = PageController();
  List<int> listHaveBadge = [];

  List<dynamic> tmpShowBadgeList = [];

  final String svgPolygon = 'assets/images/Badge/personalBadgePolygon.svg';
  final String svgCheck = 'assets/images/Badge/personalBadgeCheck.svg';

  @override
  void initState() {
    super.initState();

    team = widget.team;

    if (team!.badgeList != null && team!.badgeList.length > 0) {
      listHaveBadge = team!.badgeList.map((BadgeModel badge) => badge.badgeID).toList();
    }
    tmpShowBadgeList.addAll(controller.badgeList);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: WillPopScope(
              onWillPop: null,
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: SheepsAppBar(context, '뱃지 선택'),
                body: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                      child: SheepsAnimatedTabBar(
                        barIndex: barIndex,
                        pageController: pageController,
                        insidePadding: 20 * sizeUnit,
                        listTabItemTitle: ['보유 뱃지', '전체 뱃지'],
                        listTabItemWidth: [63 * sizeUnit, 63 * sizeUnit],
                      ),
                    ),
                    Container(
                      width: 360 * sizeUnit,
                      height: 0.5 * sizeUnit,
                      color: sheepsColorGrey,
                    ),
                    Expanded(
                      child: PageView(
                        controller: pageController,
                        onPageChanged: (index) {
                          barIndex = index;
                          setState(() {});
                        },
                        children: [
                          haveBadgePage(),
                          allBadgePage(),
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
    );
  }

  Widget haveBadgePage() {
    Widget selectedBadge({required int badgeID}) {
      return GestureDetector(
        onTap: () {
          for (int i = 0; i < tmpShowBadgeList.length; i++) {
            if (badgeID == tmpShowBadgeList[i]) {
              tmpShowBadgeList.removeAt(i);
              setState(() {});
              break;
            }
          }
        },
        child: DottedBorder(
          borderType: BorderType.RRect,
          dashPattern: [6 * sizeUnit, 6 * sizeUnit],
          strokeWidth: 2 * sizeUnit,
          radius: Radius.circular(16 * sizeUnit),
          color: sheepsColorGrey,
          child: Container(
            width: 88 * sizeUnit,
            height: 88 * sizeUnit,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16 * sizeUnit)),
            ),
            child: Center(
              child: SvgPicture.asset(
                badgeID != null ? ReturnTeamBadgeSVG(badgeID) : svgSheepsBasicProfileImage,
                width: badgeID != null ? 70 * sizeUnit : 50 * sizeUnit,
                color: badgeID != null ? null : sheepsColorGrey,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(height: 56 * sizeUnit),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            selectedBadge(badgeID: tmpShowBadgeList.length > 0 ? tmpShowBadgeList[0] : null),
            selectedBadge(badgeID: tmpShowBadgeList.length > 1 ? tmpShowBadgeList[1] : null),
            selectedBadge(badgeID: tmpShowBadgeList.length > 2 ? tmpShowBadgeList[2] : null),
          ],
        ),
        SizedBox(height: 56 * sizeUnit),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
          child: Container(
            width: 328 * sizeUnit,
            height: 1 * sizeUnit,
            color: sheepsColorLightGrey,
          ),
        ),
        SizedBox(height: 16 * sizeUnit),
        Expanded(
          child: listHaveBadge.length > 0 ?
          ListView(
            children: [
              haveBadgeGrid(badgeList: listHaveBadge),
            ],
          )
          : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(svgGreySheepEyeX, width: 145 * sizeUnit, height: 105 * sizeUnit),
              SizedBox(height: 20 * sizeUnit),
              Text(
                '보유 중인 뱃지가 없어요.\n다양한 활동을 통해 뱃지를 획득해 보세요!',
                style: SheepsTextStyle.b2(),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(20 * sizeUnit),
          child: SheepsBottomButton(
            context: context,
            function: () {
              controller.badgeList.clear();
              if (tmpShowBadgeList.isNotEmpty) {
                for (int i = 0; i < tmpShowBadgeList.length; i++) {
                  controller.badgeList.add(tmpShowBadgeList[i]);
                }
              }
              Get.back();
            },
            text: '선택 완료',
          ),
        ),
      ],
    );
  }

  Widget haveBadgeGrid({
    required List<int> badgeList,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 10 * sizeUnit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              shrinkWrap: true,
              itemCount: badgeList.length,
              itemBuilder: (context, index) {
                bool isSelect = false;
                if (tmpShowBadgeList.isNotEmpty) {
                  for (int j = 0; j < tmpShowBadgeList.length; j++) {
                    if (badgeList[index] == tmpShowBadgeList[j]) {
                      isSelect = true;
                      break;
                    }
                  }
                }
                return GestureDetector(
                  onTap: () {
                    if (isSelect) {
                      for (int i = 0; i < tmpShowBadgeList.length; i++) {
                        if (badgeList[index] == tmpShowBadgeList[i]) {
                          tmpShowBadgeList.removeAt(i);
                          setState(() {});
                          break;
                        }
                      }
                    } else {
                      if (tmpShowBadgeList.length < 3) {
                        tmpShowBadgeList.add(badgeList[index]);
                        setState(() {});
                      }
                    }
                  },
                  child: Container(
                    width: 76 * sizeUnit,
                    height: 84 * sizeUnit,
                    child: Center(
                      child: Stack(
                        children: [
                          Center(
                            child: SvgPicture.asset(
                              ReturnTeamBadgeSVG(badgeList[index]),
                              width: 70 * sizeUnit,
                            ),
                          ),
                          if (isSelect) ...[
                            Center(
                              child: Opacity(
                                opacity: 0.9,
                                child: SvgPicture.asset(
                                  svgPolygon,
                                  color: sheepsColorGreen,
                                  width: 66 * sizeUnit,
                                ),
                              ),
                            ),
                            Center(
                              child: SvgPicture.asset(
                                svgCheck,
                                width: 28 * sizeUnit,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget allBadgePage() {
    return ListView(
      children: [
        badgeGridTile(title: '프로필 완성도', badgeList: teamBadgeProfileComp),
        badgeGridTile(title: '뱃지 개수', badgeList: teamBadgeBadgeCount),
        badgeGridTile(title: '기업형태', badgeList: teamBadgeCorporateType),
        badgeGridTile(title: '직원 규모', badgeList: teamBadgeEmployees),
        badgeGridTile(title: '팀원 규모', badgeList: teamBadgeMembers),
        badgeGridTile(title: '사업장', badgeList: teamBadgeWorkplace),
        badgeGridTile(title: '인증', badgeList: teamBadgeCertification),
        badgeGridTile(title: '과제', badgeList: teamBadgeTask),
        badgeGridTile(title: '연 매출', badgeList: teamBadgeSales),
        badgeGridTile(title: '투자', badgeList: teamBadgeInvestment),
        badgeGridTile(title: '특허', badgeList: teamBadgePatent),
        badgeGridTile(title: '국내 수상', badgeList: teamBadgeAwardIn),
        badgeGridTile(title: '해외 수상', badgeList: teamBadgeAwardOut),
        badgeGridTile(title: '수상 횟수', badgeList: teamBadgeAwardCount),
        badgeGridTile(title: '비흡연', badgeList: teamBadgeAttraction),
      ],
    );
  }

  Widget badgeGridTile({
    String title = '',
    required List<int> badgeList,
  }) {
    int countHaveBadge = 0;
    if (listHaveBadge.isNotEmpty) {
      for (int i = 0; i < badgeList.length; i++) {
        for (int j = 0; j < listHaveBadge.length; j++) {
          if (badgeList[i] == listHaveBadge[j]) {
            countHaveBadge++;
          }
        }
      }
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 10 * sizeUnit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != '') ...[
            Text(
              title + '(' + countHaveBadge.toString() + '\/' + badgeList.length.toString() + ')',
              style: SheepsTextStyle.badgeTitle(),
            ),
            SizedBox(height: 12 * sizeUnit),
          ],
          Container(
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              shrinkWrap: true,
              itemCount: badgeList.length,
              itemBuilder: (context, index) {
                bool isHave = false;
                if (listHaveBadge.isNotEmpty) {
                  for (int j = 0; j < listHaveBadge.length; j++) {
                    if (badgeList[index] == listHaveBadge[j]) {
                      isHave = true;
                      break;
                    }
                  }
                }
                return GestureDetector(
                  onTap: () {
                    showTeamBadgeDialog(badgeID: badgeList[index]);
                  },
                  child: Container(
                    height: 76 * sizeUnit,
                    width: 76 * sizeUnit,
                    child: Center(
                      child: Opacity(
                        opacity: isHave ? 1.0 : 0.2,
                        child: SvgPicture.asset(
                          ReturnTeamBadgeSVG(badgeList[index]),
                          width: 72 * sizeUnit,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
