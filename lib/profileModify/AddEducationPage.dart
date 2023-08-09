import 'dart:io';

import 'package:flutter/material.dart';
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

class AddEducationPage extends StatefulWidget {
  @override
  _AddEducationState createState() => _AddEducationState();
}

class _AddEducationState extends State<AddEducationPage> {
  PersonalProfileModifyController controller = Get.put(PersonalProfileModifyController());
  final TextEditingController educationController = TextEditingController();
  final TextEditingController majorController = TextEditingController();

  bool isHighSchool = false;
  bool isCollege = false;
  bool isBachelor = false;
  bool isMaster = false;
  bool isDoctor = false;

  bool isGraduated = false;
  bool isAttending = false;
  bool isDropOut = false;

  String startDate = '';
  String endDate = '';

  DateTime? dateStart;
  DateTime? dateEnd;

  File? authFile;

  @override
  void dispose() {
    educationController.dispose();
    majorController.dispose();
    super.dispose();
  }

  bool isOk() {
    bool _isOk = true;
    if (!isHighSchool && !isCollege && !isBachelor && !isMaster && !isDoctor) _isOk = false;
    if (educationController.text.isEmpty) _isOk = false;
    if (majorController.text.isEmpty) _isOk = false;
    if (!isGraduated && !isAttending && !isDropOut) _isOk = false;
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
                  appBar: SheepsAppBar(context, '학력 추가'),
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
                                  Text('학력선택', style: SheepsTextStyle.h3()),
                                  SizedBox(height: 12 * sizeUnit),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (!isHighSchool) {
                                            setState(() {
                                              isHighSchool = true;
                                              isCollege = false;
                                              isBachelor = false;
                                              isMaster = false;
                                              isDoctor = false;
                                            });
                                          }
                                        },
                                        child: chooseEducationContainer('고등학교', isHighSchool),
                                      ),
                                      SizedBox(width: 12 * sizeUnit),
                                      GestureDetector(
                                        onTap: () {
                                          if (!isCollege) {
                                            setState(() {
                                              isHighSchool = false;
                                              isCollege = true;
                                              isBachelor = false;
                                              isMaster = false;
                                              isDoctor = false;
                                            });
                                          }
                                        },
                                        child: chooseEducationContainer('전문대', isCollege),
                                      ),
                                      SizedBox(width: 12 * sizeUnit),
                                      GestureDetector(
                                        onTap: () {
                                          if (!isBachelor) {
                                            setState(() {
                                              isHighSchool = false;
                                              isCollege = false;
                                              isBachelor = true;
                                              isMaster = false;
                                              isDoctor = false;
                                            });
                                          }
                                        },
                                        child: chooseEducationContainer('학사', isBachelor),
                                      ),
                                      SizedBox(width: 12 * sizeUnit),
                                      GestureDetector(
                                        onTap: () {
                                          if (!isMaster) {
                                            setState(() {
                                              isHighSchool = false;
                                              isCollege = false;
                                              isBachelor = false;
                                              isMaster = true;
                                              isDoctor = false;
                                            });
                                          }
                                        },
                                        child: chooseEducationContainer('석사', isMaster),
                                      ),
                                      SizedBox(width: 12 * sizeUnit),
                                      GestureDetector(
                                        onTap: () {
                                          if (!isDoctor) {
                                            setState(() {
                                              isHighSchool = false;
                                              isCollege = false;
                                              isBachelor = false;
                                              isMaster = false;
                                              isDoctor = true;
                                            });
                                          }
                                        },
                                        child: chooseEducationContainer('박사', isDoctor),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20 * sizeUnit),
                                  Text('학력', style: SheepsTextStyle.h3()),
                                  SizedBox(height: 12 * sizeUnit),
                                  multiLineTextField(
                                    controller: educationController,
                                    hintText: 'ex) 대관령 양양 대학교',
                                    borderColor: sheepsColorBlue,
                                    isOneLine: true,
                                  ),
                                  SizedBox(height: 20 * sizeUnit),
                                  Text('전공', style: SheepsTextStyle.h3()),
                                  SizedBox(height: 12 * sizeUnit),
                                  multiLineTextField(
                                    controller: majorController,
                                    hintText: 'ex) 양떼목장학과',
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
                                          if (!isGraduated) {
                                            setState(() {
                                              isGraduated = true;
                                              isAttending = false;
                                              isDropOut = false;
                                              if (endDate == '재학 중') {
                                                endDate = '';
                                              }
                                            });
                                          }
                                        },
                                        child: sheepsCheckBox('졸업', isGraduated, color: sheepsColorBlue),
                                      ),
                                      SizedBox(width: 10 * sizeUnit),
                                      GestureDetector(
                                        onTap: () {
                                          if (!isAttending) {
                                            setState(() {
                                              isGraduated = false;
                                              isAttending = true;
                                              isDropOut = false;
                                              endDate = '재학 중';
                                            });
                                          }
                                        },
                                        child: sheepsCheckBox('재학', isAttending, color: sheepsColorBlue),
                                      ),
                                      SizedBox(width: 10 * sizeUnit),
                                      GestureDetector(
                                        onTap: () {
                                          if (!isDropOut) {
                                            setState(() {
                                              isGraduated = false;
                                              isAttending = false;
                                              isDropOut = true;
                                              if (endDate == '재학 중') {
                                                endDate = '';
                                                dateEnd = null;
                                              }
                                            });
                                          }
                                        },
                                        child: sheepsCheckBox('중퇴', isDropOut, color: sheepsColorBlue),
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
                                              initialDate: dateEnd != null ? dateEnd! : DateTime.now(),
                                              firstDate: DateTime(1960),
                                              lastDate: dateEnd != null ? dateEnd! : DateTime.now(),
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
                                            if (!isAttending) {
                                              //재학이면 종료 날짜 선택 불가
                                              showDatePicker(
                                                context: context,
                                                initialDate: dateStart != null ? dateStart! : DateTime.now(),
                                                firstDate: dateStart != null ? dateStart! : DateTime(1960),
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
                                      Text('재학증명서, 졸업증명서, 졸업예정증명서 등', style: SheepsTextStyle.info2()),
                                    ],
                                  ),
                                  SizedBox(height: 12 * sizeUnit),
                                  GestureDetector(
                                    onTap: () {
                                      unFocus(context);
                                      Get.to(() => AuthFileUploadPage(appBarTitle: '학력 증빙 자료', authFile: authFile))?.then((value) {
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
                              String education = educationController.text;
                              String major = majorController.text;

                              String degree = '';
                              isHighSchool
                                  ? degree = '고등학교'
                                  : isCollege
                                      ? degree = '전문대'
                                      : isBachelor
                                          ? degree = '학사'
                                          : isMaster
                                              ? degree = '석사'
                                              : isDoctor
                                                  ? degree = '박사'
                                                  : degree = '';

                              String state = '';
                              isGraduated
                                  ? state = '졸업'
                                  : isAttending
                                      ? state = '재학'
                                      : isDropOut
                                          ? state = '중퇴'
                                          : state = '';

                              String period = startDate + '~' + endDate;

                              String contents = education + ' \/ ' + major + ' \/ ' + degree + '(' + state + ')' + '||' + period;

                              bool isSameData = false;
                              for (int i = 0; i < controller.educationList.length; i++) {
                                if (contents == controller.educationList[i].contents) {
                                  isSameData = true;
                                  break;
                                }
                              }
                              if (isSameData) {
                                showAddFailDialog(title: '학력', okButtonColor: sheepsColorBlue);
                              } else {
                                controller.educationList.add(UserEducation(
                                  id: -1,
                                  contents: contents,
                                  imgUrl: authFile!.path, //우선 파일경로 저장. 이후 수정 완료시 처리. id -1으로 확인
                                  auth: 2,
                                ));
                                Get.back();
                              }
                            }
                          },
                          text: '학력 추가',
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

  Widget chooseEducationContainer(String text, bool isEducation) {
    return Container(
      height: 32 * sizeUnit,
      decoration: BoxDecoration(
        color: isEducation ? sheepsColorBlue : Colors.white,
        border: Border.all(color: isEducation ? sheepsColorBlue : sheepsColorGrey, width: 1 * sizeUnit),
        borderRadius: BorderRadius.circular(16 * sizeUnit),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit),
            child: Text(
              text,
              style: SheepsTextStyle.hint4Profile().copyWith(color: isEducation ? Colors.white : sheepsColorGrey),
            ),
          ),
        ],
      ),
    );
  }
}
