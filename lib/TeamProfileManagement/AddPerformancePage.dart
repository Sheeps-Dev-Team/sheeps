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

class AddPerformancePage extends StatefulWidget {
  @override
  _AddPerformanceState createState() => _AddPerformanceState();
}

class _AddPerformanceState extends State<AddPerformancePage> {
  TeamProfileManagementController controller = Get.put(TeamProfileManagementController());
  final TextEditingController projectController = TextEditingController();
  final TextEditingController organizationController = TextEditingController();

  String startDate = '';
  String endDate = '';

  var dateStart;
  var dateEnd;

  File? authFile;

  @override
  void dispose() {
    projectController.dispose();
    organizationController.dispose();
    super.dispose();
  }

  bool isOk() {
    bool _isOk = true;
    if (projectController.text.isEmpty) _isOk = false;
    if (organizationController.text.isEmpty) _isOk = false;
    if (startDate.isEmpty || endDate.isEmpty) _isOk = false;
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
                  appBar: SheepsAppBar(context, '수행 내역 추가'),
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
                                  Text('프로젝트명', style: SheepsTextStyle.h3()),
                                  SizedBox(height: 12 * sizeUnit),
                                  multiLineTextField(
                                    controller: projectController,
                                    hintText: 'ex) SHEEPS APP 개발, WEB 디자인 용역',
                                    borderColor: sheepsColorGreen,
                                    isOneLine: true,
                                  ),
                                  SizedBox(height: 20 * sizeUnit),
                                  Text('주관 기관', style: SheepsTextStyle.h3()),
                                  SizedBox(height: 12 * sizeUnit),
                                  multiLineTextField(
                                    controller: organizationController,
                                    hintText: 'ex) 주식회사 쉽스/자체 프로젝트',
                                    borderColor: sheepsColorGreen,
                                    isOneLine: true,
                                  ),
                                  SizedBox(height: 20 * sizeUnit),
                                  Text('기간', style: SheepsTextStyle.h3()),
                                  SizedBox(height: 12 * sizeUnit),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          unFocus(context);
                                          showDatePicker(
                                            context: context,
                                            initialDate: dateEnd != null ? dateEnd : DateTime.now(),
                                            firstDate: DateTime(1960),
                                            lastDate: dateEnd != null ? dateEnd : DateTime.now(),
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
                                                child: child!,
                                              );
                                            },
                                          ).then((value) {
                                            setState(() {
                                              if (value != null) {
                                                dateStart = value;
                                                startDate = value.year.toString() + '.' + value.month.toString();
                                              }
                                            });
                                          });
                                        },
                                        child: pickDateContainer(text: startDate),
                                      ),
                                      SizedBox(width: 14 * sizeUnit),
                                      Container(
                                        width: 8 * sizeUnit,
                                        height: 1 * sizeUnit,
                                        color: startDate.isEmpty || endDate.isEmpty ? sheepsColorGrey : sheepsColorGreen,
                                      ),
                                      SizedBox(width: 14 * sizeUnit),
                                      GestureDetector(
                                        onTap: () {
                                          unFocus(context);
                                          showDatePicker(
                                            context: context,
                                            initialDate: dateStart != null ? dateStart : DateTime.now(),
                                            firstDate: dateStart != null ? dateStart : DateTime(1960),
                                            lastDate: DateTime(DateTime.now().year + 1, 12, 31),
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
                                                child: child!,
                                              );
                                            },
                                          ).then((value) {
                                            setState(() {
                                              if (value != null) {
                                                dateEnd = value;
                                                endDate = value.year.toString() + '.' + value.month.toString();
                                              }
                                            });
                                          });
                                        },
                                        child: pickDateContainer(text: endDate),
                                      ),
                                    ],
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
                                      Text('용역계약서, 프로젝트 협약서, MOU 등', style: SheepsTextStyle.info2()),
                                    ],
                                  ),
                                  SizedBox(height: 12 * sizeUnit),
                                  GestureDetector(
                                    onTap: () {
                                      unFocus(context);
                                      Get.to(() => AuthFileUploadPage(appBarTitle: '수행 내역 증빙 자료', authFile: authFile!))?.then((value) {
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
                                                authFile != null ? authFile!.path.substring(authFile!.path.lastIndexOf('\/') + 1) : '증빙 자료는 1개의 업로드만 가능해요',
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
                              String project = projectController.text;
                              String organization = organizationController.text;

                              String period = startDate + '~' + endDate;

                              String contents = project + ' \/ ' + organization + '||' + period;

                              bool isSameData = false;

                              for(int i = 0; i < controller.performancesList.length; i++){
                                if(contents == controller.performancesList[i].contents){
                                  isSameData = true;
                                  break;
                                }
                              }
                              if(isSameData){
                                showAddFailDialog(title: '수행 내역', okButtonColor: sheepsColorGreen);
                              }else{
                                controller.performancesList.add(TeamPerformances(
                                  id: -1,
                                  contents: contents,
                                  imgUrl: authFile!.path, //우선 파일경로 저장. 이후 수정 완료시 처리. id -1으로 확인
                                  auth: 2,
                                ));
                                Get.back();
                              }
                            }
                          },
                          text: '수행 내역 추가',
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
