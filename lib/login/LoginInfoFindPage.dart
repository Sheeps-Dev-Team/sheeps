
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/login/EmailVerificationPage.dart';
import 'package:sheeps_app/registration/IdentityVerificationPage.dart';

class LoginInfoFindPage extends StatefulWidget {
  @override
  _LoginInfoFindPageState createState() => _LoginInfoFindPageState();
}

class _LoginInfoFindPageState extends State<LoginInfoFindPage> {
  final idTextField = TextEditingController();

  bool findIDState = true;

  int barIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: null,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          //사용자 스케일팩터 무시
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Scaffold(
                appBar: SheepsAppBar(context, ''),
                body: Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(svgSheepsGreenImageLogo),
                          SizedBox(height: 20 * sizeUnit),
                          Text(
                            '기억이 나지 않나요?',
                            style: SheepsTextStyle.b0().copyWith(color: sheepsColorDarkGrey),
                          ),
                          SizedBox(height: 20 * sizeUnit),
                          Text(
                            '찾을 항목을\n선택해 주세요.',
                            style: SheepsTextStyle.h5().copyWith(color: Color(0xFF000000), height: 1.6),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20 * sizeUnit),
                      child: Column(
                        children: [
                          SheepsBottomButton(
                            context: context,
                            function: () {
                              Get.to(() => IdentityVerificationPage(identityStatus: IdentityStatus.FindID)); // 아이디 찾기
                            },
                            text: '로그인 이메일',
                          ),
                          SizedBox(height: 12),
                          SheepsBottomButton(
                            context: context,
                            function: () {
                              Get.to(() => EmailVerificationPage());
                            },
                            text: '비밀번호',
                          ),
                        ],
                      ),
                    )
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
