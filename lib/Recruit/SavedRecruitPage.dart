
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sheeps_app/Recruit/Controller/RecruitController.dart';
import 'package:sheeps_app/Recruit/Models/PersonalSeekTeams.dart';
import 'package:sheeps_app/Recruit/Models/TeamMemberRecruit.dart';
import 'package:sheeps_app/Recruit/RecruitDetailPage.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';

class SavedRecruitPage extends StatefulWidget {
  final List<TeamMemberRecruit> recruitList;
  final List<PersonalSeekTeam> seekList;

  const SavedRecruitPage({Key? key, required this.recruitList, required this.seekList}) : super(key: key);

  @override
  _SavedRecruitPageState createState() => _SavedRecruitPageState();
}

class _SavedRecruitPageState extends State<SavedRecruitPage> {
  final RecruitController controller = Get.put(RecruitController());
  final PageController pageController = PageController();
  final List<String> categoryList = ['팀원모집', '팀 찾기'];
  final List<double> categoryWidthList = [59 * sizeUnit, 59 * sizeUnit];

  List<TeamMemberRecruit> recruitList = [];
  List<PersonalSeekTeam> seekList = [];

  bool isRecruit = true;
  int barIndex = 0;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();

    recruitList = widget.recruitList;
    seekList = widget.seekList;
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
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
                appBar: SheepsAppBar(context, '저장한 공고'),
                body: Column(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 36 * sizeUnit,
                          padding: EdgeInsets.only(left: 16 * sizeUnit),
                          child: SheepsAnimatedTabBar(
                            barIndex: barIndex,
                            listTabItemWidth: categoryWidthList,
                            insidePadding: 20 * sizeUnit,
                            listTabItemTitle: categoryList,
                            pageController: pageController,
                          ),
                        ),
                        Container(
                          width: 360 * sizeUnit,
                          height: 1,
                          color: sheepsColorLightGrey,
                        ),
                      ],
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: pageController,
                        itemCount: categoryList.length,
                        onPageChanged: (value) {
                          barIndex = value;
                          if (barIndex == 0)
                            isRecruit = true;
                          else
                            isRecruit = false;
                          setState(() {});
                        },
                        itemBuilder: (context, index) {
                          List resultList = isRecruit ? recruitList : seekList;

                          if(resultList.isEmpty) return noSearchResultsPage('저장한 공고가 없어요!');
                          return recruitListView(resultList);
                        },
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

  ListView recruitListView(List resultList) {
    return ListView.builder(
        itemCount: resultList.length,
        itemBuilder: (context, index) {
          return sheepsRecruitPostCard(
            isRecruit: isRecruit,
            dataSetFunc: () => controller.postCardDataSet(data: resultList[index], isRecruit: isRecruit),
            press: () => Get.to(() => RecruitDetailPage(
                  isRecruit: isRecruit,
                  data: resultList[index],
                  dataList: resultList,
                ))?.then(
              (value) => setState(() {}),
            ),
            controller: controller,
          );
        });
  }
}
