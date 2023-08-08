import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/notification/models/LocalNotification.dart';
import 'package:sheeps_app/registration/model/RegistrationModel.dart';

class AuthSuccessPage extends StatefulWidget {
  final int state; //0 실패, 1 성공, 2 중복번호

  AuthSuccessPage({Key? key, required this.state}) : super(key: key);

  @override
  _AuthSuccessPageState createState() => _AuthSuccessPageState();
}

class _AuthSuccessPageState extends State<AuthSuccessPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SocketProvider provider = SocketProvider.to;
    provider.setLocalNotification(LocalNotification());
    provider.setChatGlobal(Get.put(ChatGlobal()));

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
                body: Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 145 * sizeUnit,
                            height: 105 * sizeUnit,
                            child: SvgPicture.asset(
                              widget.state == 0 || widget.state == 2 ? svgSheepsXeyeImageLogo : svgSheepsCuteImageLogo,
                              width: 145 * sizeUnit,
                              height: 105 * sizeUnit,
                            ),
                          ),
                          Row(children: [SizedBox(height: 20 * sizeUnit)]),
                          Text(
                            globalLoginType != LOGIN_TYPE_SHEEPS
                                ? '회윈가입 완료!'
                                : widget.state == 0
                                    ? '본인인증 실패!'
                                    : '본인인증 완료!',
                            style: SheepsTextStyle.b0(),
                          ),
                          SizedBox(height: 20 * sizeUnit),
                          Text(
                            widget.state == 0
                                ? '본인인증에\n실패했어요.'
                                : widget.state == 2
                                    ? '이미 가입된 번호에요!'
                                    : '쉽스에선\n스타트업도, 팀모집도\n어렵지 않아요!',
                            style: SheepsTextStyle.h5(),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20 * sizeUnit),
                      child: SheepsBottomButton(
                        context: context,
                        function: () async{
                          if(widget.state == 1){
                            var result;
                            if(globalLoginType == LOGIN_TYPE_SHEEPS){
                              //로그인해서 메인페이지로
                              String loginURL = !kReleaseMode ? '/Personal/Select/DebugLogin' : '/Personal/Select/Login';

                              result = await ApiProvider().post(
                                  loginURL,
                                  jsonEncode({
                                    "id": globalLoginID,
                                    "password": globalLoginPW,
                                  }));
                            } else {
                              result = await ApiProvider().post(
                                  '/Personal/Select/SocialLogin',
                                  jsonEncode({
                                    "id": globalLoginID,
                                    "name": globalSocialName,
                                    "social": globalLoginType,
                                  }));
                            }

                            if (result != null) {
                              globalLogin(context, provider, result);
                            } else{
                              showSheepsToast(context: context, text: '로그인 실패하였습니다.');
                              Get.back();
                            }
                          } else {
                            Get.back();
                          }
                        },
                        text: widget.state == 1
                            ? '쉽스 시작하기'
                            : '다시 인증하기',
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
