import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sheeps_app/Recruit/SpecificUserRecruitPage.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/LoadingUI.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'Models/PersonalSeekTeams.dart';
import 'Controller/PersonalSeekTeamsEditController.dart';
import 'RecruitDetailPage.dart';

class PersonalSeekTeamsEditPage extends StatefulWidget {
  final PersonalSeekTeam? personalSeekTeam; //수정일때만 받음
  final bool isMyPagePersonalSeek; // 마이페이지에서 왔으면 true

  PersonalSeekTeamsEditPage({Key? key, this.personalSeekTeam, this.isMyPagePersonalSeek = false}) : super(key: key);

  @override
  _PersonalSeekTeamsEditPageState createState() => _PersonalSeekTeamsEditPageState();
}

class _PersonalSeekTeamsEditPageState extends State<PersonalSeekTeamsEditPage> {
  PersonalSeekTeamsEditController controller = Get.put(PersonalSeekTeamsEditController());

  PageController pageController = PageController();
  TextEditingController titleController = TextEditingController();
  TextEditingController infoController = TextEditingController();
  TextEditingController abilityContentsController = TextEditingController();
  TextEditingController needWorkConditionController = TextEditingController();

  bool isReady = true;
  bool isEdit = false;

  bool isCanRecruit = true;

  @override
  void initState() {
    super.initState();
    controller.loading();
    if (widget.personalSeekTeam != null) {
      isEdit = true;
      controller.editLoading(widget.personalSeekTeam!);
      titleController.text = controller.title.value;
      infoController.text = controller.selfInfo.value;
      abilityContentsController.text = controller.abilityContents.value;
      needWorkConditionController.text = controller.needWorkConditionContents.value;
    }

    Future.microtask(() async {
      controller.seekingState.value = await checkCanRecruit();
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    titleController.dispose();
    infoController.dispose();
    abilityContentsController.dispose();
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

  Future<bool> checkCanRecruit() async {
    int countRecruit = 0;

    List<PersonalSeekTeam> seekList = [];

    var res = await ApiProvider().post(
        '/Matching/Select/PersonalSeekTeamByUserID',
        jsonEncode({
          'userID': GlobalProfile.loggedInUser!.userID,
        }));

    if (res != null) {
      for (int i = 0; i < res.length; i++) {
        PersonalSeekTeam tmpSeek = PersonalSeekTeam.fromJson(res[i]);
        seekList.add(tmpSeek);
      }
    }

    seekList.forEach((e) {
      if(widget.personalSeekTeam != null){
        if(e.id != widget.personalSeekTeam!.id) if (e.seekingState == 1) countRecruit++;
      }else{
        if (e.seekingState == 1) countRecruit++;
      }
    });

    if (countRecruit < RECRUIT_LIMIT_PERSON) return true;

    isCanRecruit = false;
    return false;
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
                  appBar: SheepsAppBar(context, '팀 찾는 글쓰기', backFunc: () {
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
                            listTabItemTitle: ['구직정보', '이력정보', '근무조건'],
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
                            jobSearchInfoPage(),
                            recordInfoPage(),
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
                                    } else {
                                      showSheepsCustomDialog(
                                          title: Text.rich(
                                            TextSpan(
                                              text: '필수 정보',
                                              children: [
                                                TextSpan(
                                                  text: '*',
                                                  style: TextStyle(color: sheepsColorBlue),
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
                                                  style: TextStyle(color: sheepsColorBlue),
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
                                    ? true
                                    : controller.checkFilledRequiredInfo(),
                            color: sheepsColorBlue,
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

  Widget jobSearchInfoPage() {
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
                  text: '구직 제목',
                  children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorBlue))],
                ),
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(height: 4 * sizeUnit),
              Obx(
                () => sheepsTextField(
                  context,
                  controller: titleController,
                  hintText: '구직 제목 입력',
                  errorText: removeSpace(controller.title.value).length > 42 ? '제목은 42자 이하로 입력해주세요.' : null,
                  onChanged: (val) {
                    controller.title.value = val;
                    controller.checkFilledRequiredInfo();
                  },
                  onPressClear: () {
                    titleController.clear();
                    controller.title.value = '';
                    controller.checkFilledRequiredInfo();
                  },
                  borderColor: sheepsColorBlue,
                ),
              ),
              SizedBox(height: 20 * sizeUnit),
              Text.rich(
                TextSpan(
                  text: '구직상태',
                  children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorBlue))],
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
                      if (isCanRecruit) {
                        controller.seekingState.value = true;
                      } else {
                        showSheepsDialog(
                          context: context,
                          title: '이미 구직중인\n상태 입니다!',
                          description: '현재 원활한 서비스 운영 및 매칭을 위해\n최대 $RECRUIT_LIMIT_PERSON개까지 구직중 상태가 가능해요.',
                          okColor: sheepsColorBlue,
                          isCancelButton: false,
                        );
                      }
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '구직중', isSelected: controller.seekingState.value, color: sheepsColorBlue);
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.seekingState.value = false;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '구직완료', isSelected: !controller.seekingState.value, color: sheepsColorBlue);
                    }),
                  ),
                ],
              ),
              SizedBox(height: 20 * sizeUnit),
              Text.rich(
                TextSpan(
                  text: '자기 소개',
                  children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorBlue))],
                ),
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(height: 12 * sizeUnit),
              multiLineTextField(
                controller: infoController,
                maxTextLength: 250,
                hintText: '멋진 자기소개 입력',
                borderColor: sheepsColorBlue,
                onChange: (val) {
                  controller.selfInfo.value = val;
                  controller.checkFilledRequiredInfo();
                },
              ),
              SizedBox(height: 8 * sizeUnit),
              GestureDetector(
                onTap: () {
                  if (GlobalProfile.loggedInUser!.information != null) {
                    infoController.text = GlobalProfile.loggedInUser!.information;
                    controller.selfInfo.value = GlobalProfile.loggedInUser!.information;
                  }
                },
                child: Container(
                  height: 32 * sizeUnit,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: sheepsColorBlue, width: 1 * sizeUnit),
                    borderRadius: BorderRadius.circular(16 * sizeUnit),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit),
                        child: Text(
                          '프로필 소개글 불러오기',
                          style: SheepsTextStyle.hint4Profile().copyWith(color: sheepsColorBlue),
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
                  children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorBlue))],
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
                      controller.isCategoryDevelopment.value = true;
                      controller.isCategoryOperation.value = false;
                      controller.isCategoryDesign.value = false;
                      controller.isCategoryMarketing.value = false;
                      controller.isCategorySales.value = false;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '개발', isSelected: controller.isCategoryDevelopment.value, color: sheepsColorBlue);
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isCategoryDevelopment.value = false;
                      controller.isCategoryOperation.value = true;
                      controller.isCategoryDesign.value = false;
                      controller.isCategoryMarketing.value = false;
                      controller.isCategorySales.value = false;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '경영', isSelected: controller.isCategoryOperation.value, color: sheepsColorBlue);
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isCategoryDevelopment.value = false;
                      controller.isCategoryOperation.value = false;
                      controller.isCategoryDesign.value = true;
                      controller.isCategoryMarketing.value = false;
                      controller.isCategorySales.value = false;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '디자인', isSelected: controller.isCategoryDesign.value, color: sheepsColorBlue);
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isCategoryDevelopment.value = false;
                      controller.isCategoryOperation.value = false;
                      controller.isCategoryDesign.value = false;
                      controller.isCategoryMarketing.value = true;
                      controller.isCategorySales.value = false;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '마케팅', isSelected: controller.isCategoryMarketing.value, color: sheepsColorBlue);
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      controller.isCategoryDevelopment.value = false;
                      controller.isCategoryOperation.value = false;
                      controller.isCategoryDesign.value = false;
                      controller.isCategoryMarketing.value = false;
                      controller.isCategorySales.value = true;
                    },
                    child: Obx(() {
                      return sheepsSelectContainer(text: '영업', isSelected: controller.isCategorySales.value, color: sheepsColorBlue);
                    }),
                  ),
                ],
              ),
              SizedBox(height: 20 * sizeUnit),
              Text.rich(
                TextSpan(
                  text: '구직분야',
                  children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorBlue))],
                ),
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(height: 12 * sizeUnit),
              Wrap(
                spacing: 10 * sizeUnit,
                runSpacing: 10 * sizeUnit,
                children: [
                  if (controller.part.isNotEmpty) ...[
                    GestureDetector(
                      onTap: () {
                        unFocus(context);
                        controller.isPart1.value = true;
                        controller.isPart2.value = false;
                      },
                      child: Obx(() {
                        return sheepsSelectContainer(text: controller.part, isSelected: controller.isPart1.value, color: sheepsColorBlue);
                      }),
                    ),
                  ],
                  if (controller.subPart.isNotEmpty) ...[
                    GestureDetector(
                      onTap: () {
                        unFocus(context);
                        controller.isPart1.value = false;
                        controller.isPart2.value = true;
                      },
                      child: Obx(() {
                        return sheepsSelectContainer(text: controller.subPart, isSelected: controller.isPart2.value, color: sheepsColorBlue);
                      }),
                    ),
                  ],
                  if (controller.part.isEmpty) ...[
                    Row(
                      children: [
                        SvgPicture.asset(
                          svgIInCircleOutline,
                          width: 14 * sizeUnit,
                          height: 14 * sizeUnit,
                          color: sheepsColorGrey,
                        ),
                        SizedBox(width: 4 * sizeUnit),
                        Text(
                          '분야가 없어요! 프로필 수정에서 입력할 수 있습니다.',
                          style: SheepsTextStyle.b3().copyWith(color: sheepsColorGrey),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              SizedBox(height: 20 * sizeUnit),
              Text.rich(
                TextSpan(
                  text: '역량',
                  children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorBlue))],
                ),
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(height: 12 * sizeUnit),
              multiLineTextField(
                controller: abilityContentsController,
                maxTextLength: 250,
                hintText: '역량 입력',
                borderColor: sheepsColorBlue,
                onChange: (val) {
                  controller.abilityContents.value = val;
                  controller.checkFilledRequiredInfo();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget recordInfoPage() {
    bool isHaveHighSchool = false;
    bool isHaveCollege = false;
    bool isHaveBachelor = false;
    bool isHaveMaster = false;
    bool isHaveDoctor = false;

    for (int i = 0; i < controller.educationList.length; i++) {
      if (controller.educationList[i].auth == 1) {
        if (controller.educationList[i].contents.contains('고등학교(졸업)')) isHaveHighSchool = true;
        if (controller.educationList[i].contents.contains('전문대(졸업)')) isHaveCollege = true;
        if (controller.educationList[i].contents.contains('학사(졸업)')) isHaveBachelor = true;
        if (controller.educationList[i].contents.contains('석사(졸업)')) isHaveMaster = true;
        if (controller.educationList[i].contents.contains('박사(졸업)')) isHaveDoctor = true;
      }
    }

    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12 * sizeUnit),
              Row(
                children: [
                  SvgPicture.asset(
                    svgIInCircleOutline,
                    width: 14 * sizeUnit,
                    height: 14 * sizeUnit,
                    color: sheepsColorGrey,
                  ),
                  SizedBox(width: 4 * sizeUnit),
                  Text(
                    '내 프로필에 작성된 정보가 연동되어 채워집니다.',
                    style: SheepsTextStyle.b3().copyWith(color: sheepsColorGrey),
                  ),
                ],
              ),
              SizedBox(height: 12 * sizeUnit),
              Text('학력', style: SheepsTextStyle.h3()),
              SizedBox(height: 12 * sizeUnit),
              if (controller.educationList.length == 0) ...[
                Row(
                  children: [
                    SvgPicture.asset(
                      svgIInCircleOutline,
                      width: 14 * sizeUnit,
                      height: 14 * sizeUnit,
                      color: sheepsColorGrey,
                    ),
                    SizedBox(width: 4 * sizeUnit),
                    Text(
                      '학력이 없어요! 프로필 수정에서 추가할 수 있습니다.',
                      style: SheepsTextStyle.b3().copyWith(color: sheepsColorGrey),
                    ),
                  ],
                ),
              ] else ...[
                Wrap(
                  spacing: 10 * sizeUnit,
                  runSpacing: 10 * sizeUnit,
                  children: [
                    if (isHaveHighSchool) ...[
                      GestureDetector(
                        onTap: () {
                          unFocus(context);
                          controller.isEduHighSchool.value = true;
                          controller.isEduCollege.value = false;
                          controller.isEduBachelor.value = false;
                          controller.isEduMaster.value = false;
                          controller.isEduDoctor.value = false;
                        },
                        child: Obx(() {
                          return sheepsSelectContainer(text: '고졸', isSelected: controller.isEduHighSchool.value, color: sheepsColorBlue);
                        }),
                      ),
                    ],
                    if (isHaveCollege) ...[
                      GestureDetector(
                        onTap: () {
                          unFocus(context);
                          controller.isEduHighSchool.value = false;
                          controller.isEduCollege.value = true;
                          controller.isEduBachelor.value = false;
                          controller.isEduMaster.value = false;
                          controller.isEduDoctor.value = false;
                        },
                        child: Obx(() {
                          return sheepsSelectContainer(text: '초대졸', isSelected: controller.isEduCollege.value, color: sheepsColorBlue);
                        }),
                      ),
                    ],
                    if (isHaveBachelor) ...[
                      GestureDetector(
                        onTap: () {
                          unFocus(context);
                          controller.isEduHighSchool.value = false;
                          controller.isEduCollege.value = false;
                          controller.isEduBachelor.value = true;
                          controller.isEduMaster.value = false;
                          controller.isEduDoctor.value = false;
                        },
                        child: Obx(() {
                          return sheepsSelectContainer(text: '대졸', isSelected: controller.isEduBachelor.value, color: sheepsColorBlue);
                        }),
                      ),
                    ],
                    if (isHaveMaster) ...[
                      GestureDetector(
                        onTap: () {
                          unFocus(context);
                          controller.isEduHighSchool.value = false;
                          controller.isEduCollege.value = false;
                          controller.isEduBachelor.value = false;
                          controller.isEduMaster.value = true;
                          controller.isEduDoctor.value = false;
                        },
                        child: Obx(() {
                          return sheepsSelectContainer(text: '석사', isSelected: controller.isEduMaster.value, color: sheepsColorBlue);
                        }),
                      ),
                    ],
                    if (isHaveDoctor) ...[
                      GestureDetector(
                        onTap: () {
                          unFocus(context);
                          controller.isEduHighSchool.value = false;
                          controller.isEduCollege.value = false;
                          controller.isEduBachelor.value = false;
                          controller.isEduMaster.value = false;
                          controller.isEduDoctor.value = true;
                        },
                        child: Obx(() {
                          return sheepsSelectContainer(text: '박사', isSelected: controller.isEduDoctor.value, color: sheepsColorBlue);
                        }),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 11 * sizeUnit),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: controller.educationList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 1 * sizeUnit),
                      child: authItem(controller.educationList[index].contents, controller.educationList[index].auth),
                    );
                  },
                ),
              ],
              SizedBox(height: 20 * sizeUnit),
              Text('경력', style: SheepsTextStyle.h3()),
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
                      return sheepsSelectContainer(text: '신입', isSelected: controller.isCareerNew.value, color: sheepsColorBlue);
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
                      return sheepsSelectContainer(text: '경력', isSelected: controller.isCareerCareer.value, color: sheepsColorBlue);
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
                      return sheepsSelectContainer(text: '경력무관', isSelected: controller.isCareerAny.value, color: sheepsColorBlue);
                    }),
                  ),
                ],
              ),
              SizedBox(height: 11 * sizeUnit),
              if (controller.careerList.length == 0) ...[
                Row(
                  children: [
                    SvgPicture.asset(
                      svgIInCircleOutline,
                      width: 14 * sizeUnit,
                      height: 14 * sizeUnit,
                      color: sheepsColorGrey,
                    ),
                    SizedBox(width: 4 * sizeUnit),
                    Text(
                      '경력이 없어요! 프로필 수정에서 추가할 수 있습니다.',
                      style: SheepsTextStyle.b3().copyWith(color: sheepsColorGrey),
                    ),
                  ],
                ),
              ] else ...[
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: controller.careerList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 1 * sizeUnit),
                      child: authItem(controller.careerList[index].contents, controller.careerList[index].auth),
                    );
                  },
                ),
              ],
              SizedBox(height: 20 * sizeUnit),
              Text('자격증', style: SheepsTextStyle.h3()),
              SizedBox(height: 11 * sizeUnit),
              if (controller.licenseList.length == 0) ...[
                Row(
                  children: [
                    SvgPicture.asset(
                      svgIInCircleOutline,
                      width: 14 * sizeUnit,
                      height: 14 * sizeUnit,
                      color: sheepsColorGrey,
                    ),
                    SizedBox(width: 4 * sizeUnit),
                    Text(
                      '자격증이 없어요! 프로필 수정에서 추가할 수 있습니다.',
                      style: SheepsTextStyle.b3().copyWith(color: sheepsColorGrey),
                    ),
                  ],
                ),
              ] else ...[
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: controller.licenseList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 1 * sizeUnit),
                      child: authItem(controller.licenseList[index].contents, controller.licenseList[index].auth),
                    );
                  },
                ),
              ],
              SizedBox(height: 20 * sizeUnit),
              Text('수상 이력', style: SheepsTextStyle.h3()),
              SizedBox(height: 11 * sizeUnit),
              if (controller.winList.length == 0) ...[
                Row(
                  children: [
                    SvgPicture.asset(
                      svgIInCircleOutline,
                      width: 14 * sizeUnit,
                      height: 14 * sizeUnit,
                      color: sheepsColorGrey,
                    ),
                    SizedBox(width: 4 * sizeUnit),
                    Text(
                      '수상 이력이 없어요! 프로필 수정에서 추가할 수 있습니다.',
                      style: SheepsTextStyle.b3().copyWith(color: sheepsColorGrey),
                    ),
                  ],
                ),
              ] else ...[
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: controller.winList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 1 * sizeUnit),
                      child: authItem(controller.winList[index].contents, controller.winList[index].auth),
                    );
                  },
                ),
              ],
              SizedBox(height: 20 * sizeUnit),
              Text('이력 링크', style: SheepsTextStyle.h3()),
              SizedBox(height: 12 * sizeUnit),
              Wrap(
                spacing: 12 * sizeUnit,
                runSpacing: 8 * sizeUnit,
                children: [
                  Obx(() => linkItem(title: '포트폴리오', linkUrl: controller.portfolioUrl)),
                  Obx(() => linkItem(title: '이력서', linkUrl: controller.resumeUrl)),
                  Obx(() => linkItem(title: 'Site', linkUrl: controller.siteUrl)),
                  Obx(() => linkItem(title: 'LinkedIn', linkUrl: controller.linkedInUrl, color: Color(0xFF005AB6))),
                  Obx(() => linkItem(title: 'Instagram', linkUrl: controller.instagramUrl, color: Color(0xFFDA4064))),
                  Obx(() => linkItem(title: 'Facebook', linkUrl: controller.facebookUrl, color: Color(0xFF006AEA))),
                  Obx(() => linkItem(title: 'GitHub', linkUrl: controller.gitHubUrl, color: Color(0xFF191D20))),
                  Obx(() => linkItem(title: 'Notion', linkUrl: controller.notionUrl, color: Colors.black)),
                ],
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
                      children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorBlue))],
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
                selectedList: controller.workForm,
                maxSelect: 2,
                color: sheepsColorBlue,
              ),
              SizedBox(height: 20 * sizeUnit),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(
                    TextSpan(
                      text: '근무요일',
                      children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorBlue))],
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
                      return sheepsSelectContainer(text: '주 5일', isSelected: controller.isWorkDayOfWeek5.value, color: sheepsColorBlue);
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
                      return sheepsSelectContainer(text: '주 6일', isSelected: controller.isWorkDayOfWeek6.value, color: sheepsColorBlue);
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
                      return sheepsSelectContainer(text: '주 3일', isSelected: controller.isWorkDayOfWeek3.value, color: sheepsColorBlue);
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
                      return sheepsSelectContainer(text: '탄력근무제', isSelected: controller.isWorkDayOfWeekFlexible.value, color: sheepsColorBlue);
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
                      return sheepsSelectContainer(text: '협의', isSelected: controller.isWorkDayOfWeekNegotiable.value, color: sheepsColorBlue);
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
                      children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorBlue))],
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
                      return sheepsSelectContainer(text: '1일 8시간', isSelected: controller.isWorkTime8.value, color: sheepsColorBlue);
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
                      return sheepsSelectContainer(text: '탄력근무', isSelected: controller.isWorkTimeFlexible.value, color: sheepsColorBlue);
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
                      return sheepsSelectContainer(text: '자율', isSelected: controller.isWorkTimeAutonomous.value, color: sheepsColorBlue);
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
                      return sheepsSelectContainer(text: '협의', isSelected: controller.isWorkTimeNegotiable.value, color: sheepsColorBlue);
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
                selectedList: controller.welfare,
                maxSelect: 9,
                isCanSelectAll: true,
                color: sheepsColorBlue,
              ),
              SizedBox(height: 20 * sizeUnit),
              Text.rich(
                TextSpan(
                  text: '원하는 근무조건',
                ),
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(height: 12 * sizeUnit),
              multiLineTextField(
                controller: needWorkConditionController,
                maxTextLength: 250,
                hintText: '원하는 근무조건 입력',
                borderColor: sheepsColorBlue,
                onChange: (val) {
                  controller.needWorkConditionContents.value = val;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget linkItem({
    required String title,
    required RxString linkUrl,
    Color color = sheepsColorBlue,
  }) {
    return GestureDetector(
      onTap: () {
        showSheepsCustomDialog(
          title: Text(
            title + ' 링크',
            style: SheepsTextStyle.h5(),
            textAlign: TextAlign.center,
          ),
          contents: Column(
            children: [
              Text(
                '링크는 프로필 수정에서 입력할 수 있습니다.',
                style: SheepsTextStyle.b3(),
                textAlign: TextAlign.center,
              ),
              if (linkUrl.value.isNotEmpty) ...[
                SizedBox(height: 20 * sizeUnit),
                Text(
                  linkUrl.value,
                  style: SheepsTextStyle.b3().copyWith(color: sheepsColorBlue),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
          okButtonColor: sheepsColorBlue,
        );
      },
      child: Container(
        height: 32 * sizeUnit,
        decoration: BoxDecoration(
          color: linkUrl.value.isNotEmpty ? color : Colors.white,
          border: Border.all(color: linkUrl.value.isNotEmpty ? Colors.transparent : sheepsColorGrey, width: 1 * sizeUnit),
          borderRadius: BorderRadius.circular(16 * sizeUnit),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10 * sizeUnit),
              child: Text(
                title,
                style: SheepsTextStyle.b3().copyWith(color: linkUrl.value.isNotEmpty ? Colors.white : sheepsColorGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget authItem(String contents, int auth) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Text(
            '・ ',
            style: SheepsTextStyle.b3(),
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 280 * sizeUnit),
            child: Text(
              cutAuthInfo(contents),
              style: SheepsTextStyle.b3(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 4 * sizeUnit),
          SvgPicture.asset(
            svgCheckInCircle,
            width: 20 * sizeUnit,
            height: 20 * sizeUnit,
            color: auth == 1 ? sheepsColorBlue : sheepsColorGrey,
          ),
        ],
      ),
    );
  }

  Future upload() async {
    Future.microtask(() async {
      String category = '';
      if (controller.isCategoryDevelopment.value) {
        category = '개발';
      } else if (controller.isCategoryOperation.value) {
        category = '경영';
      } else if (controller.isCategoryDesign.value) {
        category = '디자인';
      } else if (controller.isCategoryMarketing.value) {
        category = '마케팅';
      } else if (controller.isCategorySales.value) {
        category = '영업';
      }

      String job;
      String part;
      if (controller.isPart1.value) {
        job = controller.job;
        part = controller.part;
      } else {
        job = controller.subJob;
        part = controller.subPart;
      }

      String education = '';
      if (controller.isEduHighSchool.value) {
        education = '고졸';
      } else if (controller.isEduCollege.value) {
        education = '초대졸';
      } else if (controller.isEduBachelor.value) {
        education = '대졸';
      } else if (controller.isEduMaster.value) {
        education = '석사';
      } else if (controller.isEduDoctor.value) {
        education = '박사';
      }

      String career = '';
      if (controller.isCareerNew.value) {
        career = '신입';
      } else if (controller.isCareerCareer.value) {
        career = '경력';
      } else if (controller.isCareerAny.value) {
        career = '경력무관';
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
      for (int i = 0; i < controller.welfare.length; i++) {
        if (i == 0) {
          welfare = controller.welfare[i];
        } else {
          welfare = welfare + ' | ' + controller.welfare[i];
        }
      }

      if (isEdit) {
        DialogBuilder(context).showLoadingIndicator("");

        await ApiProvider().post(
            '/Matching/Update/PersonalSeekTeam',
            jsonEncode({
              'id': widget.personalSeekTeam!.id,
              "userID": widget.personalSeekTeam!.userId,
              "title": controller.title.value + '||' + GlobalProfile.loggedInUser!.name,
              'seekingState': controller.seekingState.value ? 1 : 0,
              'selfInfo': controlSpace(controller.selfInfo.value),
              'category': category,
              'seekingFieldPart': job,
              'seekingFieldSubPart': part,
              'abilityContents': controlSpace(controller.abilityContents.value),
              'education': education,
              'career': career,
              'workFormFirst': controller.workForm[0],
              'workFormSecond': controller.workForm.length > 1 ? controller.workForm[1] : '',
              'workDayOfWeek': workDayOfWeek,
              'workTime': workTime,
              'welfare': welfare,
              'needWorkConditionContents': controlSpace(controller.needWorkConditionContents.value),
              'location': GlobalProfile.loggedInUser!.location,
              'subLocation': GlobalProfile.loggedInUser!.subLocation,
            }));

        PersonalSeekTeam modifiedPersonalSeekTeam = PersonalSeekTeam(
          id: widget.personalSeekTeam!.id,
          userId: widget.personalSeekTeam!.userId,
          title: controller.title.value + '||' + GlobalProfile.loggedInUser!.name,
          seekingState: controller.seekingState.value ? 1 : 0,
          selfInfo: controlSpace(controller.selfInfo.value),
          category: category,
          seekingFieldPart: job,
          seekingFieldSubPart: part,
          abilityContents: controlSpace(controller.abilityContents.value),
          education: education,
          career: career,
          workFormFirst: controller.workForm[0],
          workFormSecond: controller.workForm.length > 1 ? controller.workForm[1] : '',
          workDayOfWeek: workDayOfWeek,
          workTime: workTime,
          welfare: welfare,
          needWorkConditionContents: controlSpace(controller.needWorkConditionContents.value),
          location: GlobalProfile.loggedInUser!.location,
          subLocation: GlobalProfile.loggedInUser!.subLocation,
          isShow: widget.personalSeekTeam!.isShow,
          createdAt: getYearMonthDayByDate(),
          updateAt: getYearMonthDayByDate(),
        );

        for (int i = 0; i < globalPersonalSeekTeamList.length; i++) {
          if (globalPersonalSeekTeamList[i].id == modifiedPersonalSeekTeam.id) {
            globalPersonalSeekTeamList[i] = modifiedPersonalSeekTeam;
            break;
          }
        }

        DialogBuilder(context).hideOpenDialog();

        showSheepsDialog(
          context: context,
          title: '구직글이\n수정되었어요 😄',
          description: '제안이 오면, 면접 채팅방이 생겨요!\n충분히 대화 후 결정해주세요.',
          isCancelButton: false,
          isBarrierDismissible: false,
        ).then((val) {
          Get.back(result: [modifiedPersonalSeekTeam]);
          Get.back();
        });
      } else {
        DialogBuilder(context).showLoadingIndicator("");

        var res = await ApiProvider().post(
            '/Matching/Insert/PersonalSeekTeam',
            jsonEncode({
              "userID": GlobalProfile.loggedInUser!.userID,
              "title": controller.title.value + '||' + GlobalProfile.loggedInUser!.name,
              'seekingState': controller.seekingState.value ? 1 : 0,
              'selfInfo': controlSpace(controller.selfInfo.value),
              'category': category,
              'seekingFieldPart': job,
              'seekingFieldSubPart': part,
              'abilityContents': controlSpace(controller.abilityContents.value),
              'education': education,
              'career': career,
              'workFormFirst': controller.workForm[0],
              'workFormSecond': controller.workForm.length > 1 ? controller.workForm[1] : '',
              'workDayOfWeek': workDayOfWeek,
              'workTime': workTime,
              'welfare': welfare,
              'needWorkConditionContents': controlSpace(controller.needWorkConditionContents.value),
              'location': GlobalProfile.loggedInUser!.location,
              'subLocation': GlobalProfile.loggedInUser!.subLocation,
            }));

        PersonalSeekTeam newPersonalSeekTeam = PersonalSeekTeam.fromJson(res);

        DialogBuilder(context).hideOpenDialog();

        showSheepsDialog(
          context: context,
          title: '구직글이\n게시되었어요 😄',
          description: '제안이 오면, 면접 채팅방이 생겨요!\n충분히 대화 후 결정해주세요.',
          okText: '게시글 확인하기',
          okColor: sheepsColorBlue,
          isCancelButton: false,
          isBarrierDismissible: false,
        ).then((val) {
          globalPersonalSeekTeamList.insert(0, newPersonalSeekTeam);
          if(widget.isMyPagePersonalSeek) myPageSeekList.add(newPersonalSeekTeam); // 마이페이지에서 온거면 마이페이지 리스트에 넣어주기

          if(!widget.isMyPagePersonalSeek) Get.back(); // 마이페이지에서 온게 아닐 때만
          Get.back(); // ExpandedFab
          Get.to(() => RecruitDetailPage(isRecruit: false, data: newPersonalSeekTeam));
        });
      }
    });
  }
}
