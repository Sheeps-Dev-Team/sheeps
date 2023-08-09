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
import 'package:sheeps_app/profileModify/models/PersonalProfileModifyController.dart';
import 'package:sheeps_app/userdata/User.dart';

import 'AuthFileUploadPage.dart';

class AddCareerPage extends StatefulWidget {
  @override
  _AddCareerState createState() => _AddCareerState();
}

class _AddCareerState extends State<AddCareerPage> {
  PersonalProfileModifyController controller = Get.put(PersonalProfileModifyController());
  final TextEditingController companyController = TextEditingController();
  final TextEditingController partController = TextEditingController();

  bool isWorking = false;
  bool isLeft = false;

  String startDate = '';
  String endDate = '';

  var dateStart;
  var dateEnd;

  File? authFile;

  @override
  void dispose() {
    companyController.dispose();
    partController.dispose();
    super.dispose();
  }

  bool isOk() {
    bool _isOk = true;
    if (companyController.text.isEmpty) _isOk = false;
    if (partController.text.isEmpty) _isOk = false;
    if (!isWorking && !isLeft) _isOk = false;
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
                  appBar: SheepsAppBar(context, '경력 추가'),
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
                                  Text('기업명', style: SheepsTextStyle.h3()),
                                  SizedBox(height: 12 * sizeUnit),
                                  multiLineTextField(
                                    controller: companyController,
                                    hintText: 'ex) 주식회사 쉽스',
                                    borderColor: sheepsColorBlue,
                                    isOneLine: true,
                                  ),
                                  SizedBox(height: 20 * sizeUnit),
                                  Text('분야', style: SheepsTextStyle.h3()),
                                  SizedBox(height: 12 * sizeUnit),
                                  multiLineTextField(
                                    controller: partController,
                                    hintText: 'ex) CEO, 서버개발, UX/UI 등',
                                    borderColor: sheepsColorBlue,
                                    isOneLine: true,
                                  ),
                                  SizedBox(height: 20 * sizeUnit),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('기간', style: SheepsTextStyle.h3()),
                                      SizedBox(width: 18 * sizeUnit),
                                      GestureDetector(
                                        onTap: () {
                                          if (!isWorking) {
                                            setState(() {
                                              isWorking = true;
                                              isLeft = false;
                                              endDate = '재직 중';
                                            });
                                          }
                                        },
                                        child: sheepsCheckBox('재직', isWorking, color: sheepsColorBlue),
                                      ),
                                      SizedBox(width: 10 * sizeUnit),
                                      GestureDetector(
                                        onTap: () {
                                          if (!isLeft) {
                                            setState(() {
                                              isWorking = false;
                                              isLeft = true;
                                              if (endDate == '재직 중') {
                                                endDate = '';
                                                dateEnd = null;
                                              }
                                            });
                                          }
                                        },
                                        child: sheepsCheckBox('퇴사', isLeft, color: sheepsColorBlue),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12 * sizeUnit),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
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
                                                  child: child ?? const SizedBox.shrink(),
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
                                          child: pickDateContainer(text: startDate, color: sheepsColorBlue),
                                        ),
                                      ),
                                      SizedBox(width: 14 * sizeUnit),
                                      Container(
                                        width: 8 * sizeUnit,
                                        height: 1 * sizeUnit,
                                        color: startDate.isEmpty || endDate.isEmpty ? sheepsColorGrey : sheepsColorBlue,
                                      ),
                                      SizedBox(width: 14 * sizeUnit),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            unFocus(context);
                                            if(!isWorking){//재직중이면 종료일 선택불가
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
                                                    child: child ?? const SizedBox.shrink(),
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
                                            }
                                          },
                                          child: pickDateContainer(text: endDate, color: sheepsColorBlue),
                                        ),
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
                                      Text('4대보험 증명원, 재직증명서 등', style: SheepsTextStyle.info2()),
                                    ],
                                  ),
                                  SizedBox(height: 12 * sizeUnit),
                                  GestureDetector(
                                    onTap: () {
                                      unFocus(context);
                                      Get.to(() => AuthFileUploadPage(appBarTitle: '경력 증빙 자료', authFile: authFile))?.then((value) {
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
                                        border: Border.all(color: authFile != null ? sheepsColorBlue : sheepsColorGrey, width: 1 * sizeUnit),
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
                                                style: SheepsTextStyle.hint4Profile().copyWith(color: authFile != null ? sheepsColorBlue : sheepsColorGrey),
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
                              String company = companyController.text;
                              String part = partController.text;

                              String state = '';
                              if(isWorking){
                                state = ' 재직 중';
                                endDate = DateTime.now().year.toString() + '.' + DateTime.now().month.toString();
                              }

                              List<String> startList = startDate.split('.');
                              List<String> endList = endDate.split('.');
                              int diffYear = int.parse(endList[0]) - int.parse(startList[0]);
                              int diffMonth = int.parse(endList[1]) - int.parse(startList[1]);

                              if(diffMonth < 0){
                                diffYear -= 1;
                                diffMonth = diffMonth + 12;
                              }

                              String diffYearString = diffYear != 0 ? diffYear.toString() + "년" : "";
                              String diffMonthString = diffMonth != 0 ? diffMonth.toString() + "개월" : "";

                              String workingPeriod = diffYearString + diffMonthString;

                              String period = startDate + '~' + endDate;

                              String contents = company + ' \/ ' + part + '(' + workingPeriod + state + ')' + '||' + period;

                              bool isSameData = false;
                              for(int i = 0; i < controller.careerList.length; i++){
                                if(contents == controller.careerList[i].contents){
                                  isSameData = true;
                                  break;
                                }
                              }
                              if(isSameData){
                                showAddFailDialog(title: '경력', okButtonColor: sheepsColorBlue);
                              }else{
                                controller.careerList.add(UserCareer(
                                  id: -1,
                                  contents: contents,
                                  imgUrl: authFile!.path, //우선 파일경로 저장. 이후 수정 완료시 처리. id -1으로 확인
                                  auth: 2,
                                ));
                                Get.back();
                              }
                            }
                          },
                          text: '경력 추가',
                          color: sheepsColorBlue,
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
