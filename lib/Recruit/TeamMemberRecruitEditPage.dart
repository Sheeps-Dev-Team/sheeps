import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:get/get.dart';
import 'package:sheeps_app/Recruit/SpecificUserRecruitPage.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/LoadingUI.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/profileModify/SelectField.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'Models/TeamMemberRecruit.dart';
import 'Controller/TeamMemberRecruitEditController.dart';
import 'RecruitDetailPage.dart';

class TeamMemberRecruitEditPage extends StatefulWidget {
  final Team team;
  final TeamMemberRecruit teamMemberRecruit;
  final bool isMyPageRecruit;

  const TeamMemberRecruitEditPage({Key key, @required this.team, this.teamMemberRecruit, this.isMyPageRecruit = false}) : super(key: key);

  @override
  _TeamMemberRecruitEditPageState createState() => _TeamMemberRecruitEditPageState();
}

class _TeamMemberRecruitEditPageState extends State<TeamMemberRecruitEditPage> {
  TeamMemberRecruitEditController controller = Get.put(TeamMemberRecruitEditController());

  PageController pageController = PageController();
  TextEditingController titleController = TextEditingController();
  TextEditingController infoController = TextEditingController();
  TextEditingController roleContentsController = TextEditingController();
  TextEditingController detailEligibilityController = TextEditingController();
  TextEditingController detailPreferenceInfoContentsController = TextEditingController();
  TextEditingController needWorkConditionController = TextEditingController();

  bool isReady = true;
  bool isEdit = false;

  bool isCanRecruit = true;

  @override
  void initState() {
    super.initState();
    if (widget.teamMemberRecruit != null) {
      isEdit = true;
      controller.editLoading(widget.teamMemberRecruit);
      titleController.text = controller.title.value;
      infoController.text = controller.recruitInfo.value;
      roleContentsController.text = controller.roleContents.value;
      detailEligibilityController.text = controller.detailEligibility.value;
      detailPreferenceInfoContentsController.text = controller.detailPreferenceInfoContents.value;
      needWorkConditionController.text = controller.detailWorkCondition.value;
    }

    checkCanRecruit();
  }

  @override
  void dispose() {
    pageController.dispose();
    titleController.dispose();
    infoController.dispose();
    roleContentsController.dispose();
    detailEligibilityController.dispose();
    detailPreferenceInfoContentsController.dispose();
    needWorkConditionController.dispose();
    super.dispose();
  }

