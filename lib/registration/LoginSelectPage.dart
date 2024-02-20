import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';


import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/registration/PageTermsOfService.dart';
import 'package:sheeps_app/registration/model/RegistrationModel.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/login/LoginPage.dart';
import 'package:sheeps_app/notification/models/LocalNotification.dart';
import 'package:sheeps_app/login/KakaoLogin.dart';

class LoginSelectPage extends StatefulWidget {
  @override
  _LoginSelectPageState createState() => _LoginSelectPageState();
}

class _LoginSelectPageState extends State<LoginSelectPage> {
  final String svgGoogleLogo = 'assets/images/LoginReg/googleLogo.svg';
  final String svgAppleWhiteLogo = 'assets/images/LoginReg/appleWhiteLogo.svg';
  final String svgKakaoLogin = 'assets/images/LoginReg/kakaoLogin.svg';

  bool? _isReady; //서버중복신호방지

  @override
  void initState() {
    _isReady = true; //서버중복신호방지
    isCanDynamicLink = true;//로그인 후 다이나믹링크로 보내기 위함

    super.initState();
  }

  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn googleSignIn = GoogleSignIn();
  User? currentUser;
  String name = "";
  String email = "";

  // Future<String?> googleLogin(SocketProvider provider) async {
  //   if (googleSignIn == null) return null;
  //
  //   GoogleSignInAccount? account;
  //
  //   try {
  //     account = await googleSignIn.signIn();
  //   } catch (err) {
  //     //debugPrint('구글 로그인 실패');
  //     if(kReleaseMode){
  //       showSheepsToast(context: context, text: '구글 로그인에 문제가 생겼어요! 다른 방법으로 로그인해주세요.\n' + err.toString());
  //     }else{
  //       debugPrint(err.toString());
  //       showSheepsToast(context: context, text: err.toString());
  //     }
  //   }
  //
  //   if (account == null) return null;
  //
  //   final GoogleSignInAuthentication googleAuth = await account.authentication;
  //
  //   final AuthCredential credential = GoogleAuthProvider.credential(
  //     accessToken: googleAuth.accessToken,
  //     idToken: googleAuth.idToken,
  //   );
  //
  //   final UserCredential authResult = await _auth.signInWithCredential(credential);
  //   final User user = authResult.user!;
  //
  //   assert(!user.isAnonymous);
  //   assert(await user.getIdToken() != null);
  //
  //   currentUser = _auth.currentUser;
  //   assert(user.uid == currentUser!.uid);
  //
  //   setState(() {
  //     email = user.email!;
  //     name = user.displayName! == null ? '사담의 어린 양' : user.displayName!;
  //   });
  //
  //   globalSocialName = name;
  //
  //   debugPrint('구글 로그인 성공: $user');
  //
  //   var result = await ApiProvider().post(
  //       '/Personal/Select/SocialLogin',
  //       jsonEncode({
  //         "id": email,
  //         "name": name,
  //         "social": 1, //구글로그인
  //       }));
  //   //result
  //   //1 로그인성공,
  //   //2 구글로그인일 경우, 본인인증 안한 상태
  //   //3 애플로그인일 경우, 이름 업데이트 안한 상태
  //
  //   if (result != null) {
  //     //핸드폰 페이지로 이동
  //     globalLoginID = email;
  //     globalName = name;
  //     globalLoginType = LOGIN_TYPE_GOOGLE;
  //     if (result['res'] == 2 || result['res'] == '2') {
  //       Get.to(() => PageTermsOfService(
  //         loginType: LOGIN_TYPE_GOOGLE, //1
  //       ));
  //     } else {
  //       // 로그인
  //       if (result['result'] == null) {
  //         Function okFunc = () {
  //           ApiProvider().post('/Personal/Logout', jsonEncode({"userID": result['userID'], "isSelf": 0}), isChat: true);
  //
  //           Get.back();
  //         };
  //         showSheepsDialog(
  //           context: context,
  //           title: "로그아웃",
  //           description: "해당 아이디는 이미 로그인 중입니다.\n로그아웃을 요청하시겠어요?",
  //           okText: "로그아웃 할게요",
  //           okFunc: okFunc,
  //           cancelText: "좀 더 생각해볼게요",
  //         );
  //         return null;
  //       }
  //
  //       final SharedPreferences prefs = await SharedPreferences.getInstance();
  //       prefs.setBool('autoLoginKey', true);
  //       prefs.setString('autoLoginId', email);
  //       prefs.setString('autoLoginPw', name);
  //       prefs.setString('socialLogin', 1.toString());
  //
  //       globalLogin(context, provider, result);
  //     }
  //   }
  //
  //   return '구글 로그인 성공: $user';
  // }
  //
  // Future<UserCredential> signInWithApple() async {
  //   final appleCredential = await SignInWithApple.getAppleIDCredential(
  //     scopes: [
  //       AppleIDAuthorizationScopes.email,
  //       AppleIDAuthorizationScopes.fullName,
  //     ],
  //   );
  //
  //   final oauthCredential = OAuthProvider("apple.com").credential(
  //     idToken: appleCredential.identityToken,
  //     accessToken: appleCredential.authorizationCode,
  //   );
  //
  //   return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  // }
  //
  // Future<String?> appleLogin(SocketProvider provider) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final credential = await SignInWithApple.getAppleIDCredential(
  //     scopes: [
  //       AppleIDAuthorizationScopes.email,
  //       AppleIDAuthorizationScopes.fullName,
  //     ],
  //   );
  //
  //   final oauthCredential = OAuthProvider("apple.com").credential(
  //     idToken: credential.identityToken,
  //     accessToken: credential.authorizationCode,
  //   );
  //
  //   UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  //
  //   email = userCredential.user!.email!;
  //   name = userCredential.user!.displayName! != null || userCredential.user!.displayName! == '' ? userCredential.user!.displayName! : "MUSTCHANGEAPPLEID";
  //   globalSocialName = name;
  //
  //   prefs.setString('autoLoginAppleId', email);
  //   prefs.setString('autoLoginApplePw', name);
  //   prefs.setString('socialLogin', 2.toString());
  //
  //   var result = await ApiProvider().post(
  //       '/Personal/Select/SocialLogin',
  //       jsonEncode({
  //         "id": email,
  //         "name": name,
  //         "social": 2,//애플로그인
  //       }));
  //   //1 로그인성공,
  //   //2 구글로그인일 경우, 본인인증 안한 상태
  //   //3 애플로그인일 경우, 이름 업데이트 안한 상태
  //
  //   if (result != null) {
  //     //첫 로그인시, 인증정보 없을 때,
  //     globalLoginID = email;
  //     globalLoginType = LOGIN_TYPE_APPLE;
  //     if (result['res'] == 3) {
  //       Get.to(() => PageTermsOfService(
  //         loginType: LOGIN_TYPE_APPLE, //2
  //       ));
  //     } else {
  //       // 로그인
  //       if (result['result'] == null) {
  //         Function okFunc = () {
  //           ApiProvider().post('/Personal/Logout', jsonEncode({"userID": result['userID'], "isSelf": 0}), isChat: true);
  //
  //           Get.back();
  //         };
  //
  //         showSheepsDialog(
  //           context: context,
  //           title: "로그아웃",
  //           description: "해당 아이디는 이미 로그인 중입니다.\n로그아웃을 요청하시겠어요?",
  //           okText: "로그아웃 할게요",
  //           okFunc: okFunc,
  //           cancelText: "좀 더 생각해볼게요",
  //         );
  //
  //         return null;
  //       }
  //
  //       prefs.setBool('autoLoginKey', true);
  //       prefs.setString('autoLoginAppleId', email);
  //       prefs.setString('autoLoginApplePw', name);
  //       prefs.setString('socialLogin', 2.toString());
  //
  //       globalLogin(context, provider, result);
  //     }
  //   }
  //
  //   return null;
  // }
  //
  // void googleSignOut() async {
  //   await _auth.signOut();
  //   await googleSignIn.signOut();
  //
  //   setState(() {
  //     email = "";
  //     name = "";
  //   });
  // }
  //
  // static DateTime? currentBackPressTime;
  //
  // _isEnd() {
  //   DateTime now = DateTime.now();
  //   if (currentBackPressTime == null || now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
  //     currentBackPressTime = now;
  //     showSheepsToast(context: context, text: '뒤로 가기를 한 번 더 입력하시면 종료됩니다.');
  //     return false;
  //   }
  //   return true;
  // }

