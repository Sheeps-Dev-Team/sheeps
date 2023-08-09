
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sheeps_app/Recruit/Controller/RecruitController.dart';
import 'package:sheeps_app/Recruit/Models/PersonalSeekTeams.dart';
import 'package:sheeps_app/Recruit/Models/TeamMemberRecruit.dart';
import 'package:sheeps_app/Recruit/RecruitDetailPage.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';

class MyRecruitPage extends StatelessWidget {
  final List<TeamMemberRecruit> myRecruitList;
  final List<PersonalSeekTeam> mySeekList;
  final bool isRecruit;

  const MyRecruitPage({Key? key, this.myRecruitList = const [], this.mySeekList = const [], required this.isRecruit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  final RecruitController controller = Get.put(RecruitController());

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
                appBar: SheepsAppBar(context, '내 리쿠르트 현황'),
                body: ListView.builder(
                  itemCount: isRecruit ? myRecruitList.length : mySeekList.length,
                  itemBuilder: (context, index) {
                    return sheepsRecruitPostCard(
                      isRecruit: isRecruit,
                      dataSetFunc: () => controller.postCardDataSet(data: isRecruit ? myRecruitList[index] : mySeekList[index], isRecruit: isRecruit),
                      press: () => Get.to(() => RecruitDetailPage(isRecruit: isRecruit, data: isRecruit ? myRecruitList[index] : mySeekList[index])),
                      controller: controller,
                    );
                  }
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
