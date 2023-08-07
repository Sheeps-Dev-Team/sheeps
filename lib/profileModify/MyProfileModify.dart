import 'dart:io';
import 'dart:convert';

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
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';
import 'models/PersonalProfileModifyController.dart';
import 'AddBadge.dart';
import 'AddCareerPage.dart';
import 'AddEducationPage.dart';
import 'AddLicensePage.dart';
import 'AddWinPage.dart';
import 'SelectArea.dart';
import 'SelectField.dart';

class MyProfileModify extends StatefulWidget {
  const MyProfileModify({Key key}) : super(key: key);

  @override
  _MyProfileModifyState createState() => _MyProfileModifyState();
}

const int DRAG_LIST_ID_EDUCATION = 1;
const int DRAG_LIST_ID_CAREER = 2;
const int DRAG_LIST_ID_LICENSE = 3;
const int DRAG_LIST_ID_WIN = 4;

class _MyProfileModifyState extends State<MyProfileModify> with SingleTickerProviderStateMixin {
  PersonalProfileModifyController controller = Get.put(PersonalProfileModifyController());

  PageController pageController = PageController();
  TextEditingController nameController = TextEditingController();
  TextEditingController infoController = TextEditingController();
  TextEditingController linkController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  MultipartImgFilesController _filesController = Get.put(MultipartImgFilesController());

  bool isEditMode = false;
  bool isReady = true;

  D.FormData formData;
  D.Response res;
  var result;

  AnimationController extendedController;

