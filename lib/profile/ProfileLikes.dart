import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/profile/DetailProfile.dart';
import 'package:sheeps_app/profile/DetailTeamProfile.dart';
import 'package:sheeps_app/profile/models/ModelLikes.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';

class ProfileLikesPage extends StatefulWidget {
  @override
  _ProfileLikesPageState createState() => _ProfileLikesPageState();
}

class ProfileLikesPageController extends GetxController {
  RxInt barIndex = 0.obs;
  static const int STATE_PERSON = 0;
  static const int STATE_TEAM = 1;
  static const int STATE_EXPERT = 2;
}

class _ProfileLikesPageState extends State<ProfileLikesPage> {
  ProfileLikesPageController controller = Get.put(ProfileLikesPageController());
  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
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
      child: WillPopScope(
        onWillPop: null,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: SheepsAppBar(context, '저장한 프로필'),
                body: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16 * sizeUnit),
                      child: Obx(() => SheepsAnimatedTabBar(
                            pageController: pageController,
                            barIndex: controller.barIndex.value,
                            insidePadding: 22 * sizeUnit,
                            listTabItemTitle: ['개인', '팀・스타트업', '전문가'],
                            listTabItemWidth: [30 * sizeUnit, 90 * sizeUnit, 45 * sizeUnit],
                          )),
                    ),
                    Container(
                      width: 360 * sizeUnit,
                      height: 1 * sizeUnit,
                      color: sheepsColorGrey,
                    ),
                    Expanded(
                      child: PageView(
                        controller: pageController,
                        onPageChanged: (index) {
                          controller.barIndex.value = index;
                        },
                        children: [
                          personalLikesPage(),
                          teamLikesPage(),
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

  Widget personalLikesPage() {
    return globalPersonalLikeList.length > 0
        ? Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit),
            child: GridView.count(
                mainAxisSpacing: 8 * sizeUnit,
                crossAxisSpacing: 8 * sizeUnit,
                crossAxisCount: 2,
                childAspectRatio: 160 / 284,
                //각 그리드뷰 비율 조정
                children: List.generate(globalPersonalLikeList.length, (index) {
                  UserData person = GlobalProfile.getUserByUserID(globalPersonalLikeList[index].TargetID);

                  return SheepsPersonalProfileCard(context, person, index, onTap: () async {
                    var getData = await ApiProvider().post('/Personal/Select/ModifyUser', jsonEncode({"userID": person.userID, "updatedAt": person.updatedAt}));

                    UserData user = person;
                    if (getData != null) {
                      user = UserData.fromJson(getData);
                      GlobalProfile.personalProfile[index] = user; //개인 프로필 바뀐 데이터로 전역 데이터 세팅
                    }

                    Get.to(() => DetailProfile(index: 0, user: user, profileStatus: PROFILE_STATUS.OtherProfile))?.then((value) => setState(() {}));
                  });
                })),
          )
        : noSearchResultsPage('저장한 프로필이 없어요.\n마음에 드는 프로필을 저장해 보세요!');
  }

  Widget teamLikesPage() {
    return globalTeamLikeList.length > 0
        ? Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit),
            child: GridView.count(
                mainAxisSpacing: 8 * sizeUnit,
                crossAxisSpacing: 8 * sizeUnit,
                crossAxisCount: 2,
                childAspectRatio: 160 / 284,
                //각 그리드뷰 비율 조정
                children: List.generate(globalTeamLikeList.length, (index) {
                  Team team = GlobalProfile.getTeamByID(globalTeamLikeList[index].TargetID);
                  return SheepsTeamProfileCard(
                    context,
                    team,
                    index,
                    onTap: () async {
                      var getData = await ApiProvider().post('/Team/Profile/SelectID', jsonEncode({"id": team.id, "updatedAt": team.updatedAt}));

                      Team resTeam = team;
                      if (getData != null) {
                        Team resTeam = Team.fromJson(getData);

                        GlobalProfile.teamProfile[index] = resTeam;
                      }

                      Get.to(() => DetailTeamProfile(index: index, team: resTeam))?.then((value) => setState(() {}));
                    },
                  );
                })),
          )
        : noSearchResultsPage('저장한 프로필이 없어요.\n마음에 드는 프로필을 저장해 보세요!',);
  }

}
