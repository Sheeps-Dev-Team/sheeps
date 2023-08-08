import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheeps_app/Setting/model/Banner.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/notification/models/LocalNotification.dart';
import 'package:sheeps_app/onboarding/OnboardingScreen.dart';
import 'package:sheeps_app/registration/LoginSelectPage.dart';
import 'package:sheeps_app/login/LoginPage.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {

  late Animation<double> animation;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    isCanDynamicLink = true;//로그인 후 다이나믹링크로 보내기 위함

    try{
      (() async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        bool? res = prefs.getBool('IfNewUser');

        //todo roy to luen 버전체크 upgrader

        //client에서 시작전 세팅되어야 할 데이터
        setClientBannerData();

        if(res == null) {
          Timer(Duration(milliseconds: 1500), () {
            Get.off(() => OnboardingScreen());
          });
        } else if(res){
          bool? res = prefs.getBool('autoLoginKey');

          // ignore: unnecessary_statements
          SocketProvider provider = SocketProvider.to;
          provider.setLocalNotification(LocalNotification());
          provider.setChatGlobal(Get.put(ChatGlobal()));

          if(res == false) {
            Timer(Duration(milliseconds: 1500), () {
              Get.off(() => LoginSelectPage());
            });
          } else {
            String? isSocial = prefs.getString('socialLogin');

            dynamic result;
            String id = '';
            String pw = '';
            if(isSocial == '0'){
              id = prefs.getString('autoLoginId') ?? '';
              pw = prefs.getString('autoLoginPw') ?? '';

              String loginURL = !kReleaseMode ? '/Personal/Select/DebugLogin' : '/Personal/Select/Login';

              result = await ApiProvider().post(loginURL, jsonEncode(
                  {
                    "id": id,
                    "password": pw,
                  }
              ));
            } else if(isSocial == '1'){
              id = prefs.getString('autoLoginId') ?? '';
              pw = prefs.getString('autoLoginPw') ?? '';

              result = await ApiProvider().post('/Personal/Select/SocialLogin', jsonEncode(
                  {
                    "id" : id,
                    "name" : pw,
                    "social" : 1
                  }
              ));
            }else if(isSocial == '2'){
              id = prefs.getString('autoLoginAppleId') ?? '';
              pw = prefs.getString('autoLoginApplePw') ?? '';

              result = await ApiProvider().post('/Personal/Select/SocialLogin', jsonEncode(
                  {
                    "id" : id,
                    "name" : pw,
                    "social" : 2
                  }
              ));
            }else if(isSocial == '3'){
              id = prefs.getString('autoLoginId') ?? '';
              pw = prefs.getString('autoLoginPw') ?? '';

              result = await ApiProvider().post('/Personal/Select/SocialLogin', jsonEncode(
                  {
                    "id" : id,
                    "name" : pw,
                    "social" : 3
                  }
              ));
            }

            if(result == null || result['result'] == null){
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('autoLoginKey',false);
              prefs.setString('autoLoginId', '');
              prefs.setString('autoLoginPw', '');

              Fluttertoast.showToast(msg: "로그인 정보가 올바르지 않습니다.\n로그인 페이지로 이동합니다.", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Color.fromRGBO(0, 0, 0, 0.51), textColor: Colors.white );

              Get.off(() => LoginSelectPage());
            }else{
              globalLogin(context, provider, result, isHandLogin: false, isSplashLogin: true);
            }
          }}}
      )();
    }catch(e){
      Get.off(() => LoginPage());
    }
    
    animationController = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animation = CurvedAnimation(parent: animationController, curve: Curves.easeIn);
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnitStandard(context).fontSize!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      AnimatedSheepsLogo(animation: animation),
                      Row(
                        children: [
                          SizedBox.shrink(),
                        ],
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Copyright © 2021 SHEEPS Inc. 모든 권리 보유.",
                          textAlign: TextAlign.center,
                          style: SheepsTextStyle.splashCopyright(),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            height: 60*sizeUnit,
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

class AnimatedSheepsLogo extends AnimatedWidget{
  static final _opacityTween = Tween<double>(begin: 0.1, end: 1);
  
  AnimatedSheepsLogo({Key? key, required Animation<double> animation}) : super(key: key, listenable: animation);

  Widget build(BuildContext context){
    final animation = listenable as Animation<double>;
    return Opacity(
      opacity: _opacityTween.evaluate(animation),
      child: SvgPicture.asset(
        svgSheepsFullLogo,
        width: 120 *sizeUnit,
        height: 120 *sizeUnit,
        color: sheepsColorGreen,
      ),
    );
  }
}