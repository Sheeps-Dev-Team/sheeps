import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';


import 'package:iamport_flutter/Iamport_certification.dart';
import 'package:iamport_flutter/model/certification_data.dart';
import 'package:get/get.dart';

import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/login/LoginCheckPage.dart';
import 'package:sheeps_app/login/PasswordChangePage.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/registration/IdentityVerificationPage.dart';
import 'package:sheeps_app/registration/model/RegistrationModel.dart';
import 'package:sheeps_app/registration/AuthSuccessPage.dart';

class iamportCertificationPage extends StatefulWidget {
  final String realName;
  final String phoneNumber;
  final IdentityStatus identityStatus; //1 가입, 2 아이디 찾기, 3 비번 찾기

  iamportCertificationPage({Key? key, required this.realName, required this.phoneNumber, required this.identityStatus}) : super(key: key);

  @override
  _iamportCertificationPageState createState() => _iamportCertificationPageState();
}

class _iamportCertificationPageState extends State<iamportCertificationPage> {
  String userCode = 'imp99004464';

  CertificationData? data;

  @override
  void initState() {
    super.initState();
    data = CertificationData.fromJson({
      'merchantUid': 'mid_${DateTime.now().millisecondsSinceEpoch}', // 주문번호
      'company': '아임포트', // 회사명 또는 URL
      'name': widget.realName, // 이름
      'phone': widget.phoneNumber, //휴대전화번호
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: null,
        child: IamportCertification(
          initialChild: Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/LoginReg/iamport-logo.png'),
                  Container(
                    padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
                    child: Text('잠시만 기다려주세요...', style: TextStyle(fontSize: 20.0)),
                  ),
                ],
              ),
            ),
          ),
          userCode: userCode,
          data: data!,
          callback: (Map<String, String> result) async {
            if (result['success'] == 'true') {
              switch (widget.identityStatus) {
                case IdentityStatus.SignUP: //가입
                  {
                    print(globalLoginID);
                    String email = globalLoginID;
                    var res = await ApiProvider().post(
                        '/Personal/Update/Phone',
                        jsonEncode({
                          "id": email,
                          "realName": widget.realName,
                          "phonenumber": widget.phoneNumber,
                        }));
                    switch (globalLoginType) {
                      case LOGIN_TYPE_SHEEPS:
                        {
                          break;
                        }
                      case LOGIN_TYPE_GOOGLE:
                        {
                          await ApiProvider().post(
                              '/Personal/Update/Name',
                              jsonEncode({
                                "id": globalLoginID,
                                "realName": widget.realName,
                                "name": globalName,
                              }));
                          break;
                        }
                    }

                    if(res == null || res['result'] == 'SUCCESS'){//인증 성공, 중복번호
                      Get.off(() => AuthSuccessPage(state: 1));
                    }else if (res['result'] == 'ALREADY'){
                      Get.off(() => AuthSuccessPage(state: 2));
                    }
                    break;
                  }
                case IdentityStatus.FindID: //아이디 찾기
                  {
                    Get.off(() => LoginCheckPage());
                    break;
                  }
                case IdentityStatus.FindPW: //비번 찾기
                  {
                    Get.off(() => PasswordChangePage());
                    break;
                  }
              }
            } else {//본인인증 실패
              Get.off(()=>AuthSuccessPage(state: 0));
            }
          },
        ),
      ),
    );
  }
}
