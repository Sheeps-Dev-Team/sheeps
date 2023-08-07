import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/registration/model/RegistrationModel.dart';

class PasswordCheckPage extends StatefulWidget {
  final String password;

  PasswordCheckPage({Key key, @required this.password}) : super(key: key);

  @override
  _PasswordCheckPageState createState() => _PasswordCheckPageState();
}

class _PasswordCheckPageState extends State<PasswordCheckPage> {
  bool success = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      var result = await ApiProvider().post('/Personal/Select/CheckAndChangePassword', jsonEncode({"id": globalLoginID, "password": widget.password}));
      setState(() {
        // result 값에 따라 success 정해주기
        if (null == result)
          success = false;
        else
          success = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: () {
          return Future.value(false);
        },
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
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
                          SvgPicture.asset(success ? svgSheepsCuteImageLogo : svgSheepsXeyeImageLogo),
                          SizedBox(height: 20 * sizeUnit),
                          Text(
                            success ? '변경 완료!' : '변경 실패!',
                            style: SheepsTextStyle.b0().copyWith(color: sheepsColorDarkGrey),
                          ),
                          SizedBox(height: 20 * sizeUnit),
                          Text(
                            success ? '비밀번호가\n변경되었어요.' : '비밀번호 변경에\n실패했어요.',
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
                        function: () {
                          if (success) {
                            // 로그인 페이지로 보내기
                            Get.back();
                            Get.back();
                            Get.back();
                            Get.back();
                          } else {
                            // 비밀번호 수정 페이지로 보내기
                            Get.back();
                          }
                        },
                        text: success ? '로그인 하기' : '다시 시도하기',
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
