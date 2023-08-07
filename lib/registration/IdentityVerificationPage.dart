
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';



import 'package:get/get.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/registration/iamportCertificationPage.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/registration/model/RegistrationModel.dart';

enum IdentityStatus{SignUP, FindID, FindPW} // 가입, 아이디 찾기, 비번 찾기

class IdentityVerificationPage extends StatefulWidget {
  final IdentityStatus identityStatus;
  const IdentityVerificationPage({Key key, @required this.identityStatus}) : super(key: key);

  @override
  _IdentityVerificationPageState createState() => _IdentityVerificationPageState();
}

class _IdentityVerificationPageState extends State<IdentityVerificationPage> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController phoneNumberTextEditingController = TextEditingController();

  bool isCheckName = false;
  bool isCheckNumber = false;

  @override
  Widget build(BuildContext context) {
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
                  appBar: SheepsAppBar(context, '본인인증'),
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
                                      '본인인증을 해주세요.',
                                      style: SheepsTextStyle.h1(),
                                    ),
                                    SizedBox(height: 24 * sizeUnit),
                                    Text(
                                      '이름과 휴대폰 번호를 입력하고\n본인인증을 진행해주세요.',
                                      style: SheepsTextStyle.b2(),
                                    ),
                                    SizedBox(
                                      height: 36 * sizeUnit,
                                    ),
                                    sheepsTextField(
                                      context,
                                      title: '이름',
                                      controller: nameTextEditingController,
                                      hintText: '실명을 적어주세요.',
                                      errorText: validRealNameErrorText(nameTextEditingController.text) == 'empty' ? null : validRealNameErrorText(nameTextEditingController.text),
                                      onChanged: (val) {
                                        validRealNameErrorText(nameTextEditingController.text) == null ? isCheckName = true : isCheckName = false;
                                        setState(() {});
                                      },
                                    ),
                                    SizedBox(height: 20 * sizeUnit),
                                    sheepsTextField(
                                      context,
                                      title: '휴대폰 번호',
                                      controller: phoneNumberTextEditingController,
                                      keyboardType: TextInputType.number,
                                      hintText: '숫자만 적어주세요.',
                                      errorText: validPhoneNumErrorText(phoneNumberTextEditingController.text) == 'empty' ? null : validPhoneNumErrorText(phoneNumberTextEditingController.text),
                                      onChanged: (val) {
                                        validPhoneNumErrorText(phoneNumberTextEditingController.text) == null ? isCheckNumber = true : isCheckNumber = false;
                                        setState(() {});
                                      },
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
                            function: () {
                              if(isCheckName && isCheckNumber){
                                globalRealName = nameTextEditingController.text;
                                globalPhoneNumber = phoneNumberTextEditingController.text;

                                switch (widget.identityStatus){
                                  case IdentityStatus.SignUP ://가입
                                    {
                                      Get.off(() => iamportCertificationPage(
                                        realName: nameTextEditingController.text,
                                        phoneNumber: phoneNumberTextEditingController.text,
                                        identityStatus: IdentityStatus.SignUP, // 가입
                                      ));
                                      break;
                                    }
                                  case IdentityStatus.FindID ://아이디 찾기
                                    {
                                      Get.off(() => iamportCertificationPage(
                                        realName: nameTextEditingController.text,
                                        phoneNumber: phoneNumberTextEditingController.text,
                                        identityStatus: IdentityStatus.FindID, // 아이디 찾기
                                      ));
                                      break;
                                    }
                                  case IdentityStatus.FindPW : //비밀번호 찾기
                                    {
                                      Get.off(() => iamportCertificationPage(
                                        realName: nameTextEditingController.text,
                                        phoneNumber: phoneNumberTextEditingController.text,
                                        identityStatus: IdentityStatus.FindPW, // 비번 찾기
                                      ));
                                      break;
                                    }
                                }
                              }
                            },
                            text: '인증하기',
                            isOK: isCheckName && isCheckNumber,
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
