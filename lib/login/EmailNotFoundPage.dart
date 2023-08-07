
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';


import 'package:get/get.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';

class EmailNotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: () {
          return Future.value(false);
        },
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Scaffold(
                appBar: SheepsAppBar(context, '', isBackButton: false),
                body: Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(svgSheepsXeyeImageLogo),
                          SizedBox(height: 20 * sizeUnit),
                          Text(
                            '가입되지 않은 이메일이에요!',
                            style: SheepsTextStyle.b0().copyWith(color: sheepsColorDarkGrey),
                          ),
                          SizedBox(height: 20 * sizeUnit),
                          Text(
                            '이메일을\n확인해주세요.',
                            textAlign: TextAlign.center,
                            style: SheepsTextStyle.h5().copyWith(color: Color(0xFF000000), height: 1.6),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20 * sizeUnit),
                      child: SheepsBottomButton(
                        context: context,
                        function: () => Get.back(),
                        text: '다시 시도하기',
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
}