  void backFunc() {
    switch (controller.barIndex.value) {
      case 0:
        {
          showEditCancelDialog(okButtonColor: sheepsColorBlue);
          break;
        }
      case 1:
        {
          controller.barIndex.value = 0;
          pageController.previousPage(duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
          break;
        }
      case 2:
        {
          controller.barIndex.value = 1;
          pageController.previousPage(duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
          break;
        }
    }
  }

  void checkCanRecruit() async {
    int countRecruit = 0;

    List<TeamMemberRecruit> recruitList = [];

    var res = await ApiProvider().post(
        '/Matching/Select/TeamMemberRecruitByTeamID',
        jsonEncode({
          'teamID': widget.team.id,
        }));

    if (res != null) {
      for (int i = 0; i < res.length; i++) {
        TeamMemberRecruit tmpRecruit = TeamMemberRecruit.fromJson(res[i]);
        recruitList.add(tmpRecruit);
      }
    }

    recruitList.forEach((e) {
      if (widget.teamMemberRecruit != null) {
        if (e.id != widget.teamMemberRecruit.id) if (setPeriodState(e.recruitPeriodEnd) != '모집마감') countRecruit++;
      } else {
        if (setPeriodState(e.recruitPeriodEnd) != '모집마감') countRecruit++;
      }
    });

    if (countRecruit < RECRUIT_LIMIT_TEAM) return;

    isCanRecruit = false;
    return;
  }

  void showCannotRecruitDialog(){
    showSheepsDialog(
      context: context,
      title: '이미 모집중인 글이\n$RECRUIT_LIMIT_TEAM개나 있어요!',
      description: '현재 원활한 서비스 운영 및 매칭을 위해\n최대 $RECRUIT_LIMIT_TEAM개까지 모집중 상태가 가능해요.',
      isCancelButton: false,
    );
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
                onWillPop: () {
                  backFunc();
                  return Future.value(false);
                },
                child: Scaffold(
                  appBar: SheepsAppBar(context, '팀원 모집하는 글쓰기', backFunc: () {
                    showEditCancelDialog(okButtonColor: sheepsColorBlue);
                  }),
                  body: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16 * sizeUnit),
                        child: Obx(() {
                          return SheepsAnimatedTabBar(
                            barIndex: controller.barIndex.value,
                            pageController: pageController,
                            insidePadding: 20 * sizeUnit,
                            listTabItemTitle: ['모집정보', '지원자격', '근무조건'],
                            listTabItemWidth: [60 * sizeUnit, 60 * sizeUnit, 60 * sizeUnit],
                          );
                        }),
                      ),
                      Container(width: 360 * sizeUnit, height: 0.5 * sizeUnit, color: sheepsColorGrey),
                      Expanded(
                        child: PageView(
                          controller: pageController,
                          physics: NeverScrollableScrollPhysics(),
                          onPageChanged: (index) {
                            controller.setBarIndex(index);
                          },
                          children: [
                            recruitInfoPage(),
                            eligibilityPage(),
                            workConditionsPage(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20 * sizeUnit),
                        child: Obx(() {
                          return SheepsBottomButton(
                            context: context,
                            function: () {
                              unFocus(context);
                              switch (controller.getBarIndex()) {
                                case 0:
                                  {
                                    controller.setBarIndex(1);
                                    pageController.animateToPage(controller.getBarIndex(), duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
                                  }
                                  break;
                                case 1:
                                  {
                                    controller.setBarIndex(2);
                                    pageController.animateToPage(controller.getBarIndex(), duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
                                  }
                                  break;
                                case 2:
                                  {
                                    if (controller.checkFilledRequiredInfo()) {
                                      if (controller.checkFilledDetailQualification()) {
                                        showSheepsCustomDialog(
                                            title: Text(
                                              '상세 자격을 입력하지\n않았어요 😢',
                                              style: SheepsTextStyle.h5(),
                                              textAlign: TextAlign.center,
                                            ),
                                            contents: Text.rich(
                                              TextSpan(
                                                text: '상세 자격을 입력하시면,\n팀원 모집 확률이 ',
                                                children: [
                                                  TextSpan(
                                                    text: '6배 이상 높아요!',
                                                    style: SheepsTextStyle.h4(),
                                                  ),
                                                ],
                                              ),
                                              style: SheepsTextStyle.b3(),
                                              textAlign: TextAlign.center,
                                            ),
                                            okText: '입력하기',
                                            okFunc: () {
                                              controller.setBarIndex(1);
                                              pageController.animateToPage(controller.getBarIndex(), duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
                                              Get.back();
                                            },
                                            isCancelButton: true,
                                            cancelText: '넘어가기',
                                            cancelFunc: () {
                                              if (isReady) {
                                                isReady = false;
                                                Future.microtask(() => Future.delayed(
                                                      Duration(milliseconds: 500),
                                                      () {
                                                        isReady = true;
                                                      },
                                                    ));
                                                upload();
                                              }
                                            });
                                      } else {
                                        if (isReady) {
                                          isReady = false;
                                          Future.microtask(() => Future.delayed(
                                                Duration(milliseconds: 500),
                                                () {
                                                  isReady = true;
                                                },
                                              ));
                                          upload();
                                        }
                                      }
                                    } else {
                                      showSheepsCustomDialog(
                                          title: Text.rich(
                                            TextSpan(
                                              text: '필수 정보',
                                              children: [
                                                TextSpan(
                                                  text: '*',
                                                  style: TextStyle(color: sheepsColorGreen),
                                                ),
                                                TextSpan(text: ' 를\n입력해주세요!')
                                              ],
                                            ),
                                            style: SheepsTextStyle.h5(),
                                            textAlign: TextAlign.center,
                                          ),
                                          contents: Text.rich(
                                            TextSpan(
                                              text: '',
                                              children: [
                                                TextSpan(
                                                  text: '*',
                                                  style: TextStyle(color: sheepsColorGreen),
                                                ),
                                                TextSpan(text: '가 붙어있는 입력칸은\n필수로 채워주셔야 합니다!')
                                              ],
                                            ),
                                            style: SheepsTextStyle.b3(),
                                            textAlign: TextAlign.center,
                                          ),
                                          okFunc: () {
                                            if (!controller.checkActiveNext1()) {
                                              controller.setBarIndex(0);
                                              pageController.animateToPage(controller.getBarIndex(), duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
                                            } else if (!controller.checkActiveNext2()) {
                                              controller.setBarIndex(1);
                                              pageController.animateToPage(controller.getBarIndex(), duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
                                            }
                                            Get.back();
                                          });
                                    }
                                  }
                                  break;
                              }
                            },
                            text: controller.getBarIndex() == 2 ? '구직 시작!' : '다음',
                            isOK: controller.barIndex.value == 0
                                ? controller.checkActiveNext1()
                                : controller.barIndex.value == 1
                                    ? controller.checkActiveNext2()
                                    : controller.checkFilledRequiredInfo(),
                            color: sheepsColorGreen,
                          );
                        }),
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

  Widget recruitInfoPage() {
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [SizedBox(height: 20 * sizeUnit)]), //가로길이 채우기용 Row
              Text.rich(
                TextSpan(
                  text: '모집 제목',
                  children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorGreen))],
                ),
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(height: 4 * sizeUnit),
              Obx(() => sheepsTextField(
                  context,
                  controller: titleController,
                  hintText: '모집 제목 입력',
                  errorText: removeSpace(controller.title.value).length > 42 ? '제목은 42자 이하로 입력해주세요.' : null,
                  onChanged: (val) {
                    controller.title.value = val;
                    controller.checkActiveNext1();
                    controller.checkFilledRequiredInfo();
                  },
                  onPressClear: () {
                    titleController.clear();
                    controller.title.value = '';
                    controller.checkActiveNext1();
                    controller.checkFilledRequiredInfo();
                  },
                  borderColor: sheepsColorGreen,
                ),
              ),
              SizedBox(height: 20 * sizeUnit),
              Row(
                children: [
                  Text.rich(
                    TextSpan(
                      text: '모집기간',
                      children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorGreen))],
                    ),
                    style: SheepsTextStyle.h3(),
                  ),
                  SizedBox(width: 18 * sizeUnit),
                  GestureDetector(
                    onTap: () {
                      //모집중 리쿠르트 글 갯수 제한
                      if(isCanRecruit){
                        controller.isAlwaysRecruit.value = !controller.isAlwaysRecruit.value;
                        if (controller.isAlwaysRecruit.value) {
                          controller.recruitPeriodEnd.value = '상시모집';
                        } else {
                          controller.recruitPeriodEnd.value = '';
                        }
                        controller.checkActiveNext1();
                        controller.checkFilledRequiredInfo();
                      }else{
                        showCannotRecruitDialog();
                      }
                    },
                    child: Obx(() => sheepsCheckBox('상시모집', controller.isAlwaysRecruit.value)),
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
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now(),
                          helpText: '날짜 선택',
                          cancelText: '취소',
                          confirmText: '확인',
                          locale: const Locale('ko', 'KR'),
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
                          if (value != null) {
                            controller.recruitPeriodStart.value = value.year.toString() + '년 ';

                            if (value.month < 10) {
                              controller.recruitPeriodStart.value = controller.recruitPeriodStart.value + '0' + value.month.toString() + '월 ';
                            } else {
                              controller.recruitPeriodStart.value = controller.recruitPeriodStart.value + value.month.toString() + '월 ';
                            }

                            if (value.day < 10) {
                              controller.recruitPeriodStart.value = controller.recruitPeriodStart.value + '0' + value.day.toString() + '일';
                            } else {
                              controller.recruitPeriodStart.value = controller.recruitPeriodStart.value + value.day.toString() + '일';
                            }
                          }
                          if (controller.recruitPeriodStart.value.compareTo(controller.recruitPeriodEnd.value) == 1) controller.recruitPeriodEnd.value = '';
                          controller.checkActiveNext1();
                          controller.checkFilledRequiredInfo();
                        });
                      },
                      child: Obx(() => pickDateContainer(text: controller.recruitPeriodStart.value, isNeedDay: true)),
                    ),
                  ),
                  SizedBox(width: 14 * sizeUnit),
                  Container(
                    width: 8 * sizeUnit,
                    height: 1 * sizeUnit,
                    color: controller.recruitPeriodStart.value.isEmpty || controller.recruitPeriodEnd.value.isEmpty ? sheepsColorGrey : sheepsColorGreen,
                  ),
                  SizedBox(width: 14 * sizeUnit),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        unFocus(context);

                        //모집중 리쿠르트 글 갯수 제한
                        if(isCanRecruit){
                          if (!controller.isAlwaysRecruit.value) {
                            //상시모집이면 날짜 선택 불가
                            showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(DateTime.now().year + 1, 12, 31),
                              helpText: '날짜 선택',
                              cancelText: '취소',
                              confirmText: '확인',
                              locale: const Locale('ko', 'KR'),
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
                              if (value != null) {
                                controller.recruitPeriodEnd.value = value.year.toString() + '년 ';

                                if (value.month < 10) {
                                  controller.recruitPeriodEnd.value = controller.recruitPeriodEnd.value + '0' + value.month.toString() + '월 ';
                                } else {
                                  controller.recruitPeriodEnd.value = controller.recruitPeriodEnd.value + value.month.toString() + '월 ';
                                }

                                if (value.day < 10) {
                                  controller.recruitPeriodEnd.value = controller.recruitPeriodEnd.value + '0' + value.day.toString() + '일';
                                } else {
                                  controller.recruitPeriodEnd.value = controller.recruitPeriodEnd.value + value.day.toString() + '일';
                                }
                              }
                              controller.checkActiveNext1();
                              controller.checkFilledRequiredInfo();
                            });
                          }
                        }else{
                          showCannotRecruitDialog();
                        }
                      },
                      child: Obx(() => pickDateContainer(text: controller.recruitPeriodEnd.value, isNeedDay: true)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20 * sizeUnit),
              Text.rich(
                TextSpan(
                  text: '모집 소개',
                  children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorGreen))],
                ),
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(height: 12 * sizeUnit),
              multiLineTextField(
                controller: infoController,
                maxTextLength: 250,
                hintText: '팀・스타트업 소개 및 모집개요 등 입력',
                borderColor: sheepsColorGreen,
                onChange: (val) {
                  controller.recruitInfo.value = val;
                  controller.checkActiveNext1();
                  controller.checkFilledRequiredInfo();
                },
              ),
              SizedBox(height: 8 * sizeUnit),
              GestureDetector(
                onTap: () {
                  if (widget.team.information != null) {
                    infoController.text = widget.team.information;
                    controller.recruitInfo.value = widget.team.information;
                  }
                },
                child: Container(
                  height: 32 * sizeUnit,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: sheepsColorGreen, width: 1 * sizeUnit),
                    borderRadius: BorderRadius.circular(16 * sizeUnit),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit),
                        child: Text(
                          '프로필 소개글 불러오기',
                          style: SheepsTextStyle.hint4Profile().copyWith(color: sheepsColorGreen),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20 * sizeUnit),
              Text.rich(
                TextSpan(
                  text: '카테고리',
                  children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorGreen))],
                ),
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(height: 12 * sizeUnit),
              Wrap(
                spacing: 10 * sizeUnit,
                runSpacing: 10 * sizeUnit,
                children: [
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isCategoryStartup.value = true;
                      controller.isCategorySupport.value = false;
                      controller.isCategoryCompetition.value = false;
                      controller.isCategorySmallClass.value = false;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '팀・스타트업', isSelected: controller.isCategoryStartup.value, color: sheepsColorGreen);
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isCategoryStartup.value = false;
                      controller.isCategorySupport.value = true;
                      controller.isCategoryCompetition.value = false;
                      controller.isCategorySmallClass.value = false;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '지원사업', isSelected: controller.isCategorySupport.value, color: sheepsColorGreen);
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isCategoryStartup.value = false;
                      controller.isCategorySupport.value = false;
                      controller.isCategoryCompetition.value = true;
                      controller.isCategorySmallClass.value = false;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '공모전', isSelected: controller.isCategoryCompetition.value, color: sheepsColorGreen);
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isCategoryStartup.value = false;
                      controller.isCategorySupport.value = false;
                      controller.isCategoryCompetition.value = false;
                      controller.isCategorySmallClass.value = true;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '소모임', isSelected: controller.isCategorySmallClass.value, color: sheepsColorGreen);
                    }),
                  ),
                ],
              ),
              SizedBox(height: 20 * sizeUnit),
              Text.rich(
                TextSpan(
                  text: '모집분야',
                  children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorGreen))],
                ),
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(height: 12 * sizeUnit),
              GestureDetector(
                onTap: () {
                  Get.to(() => SelectField()).then((value) {
                    if (value != null) {
                      controller.recruitJob = value[0];
                      controller.recruitPart.value = value[1];
                      controller.checkActiveNext1();
                      controller.checkFilledRequiredInfo();
                    }
                  });
                },
                child: Obx(() {
                  return sheepsSelectContainer(
                    text: controller.recruitPart.value.isEmpty ? '분야 선택' : controller.recruitPart.value,
                    isSelected: controller.recruitPart.value.isNotEmpty,
                    color: sheepsColorGreen,
                  );
                }),
              ),
              SizedBox(height: 20 * sizeUnit),
              Text.rich(
                TextSpan(
                  text: '역할',
                  children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorGreen))],
                ),
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(height: 12 * sizeUnit),
              multiLineTextField(
                controller: roleContentsController,
                maxTextLength: 250,
                hintText: '역할 입력',
                borderColor: sheepsColorGreen,
                onChange: (val) {
                  controller.roleContents.value = val;
                  controller.checkActiveNext1();
                  controller.checkFilledRequiredInfo();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget eligibilityPage() {
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20 * sizeUnit),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(
                    TextSpan(
                      text: '학력',
                      children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorGreen))],
                    ),
                    style: SheepsTextStyle.h3(),
                  ),
                  SizedBox(width: 8 * sizeUnit),
                  Text('1개 선택', style: SheepsTextStyle.info2()),
                ],
              ),
              SizedBox(height: 12 * sizeUnit),
              Wrap(
                spacing: 10 * sizeUnit,
                runSpacing: 10 * sizeUnit,
                children: [
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isEduAny.value = true;
                      controller.isEduHighSchool.value = false;
                      controller.isEduCollege.value = false;
                      controller.isEduBachelor.value = false;
                      controller.isEduMaster.value = false;
                      controller.isEduDoctor.value = false;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '학력무관', isSelected: controller.isEduAny.value, color: sheepsColorGreen);
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isEduAny.value = false;
                      controller.isEduHighSchool.value = true;
                      controller.isEduCollege.value = false;
                      controller.isEduBachelor.value = false;
                      controller.isEduMaster.value = false;
                      controller.isEduDoctor.value = false;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '고졸이상', isSelected: controller.isEduHighSchool.value, color: sheepsColorGreen);
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isEduAny.value = false;
                      controller.isEduHighSchool.value = false;
                      controller.isEduCollege.value = true;
                      controller.isEduBachelor.value = false;
                      controller.isEduMaster.value = false;
                      controller.isEduDoctor.value = false;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '초대졸이상', isSelected: controller.isEduCollege.value, color: sheepsColorGreen);
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isEduAny.value = false;
                      controller.isEduHighSchool.value = false;
                      controller.isEduCollege.value = false;
                      controller.isEduBachelor.value = true;
                      controller.isEduMaster.value = false;
                      controller.isEduDoctor.value = false;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '대졸이상', isSelected: controller.isEduBachelor.value, color: sheepsColorGreen);
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isEduAny.value = false;
                      controller.isEduHighSchool.value = false;
                      controller.isEduCollege.value = false;
                      controller.isEduBachelor.value = false;
                      controller.isEduMaster.value = true;
                      controller.isEduDoctor.value = false;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '석사이상', isSelected: controller.isEduMaster.value, color: sheepsColorGreen);
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isEduAny.value = false;
                      controller.isEduHighSchool.value = false;
                      controller.isEduCollege.value = false;
                      controller.isEduBachelor.value = false;
                      controller.isEduMaster.value = false;
                      controller.isEduDoctor.value = true;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '박사졸업', isSelected: controller.isEduDoctor.value, color: sheepsColorGreen);
                    }),
                  ),
                ],
              ),
              SizedBox(height: 20 * sizeUnit),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(
                    TextSpan(
                      text: '경력',
                      children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorGreen))],
                    ),
                    style: SheepsTextStyle.h3(),
                  ),
                  SizedBox(width: 8 * sizeUnit),
                  Text('1개 선택', style: SheepsTextStyle.info2()),
                ],
              ),
              SizedBox(height: 12 * sizeUnit),
              Wrap(
                spacing: 10 * sizeUnit,
                runSpacing: 10 * sizeUnit,
                children: [
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isCareerNew.value = true;
                      controller.isCareerCareer.value = false;
                      controller.isCareerAny.value = false;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '신입', isSelected: controller.isCareerNew.value, color: sheepsColorGreen);
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isCareerNew.value = false;
                      controller.isCareerCareer.value = true;
                      controller.isCareerAny.value = false;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '경력', isSelected: controller.isCareerCareer.value, color: sheepsColorGreen);
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isCareerNew.value = false;
                      controller.isCareerCareer.value = false;
                      controller.isCareerAny.value = true;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '경력무관', isSelected: controller.isCareerAny.value, color: sheepsColorGreen);
                    }),
                  ),
                ],
              ),
              SizedBox(height: 20 * sizeUnit),
              Text.rich(
                TextSpan(
                  text: '상세 지원자격',
                ),
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(height: 12 * sizeUnit),
              multiLineTextField(
                controller: detailEligibilityController,
                maxTextLength: 200,
                hintText: '자격 요건 입력',
                borderColor: sheepsColorGreen,
                onChange: (val) {
                  controller.detailEligibility.value = val;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(
                    TextSpan(
                      text: '우대사항',
                    ),
                    style: SheepsTextStyle.h3(),
                  ),
                  SizedBox(width: 8 * sizeUnit),
                  Text('중복 선택 가능', style: SheepsTextStyle.info2()),
                ],
              ),
              SizedBox(height: 12 * sizeUnit),
              multipleSelectionWrap(
                inputList: ['관련 전공', '관련 자격증', '인근거주', '수상경력', '영어가능', '중국어 가능', '문서작성 우수'],
                selectedList: controller.preferenceInfoList,
                maxSelect: 7,
                isCanSelectAll: true,
              ),
              SizedBox(height: 20 * sizeUnit),
              Text.rich(
                TextSpan(
                  text: '상세 우대사항',
                ),
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(height: 12 * sizeUnit),
              multiLineTextField(
                controller: detailPreferenceInfoContentsController,
                maxTextLength: 200,
                hintText: '우대 요건 입력',
                borderColor: sheepsColorGreen,
                onChange: (val) {
                  controller.detailPreferenceInfoContents.value = val;
                },
              ),
              SizedBox(height: 20 * sizeUnit),
            ],
          ),
        ),
      ],
    );
  }

  Widget workConditionsPage() {
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20 * sizeUnit),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(
                    TextSpan(
                      text: '근무형태',
                      children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorGreen))],
                    ),
                    style: SheepsTextStyle.h3(),
                  ),
                  SizedBox(width: 8 * sizeUnit),
                  Text('최대 2개 선택', style: SheepsTextStyle.info2()),
                ],
              ),
              SizedBox(height: 12 * sizeUnit),
              multipleSelectionWrap(
                inputList: ['공동창업', '팀원', '정규직', '계약직', '인턴', '프리랜서', '재택근무', '아르바이트', '협의'],
                selectedList: controller.workFormList,
                maxSelect: 2,
              ),
              SizedBox(height: 20 * sizeUnit),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(
                    TextSpan(
                      text: '근무요일',
                      children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorGreen))],
                    ),
                    style: SheepsTextStyle.h3(),
                  ),
                  SizedBox(width: 8 * sizeUnit),
                  Text('1개 선택', style: SheepsTextStyle.info2()),
                ],
              ),
              SizedBox(height: 12 * sizeUnit),
              Wrap(
                spacing: 10 * sizeUnit,
                runSpacing: 10 * sizeUnit,
                children: [
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isWorkDayOfWeek5.value = true;
                      controller.isWorkDayOfWeek6.value = false;
                      controller.isWorkDayOfWeek3.value = false;
                      controller.isWorkDayOfWeekFlexible.value = false;
                      controller.isWorkDayOfWeekNegotiable.value = false;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '주 5일', isSelected: controller.isWorkDayOfWeek5.value, color: sheepsColorGreen);
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isWorkDayOfWeek5.value = false;
                      controller.isWorkDayOfWeek6.value = true;
                      controller.isWorkDayOfWeek3.value = false;
                      controller.isWorkDayOfWeekFlexible.value = false;
                      controller.isWorkDayOfWeekNegotiable.value = false;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '주 6일', isSelected: controller.isWorkDayOfWeek6.value, color: sheepsColorGreen);
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isWorkDayOfWeek5.value = false;
                      controller.isWorkDayOfWeek6.value = false;
                      controller.isWorkDayOfWeek3.value = true;
                      controller.isWorkDayOfWeekFlexible.value = false;
                      controller.isWorkDayOfWeekNegotiable.value = false;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '주 3일', isSelected: controller.isWorkDayOfWeek3.value, color: sheepsColorGreen);
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isWorkDayOfWeek5.value = false;
                      controller.isWorkDayOfWeek6.value = false;
                      controller.isWorkDayOfWeek3.value = false;
                      controller.isWorkDayOfWeekFlexible.value = true;
                      controller.isWorkDayOfWeekNegotiable.value = false;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '탄력근무제', isSelected: controller.isWorkDayOfWeekFlexible.value, color: sheepsColorGreen);
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isWorkDayOfWeek5.value = false;
                      controller.isWorkDayOfWeek6.value = false;
                      controller.isWorkDayOfWeek3.value = false;
                      controller.isWorkDayOfWeekFlexible.value = false;
                      controller.isWorkDayOfWeekNegotiable.value = true;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '협의', isSelected: controller.isWorkDayOfWeekNegotiable.value, color: sheepsColorGreen);
                    }),
                  ),
                ],
              ),
              SizedBox(height: 20 * sizeUnit),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(
                    TextSpan(
                      text: '근무시간',
                      children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorGreen))],
                    ),
                    style: SheepsTextStyle.h3(),
                  ),
                  SizedBox(width: 8 * sizeUnit),
                  Text('1개 선택', style: SheepsTextStyle.info2()),
                ],
              ),
              SizedBox(height: 12 * sizeUnit),
              Wrap(
                spacing: 10 * sizeUnit,
                runSpacing: 10 * sizeUnit,
                children: [
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isWorkTime8.value = true;
                      controller.isWorkTimeFlexible.value = false;
                      controller.isWorkTimeAutonomous.value = false;
                      controller.isWorkTimeNegotiable.value = false;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '1일 8시간', isSelected: controller.isWorkTime8.value, color: sheepsColorGreen);
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isWorkTime8.value = false;
                      controller.isWorkTimeFlexible.value = true;
                      controller.isWorkTimeAutonomous.value = false;
                      controller.isWorkTimeNegotiable.value = false;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '탄력근무', isSelected: controller.isWorkTimeFlexible.value, color: sheepsColorGreen);
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isWorkTime8.value = false;
                      controller.isWorkTimeFlexible.value = false;
                      controller.isWorkTimeAutonomous.value = true;
                      controller.isWorkTimeNegotiable.value = false;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '자율', isSelected: controller.isWorkTimeAutonomous.value, color: sheepsColorGreen);
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isWorkTime8.value = false;
                      controller.isWorkTimeFlexible.value = false;
                      controller.isWorkTimeAutonomous.value = false;
                      controller.isWorkTimeNegotiable.value = true;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '협의', isSelected: controller.isWorkTimeNegotiable.value, color: sheepsColorGreen);
                    }),
                  ),
                ],
              ),
              SizedBox(height: 20 * sizeUnit),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(
                    TextSpan(
                      text: '복리후생',
                    ),
                    style: SheepsTextStyle.h3(),
                  ),
                  SizedBox(width: 8 * sizeUnit),
                  Text('중복 선택 가능', style: SheepsTextStyle.info2()),
                ],
              ),
              SizedBox(height: 12 * sizeUnit),
              multipleSelectionWrap(
                inputList: ['상여금', '스톡옵션', '4대보험', '연차', '닉네임', '채움공제', '업무장비 제공', '휴게실', '칼퇴근'],
                selectedList: controller.welfareList,
                maxSelect: 9,
                isCanSelectAll: true,
              ),
              SizedBox(height: 20 * sizeUnit),
              Text.rich(
                TextSpan(
                  text: '상세 근무조건',
                ),
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(height: 12 * sizeUnit),
              multiLineTextField(
                controller: needWorkConditionController,
                maxTextLength: 250,
                hintText: '상세 근무조건 입력',
                borderColor: sheepsColorGreen,
                onChange: (val) {
                  controller.detailWorkCondition.value = val;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future upload() async {
    Future.microtask(() async {
      String category = '';
      if (controller.isCategoryStartup.value) {
        category = '팀・스타트업';
      } else if (controller.isCategorySupport.value) {
        category = '지원사업';
      } else if (controller.isCategoryCompetition.value) {
        category = '공모전';
      } else if (controller.isCategorySmallClass.value) {
        category = '소모임';
      }

      String education = '';
      if (controller.isEduAny.value) {
        education = '학력무관';
      } else if (controller.isEduHighSchool.value) {
        education = '고졸이상';
      } else if (controller.isEduCollege.value) {
        education = '초대졸이상';
      } else if (controller.isEduBachelor.value) {
        education = '대졸이상';
      } else if (controller.isEduMaster.value) {
        education = '석사이상';
      } else if (controller.isEduDoctor.value) {
        education = '박사졸업';
      }

      String career = '';
      if (controller.isCareerNew.value) {
        career = '신입';
      } else if (controller.isCareerCareer.value) {
        career = '경력';
      } else if (controller.isCareerAny.value) {
        career = '경력무관';
      }

      String preferenceInfo = '';
      for (int i = 0; i < controller.preferenceInfoList.length; i++) {
        if (i == 0) {
          preferenceInfo = controller.preferenceInfoList[i];
        } else {
          preferenceInfo = preferenceInfo + ' | ' + controller.preferenceInfoList[i];
        }
      }

      String workDayOfWeek = '';
      if (controller.isWorkDayOfWeek5.value) {
        workDayOfWeek = '주 5일';
      } else if (controller.isWorkDayOfWeek6.value) {
        workDayOfWeek = '주 6일';
      } else if (controller.isWorkDayOfWeek3.value) {
        workDayOfWeek = '주 3일';
      } else if (controller.isWorkDayOfWeekFlexible.value) {
        workDayOfWeek = '탄력근무제';
      } else if (controller.isWorkDayOfWeekNegotiable.value) {
        workDayOfWeek = '협의';
      }

      String workTime = '';
      if (controller.isWorkTime8.value) {
        workTime = '1일 8시간';
      } else if (controller.isWorkTimeFlexible.value) {
        workTime = '탄력근무';
      } else if (controller.isWorkTimeAutonomous.value) {
        workTime = '자율';
      } else if (controller.isWorkTimeNegotiable.value) {
        workTime = '협의';
      }

      String welfare = '';
      for (int i = 0; i < controller.welfareList.length; i++) {
        if (i == 0) {
          welfare = controller.welfareList[i];
        } else {
          welfare = welfare + ' | ' + controller.welfareList[i];
        }
      }

      if (isEdit) {
        DialogBuilder(context).showLoadingIndicator();

        await ApiProvider().post(
            '/Matching/Update/TeamMemberRecruit',
            jsonEncode({
              'id': widget.teamMemberRecruit.id,
              'teamID': widget.teamMemberRecruit.teamId,
              'title': controller.title.value + '||' + widget.team.name,
              'recruitPeriodStart': controller.recruitPeriodStart.value.replaceAll('년 ', '').replaceAll('월 ', '').replaceAll('일', '') + '000000',
              'recruitPeriodEnd': controller.recruitPeriodEnd.value == '상시모집' ? '상시모집' : controller.recruitPeriodEnd.value.replaceAll('년 ', '').replaceAll('월 ', '').replaceAll('일', '') + '235959',
              'recruitInfo': controlSpace(controller.recruitInfo.value),
              'category': category,
              'servicePart': widget.team.part,
              'location': widget.team.location,
              'subLocation': widget.team.subLocation,
              'recruitField': controller.recruitJob,
              'recruitSubField': controller.recruitPart.value,
              'roleContents': controlSpace(controller.roleContents.value),
              'education': education,
              'career': career,
              'detailVolunteerQualification': controller.detailEligibility.value,
              'preferenceInfo': preferenceInfo,
              'detailPreferenceInfoContents': controlSpace(controller.detailPreferenceInfoContents.value),
              'workFormFirst': controller.workFormList[0],
              'workFormSecond': controller.workFormList.length > 1 ? controller.workFormList[1] : '',
              'workDayOfWeek': workDayOfWeek,
              'workTime': workTime,
              'welfare': welfare,
              'detailWorkCondition': controlSpace(controller.detailWorkCondition.value),
            }));

        TeamMemberRecruit modifiedTeamMemberRecruit = TeamMemberRecruit(
          id: widget.teamMemberRecruit.id,
          teamId: widget.teamMemberRecruit.teamId,
          title: controller.title.value + '||' + widget.team.name,
          recruitPeriodStart: controller.recruitPeriodStart.value.replaceAll('년 ', '').replaceAll('월 ', '').replaceAll('일', '') + '000000',
          recruitPeriodEnd: controller.recruitPeriodEnd.value == '상시모집' ? '상시모집' : controller.recruitPeriodEnd.value.replaceAll('년 ', '').replaceAll('월 ', '').replaceAll('일', '') + '235959',
          recruitInfo: controlSpace(controller.recruitInfo.value),
          category: category,
          servicePart: widget.team.part,
          location: widget.team.location,
          subLocation: widget.team.subLocation,
          recruitField: controller.recruitJob,
          recruitSubField: controller.recruitPart.value,
          roleContents: controlSpace(controller.roleContents.value),
          education: education,
          career: career,
          detailVolunteerQualification: controller.detailEligibility.value,
          preferenceInfo: preferenceInfo,
          detailPreferenceInfoContents: controlSpace(controller.detailPreferenceInfoContents.value),
          workFormFirst: controller.workFormList[0],
          workFormSecond: controller.workFormList.length > 1 ? controller.workFormList[1] : '',
          workDayOfWeek: workDayOfWeek,
          workTime: workTime,
          welfare: welfare,
          detailWorkCondition: controlSpace(controller.detailWorkCondition.value),
          createdAt: getYearMonthDayByDate(),
          updateAt: getYearMonthDayByDate(),
        );

        for (int i = 0; i < globalTeamMemberRecruitList.length; i++) {
          if (globalTeamMemberRecruitList[i].id == modifiedTeamMemberRecruit.id) {
            globalTeamMemberRecruitList[i] = modifiedTeamMemberRecruit;
            break;
          }
        }

        DialogBuilder(context).hideOpenDialog();

        showSheepsDialog(
          context: context,
          title: '모집글이\n수정되었어요 😄',
          description: '제안이 오면, 면접 채팅방이 생겨요!\n충분히 대화 후 결정해주세요.',
          okText: '게시글 확인하기',
          isCancelButton: false,
          isBarrierDismissible: false,
        ).then((val) {
          Get.back(result: [modifiedTeamMemberRecruit]);
          Get.back();
        });
      } else {
        DialogBuilder(context).showLoadingIndicator("");

        var res = await ApiProvider().post(
            '/Matching/Insert/TeamMemberRecruit',
            jsonEncode({
              'teamID': widget.team.id,
              'title': controller.title.value + '||' + widget.team.name,
              'recruitPeriodStart': controller.recruitPeriodStart.value.replaceAll('년 ', '').replaceAll('월 ', '').replaceAll('일', '') + '000000',
              'recruitPeriodEnd': controller.recruitPeriodEnd.value == '상시모집' ? '상시모집' : controller.recruitPeriodEnd.value.replaceAll('년 ', '').replaceAll('월 ', '').replaceAll('일', '') + '235959',
              'recruitInfo': controlSpace(controller.recruitInfo.value),
              'category': category,
              'servicePart': widget.team.part,
              'location': widget.team.location,
              'subLocation': widget.team.subLocation,
              'recruitField': controller.recruitJob,
              'recruitSubField': controller.recruitPart.value,
              'roleContents': controlSpace(controller.roleContents.value),
              'education': education,
              'career': career,
              'detailVolunteerQualification': controller.detailEligibility.value,
              'preferenceInfo': preferenceInfo,
              'detailPreferenceInfoContents': controlSpace(controller.detailPreferenceInfoContents.value),
              'workFormFirst': controller.workFormList[0],
              'workFormSecond': controller.workFormList.length > 1 ? controller.workFormList[1] : '',
              'workDayOfWeek': workDayOfWeek,
              'workTime': workTime,
              'welfare': welfare,
              'detailWorkCondition': controlSpace(controller.detailWorkCondition.value),
            }));

        TeamMemberRecruit newTeamMemberRecruit = TeamMemberRecruit.fromJson(res);
        
        DialogBuilder(context).hideOpenDialog();

        showSheepsDialog(
          context: context,
          title: '모집글이\n게시되었어요 😄',
          description: '제안이 오면, 면접 채팅방이 생겨요!\n충분히 대화 후 결정해주세요.',
          okText: '게시글 확인하기',
          isCancelButton: false,
          isBarrierDismissible: false,
        ).then((val) {
          globalTeamMemberRecruitList.insert(0, newTeamMemberRecruit);
          if(widget.isMyPageRecruit) myPageRecruitList.insert(0, newTeamMemberRecruit); // 마이페이지에서 왔다면 리스트에 추가
          Get.back(); // Dialog
          Get.back(); // TeamMemberRecruitEditPage
          Get.back(); // ExpandedFab

          Get.to(() => RecruitDetailPage(isRecruit: true, data: newTeamMemberRecruit));
        });
      }
    });
  }
}
