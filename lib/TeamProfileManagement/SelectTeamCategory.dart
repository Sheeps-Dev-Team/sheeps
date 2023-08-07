
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:get/get.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/ListForProfileModify.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';

class SelectTeamCategory extends StatelessWidget {
  Widget getColumn(String text) {
    return GestureDetector(
      onTap: () {
        Get.back(result: [text]);
      },
      child: Container(
        color: Colors.white,
        height: 48 * sizeUnit,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: SheepsTextStyle.b1(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: null,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
          child: Scaffold(
            appBar: SheepsAppBar(context, '팀 분류 선택'),
            body: ScrollConfiguration(
              behavior: MyBehavior(),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [SizedBox(height: 36 * sizeUnit)]),
                      Text('팀 유형', style: SheepsTextStyle.h3()),
                      SizedBox(height: 12 * sizeUnit),
                      getColumn(distingNameList[0]),
                      Container(height: 1 * sizeUnit, color: sheepsColorGrey),
                      getColumn(distingNameList[1]),
                      Container(height: 1 * sizeUnit, color: sheepsColorGrey),
                      getColumn(distingNameList[2]),
                      Container(height: 1 * sizeUnit, color: sheepsColorGrey),
                      SizedBox(height: 36 * sizeUnit),
                      Text('기업 유형', style: SheepsTextStyle.h3()),
                      SizedBox(height: 12 * sizeUnit),
                      getColumn(distingNameList[3]),
                      Container(height: 1 * sizeUnit, color: sheepsColorGrey),
                      getColumn(distingNameList[4]),
                      Container(height: 1 * sizeUnit, color: sheepsColorGrey),
                      getColumn(distingNameList[5]),
                      Container(height: 1 * sizeUnit, color: sheepsColorGrey),
                      getColumn(distingNameList[6]),
                      Container(height: 1 * sizeUnit, color: sheepsColorGrey),
                      getColumn(distingNameList[7]),
                      Container(height: 1 * sizeUnit, color: sheepsColorGrey),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