  @override
  Widget build(BuildContext context) {
    SocketProvider provider = Get.put(SocketProvider());
    provider.setLocalNotification(LocalNotification());
    provider.setChatGlobal(Get.put(ChatGlobal()));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: () async {
          // bool result = _isEnd();
          return await Future.value(true);
        },
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Scaffold(
                body: Container(
                  padding: EdgeInsets.fromLTRB(20 * sizeUnit, 0, 20 * sizeUnit, 0),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              svgSheepsFullLogo,
                              color: sheepsColorGreen,
                              width: 160 * sizeUnit,
                              height: 160 * sizeUnit,
                            ),
                          ],
                        ),
                      ),
                      // Container(
                      //   width: 320 * sizeUnit,
                      //   height: 54 * sizeUnit,
                      //   decoration: BoxDecoration(
                      //     color: sheepsColorGreen,
                      //     borderRadius: BorderRadius.circular(12 * sizeUnit),
                      //   ),
                      //   child: TextButton(
                      //     onPressed: () {
                      //       globalLoginType = LOGIN_TYPE_SHEEPS;
                      //       Get.to(() => PageTermsOfService(loginType: LOGIN_TYPE_SHEEPS));
                      //     },
                      //     child: Text(
                      //       "쉽게 창업 시작하기",
                      //       style: SheepsTextStyle.button1(),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 12 * sizeUnit),
                      Container(
                        width: 320 * sizeUnit,
                        height: 54 * sizeUnit,
                        decoration: BoxDecoration(
                          color: sheepsColorBlue,
                          borderRadius: BorderRadius.circular(12 * sizeUnit),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Get.to(() => LoginPage());
                          },
                          child: Text(
                            "로그인",
                            style: SheepsTextStyle.button1(),
                          ),
                        ),
                      ),
                      // SizedBox(height: 20 * sizeUnit),
                      // Text(
                      //   '간편하게 로그인 하는 방법',
                      //   style: SheepsTextStyle.info1(),
                      // ),
                      // SizedBox(height: 20 * sizeUnit),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Platform.isIOS
                      //         ? GestureDetector(
                      //       onTap: () {
                      //         if (_isReady!) {
                      //           _isReady = false;
                      //           appleLogin(provider);
                      //           Future.delayed(Duration(milliseconds: 500), () {
                      //             _isReady = true;
                      //           });
                      //         }
                      //       },
                      //       child: Container(
                      //         width: 54 * sizeUnit,
                      //         height: 54 * sizeUnit,
                      //         decoration: BoxDecoration(
                      //           color: Colors.black,
                      //           border: Border.all(style: BorderStyle.none),
                      //           borderRadius: BorderRadius.circular(27 * sizeUnit),
                      //         ),
                      //         child: Center(
                      //           child: SvgPicture.asset(
                      //             svgAppleWhiteLogo,
                      //             width: 28 * sizeUnit,
                      //             height: 28 * sizeUnit,
                      //           ),
                      //         ),
                      //       ),
                      //     )
                      //         : SizedBox.shrink(),
                      //     Platform.isIOS ? SizedBox(width: 12 * sizeUnit) : SizedBox.shrink(),
                      //     GestureDetector(
                      //       onTap: () {
                      //         if (_isReady!) {
                      //           _isReady = false; //서버 중복 신호 방지
                      //           googleLogin(provider);
                      //           Future.delayed(Duration(milliseconds: 500), () {
                      //             _isReady = true;
                      //           });
                      //         }
                      //       },
                      //       child: Container(
                      //         width: 54 * sizeUnit,
                      //         height: 54 * sizeUnit,
                      //         decoration: BoxDecoration(
                      //           color: Colors.white,
                      //           border: Border.all(color: sheepsColorGrey, width: 0.5 * sizeUnit),
                      //           borderRadius: BorderRadius.circular(27 * sizeUnit),
                      //         ),
                      //         child: Center(
                      //           child: SvgPicture.asset(
                      //             svgGoogleLogo,
                      //             width: 28 * sizeUnit,
                      //             height: 28 * sizeUnit,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     SizedBox(width: 12 * sizeUnit),
                      //     GestureDetector(
                      //       onTap: () {
                      //         if (_isReady!) {
                      //           _isReady = false; //서버 중복 신호 방지
                      //           kakaoLoginButtonClicked(context, provider);
                      //           Future.delayed(Duration(milliseconds: 500), () {
                      //             _isReady = true;
                      //           });
                      //         }
                      //       },
                      //       child: Container(
                      //         width: 54 * sizeUnit,
                      //         height: 54 * sizeUnit,
                      //         decoration: BoxDecoration(
                      //           color: Color(0xFFFFE500), //카카오 노랑
                      //           border: Border.all(style: BorderStyle.none),
                      //           borderRadius: BorderRadius.circular(27 * sizeUnit),
                      //         ),
                      //         child: Center(
                      //           child: SvgPicture.asset(
                      //             svgKakaoLogin,
                      //             width: 54 * sizeUnit,
                      //             height: 54 * sizeUnit,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(height: 40 * sizeUnit),
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
