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
import 'model/Team.dart';
import 'model/TeamProfileManagementController.dart';


class AddTeamWinPage extends StatefulWidget {
  @override
  _AddTeamWinState createState() => _AddTeamWinState();
}

class _AddTeamWinState extends State<AddTeamWinPage> {
  TeamProfileManagementController controller = Get.put(TeamProfileManagementController());
  final TextEditingController winController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController organizationController = TextEditingController();

  String date = '';

  File authFile;

  @override
  void dispose() {
    winController.dispose();
    gradeController.dispose();
    organizationController.dispose();
    super.dispose();
  }

  bool isOk() {
    bool _isOk = true;
    if (winController.text.isEmpty) _isOk = false;
    if (gradeController.text.isEmpty) _isOk = false;
    if (organizationController.text.isEmpty) _isOk = false;
    if (date.isEmpty) _isOk = false;
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
                  appBar: SheepsAppBar(context, '수상 이력 추가'),
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
                                  Text('대회명', style: SheepsTextStyle.h3()),
                                  SizedBox(height: 12 * sizeUnit),
                                  multiLineTextField(
                                    controller: winController,
                                    hintText: 'ex)쉽스경진대회',
                                    borderColor: sheepsColorGreen,
                                    isOneLine: true,
                                  ),
                                  SizedBox(height: 20 * sizeUnit),
                                  Text('수상내역', style: SheepsTextStyle.h3()),
                                  SizedBox(height: 12 * sizeUnit),
                                  multiLineTextField(
                                    controller: gradeController,
                                    hintText: 'ex)최우수상',
                                    borderColor: sheepsColorGreen,
                                    isOneLine: true,
                                  ),
                                  SizedBox(height: 20 * sizeUnit),
                                  Text('주관기관', style: SheepsTextStyle.h3()),
                                  SizedBox(height: 12 * sizeUnit),
                                  multiLineTextField(
                                    controller: organizationController,
                                    hintText: 'ex)중소기업벤처기업부',
                                    borderColor: sheepsColorGreen,
                                    isOneLine: true,
                                  ),
                                  SizedBox(height: 20 * sizeUnit),
                                  Text('수상일', style: SheepsTextStyle.h3()),
                                  SizedBox(height: 12 * sizeUnit),
                                  GestureDetector(
                                    onTap: () {
                                      unFocus(context);
                                      showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1960),
                                        lastDate: DateTime.now(),
                                        helpText: '날짜 선택',
                                        cancelText: '취소',
                                        confirmText: '확인',
                                        locale: const Locale('ko', 'KR'),
                                        initialDatePickerMode: DatePickerMode.year,
                                        errorFormatText: '형식이 맞지 않습니다.',
                                        errorInvalidText: '형식이 맞지 않습니다!',
                                        fieldLabelText: '날짜 입력',
                                        builder: (context, child) {
                                          return Theme(
                                            data: ThemeData(
                                              fontFamily: 'SpoqaHanSansNeo',
                                              colorScheme: ColorScheme.fromSwatch(
                                                primarySwatch: Colors.grey,
                                              ),
                                            ),
                                            child: child,
                                          );
                                        },
                                      ).then((value) {
                                        setState(() {
                                          if (value != null) {
                                            date = value.year.toString() + '.' + value.month.toString();
                                          }
                                        });
                                      });
                                    },
                                    child: pickDateContainer(text: date),
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
                                      Text('상장 사본, 수상 증명서 등', style: SheepsTextStyle.info2()),
                                    ],
                                  ),
                                  SizedBox(height: 12 * sizeUnit),
                                  GestureDetector(
                                    onTap: () {
                                      unFocus(context);
                                      Get.to(() => AuthFileUploadPage(appBarTitle: '수상 증빙 자료', authFile: authFile)).then((value) {
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
                              String win = winController.text;
                              String grade = gradeController.text;
                              String organization = organizationController.text;

                              String contents = win + ' \/ ' + grade + '||' + organization + ' ' + date;

                              bool isSameData = false;
                              for(int i = 0; i < controller.winList.length; i++){
                                if(contents == controller.winList[i].contents){
                                  isSameData = true;
                                  break;
                                }
                              }
                              if(isSameData){
                                showAddFailDialog(title: '수상 이력', okButtonColor: sheepsColorGreen);
                              }else{
                                controller.winList.add(TeamWins(
                                  id: -1,
                                  contents: contents,
                                  imgUrl: authFile.path, //우선 파일경로 저장. 이후 수정 완료시 처리. id -1으로 확인
                                  auth: 2,
                                ));
                                Get.back();
                              }
                            }
                          },
                          text: '수상 이력 추가',
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
