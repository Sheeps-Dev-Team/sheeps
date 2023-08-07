import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:kakao_flutter_sdk/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/registration/PageTermsOfService.dart';
import 'package:sheeps_app/registration/model/RegistrationModel.dart';

//카카오 로그인
void kakaoLoginButtonClicked(BuildContext context, SocketProvider provider) async {
  final installed = await isKakaoTalkInstalled();

  if (Platform.isIOS) {
    try {
      installed ? await UserApi.instance.loginWithKakaoTalk() : await UserApi.instance.loginWithKakaoAccount();
      print('카카오 로그인 성공');
    } catch (e) {
      print('error on login: $e');
      showSheepsToast(context: context, text: e.toString());
      return;
    }
  } else {
    try {
      if(installed){
        await UserApi.instance.loginWithKakaoTalk();
        debugPrint('카카오 로그인 성공');
      } else{
        showSheepsToast(context: context, text: '카카오톡이 설치되지 않았어요!');
        return;
      }
    } catch (err) {
      debugPrint(err.toString());
      if(kReleaseMode)
        showSheepsToast(context: context, text: '카카오 로그인에 문제가 생겼어요! 다른 방법으로 로그인해주세요.\n' + err.toString());
      else
        showSheepsToast(context: context, text: err.toString());
      return;
    }
  }

  User user;

  user = await UserApi.instance.me();
  print("=========================[kakao account]=================================");
  print(user.kakaoAccount.toString());
  print("=========================[kakao account]=================================");

  if (user == null) return null;

  String email = user.kakaoAccount.email;
  String name = user.kakaoAccount.profile.nickname == null ? '' : user.kakaoAccount.profile.nickname;

  globalSocialName = name;

  var result = await ApiProvider().post(
      '/Personal/Select/SocialLogin',
      jsonEncode({
        "id": email,
        "name": name,
        "social": 3, //카카오로그인. 서버에선 구글로그인이랑 같은 방식으로 처리하되, 클라에선 애플처럼 활동명 및 실명 입력부분으로 보냄.
      }));
  //1 로그인성공,
  //2 구글, 카카오 로그인일 경우, 본인인증 안한 상태
  //3 애플로그인일 경우, 이름 업데이트 안한 상태

  if (result != null) {
    //핸드폰 페이지로 이동
    globalLoginID = email;
    globalName = name;
    globalLoginType = LOGIN_TYPE_APPLE;
    if (result['res'] == 2) {//구글로그인으로 인지해서 오지만 이후 과정은 애플처럼
      Get.to(() => PageTermsOfService(
        loginType: LOGIN_TYPE_APPLE, //2
      ));
    } else {
      // 로그인
      if (result['result'] == null) {
        Function okFunc = () {
          ApiProvider().post('/Personal/Logout', jsonEncode({"userID": result['userID'], "isSelf": 0}), isChat: true);

          Get.back();
        };
        showSheepsDialog(
          context: context,
          title: "로그아웃",
          description: "해당 아이디는 이미 로그인 중입니다.\n로그아웃을 요청하시겠어요?",
          okText: "로그아웃 할게요",
          okFunc: okFunc,
          cancelText: "좀 더 생각해볼게요",
        );
        return null;
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('autoLoginKey', true);
      prefs.setString('autoLoginId', email);
      prefs.setString('autoLoginPw', name);
      prefs.setString('socialLogin', 3.toString());

      globalLogin(context, provider, result);
      return null;
    }
  }
}
