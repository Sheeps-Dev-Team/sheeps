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

class LoginCheckPage extends StatefulWidget {
  @override
  _LoginCheckPageState createState() => _LoginCheckPageState();
}

class _LoginCheckPageState extends State<LoginCheckPage> {
  String? findID = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      var res = await ApiProvider().post(
          '/Personal/Select/FindID',
          jsonEncode({
            "phoneNumber": globalPhoneNumber,
          }));
      setState(() {
        if (res == null)
          findID = null;
        else
          findID = res['ID'];
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
                          SvgPicture.asset(findID != null ? svgSheepsCuteImageLogo : svgSheepsXeyeImageLogo),
                          SizedBox(height: 20 * sizeUnit),
                          Text(
                            findID != null ? '찾기 완료!' : '찾기 실패!',
                            style: SheepsTextStyle.b0().copyWith(color: sheepsColorDarkGrey),
                          ),
                          SizedBox(height: 20 * sizeUnit),
                          Text(
                            findID != null ? findID! : "본인인증이\n실패했어요.",
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
                          if(findID != null){
                            Get.back();
                            Get.back();
                          } else{
                            Get.back();
                          }
                        },
                        text: findID != null ? '로그인 하기' : '다시 시도하기',
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
