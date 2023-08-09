import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sheeps_app/Recruit/RecruitTeamSelectionPage.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/constants.dart';
import 'PersonalSeekTeamsEditPage.dart';

class ExpandableFab extends StatelessWidget {
  final bool isRecruit;

  const ExpandableFab({Key? key, required this.isRecruit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            actionButton(
              text: '들어갈 팀을 찾을래요',
              iconPath: svgSearchIcon,
              color: sheepsColorBlue,
              onTap: () {
                Get.back();
                Get.to(() => PersonalSeekTeamsEditPage());
              },
            ),
            SizedBox(height: 16 * sizeUnit),
            actionButton(
              text: '팀원을 모집할래요',
              iconPath: 'assets/images/NavigationBar/TeamRecruitIcon.svg',
              color: sheepsColorGreen,
              onTap: () {
                Get.back();
                Get.to(() => RecruitTeamSelectionPage(isCreated: true));
              },
            ),
            SizedBox(height: 16 * sizeUnit),
            FloatingActionButton(
              onPressed: () => Get.back(),
              backgroundColor: Colors.white,
              child: Icon(
                Icons.clear,
                size: 40 * sizeUnit,
                color: isRecruit ? sheepsColorGreen : sheepsColorBlue,
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          onTap: (index) {},
          items: [
            buildBottomNavigationBarItem(),
            buildBottomNavigationBarItem(),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem buildBottomNavigationBarItem() {
    return BottomNavigationBarItem(
      backgroundColor: Colors.transparent,
      icon: Column(
        children: [
          SizedBox(height: 18 * sizeUnit),
          SizedBox(height: 6 * sizeUnit),
          Text('', style: TextStyle(color: Colors.transparent)),
          SizedBox(height: 4 * sizeUnit),
        ],
      ),
      label: ''
    );
  }

  Widget actionButton({required String text, required String iconPath, required Color color, required Function onTap}) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(text, style: SheepsTextStyle.hProfile().copyWith(shadows: [Shadow(color: Color.fromRGBO(0, 0, 0, 0.7), blurRadius: 4*sizeUnit)])),
          SizedBox(width: 12 * sizeUnit),
          Container(
            alignment: Alignment.center,
            width: 36 * sizeUnit,
            height: 36 * sizeUnit,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(blurRadius: 4 * sizeUnit, color: Color.fromRGBO(0, 0, 0, 0.25))],
            ),
            child: SvgPicture.asset(
              iconPath,
              width: 18 * sizeUnit,
              height: 18 * sizeUnit,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 7 * sizeUnit),
        ],
      ),
    );
  }
}
