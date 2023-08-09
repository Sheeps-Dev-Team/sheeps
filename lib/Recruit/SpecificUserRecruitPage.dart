
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sheeps_app/Recruit/Controller/RecruitController.dart';
import 'package:sheeps_app/Recruit/Models/PersonalSeekTeams.dart';
import 'package:sheeps_app/Recruit/Models/TeamMemberRecruit.dart';
import 'package:sheeps_app/Recruit/PersonalSeekTeamsEditPage.dart';
import 'package:sheeps_app/Recruit/RecruitDetailPage.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/constants.dart';

import 'RecruitTeamSelectionPage.dart';

List<TeamMemberRecruit> myPageRecruitList = []; // 나의 모집 공고 리스트
List<PersonalSeekTeam> myPageSeekList = []; // 나의 구직 공고 리스트

class SpecificUserRecruitPage extends StatefulWidget {
  final List<TeamMemberRecruit> myRecruitList;
  final List<PersonalSeekTeam> mySeekList;
  final bool isRecruit;
  final String appBarTitle;

  const SpecificUserRecruitPage({Key? key, this.myRecruitList = const [], this.mySeekList = const [], required this.isRecruit, required this.appBarTitle}) : super(key: key);

  @override
  _SpecificUserRecruitPageState createState() => _SpecificUserRecruitPageState();
}

class _SpecificUserRecruitPageState extends State<SpecificUserRecruitPage> {
  final RecruitController controller = Get.put(RecruitController());

  @override
  void initState() {
    super.initState();

    myPageRecruitList = widget.myRecruitList;
    myPageSeekList = widget.mySeekList;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: null,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), // 사용자 스케일팩터 무시,
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Scaffold(
                appBar: SheepsAppBar(context, widget.appBarTitle),
                body: widget.isRecruit
                    ? myPageRecruitList.isEmpty
                        ? noSearchResultsPage('팀원을 모집하고 싶으신가요?\n아래 버튼을 눌러 팀원을 모집해 보세요!')
                        : buildListView()
                    : myPageSeekList.isEmpty
                        ? noSearchResultsPage('들어갈 팀을 찾고 계신가요?\n아래 버튼을 눌러 팀을 찾아보세요!')
                        : buildListView(),
                floatingActionButton:

                widget.isRecruit ?
                FloatingActionButton(
                  onPressed: () => Get.to(RecruitTeamSelectionPage(isCreated: true, isMyPageRecruit: true))?.then((value) => setState(() {})),
                  backgroundColor: sheepsColorGreen,
                  child: SvgPicture.asset('assets/images/NavigationBar/TeamRecruitIcon.svg', color: Colors.white, width: 24 * sizeUnit, height: 24 * sizeUnit),
                ) :
                FloatingActionButton(
                  onPressed: () => Get.to(PersonalSeekTeamsEditPage(isMyPagePersonalSeek: true))?.then((value) => setState(() {})),
                  backgroundColor: sheepsColorBlue,
                  child: SvgPicture.asset(svgSearchIcon, width: 24 * sizeUnit, height: 24 * sizeUnit),
                )
                ,
              ),
            ),
          ),
        ),
      ),
    );
  }

  ListView buildListView() {
    return ListView.builder(
        itemCount: widget.isRecruit ? myPageRecruitList.length : myPageSeekList.length,
        itemBuilder: (context, index) {
          return sheepsRecruitPostCard(
            isRecruit: widget.isRecruit,
            dataSetFunc: () => controller.postCardDataSet(data: widget.isRecruit ? myPageRecruitList[index] : myPageSeekList[index], isRecruit: widget.isRecruit),
            press: () => Get.to(() => RecruitDetailPage(
                  isRecruit: widget.isRecruit,
                  data: widget.isRecruit ? myPageRecruitList[index] : myPageSeekList[index],
                  onlyShowSuggest: true,
                  dataList: widget.isRecruit ? myPageRecruitList : myPageSeekList,
                ))?.then((value) {
              setState(() {
                if(widget.isRecruit) {
                  if(value != null) myPageRecruitList[index] = value;
                } else {
                  if(value != null) myPageSeekList[index] = value;
                }
              });
            }),
            controller: controller,
          );
        });
  }
}
