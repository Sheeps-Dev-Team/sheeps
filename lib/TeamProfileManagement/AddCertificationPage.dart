import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';


import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/profileModify/AuthFileUploadPage.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';

import 'model/TeamProfileManagementController.dart';

class AddCertificationPage extends StatefulWidget {
  @override
  _AddCertificationPageState createState() => _AddCertificationPageState();
}

class _AddCertificationPageState extends State<AddCertificationPage> {
  TeamProfileManagementController controller = Get.put(TeamProfileManagementController());
  final TextEditingController certificationController = TextEditingController();
  final TextEditingController organizationController = TextEditingController();

  File authFile;

  @override
  void dispose() {
    certificationController.dispose();
    organizationController.dispose();
    super.dispose();
  }

  bool isOk() {
    bool _isOk = true;
    if (certificationController.text.isEmpty) _isOk = false;
    if (organizationController.text.isEmpty) _isOk = false;
    if (authFile == null) _isOk = false;
    return _isOk;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: GestureDetector(
        onTap: () {
          unFocus(context);
        },
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: WillPopScope(
                onWillPop: null,
                child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: SheepsAppBar(context, '인증 추가'),
                  body: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20 * sizeUnit),
                                  Text('인증명', style: SheepsTextStyle.h3()),
                                  SizedBox(height: 12 * sizeUnit),
                                  multiLineTextField(
                                    controller: certificationController,
                                    hintText: 'ex) 벤처기업인증',
                                    borderColor: sheepsColorGreen,
                                    isOneLine: true,
                                  ),
                                  SizedBox(height: 20 * sizeUnit),
                                  Text('주관 기관', style: SheepsTextStyle.h3()),
                                  SizedBox(height: 12 * sizeUnit),
                                  multiLineTextField(
                                    controller: organizationController,
                                    hintText: 'ex) 중소벤처기업부',
                                    borderColor: sheepsColorGreen,
                                    isOneLine: true,
                                  ),
                                  SizedBox(height: 20 * sizeUnit),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text.rich(
                                        TextSpan(
                                          text: '증빙 자료',
                                        ),
                                        style: SheepsTextStyle.h3(),
                                      ),
                                      SizedBox(width: 8 * sizeUnit),
                                      Text('사업자등록증, 벤처기업인증서 등', style: SheepsTextStyle.info2()),
                                    ],
                                  ),
                                  SizedBox(height: 12 * sizeUnit),
                                  GestureDetector(
                                    onTap: () {
                                      unFocus(context);
                                      Get.to(() => AuthFileUploadPage(appBarTitle: '인증 증빙 자료', authFile: authFile)).then((value) {
                                        if (value != null) {
                                          setState(() {
                                            authFile = value[0];
                                          });
                                        }
                                      });
                                    },
                                    child: Container(
                                      width: 328 * sizeUnit,
                                      height: 32 * sizeUnit,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(color: authFile != null ? sheepsColorGreen : sheepsColorGrey, width: 1 * sizeUnit),
                                        borderRadius: BorderRadius.circular(16 * sizeUnit),
                                      ),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 12 * sizeUnit),
                                            child: Container(
                                              width: 284 * sizeUnit,
                                              child: Text(
                                                authFile != null ? authFile.path.substring(authFile.path.lastIndexOf('\/') + 1) : '증빙 자료는 1개의 업로드만 가능해요',
                                                style: SheepsTextStyle.hint4Profile().copyWith(color: authFile != null ? sheepsColorGreen : sheepsColorGrey),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          Padding(
                                            padding: EdgeInsets.only(right: 12 * sizeUnit),
                                            child: SvgPicture.asset(
                                              svgGreyNextIcon,
                                              width: 12 * sizeUnit,
                                              color: sheepsColorGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20 * sizeUnit),
                        child: SheepsBottomButton(
                          context: context,
                          function: () {
                            if (isOk()) {
                              String certification = certificationController.text;
                              String organization = organizationController.text;

                              String contents = certification + ' \/ ' + organization;

                              bool isSameData = false;
                              for(int i = 0; i < controller.certificationList.length; i++){
                                if(contents == controller.certificationList[i].contents){
                                  isSameData = true;
                                  break;
                                }
                              }
                              if(isSameData){
                                showAddFailDialog(title: '인증', okButtonColor: sheepsColorGreen);
                              }else{
                                controller.certificationList.add(TeamAuth(
                                  id: -1,
                                  contents: contents,
                                  imgUrl: authFile.path, //우선 파일경로 저장. 이후 수정 완료시 처리. id -1으로 확인
                                  auth: 2,
                                ));
                                Get.back();
                              }
                            }
                          },
                          text: '인증 추가',
                          color: sheepsColorGreen,
                          isOK: isOk(),
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
