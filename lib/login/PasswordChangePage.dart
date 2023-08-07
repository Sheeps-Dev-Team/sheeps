
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:get/get.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/login/PasswordCheckPage.dart';

class PasswordChangePage extends StatefulWidget {
  @override
  _PasswordChangePageState createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends State<PasswordChangePage> {
  final passwordController = TextEditingController();
  final passwordCheckController = TextEditingController();

  bool isCheckPassword = false;

  @override
  void dispose() {
    passwordController.dispose();
    passwordCheckController.dispose();
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
                                Text('비밀번호를 설정해주세요', style: SheepsTextStyle.h1()),
                                SizedBox(height: 24 * sizeUnit),
                                Text(
                                  '아무도 해킹할 수 없도록,\n강력한 비밀번호를 입력해 주세요!',
                                  style: SheepsTextStyle.b2(),
                                ),
                                SizedBox(height: 36 * sizeUnit),
                                sheepsTextField(
                                  context,
                                  title: '비밀번호',
                                  controller: passwordController,
                                  hintText: '비밀번호',
                                  obscureText: true,
                                  errorText: validPasswordErrorText(passwordController.text) == 'empty' ? null : validPasswordErrorText(passwordController.text),
                                  onChanged: (value) {
                                    validPasswordErrorText(passwordController.text) == null && validPasswordConfirmErrorText(passwordController.text, passwordCheckController.text) == null
                                        ? isCheckPassword = true
                                        : isCheckPassword = false;
                                    setState(() {});
                                  },
                                  onPressClear: () {
                                    passwordController.clear();
                                    isCheckPassword = false;
                                    setState(() {});
                                  },
                                ),
                                SizedBox(height: 20 * sizeUnit),
                                sheepsTextField(
                                  context,
                                  title: '비밀번호 확인',
                                  controller: passwordCheckController,
                                  hintText: '비밀번호 확인',
                                  obscureText: true,
                                  errorText: validPasswordConfirmErrorText(passwordController.text, passwordCheckController.text),
                                  onChanged: (value) {
                                    validPasswordErrorText(passwordController.text) == null && validPasswordConfirmErrorText(passwordController.text, passwordCheckController.text) == null
                                        ? isCheckPassword = true
                                        : isCheckPassword = false;
                                    setState(() {});
                                  },
                                  onPressClear: () {
                                    passwordCheckController.clear();
                                    isCheckPassword = false;
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
                            if (isCheckPassword) Get.to(() => PasswordCheckPage(password: passwordController.text));
                          },
                          isOK: isCheckPassword,
                          text: '확인',
                        ),
                      ),
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
