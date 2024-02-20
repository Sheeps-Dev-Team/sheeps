import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:get/get.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/registration/RegistrationSuccessPage.dart';
import 'package:sheeps_app/registration/model/RegistrationModel.dart';
import 'package:sheeps_app/registration/NameUpdatePage.dart';
import 'package:sheeps_app/registration/IdentityVerificationPage.dart';

class RegistrationPage extends StatefulWidget {
  final bool isMarketingAgree;
  final int loginType;

  RegistrationPage({Key? key, this.isMarketingAgree = true, required this.loginType}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  int currentPage = 0;
  PageController pageController = PageController();
  final int pageAniTime = 300;

  final TextEditingController nameTextEditingController = TextEditingController();
  final TextEditingController emailTextEditingController = TextEditingController();
  final TextEditingController passwordTextEditingController = TextEditingController();
  final TextEditingController passwordConfirmTextEditingController = TextEditingController();

  ScrollController? nameScrollController;
  ScrollController? emailScrollController;
  ScrollController? passwordScrollController;

  String name = '';
  String email = '';
  String password = '';

  bool isCheckName = false;
  bool isCheckEmail = false;
  bool isCheckPassword = false;

  bool isReady = true;

  String? emailErrMsg;

  _scrollControllerToBottom(ScrollController controller){
    if (controller.hasClients) {
      controller.jumpTo(
        controller.position.maxScrollExtent,
      );
    }
  }

  void backFunc(int currentPage) {
    unFocus(context);
    switch (currentPage) {
      case 0:
        {
          Get.back();
        }
        break;
      case 1:
        {
          pageController.previousPage(duration: Duration(milliseconds: pageAniTime), curve: Curves.easeOut);
        }
        break;
      case 2:
        {
          pageController.previousPage(duration: Duration(milliseconds: pageAniTime), curve: Curves.easeOut);
        }
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    nameScrollController = ScrollController(initialScrollOffset: 0.0); //flutter 제공
    emailScrollController = ScrollController(initialScrollOffset: 0.0); //flutter 제공
    passwordScrollController = ScrollController(initialScrollOffset: 0.0); //flutter 제공
    if(globalName.isNotEmpty) name = globalName;
    nameTextEditingController.text = name;
    validNameErrorText(nameTextEditingController.text) == null ? isCheckName = true : isCheckName = false;
  }

  @override
  void dispose() {
    nameTextEditingController.dispose();
    emailTextEditingController.dispose();
    passwordTextEditingController.dispose();
    passwordConfirmTextEditingController.dispose();

    nameScrollController!.dispose();
    emailScrollController!.dispose();
    passwordScrollController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: () async {
          backFunc(currentPage);
          return await Future.value(false);
        },
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Scaffold(
                appBar: SheepsAppBar(
                  context,
                  '회원가입',
                  backFunc: () {
                    backFunc(currentPage);
                  },
                ),
                body: Container(
                  height: double.infinity,
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView(
                          physics: NeverScrollableScrollPhysics(),
                          controller: pageController,
                          onPageChanged: (index) {
                            currentPage = index;
                            setState(() {}); //버튼 색 바꾸기용
                          },
                          children: [
                            namePage(),
                            emailPage(),
                            passwordPage(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20 * sizeUnit),
                        child: SheepsBottomButton(
                            context: context,
                            function: () {
                              unFocus(context);
                              switch (currentPage) {
                                case 0:
                                  {
                                    if (isCheckName) {
                                      switch (widget.loginType) {
                                        case LOGIN_TYPE_SHEEPS:
                                          {
                                            name = nameTextEditingController.text;
                                            pageController.nextPage(duration: Duration(milliseconds: pageAniTime), curve: Curves.easeOut);
                                          }
                                          break;
                                        case LOGIN_TYPE_GOOGLE:
                                          {
                                            globalName = nameTextEditingController.text;
                                            Get.off(() => IdentityVerificationPage(identityStatus: IdentityStatus.SignUP)); //1 가입 본인인증페이지로
                                          }
                                          break;
                                        case LOGIN_TYPE_APPLE:
                                          {
                                            globalName = nameTextEditingController.text;
                                            Get.off(() => NameUpdatePage()); //실명입력페이지로
                                          }
                                          break;
                                      }
                                    }
                                  }
                                  break;
                                case 1:
                                  {
                                    if (isCheckEmail) {
                                      email = emailTextEditingController.text;

                                      Future.microtask(() async {
                                        var res = await ApiProvider().post('/Personal/Select/IDCheck', jsonEncode({"id": email}));
                                        if (res != null) {
                                          emailErrMsg = "이미 등록된 아이디인걸요? 흑흑";
                                        } else {
                                          pageController.nextPage(duration: Duration(milliseconds: pageAniTime), curve: Curves.easeOut);
                                        }
                                      }).then((value) {
                                        setState(() {});
                                      });
                                    }
                                  }
                                  break;
                                case 2:
                                  {
                                    if (isCheckPassword) {
                                      password = passwordTextEditingController.text;
                                      if (isReady) {
                                        isReady = false;
                                        Future.delayed(Duration(milliseconds: 500), () {
                                          isReady = true;
                                        });

                                        globalLoginID = email;
                                        globalLoginPW = password;
                                        globalName = name;

                                        Future.microtask(()async{
                                          var res = await ApiProvider().post("/Personal/Insert", jsonEncode({"id": email, "password": password, "name": name, "marketingAgree": widget.isMarketingAgree}));

                                          if (res == null) {
                                            Get.off(() => RegistrationSuccessPage(state: 2)); //실패
                                          } else {
                                            globalUserID = res[0]['UserID'];
                                            Get.off(() => RegistrationSuccessPage(state: 1)); //성공
                                          }
                                        });
                                      }
                                    }
                                  }
                                  break;
                              }
                            },
                            text: '다음',
                            isOK: currentPage == 0
                                ? isCheckName
                                : currentPage == 1
                                    ? isCheckEmail
                                    : currentPage == 2
                                        ? isCheckPassword
                                        : true),
                      )
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

  Widget namePage() {
    return GestureDetector(
      onTap: () {
        unFocus(context);
      },
      child: SingleChildScrollView(
        controller: nameScrollController,
        child: Container(
          color: Colors.white, //채우기용
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 22 * sizeUnit),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [SizedBox(height: 72 * sizeUnit)]),
                Text(
                  '이름이 뭐예요?',
                  style: SheepsTextStyle.h1(),
                ),
                SizedBox(height: 32 * sizeUnit),
                Text(
                  '사담에서 활동할 이름을 알려주세요.\n꼭 실명이 아니어도 괜찮아요!',
                  style: SheepsTextStyle.b2(),
                ),
                SizedBox(
                  height: 40 * sizeUnit,
                ),
                sheepsTextField(
                  context,
                  title: '활동 이름',
                  controller: nameTextEditingController,
                  hintText: '사용하실 이름을 적어주세요.',
                  errorText: validNameErrorText(nameTextEditingController.text) == 'empty' ? null : validNameErrorText(nameTextEditingController.text),
                  onChanged: (val) {
                    setState(() {
                      validNameErrorText(nameTextEditingController.text) == null ? isCheckName = true : isCheckName = false;

                      if(false == isCheckName){
                        _scrollControllerToBottom(nameScrollController!);
                      }
                    });
                  },
                  onPressClear: () {
                    nameTextEditingController.clear();
                    isCheckName = false;
                    setState(() {});
                  },
                ),
                SizedBox(height: 20 * sizeUnit),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget emailPage() {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context); //텍스트 포커스 해제
        if (!currentFocus.hasPrimaryFocus) {
          if (Platform.isIOS) {
            FocusManager.instance.primaryFocus!.unfocus();
          } else {
            currentFocus.unfocus();
          }
        }
      },
      child: SingleChildScrollView(
        controller: emailScrollController,
        child: Container(
          color: Colors.white, //채우기용
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 22 * sizeUnit),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [SizedBox(height: 72 * sizeUnit)]),
                Text(
                  '로그인 이메일은요?',
                  style: SheepsTextStyle.h1(),
                ),
                SizedBox(height: 32 * sizeUnit),
                Text(
                  '로그인 이메일을 알려주세요.\n이메일 형식은 꼭 지켜야해요!',
                  style: SheepsTextStyle.b2(),
                ),
                SizedBox(
                  height: 40 * sizeUnit,
                ),
                sheepsTextField(
                  context,
                  title: '로그인 이메일',
                  controller: emailTextEditingController,
                  hintText: '로그인에 사용할 이메일을 적어주세요.',
                  errorText: validEmailErrorText(emailTextEditingController.text) == 'empty'
                      ? null
                      : validEmailErrorText(emailTextEditingController.text) == null
                          ? emailErrMsg //이메일 중복에러 메세지
                          : validEmailErrorText(emailTextEditingController.text),//정규식 에러 메세지
                  onChanged: (val) {
                    emailErrMsg = null;
                    validEmailErrorText(emailTextEditingController.text) == null ? isCheckEmail = true : isCheckEmail = false;
                    setState(() {
                      if(false == isCheckEmail){
                        _scrollControllerToBottom(emailScrollController!);
                      }
                    });
                  },
                  onPressClear: () {
                    emailTextEditingController.clear();
                    isCheckEmail = false;
                    setState(() {});
                  },
                ),
                SizedBox(height: 20 * sizeUnit),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget passwordPage() {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context); //텍스트 포커스 해제
        if (!currentFocus.hasPrimaryFocus) {
          if (Platform.isIOS) {
            FocusManager.instance.primaryFocus!.unfocus();
          } else {
            currentFocus.unfocus();
          }
        }
      },
      child: SingleChildScrollView(
        controller: passwordScrollController,
        child: Container(
          color: Colors.white, //채우기용
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 22 * sizeUnit),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [SizedBox(height: 72 * sizeUnit)]),
                Text(
                  '비밀번호를 설정해주세요.',
                  style: SheepsTextStyle.h1(),
                ),
                SizedBox(height: 32 * sizeUnit),
                Text(
                  '아무도 해킹할 수 없도록,\n강력한 비밀번호를 입력해 주세요!',
                  style: SheepsTextStyle.b2(),
                ),
                SizedBox(height: 40 * sizeUnit),
                sheepsTextField(
                  context,
                  title: '비밀번호',
                  controller: passwordTextEditingController,
                  hintText: '8자 이상 입력해주세요.',
                  errorText: validPasswordErrorText(passwordTextEditingController.text) == 'empty' ? null : validPasswordErrorText(passwordTextEditingController.text),
                  obscureText: true,
                  onChanged: (val) {
                    validPasswordErrorText(passwordTextEditingController.text) == null &&
                            validPasswordConfirmErrorText(passwordTextEditingController.text, passwordConfirmTextEditingController.text) == null
                        ? isCheckPassword = true
                        : isCheckPassword = false;
                    setState(() {
                      if(false == isCheckPassword){
                        _scrollControllerToBottom(passwordScrollController!);
                      }
                    });
                  },
                  onPressClear: () {
                    passwordTextEditingController.clear();
                    isCheckPassword = false;
                    setState(() {});
                  },
                ),
                SizedBox(height: 20 * sizeUnit),
                sheepsTextField(
                  context,
                  title: '비밀번호 확인',
                  controller: passwordConfirmTextEditingController,
                  hintText: '비밀번호를 한 번 더 입력해주세요.',
                  errorText: validPasswordConfirmErrorText(passwordTextEditingController.text, passwordConfirmTextEditingController.text),
                  obscureText: true,
                  onChanged: (val) {
                    validPasswordErrorText(passwordTextEditingController.text) == null &&
                            validPasswordConfirmErrorText(passwordTextEditingController.text, passwordConfirmTextEditingController.text) == null
                        ? isCheckPassword = true
                        : isCheckPassword = false;
                    setState(() {
                      if(false == isCheckPassword){
                        _scrollControllerToBottom(passwordScrollController!);
                      }
                    });
                  },
                  onPressClear: () {
                    passwordConfirmTextEditingController.clear();
                    isCheckPassword = false;
                    setState(() {});
                  },
                ),
                SizedBox(height: 20 * sizeUnit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
