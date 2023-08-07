import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:get/get.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/login/EmailNotFoundPage.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/registration/IdentityVerificationPage.dart';
import 'package:sheeps_app/registration/model/RegistrationModel.dart';

class EmailVerificationPage extends StatefulWidget {
  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final emailTextController = TextEditingController();
  bool isCheckEmail = false;

  @override
  void dispose() {
    emailTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: null,
        child: GestureDetector(
          onTap: () {
            unFocus(context);
          },
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
            child: Container(
              color: Colors.white,
              child: SafeArea(
                child: Scaffold(
                  appBar: SheepsAppBar(context, ''),
                  body: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 22 * sizeUnit),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 68 * sizeUnit),
                                Text('이메일을 알려주세요.', style: SheepsTextStyle.h1()),
                                SizedBox(height: 24 * sizeUnit),
                                Text(
                                  '가입하신 로그인 이메일을 알려주세요.',
                                  style: SheepsTextStyle.b2(),
                                ),
                                SizedBox(height: 65 * sizeUnit),
                                sheepsTextField(
                                  context,
                                  title: '로그인 이메일',
                                  controller: emailTextController,
                                  hintText: '로그인 이메일',
                                  errorText: validEmailErrorText(emailTextController.text) == 'empty'
                                      ? null
                                      : validEmailErrorText(emailTextController.text),//정규식 에러 메세지
                                  onChanged: (val) {
                                    validEmailErrorText(emailTextController.text) == null ? isCheckEmail = true : isCheckEmail = false;
                                    setState(() {});
                                  },
                                  onPressClear: () {
                                    emailTextController.clear();
                                    isCheckEmail = false;
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20 * sizeUnit),
                        child: SheepsBottomButton(
                          context: context,
                          function: () {
                            if (isCheckEmail) {
                              Future.microtask(() async {
                                var res = await ApiProvider().post('/Personal/Select/IDCheck', jsonEncode({"id": emailTextController.text}));
                                if (res != null) { // 등록된 이메일이 있을 때
                                  globalLoginID = emailTextController.text;
                                  Get.to(IdentityVerificationPage(identityStatus: IdentityStatus.FindPW)); // 비밀번호 찾기
                                } else {
                                  Get.to(() => EmailNotFoundPage());
                                }
                              });
                            }
                          },
                          isOK: isCheckEmail,
                          text: '재설정 하기',
                        ),
                      ),
                    ],
                  )
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
