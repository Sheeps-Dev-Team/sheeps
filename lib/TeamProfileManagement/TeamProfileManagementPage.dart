import 'dart:io';
import 'dart:ui';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:dio/dio.dart' as D;
import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' show get;
import 'package:path_provider/path_provider.dart';

import 'package:sheeps_app/Badge/model/ModelBadge.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/MultipartImgFilesController.dart';
import 'package:sheeps_app/config/LoadingUI.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/network/CustomException.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/profileModify/SelectArea.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/MyBadge.dart';
import 'model/Team.dart';
import 'model/TeamProfileManagementController.dart';
import 'AddCertificationPage.dart';
import 'AddPerformancePage.dart';
import 'AddTeamBadgePage.dart';
import 'AddTeamWinPage.dart';
import 'SelectTeamCategory.dart';
import 'SelectTeamField.dart';

class TeamProfileManagementPage extends StatefulWidget {
  final bool isAdd; // 팀 생성 페이지면 true
  final Team team; // 팀 생성이면 기본 생성자 Team()

  const TeamProfileManagementPage({Key key, @required this.team, this.isAdd = false}) : super(key: key);

  @override
  _TeamProfileManagementPageState createState() => _TeamProfileManagementPageState();
}

const int DRAG_LIST_ID_CERTIFICATION = 1;
const int DRAG_LIST_ID_PERFORMANCE = 2;
const int DRAG_LIST_ID_WIN = 3;

class _TeamProfileManagementPageState extends State<TeamProfileManagementPage> with SingleTickerProviderStateMixin {
  TeamProfileManagementController controller = Get.put(TeamProfileManagementController());

  PageController pageController = PageController();
  TextEditingController nameController = TextEditingController();
  TextEditingController infoController = TextEditingController();
  TextEditingController linkController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  MultipartImgFilesController _filesController = Get.put(MultipartImgFilesController());

  bool isEditMode = false;
  bool isReady = true;

  D.FormData formData;
  D.Response dioRes;

  AnimationController extendedController;