  @override
  void initState() {
    super.initState();

    controller.loading();

    extendedController = AnimationController(vsync: this, duration: const Duration(seconds: 1), lowerBound: 0.0, upperBound: 1.0);

    nameController.text = controller.name.value;
    infoController.text = controller.information.value;

    File f;
    _filesController.filesList.clear();
    _filesController.filesList.add(f);

    Future.microtask(() async {
      if (GlobalProfile.loggedInUser.profileImgList != null && GlobalProfile.loggedInUser.profileImgList[0].imgUrl != 'BasicImage') {
        for (int i = 0; i < GlobalProfile.loggedInUser.profileImgList.length; i++) {
          var uri = Uri.parse(GlobalProfile.loggedInUser.profileImgList[i].imgUrl);

          var response = await get(uri);
          var documentDirectory = await getApplicationDocumentsDirectory();
          var firstPath = documentDirectory.path + "/images";
          var filePathAndName = documentDirectory.path + '/images/pict' + i.toString() + getMimeType(GlobalProfile.loggedInUser.profileImgList[i].imgUrl);
          await Directory(firstPath).create(recursive: true);
          File file2 = File(filePathAndName);
          file2.writeAsBytesSync(response.bodyBytes);
          _filesController.addFiles(file2);
        }
      }
    }).then((value) {
      if (mounted) {
        setState(() {});
      }
    });
    Future.microtask(() => controller.checkName());
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
                  appBar: SheepsAppBar(context, '내 프로필 수정', backFunc: () {
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

                                              upload();
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
                                  text: controller.getBarIndex() == 2 ? '수정 완료' : '다음',
                                  isOK: controller.checkFilledRequiredInfo(),
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
                  text: '이름',
                  children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorBlue))],
                ),
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(height: 4 * sizeUnit),
              sheepsTextField(
                context,
                controller: nameController,
                hintText: '이름 입력',
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
                borderColor: sheepsColorBlue,
              ),
              SizedBox(height: 20 * sizeUnit),
              Text.rich(
                TextSpan(
                  text: '분야',
                  children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorBlue))],
                ),
                style: SheepsTextStyle.h3(),
              ),
              SizedBox(height: 12 * sizeUnit),
              Wrap(
                spacing: 12 * sizeUnit,
                runSpacing: 12 * sizeUnit,
                children: [
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      Get.to(() => SelectField()).then((value) {
                        if (value != null) {
                          controller.job.value = value[0];
                          controller.part.value = value[1];
                          controller.checkFilledRequiredInfo();
                        }
                      });
                    },
                    child: Obx(() {
                      return Container(
                        height: 32 * sizeUnit,
                        decoration: BoxDecoration(
                          color: controller.part.value.isEmpty ? Colors.white : sheepsColorBlue,
                          border: Border.all(
                            color: controller.part.value.isEmpty ? sheepsColorGrey : sheepsColorBlue,
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
                                controller.part.value.isEmpty ? '분야 선택' : controller.part.value,
                                style: SheepsTextStyle.bProfile().copyWith(color: controller.part.value.isEmpty ? sheepsColorGrey : Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      unFocus(context);
                      if (controller.subJob.value.isEmpty) {
                        Get.to(() => SelectField()).then((value) {
                          if (value != null) {
                            controller.subJob.value = value[0];
                            controller.subPart.value = value[1];
                          }
                        });
                      } else {
                        controller.subJob.value = '';
                        controller.subPart.value = '';
                      }
                    },
                    child: Obx(() {
                      return Container(
                        height: 32 * sizeUnit,
                        decoration: BoxDecoration(
                          color: controller.subPart.value.isEmpty ? Colors.white : sheepsColorBlue,
                          border: Border.all(
                            color: controller.subPart.value.isEmpty ? sheepsColorGrey : sheepsColorBlue,
                            width: 1 * sizeUnit,
                          ),
                          borderRadius: BorderRadius.circular(16 * sizeUnit),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    controller.subPart.value.isEmpty ? '서브 분야 선택' : controller.subPart.value,
                                    style: SheepsTextStyle.bProfile().copyWith(color: controller.subPart.value.isEmpty ? sheepsColorGrey : Colors.white),
                                  ),
                                  if (controller.subPart.value.isNotEmpty) ...[
                                    SizedBox(width: 8 * sizeUnit),
                                    SvgPicture.asset(
                                      svgSimpleX,
                                      width: 10 * sizeUnit,
                                      height: 10 * sizeUnit,
                                      color: Colors.white,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              SizedBox(height: 20 * sizeUnit),
              Text.rich(
                TextSpan(
                  text: '지역',
                  children: [TextSpan(text: '*', style: TextStyle(color: sheepsColorBlue))],
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
                      color: controller.location.value.isEmpty ? Colors.white : sheepsColorBlue,
                      border: Border.all(
                        color: controller.location.value.isEmpty ? sheepsColorGrey : sheepsColorBlue,
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
                  hintText: '자기소개 입력',
                  borderColor: sheepsColorBlue,
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
                  itemCount: controller.profileImgList.length < MAX_USER_PROFILE_IMG ? controller.profileImgList.length + 1 : MAX_USER_PROFILE_IMG,
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
                                        .add(UserProfileImg(imgUrl: _filesController.filesList[_filesController.filesList.length - 1].path)); //새 프로필이미지의 이미지url에 파일 패스를 넣어둠. id = -1로 구분
                                  }
                                }); // 카메라에서 사진 가져오기
                              },
                              galleryFunc: () {
                                int checkAddFile = _filesController.filesList.length;
                                _filesController.getImageGallery().then((value) {
                                  if (checkAddFile != _filesController.filesList.length) {
                                    controller.isChangePhotos = true;
                                    controller.profileImgList
                                        .add(UserProfileImg(imgUrl: _filesController.filesList[_filesController.filesList.length - 1].path)); //새 프로필이미지의 이미지url에 파일 패스를 넣어둠. id = -1로 구분
                                  }
                                }); // 갤러리에서 사진 가져오기
                              },
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
                                    color: sheepsColorBlue,
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
                    if (controller.profileImgList.length == MAX_USER_PROFILE_IMG || (oldIndex != controller.profileImgList.length && newIndex != controller.profileImgList.length)) {
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
                              Get.to(() => AddBadge());
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
                                      color: sheepsColorBlue,
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
                                    ReturnPersonalBadgeSVG(controller.badgeList[index]),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('학력', style: SheepsTextStyle.h3()),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isEditMode = !isEditMode;
                      });
                    },
                    child: Container(
                      height: 24 * sizeUnit,
                      decoration: BoxDecoration(
                        color: isEditMode ? sheepsColorBlue : Colors.white,
                        border: Border.all(color: sheepsColorBlue, width: 1 * sizeUnit),
                        borderRadius: BorderRadius.circular(12 * sizeUnit),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isEditMode ? '편집완료' : '편집하기',
                              style: SheepsTextStyle.b3().copyWith(color: isEditMode ? Colors.white : sheepsColorBlue),
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
                    itemCount: controller.educationList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == controller.educationList.length) {
                        return Padding(
                          padding: EdgeInsets.only(top: index == 0 ? 1 * sizeUnit : 8 * sizeUnit),
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => AddEducationPage());
                            },
                            child: GreyBorderContainer(
                              icon: svgPlusInCircle,
                              iconColor: sheepsColorBlue,
                              child: Text('학력 추가', style: SheepsTextStyle.hint4Profile()),
                            ),
                          ),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 1 * sizeUnit),
                          child: authItem(controller.educationList[index].contents, controller.educationList[index].auth),
                        );
                      }
                    },
                  );
                } else {
                  return dragAndDropList(list: controller.educationList, id: DRAG_LIST_ID_EDUCATION);
                }
              }),
              SizedBox(height: 20 * sizeUnit),
              Text('경력', style: SheepsTextStyle.h3()),
              SizedBox(height: 11 * sizeUnit),
              Obx(() {
                if (!isEditMode) {
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: controller.careerList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == controller.careerList.length) {
                        return Padding(
                          padding: EdgeInsets.only(top: index == 0 ? 1 * sizeUnit : 8 * sizeUnit),
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => AddCareerPage());
                            },
                            child: GreyBorderContainer(
                              icon: svgPlusInCircle,
                              iconColor: sheepsColorBlue,
                              child: Text('경력 추가', style: SheepsTextStyle.hint4Profile()),
                            ),
                          ),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 1 * sizeUnit),
                          child: authItem(controller.careerList[index].contents, controller.careerList[index].auth),
                        );
                      }
                    },
                  );
                } else {
                  return dragAndDropList(list: controller.careerList, id: DRAG_LIST_ID_CAREER);
                }
              }),
              SizedBox(height: 20 * sizeUnit),
              Text('자격증', style: SheepsTextStyle.h3()),
              SizedBox(height: 11 * sizeUnit),
              Obx(() {
                if (!isEditMode) {
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: controller.licenseList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == controller.licenseList.length) {
                        return Padding(
                          padding: EdgeInsets.only(top: index == 0 ? 1 * sizeUnit : 8 * sizeUnit),
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => AddLicensePage());
                            },
                            child: GreyBorderContainer(
                              icon: svgPlusInCircle,
                              iconColor: sheepsColorBlue,
                              child: Text('자격증 추가', style: SheepsTextStyle.hint4Profile()),
                            ),
                          ),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 1 * sizeUnit),
                          child: authItem(controller.licenseList[index].contents, controller.licenseList[index].auth),
                        );
                      }
                    },
                  );
                } else {
                  return dragAndDropList(list: controller.licenseList, id: DRAG_LIST_ID_LICENSE);
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
                              Get.to(() => AddWinPage());
                            },
                            child: GreyBorderContainer(
                              icon: svgPlusInCircle,
                              iconColor: sheepsColorBlue,
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
                  Text('이력 링크', style: SheepsTextStyle.h3()),
                  SizedBox(width: 12 * sizeUnit),
                  SvgPicture.asset(
                    svgIInCircleOutline,
                    width: 14 * sizeUnit,
                    height: 14 * sizeUnit,
                    color: sheepsColorGrey,
                  ),
                  SizedBox(width: 4 * sizeUnit),
                  Text(
                    '포트폴리오, 이력서 등 링크를 올려주세요.',
                    style: SheepsTextStyle.b3().copyWith(color: sheepsColorGrey),
                  ),
                ],
              ),
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

  Widget linkItem({
    @required String title,
    @required RxString linkUrl,
    Color color = sheepsColorBlue,
  }) {
    return GestureDetector(
      onTap: () {
        linkController.clear();
        showEnterLinkDialog(
          title: title,
          linkUrl: linkUrl,
          controller: linkController,
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
            okButtonColor: sheepsColorBlue,
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
                      ? sheepsColorBlue
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

  void upload() {
    D.Dio dio = D.Dio();
    dio.options.headers = {
      'Content-Type': 'application/json',
      'user': GlobalProfile.loggedInUser.userID,
    };

    Future.microtask(() async {
      DialogBuilder(context).showLoadingIndicator("프로필 수정 중...");

      formData = new D.FormData.fromMap({
        "userid": GlobalProfile.loggedInUser.userID,
        "name": controller.name.value,
        "job": controller.job.value,
        "part": controller.part.value,
        "subjob": controller.subJob.value,
        "subpart": controller.subPart.value,
        "location": controller.location.value,
        "sublocation": controller.subLocation.value,
        "information": controlSpace(controller.information.value),
        "accessToken": GlobalProfile.accessToken,
        "isChangePhotos": 1
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
          formData.files.add(MapEntry("ProfilePhoto", D.MultipartFile.fromFileSync(filePath, filename: getFileName(i, filePath))));
        }
      } else {
        formData.fields.add(MapEntry("isChangePhotos", "0")); //변동 없음
      }

      //학력
      for (int i = 0; i < controller.educationList.length; i++) {
        formData.fields.add(MapEntry("pfunivnames", controller.educationList[i].contents));
        String filePath = controller.educationList[i].imgUrl;
        formData.files.add(MapEntry("PfUnivAuthImg", D.MultipartFile.fromFileSync(filePath, filename: getFileName(1, filePath))));
      }

      //경력
      for (int i = 0; i < controller.careerList.length; ++i) {
        formData.fields.add(MapEntry("pfcareercontents", controller.careerList[i].contents));
        String filePath = controller.careerList[i].imgUrl;
        formData.files.add(MapEntry("PfCareerAuthImg", D.MultipartFile.fromFileSync(filePath, filename: getFileName(1, filePath))));
      }

      //자격증
      for (int i = 0; i < controller.licenseList.length; ++i) {
        formData.fields.add(MapEntry("pflicensecontents", controller.licenseList[i].contents));
        String filePath = controller.licenseList[i].imgUrl;
        formData.files.add(MapEntry("PfLicenseAuthImg", D.MultipartFile.fromFileSync(filePath, filename: getFileName(1, filePath))));
      }

      //수상
      for (int i = 0; i < controller.winList.length; ++i) {
        formData.fields.add(MapEntry("pfwincontents", controller.winList[i].contents));
        String filePath = controller.winList[i].imgUrl;
        formData.files.add(MapEntry("PfWinAuthImg", D.MultipartFile.fromFileSync(filePath, filename: getFileName(1, filePath))));
      }

      try {
        //링크
        await ApiProvider().post(
            '/Personal/InsertOrUpdate/Links',
            jsonEncode({
              'userID': GlobalProfile.loggedInUser.userID,
              'portfolio': controller.portfolioUrl.value,
              'resume': controller.resumeUrl.value,
              'site': controller.siteUrl.value,
              'linkedin': controller.linkedInUrl.value,
              'instagram': controller.instagramUrl.value,
              'facebook': controller.facebookUrl.value,
              'github': controller.gitHubUrl.value,
              'notion': controller.notionUrl.value,
            }));

        res = await dio.post(ApiProvider().getImgUrl + '/Personal/ProfileModify', data: formData);
      } on D.DioError catch (e) {
        DialogBuilder(context).hideOpenDialog();
        throw FetchDataException(e.message);
      }

      result = await ApiProvider().post('/Personal/Select/User', jsonEncode({"userID": GlobalProfile.loggedInUser.userID}));

      GlobalProfile.loggedInUser = UserData.fromJson(result);

      DialogBuilder(context).hideOpenDialog();
    }).then((value) {
      showSheepsDialog(
        context: context,
        title: '프로필 수정 완료!',
        description: '프로필 수정이 완료되었어요!',
        isBarrierDismissible: false,
        isCancelButton: false,
      ).then((val) {
        Get.back();
      });
    });
  }
}
