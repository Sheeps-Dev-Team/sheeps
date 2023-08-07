import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';


import 'package:get/get.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/registration/AuthSuccessPage.dart';
import 'package:sheeps_app/registration/model/RegistrationModel.dart';

class NameUpdatePage extends StatefulWidget {
  @override
  _NameUpdatePageState createState() => _NameUpdatePageState();
}

class _NameUpdatePageState extends State<NameUpdatePage> {
  TextEditingController nameTextEditingController = TextEditingController();

  String errMsg = '';
  bool isCheckName = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: () async {
          return Future.value(false);
        },
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Scaffold(
                  appBar: SheepsAppBar(context, '회원가입', isBackButton: false),
                  body: GestureDetector(
                    onTap: () {
                      unFocus(context);
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              color: Colors.white, //채우기용
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 22 * sizeUnit),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [SizedBox(height: 68 * sizeUnit)]),
                                    Text(
                                      '실명을\n알려주세요.',
                                      style: SheepsTextStyle.h1(),
                                    ),
                                    SizedBox(height: 24 * sizeUnit),
                                    Text(
                                      '학력, 경력에 대한 인증을 위해 실명이 필요해요.\n절대 타인에게 노출되지 않으며,\n인증 이외의 용도로는 사용하지 않습니다.',
                                      style: SheepsTextStyle.b2(),
                                    ),
                                    SizedBox(
                                      height: 36 * sizeUnit,
                                    ),
                                    sheepsTextField(
                                      context,
                                      title: '이름',
                                      controller: nameTextEditingController,
                                      hintText: '이름',
                                      errorText: validRealNameErrorText(nameTextEditingController.text) == 'empty' ? null : validRealNameErrorText(nameTextEditingController.text),
                                      onChanged: (val) {
                                        validRealNameErrorText(nameTextEditingController.text) == null ? isCheckName = true : isCheckName = false;
                                        setState(() {});
                                      },
                                    ),
                                    SizedBox(height: 8 * sizeUnit),
                                    Text(
                                      '* 실명이 아닌 경우, 각종 인증과 뱃지 부여가 불가할 수 있습니다.',
                                      style: SheepsTextStyle.b4(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20 * sizeUnit),
                          child: SheepsBottomButton(
                            context: context,
                            function: () async {
                              if (isCheckName) {
                                await ApiProvider().post(
                                    '/Personal/Update/Name',
                                    jsonEncode({
                                      "id": globalLoginID,
                                      "realName": nameTextEditingController.text,
                                      "name": globalName,
                                    }));
                                Get.off(() => AuthSuccessPage(state: 1));
                              }
                            },
                            text: '확인',
                            isOK: isCheckName,
                          ),
                        )
                      ],
                    ),
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