  @override
  void initState() {
    super.initState();
    controller.reset();

    extendedController = AnimationController(vsync: this, duration: const Duration(seconds: 1), lowerBound: 0.0, upperBound: 1.0);

    _filesController = Get.put(MultipartImgFilesController());

    _filesController.filesList.clear();
    File f;
    _filesController.filesList.add(f);

    if (!widget.isAdd) {
      // 수정 페이지일 때
      controller.loading(widget.team);
      nameController.text = controller.name.value;
      infoController.text = controller.information.value;
      Future.microtask(() => controller.checkName()).then((value) {
        setState(() {});
      });
      Future.microtask(() async {
        if (widget.team.profileImgList[0].imgUrl != 'BasicImage') {
          for (int i = 0; i < widget.team.profileImgList.length; i++) {
            var uri = Uri.parse(widget.team.profileImgList[i].imgUrl);
            var response = await get(uri);
            var documentDirectory = await getApplicationDocumentsDirectory();
            var firstPath = documentDirectory.path + "/images";
            var filePathAndName = documentDirectory.path + '/images/pic' + i.toString() + getMimeType(widget.team.profileImgList[i].imgUrl);
            await Directory(firstPath).create(recursive: true);
            File file2 = File(filePathAndName);
            file2.writeAsBytesSync(response.bodyBytes);
            _filesController.addFiles(file2);
          }
        }
      });
    }

    Future.microtask(() async {
      var list = await ApiProvider().post(
          '/Badge/SelectTeamID',
          jsonEncode({
            "teamID": widget.team.id,
          }));
      if (list != null) {
        widget.team.badgeList = [];
        for (int i = 0; i < list.length; ++i) {
          widget.team.badgeList.add(BadgeModel.fromJson(list[i]));
        }
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    nameController.dispose();
    infoController.dispose();
    linkController.dispose();
    _scrollController.dispose();
    extendedController.dispose();
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
                  appBar: SheepsAppBar(context, widget.isAdd ? '팀 생성' : '팀 프로필 수정', backFunc: () {
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
                            listTabItemTitle: ['필수정보', '사진・뱃지', '이력정보'],
                            listTabItemWidth: [60 * sizeUnit, 76 * sizeUnit, 60 * sizeUnit],
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
                            requiredInfoPage(),
                            photoBadgePage(),
                            recordInfoPage(),
                          ],
                        ),
                      ),
                      isEditMode
                          ? SizedBox.shrink()
                          : Padding(
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
                                          if (controller.getIsCheckFilledRequiredInfo()) {
                                            if (isReady) {
                                              isReady = false;
                                              Future.microtask(() => Future.delayed(
                                                    Duration(milliseconds: 500),
                                                    () {
                                                      isReady = true;
                                                    },
                                                  ));

                                              if (widget.isAdd) {
                                                addFunc();
                                              } else {
                                                modifyFunc();
                                              }
                                            }
                                          } else {
                                            showSheepsToast(context: context, text: '필수정보를 채워주세요!');
                                            controller.setBarIndex(0);
                                            pageController.animateToPage(controller.getBarIndex(), duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
                                          }
                                        }
                                        break;
                                    }
                                  },
                                  text: controller.getBarIndex() == 2 ? widget.isAdd? '팀 생성 완료' : '수정 완료' : '다음',
                                  isOK: controller.checkFilledRequiredInfo(),
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

  Widget requiredInfoPage() {
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
                  text: '팀명',
                  children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorGreen))],
                ),
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(height: 4 * sizeUnit),
              sheepsTextField(
                context,
                controller: nameController,
                hintText: '팀명 입력',
                errorText: validNameErrorText(nameController.text) == 'empty' ? null : validNameErrorText(nameController.text),
                onChanged: (val) {
                  controller.setName(val);
                  setState(() {});
                },
                onPressClear: () {
                  nameController.clear();
                  controller.setName('');
                  setState(() {});
                },
                borderColor: sheepsColorGreen,
              ),
              SizedBox(height: 20 * sizeUnit),
              Text.rich(
                TextSpan(
                  text: '팀 분류',
                  children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorGreen))],
                ),
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(height: 12 * sizeUnit),
              GestureDetector(
                onTap: () {
                  unFocus(context);
                  Get.to(() => SelectTeamCategory()).then((value) {
                    if (value != null) {
                      controller.category.value = value[0];
                      controller.checkFilledRequiredInfo();
                    }
                  });
                },
                child: Obx(() {
                  return Container(
                    height: 32 * sizeUnit,
                    decoration: BoxDecoration(
                      color: controller.category.value.isEmpty ? Colors.white : sheepsColorGreen,
                      border: Border.all(
                        color: controller.category.value.isEmpty ? sheepsColorGrey : sheepsColorGreen,
                        width: 1 * sizeUnit,
                      ),
                      borderRadius: BorderRadius.circular(16 * sizeUnit),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.category.value.isEmpty ? '팀 분류 선택' : controller.category.value,
                            style: SheepsTextStyle.bProfile().copyWith(color: controller.category.value.isEmpty ? sheepsColorGrey : Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 20 * sizeUnit),
              Text.rich(
                TextSpan(
                  text: '팀 분야',
                  children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorGreen))],
                ),
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(height: 12 * sizeUnit),
              GestureDetector(
                onTap: () {
                  unFocus(context);
                  Get.to(() => SelectTeamField()).then((value) {
                    if (value != null) {
                      controller.part.value = value[0];
                      controller.checkFilledRequiredInfo();
                    }
                  });
                },
                child: Obx(() {
                  return Container(
                    height: 32 * sizeUnit,
                    decoration: BoxDecoration(
                      color: controller.part.value.isEmpty ? Colors.white : sheepsColorGreen,
                      border: Border.all(
                        color: controller.part.value.isEmpty ? sheepsColorGrey : sheepsColorGreen,
                        width: 1 * sizeUnit,
                      ),
                      borderRadius: BorderRadius.circular(16 * sizeUnit),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.part.value.isEmpty ? '팀 분야 선택' : controller.part.value,
                            style: SheepsTextStyle.bProfile().copyWith(color: controller.part.value.isEmpty ? sheepsColorGrey : Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 20 * sizeUnit),
              Text.rich(
                TextSpan(
                  text: '지역',
                  children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorGreen))],
                ),
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(height: 12 * sizeUnit),
              GestureDetector(
                onTap: () {
                  unFocus(context);
                  Get.to(() => SelectArea()).then((value) {
                    if (value != null) {
                      controller.location.value = value[0];
                      controller.subLocation.value = value[1];
                      controller.checkFilledRequiredInfo();
                    }
                  });
                },
                child: Obx(() {
                  return Container(
                    height: 32 * sizeUnit,
                    decoration: BoxDecoration(
                      color: controller.location.value.isEmpty ? Colors.white : sheepsColorGreen,
                      border: Border.all(
                        color: controller.location.value.isEmpty ? sheepsColorGrey : sheepsColorGreen,
                        width: 1 * sizeUnit,
                      ),
                      borderRadius: BorderRadius.circular(16 * sizeUnit),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.location.value.isEmpty ? '지역 선택' : controller.location.value + ' ' + controller.subLocation.value,
                            style: SheepsTextStyle.bProfile().copyWith(color: controller.location.value.isEmpty ? sheepsColorGrey : Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 20 * sizeUnit),
              Row(
                children: [
                  Text.rich(
                    TextSpan(
                      text: '팀 지원 여부',
                      children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorGreen))],
                    ),
                    style: SheepsTextStyle.h3(),
                  ),
                  Spacer(),
                  Obx(() => Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: controller.isRecruiting.value,
                          onChanged: (bool value) {
                            controller.isRecruiting.value = value;
                          },
                        ),
                      )),
                ],
              ),
              SizedBox(height: 20 * sizeUnit),
              Text.rich(
                TextSpan(
                  text: '팀 소개',
                  children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorGreen))],
                ),
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(height: 12 * sizeUnit),
              multiLineTextField(
                  controller: infoController,
                  maxTextLength: 250,
                  hintText: '팀 소개 입력',
                  borderColor: sheepsColorGreen,
                  onChange: (val) {
                    controller.information.value = val;
                    controller.checkFilledRequiredInfo();
                  }),
            ],
          ),
        ),
      ],
    );
  }

  Widget photoBadgePage() {
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [SizedBox(height: 20 * sizeUnit)]), //가로길이 채우기용 Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(
                    TextSpan(
                      text: '사진',
                    ),
                    style: SheepsTextStyle.h3(),
                  ),
                  SizedBox(width: 8 * sizeUnit),
                  Text('최대 5장까지 등록 가능해요.', style: SheepsTextStyle.info2())
                ],
              ),
              SizedBox(height: 12 * sizeUnit),
              Obx(
                () => DragAndDropGridView(
                  controller: _scrollController,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 3 / 3,
                  ),
                  itemCount: controller.profileImgList.length < MAX_TEAM_PROFILE_IMG ? controller.profileImgList.length + 1 : MAX_TEAM_PROFILE_IMG,
                  itemBuilder: (context, index) => Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * sizeUnit)),
                    elevation: 0,
                    child: LayoutBuilder(builder: (context, constraints) {
                      if (index == controller.profileImgList.length) {
                        return GestureDetector(
                          onTap: () {
                            SheepsBottomSheetForImg(
                              context,
                              cameraFunc: () {
                                int checkAddFile = _filesController.filesList.length;
                                _filesController.getImageCamera().then((value) {
                                  if (checkAddFile != _filesController.filesList.length) {
                                    controller.isChangePhotos = true;
                                    controller.profileImgList
                                        .add(TeamProfileImg(imgUrl: _filesController.filesList[_filesController.filesList.length - 1].path)); //새 프로필이미지의 이미지url에 파일 패스를 넣어둠. id = -1로 구분
                                  }
                                }); // 카메라에서 사진 가져오기
                              }, // 카메라에서 사진 가져오기
                              galleryFunc: () {
                                int checkAddFile = _filesController.filesList.length;
                                _filesController.getImageGallery().then((value) {
                                  if (checkAddFile != _filesController.filesList.length) {
                                    controller.isChangePhotos = true;
                                    controller.profileImgList
                                        .add(TeamProfileImg(imgUrl: _filesController.filesList[_filesController.filesList.length - 1].path)); //새 프로필이미지의 이미지url에 파일 패스를 넣어둠. id = -1로 구분
                                  }
                                }); // 갤러리에서 사진 가져오기
                              }, // 갤러리에서 사진 가져오기
                            );
                          },
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              DottedBorder(
                                borderType: BorderType.RRect,
                                dashPattern: [6 * sizeUnit, 6 * sizeUnit],
                                strokeWidth: 2 * sizeUnit,
                                radius: Radius.circular(16 * sizeUnit),
                                color: sheepsColorGrey,
                                child: Container(
                                  width: 104 * sizeUnit,
                                  height: 104 * sizeUnit,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(16 * sizeUnit)),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      svgSheepsBasicProfileImage,
                                      width: 60 * sizeUnit,
                                      height: 55 * sizeUnit,
                                      color: sheepsColorGrey,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 1 * sizeUnit,
                                bottom: 1 * sizeUnit,
                                child: Container(
                                  child: SvgPicture.asset(
                                    svgPlusInCircle,
                                    width: 34 * sizeUnit,
                                    height: 34 * sizeUnit,
                                    color: sheepsColorGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          DottedBorder(
                            borderType: BorderType.RRect,
                            dashPattern: [6 * sizeUnit, 6 * sizeUnit],
                            strokeWidth: 2 * sizeUnit,
                            radius: Radius.circular(16 * sizeUnit),
                            color: sheepsColorGrey,
                            padding: EdgeInsets.zero,
                            child: Container(
                              width: 104 * sizeUnit,
                              height: 104 * sizeUnit,
                              decoration: BoxDecoration(
                                color: sheepsColorLightGrey,
                                borderRadius: BorderRadius.all(Radius.circular(16 * sizeUnit)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16 * sizeUnit),
                                child: FittedBox(
                                  child: controller.profileImgList[index].id == -1
                                      ? Image(image: FileImage(_filesController.filesList[index]))
                                      : getExtendedImage(controller.profileImgList[index].imgUrl, 60, extendedController),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 1 * sizeUnit,
                            bottom: 1 * sizeUnit,
                            child: GestureDetector(
                              onTap: () {
                                if (controller.profileImgList[index].id != -1) {
                                  controller.isChangePhotos = true;
                                  controller.deletedImgIdList.add(controller.profileImgList[index].id);
                                }
                                controller.profileImgList.removeAt(index);
                                _filesController.removeFile(targetFile: _filesController.filesList[index]);
                                setState(() {});
                              },
                              child: Container(
                                child: SvgPicture.asset(
                                  svgXInCircle,
                                  width: 34 * sizeUnit,
                                  height: 34 * sizeUnit,
                                  color: sheepsColorGrey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  onWillAccept: (oldIndex, newIndex) => true,
                  onReorder: (oldIndex, newIndex) {
                    if (controller.profileImgList.length == MAX_TEAM_PROFILE_IMG || (oldIndex != controller.profileImgList.length && newIndex != controller.profileImgList.length)) {
                      controller.isChangePhotos = true;
                      final tmpProfileImg = controller.profileImgList[oldIndex];
                      controller.profileImgList[oldIndex] = controller.profileImgList[newIndex];
                      controller.profileImgList[newIndex] = tmpProfileImg;

                      final tempFile = _filesController.filesList[oldIndex];
                      _filesController.filesList[oldIndex] = _filesController.filesList[newIndex];
                      _filesController.filesList[newIndex] = tempFile;
                      setState(() {});
                    }
                  },
                ),
              ),
              SizedBox(height: 40 * sizeUnit),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(
                    TextSpan(
                      text: '뱃지',
                    ),
                    style: SheepsTextStyle.h3(),
                  ),
                  SizedBox(width: 8 * sizeUnit),
                  Text('최대 3개까지 등록 가능해요.', style: SheepsTextStyle.info2())
                ],
              ),
              SizedBox(height: 12 * sizeUnit),
              Obx(() {
                return Container(
                  height: 120 * sizeUnit,
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 3 / 3,
                    ),
                    itemCount: controller.badgeList.length == 3 ? 3 : controller.badgeList.length + 1,
                    itemBuilder: (context, index) => Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * sizeUnit)),
                      elevation: 0,
                      child: LayoutBuilder(builder: (context, constraints) {
                        if (index == controller.badgeList.length && controller.badgeList.length != 3) {
                          return GestureDetector(
                            onTap: () {
                              Get.to(() => AddTeamBadgePage(team: widget.team));
                            },
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                DottedBorder(
                                  borderType: BorderType.RRect,
                                  dashPattern: [6 * sizeUnit, 6 * sizeUnit],
                                  strokeWidth: 2 * sizeUnit,
                                  radius: Radius.circular(16 * sizeUnit),
                                  color: sheepsColorGrey,
                                  child: Container(
                                    width: 104 * sizeUnit,
                                    height: 104 * sizeUnit,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(16 * sizeUnit)),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        svgSheepsBasicProfileImage,
                                        width: 60 * sizeUnit,
                                        height: 55 * sizeUnit,
                                        color: sheepsColorGrey,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 1 * sizeUnit,
                                  bottom: 1 * sizeUnit,
                                  child: Container(
                                    child: SvgPicture.asset(
                                      svgPlusInCircle,
                                      width: 34 * sizeUnit,
                                      height: 34 * sizeUnit,
                                      color: sheepsColorGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            DottedBorder(
                              borderType: BorderType.RRect,
                              dashPattern: [6 * sizeUnit, 6 * sizeUnit],
                              strokeWidth: 2 * sizeUnit,
                              radius: Radius.circular(16 * sizeUnit),
                              color: sheepsColorGrey,
                              padding: EdgeInsets.zero,
                              child: Container(
                                width: 104 * sizeUnit,
                                height: 104 * sizeUnit,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(16 * sizeUnit)),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    ReturnTeamBadgeSVG(controller.badgeList[index]),
                                    height: 100 * sizeUnit,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 1 * sizeUnit,
                              bottom: 1 * sizeUnit,
                              child: GestureDetector(
                                onTap: () {
                                  controller.badgeList.removeAt(index);
                                },
                                child: Container(
                                  child: SvgPicture.asset(
                                    svgXInCircle,
                                    width: 34 * sizeUnit,
                                    height: 34 * sizeUnit,
                                    color: sheepsColorGrey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget recordInfoPage() {
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
                  Text('인증', style: SheepsTextStyle.h3()),
                  SizedBox(width: 8 * sizeUnit),
                  Text('기업 형태, 각종 인증 등', style: SheepsTextStyle.info2()),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isEditMode = !isEditMode;
                      });
                    },
                    child: Container(
                      height: 24 * sizeUnit,
                      decoration: BoxDecoration(
                        color: isEditMode ? sheepsColorGreen : Colors.white,
                        border: Border.all(color: sheepsColorGreen, width: 1 * sizeUnit),
                        borderRadius: BorderRadius.circular(12 * sizeUnit),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isEditMode ? '편집완료' : '편집하기',
                              style: SheepsTextStyle.b3().copyWith(color: isEditMode ? Colors.white : sheepsColorGreen),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 11 * sizeUnit),
              Obx(() {
                if (!isEditMode) {
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: controller.certificationList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == controller.certificationList.length) {
                        return Padding(
                          padding: EdgeInsets.only(top: index == 0 ? 1 * sizeUnit : 8 * sizeUnit),
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => AddCertificationPage());
                            },
                            child: GreyBorderContainer(
                              icon: svgPlusInCircle,
                              iconColor: sheepsColorGreen,
                              child: Text('인증 추가', style: SheepsTextStyle.hint4Profile()),
                            ),
                          ),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 1 * sizeUnit),
                          child: authItem(controller.certificationList[index].contents, controller.certificationList[index].auth),
                        );
                      }
                    },
                  );
                } else {
                  return dragAndDropList(list: controller.certificationList, id: DRAG_LIST_ID_CERTIFICATION);
                }
              }),
              SizedBox(height: 20 * sizeUnit),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('수행 내역', style: SheepsTextStyle.h3()),
                  SizedBox(width: 8 * sizeUnit),
                  Text('프로젝트, 과제 용역 등', style: SheepsTextStyle.info2()),
                ],
              ),
              SizedBox(height: 11 * sizeUnit),
              Obx(() {
                if (!isEditMode) {
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: controller.performancesList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == controller.performancesList.length) {
                        return Padding(
                          padding: EdgeInsets.only(top: index == 0 ? 1 * sizeUnit : 8 * sizeUnit),
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => AddPerformancePage());
                            },
                            child: GreyBorderContainer(
                              icon: svgPlusInCircle,
                              iconColor: sheepsColorGreen,
                              child: Text('수행 내역 추가', style: SheepsTextStyle.hint4Profile()),
                            ),
                          ),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 1 * sizeUnit),
                          child: authItem(controller.performancesList[index].contents, controller.performancesList[index].auth),
                        );
                      }
                    },
                  );
                } else {
                  return dragAndDropList(list: controller.performancesList, id: DRAG_LIST_ID_PERFORMANCE);
                }
              }),
              SizedBox(height: 20 * sizeUnit),
              Text('수상 이력', style: SheepsTextStyle.h3()),
              SizedBox(height: 11 * sizeUnit),
              Obx(() {
                if (!isEditMode) {
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: controller.winList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == controller.winList.length) {
                        return Padding(
                          padding: EdgeInsets.only(top: index == 0 ? 1 * sizeUnit : 8 * sizeUnit),
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => AddTeamWinPage());
                            },
                            child: GreyBorderContainer(
                              icon: svgPlusInCircle,
                              iconColor: sheepsColorGreen,
                              child: Text('수상 이력 추가', style: SheepsTextStyle.hint4Profile()),
                            ),
                          ),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 1 * sizeUnit),
                          child: authItem(controller.winList[index].contents, controller.winList[index].auth),
                        );
                      }
                    },
                  );
                } else {
                  return dragAndDropList(list: controller.winList, id: DRAG_LIST_ID_WIN);
                }
              }),
              SizedBox(height: 20 * sizeUnit),
              Row(
                children: [
                  Text('팀 정보 링크', style: SheepsTextStyle.h3()),
                  SizedBox(width: 10 * sizeUnit),
                  SvgPicture.asset(
                    svgIInCircleOutline,
                    width: 14 * sizeUnit,
                    height: 14 * sizeUnit,
                    color: sheepsColorGrey,
                  ),
                  SizedBox(width: 4 * sizeUnit),
                  Text(
                    '팀에 대해 알려줄 수 있는 링크를 올려주세요.',
                    style: SheepsTextStyle.b3().copyWith(color: sheepsColorGrey),
                  ),
                ],
              ),
              SizedBox(height: 12 * sizeUnit),
              Wrap(
                spacing: 12 * sizeUnit,
                runSpacing: 8 * sizeUnit,
                children: [
                  Obx(() => linkItem(title: 'Site', linkUrl: controller.siteUrl)),
                  Obx(() => linkItem(title: '채용페이지', linkUrl: controller.recruitUrl)),
                  Obx(() => linkItem(title: 'Instagram', linkUrl: controller.instagramUrl, color: Color(0xFFDF3666))),
                  Obx(() => linkItem(title: 'Facebook', linkUrl: controller.facebookUrl, color: Color(0xFF006AEA))),
                ],
              ),
              SizedBox(height: 20 * sizeUnit),
            ],
          ),
        ),
      ],
    );
  }

  Widget linkItem({
    @required String title,
    @required RxString linkUrl,
    Color color = sheepsColorGreen,
  }) {
    return GestureDetector(
      onTap: () {
        linkController.clear();
        showEnterLinkDialog(
          title: title,
          linkUrl: linkUrl,
          controller: linkController,
          okButtonColor: sheepsColorGreen,
        );
      },
      child: Container(
        height: 32 * sizeUnit,
        decoration: BoxDecoration(
          color: linkUrl.isNotEmpty ? color : Colors.white,
          border: Border.all(color: linkUrl.isNotEmpty ? Colors.transparent : sheepsColorGrey, width: 1 * sizeUnit),
          borderRadius: BorderRadius.circular(16 * sizeUnit),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10 * sizeUnit),
              child: Text(
                title,
                style: SheepsTextStyle.b3().copyWith(color: linkUrl.isNotEmpty ? Colors.white : sheepsColorGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget authItem(String contents, int auth) {
    return GestureDetector(
      onTap: () {
        if (auth == 0) {
          showSheepsCustomDialog(
            title: Text('반려사유', style: SheepsTextStyle.h5()),
            contents: Text(
              '- 흔들림, 빛반사 등으로 인한 글씨판독 불가\n- 입력된 정보와 상이한 내용의 인증서류\n- 인증 유효기간 초과\n- 기타 유효하지 않은 인증서류\n\n'
              '위와 같은 이유로 반려되었습니다.\n삭제 후 다시 등록해주세요!',
              style: SheepsTextStyle.b3(),
              textAlign: TextAlign.center,
            ),
            okButtonColor: sheepsColorGreen,
          );
        }
      },
      child: Container(
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
              auth == 0 ? svgIInCircle : svgCheckInCircle,
              width: 20 * sizeUnit,
              height: 20 * sizeUnit,
              color: auth == 0
                  ? sheepsColorRed
                  : auth == 1
                      ? sheepsColorGreen
                      : sheepsColorGrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget GreyBorderContainer({String icon, Color iconColor, Function tapIcon, Widget child}) {
    return Container(
      width: 328 * sizeUnit,
      height: 32 * sizeUnit,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: sheepsColorGrey, width: 1 * sizeUnit),
        borderRadius: BorderRadius.circular(16 * sizeUnit),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            SizedBox(width: 5 * sizeUnit),
            GestureDetector(
              onTap: tapIcon == null ? () {} : tapIcon,
              child: SvgPicture.asset(
                icon,
                width: 22 * sizeUnit,
                height: 22 * sizeUnit,
                color: iconColor,
              ),
            ),
            SizedBox(width: 4 * sizeUnit),
          ] else ...[
            SizedBox(width: 12 * sizeUnit),
          ],
          child,
        ],
      ),
    );
  }

  Future modifyFunc() async {
    D.Dio dio = new D.Dio();
    dio.options.headers = {'Content-Type': 'application/json', 'user': GlobalProfile.loggedInUser == null ? 'sheepsToken' : GlobalProfile.loggedInUser.userID.toString()};

    Future.microtask(() async {
      formData = new D.FormData.fromMap({
        "teamid": widget.team.id,
        "name": controller.name.value,
        "category": controller.category.value,
        "part": controller.part.value,
        "location": controller.location.value,
        "sublocation": controller.subLocation.value,
        "possiblejoin": controller.isRecruiting.value ? 1 : 0,
        "information": controlSpace(controller.information.value),
        "accessToken": GlobalProfile.accessToken,
      });

      //뱃지
      if (controller.badgeList.length > 0) {
        formData.fields.add(MapEntry("badge1", controller.badgeList[0].toString()));
        if (controller.badgeList.length > 1) {
          formData.fields.add(MapEntry("badge2", controller.badgeList[1].toString()));
          if (controller.badgeList.length > 2) {
            formData.fields.add(MapEntry("badge3", controller.badgeList[2].toString()));
          }
        }
      }

      //프로필 사진
      if (controller.isChangePhotos) {
        formData.fields.add(MapEntry("isChangePhotos", "1")); //변동 있음

        for (int i = 0; i < controller.deletedImgIdList.length; i++) {
          formData.fields.add(MapEntry("removeidlist", controller.deletedImgIdList[i].toString()));
        }

        for (int i = 0; i < controller.profileImgList.length; i++) {
          formData.fields.add(MapEntry("fileidlist", controller.profileImgList[i].id.toString()));
          String filePath = _filesController.filesList[i].path;
          formData.files.add(MapEntry("TeamPhoto", D.MultipartFile.fromFileSync(filePath, filename: getFileName(i, filePath))));
        }
      } else {
        formData.fields.add(MapEntry("isChangePhotos", "0")); //변동 없음
      }

      //인증
      for (int i = 0; i < controller.certificationList.length; ++i) {
        formData.fields.add(MapEntry("tauthcontents", controller.certificationList[i].contents));
        String filePath = controller.certificationList[i].imgUrl;
        formData.files.add(MapEntry("TAuthAuthImg", D.MultipartFile.fromFileSync(filePath, filename: getFileName(1, filePath))));
      }

      //수행내역
      for (int i = 0; i < controller.performancesList.length; ++i) {
        formData.fields.add(MapEntry("tperformancecontents", controller.performancesList[i].contents));
        String filePath = controller.performancesList[i].imgUrl;
        formData.files.add(MapEntry("TPerformanceAuthImg", D.MultipartFile.fromFileSync(filePath, filename: getFileName(1, filePath))));
      }

      //수상
      for (int i = 0; i < controller.winList.length; ++i) {
        formData.fields.add(MapEntry("twincontents", controller.winList[i].contents));
        String filePath = controller.winList[i].imgUrl;
        formData.files.add(MapEntry("TWinAuthImg", D.MultipartFile.fromFileSync(filePath, filename: getFileName(1, filePath))));
      }

      DialogBuilder(context).showLoadingIndicator();

      try {
        //링크
        await ApiProvider().post(
            '/Team/InsertOrUpdate/Links',
            jsonEncode({
              'teamID': widget.team.id,
              'site': controller.siteUrl.value,
              'recruit': controller.recruitUrl.value,
              'instagram': controller.instagramUrl.value,
              'facebook': controller.facebookUrl.value,
            }));

        dioRes = await dio.post(ApiProvider().getImgUrl + '/Team/ProfileModify', data: formData);
      } on DioError catch (e) {
        DialogBuilder(context).hideOpenDialog();
        throw FetchDataException(e.message);
      }

      Team changedTeam = Team.fromJson(dioRes.data);

      DialogBuilder(context).hideOpenDialog();

      showSheepsDialog(
        context: context,
        title: '팀 프로필 수정 완료!',
        description: '팀 프로필 수정이 완료되었어요!',
        isCancelButton: false,
        isBarrierDismissible: false,
      ).then((val) {
        GlobalProfile.setModifyTeamProfile(changedTeam);
        Get.back(result: [changedTeam]); //수정된 팀 데이터 받아서 바꿔주기
      });
    });
  }

  Future addFunc() async {
    Dio dio = new Dio();
    dio.options.headers = {
      'Content-Type': 'application/json',
      'user': GlobalProfile.loggedInUser.userID,
    };

    Team addTeam;

    Future.microtask(() async {
      formData = new D.FormData.fromMap({
        "leaderid": GlobalProfile.loggedInUser.userID,
        "name": controller.name.value,
        "category": controller.category.value,
        "part": controller.part.value,
        "location": controller.location.value,
        "sublocation": controller.subLocation.value,
        "possiblejoin": controller.isRecruiting.value ? 1 : 0,
        "information": controlSpace(controller.information.value),
      });

      //새 팀은 당연히 뱃지 없음

      //프로필 사진
      if (controller.isChangePhotos) {
        formData.fields.add(MapEntry("isChangePhotos", "1")); //변동 있음

        for (int i = 0; i < controller.deletedImgIdList.length; i++) {
          formData.fields.add(MapEntry("removeidlist", controller.deletedImgIdList[i].toString()));
        }

        for (int i = 0; i < controller.profileImgList.length; i++) {
          formData.fields.add(MapEntry("fileidlist", controller.profileImgList[i].id.toString()));
          String filePath = _filesController.filesList[i].path;
          formData.files.add(MapEntry("TeamPhoto", D.MultipartFile.fromFileSync(filePath, filename: getFileName(i, filePath))));
        }
      } else {
        formData.fields.add(MapEntry("isChangePhotos", "0")); //변동 없음
      }

      //인증
      for (int i = 0; i < controller.certificationList.length; ++i) {
        formData.fields.add(MapEntry("tauthcontents", controller.certificationList[i].contents));
        String filePath = controller.certificationList[i].imgUrl;
        formData.files.add(MapEntry("TAuthAuthImg", D.MultipartFile.fromFileSync(filePath, filename: getFileName(1, filePath))));
      }

      //수행내역
      for (int i = 0; i < controller.performancesList.length; ++i) {
        formData.fields.add(MapEntry("tperformancecontents", controller.performancesList[i].contents));
        String filePath = controller.performancesList[i].imgUrl;
        formData.files.add(MapEntry("TPerformanceAuthImg", D.MultipartFile.fromFileSync(filePath, filename: getFileName(1, filePath))));
      }

      //수상
      for (int i = 0; i < controller.winList.length; ++i) {
        formData.fields.add(MapEntry("twincontents", controller.winList[i].contents));
        String filePath = controller.winList[i].imgUrl;
        formData.files.add(MapEntry("TWinAuthImg", D.MultipartFile.fromFileSync(filePath, filename: getFileName(1, filePath))));
      }

      DialogBuilder(context).showLoadingIndicator("팀 생성 중...");

      var res;
      try {
        res = await dio.post(ApiProvider().getImgUrl + "/Team/Insert", data: formData);
      } on DioError catch (e) {
        DialogBuilder(context).hideOpenDialog();
        throw FetchDataException(e.message);
      }

      if (res != null) {
        addTeam = Team.fromJson(res.data);
        //팀 생성 후 id 가져다가 링크 업데이트
        await ApiProvider().post(
            '/Team/InsertOrUpdate/Links',
            jsonEncode({
              'teamID': addTeam.id,
              'site': controller.siteUrl.value,
              'recruit': controller.recruitUrl.value,
              'instagram': controller.instagramUrl.value,
              'facebook': controller.facebookUrl.value,
            }));
        addTeam.teamLink.siteUrl = controller.siteUrl.value;
        addTeam.teamLink.recruitUrl = controller.recruitUrl.value;
        addTeam.teamLink.instagramUrl = controller.instagramUrl.value;
        addTeam.teamLink.facebookUrl = controller.facebookUrl.value;

        GlobalProfile.teamProfile.insert(0, addTeam);
      } else {
        addTeam = null;
      }
      DialogBuilder(context).hideOpenDialog();

      showSheepsDialog(
        context: context,
        title: '팀 생성 완료!',
        description: '팀 프로필 생성이 완료되었어요!\n 이제 쉽스에서 팀원들을 모아보세요!',
        isCancelButton: false,
        isBarrierDismissible: false,
      ).then((val) {
        Get.back(result: [addTeam]);
      });
    });
  }
}
