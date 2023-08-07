import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';


import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:http/http.dart' show get;
import 'package:path_provider/path_provider.dart';
import 'package:sheeps_app/Community/CommunityMainDetail.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/LoadingUI.dart';
import 'package:sheeps_app/config/MultipartImgFilesController.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/CustomException.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'Controller/CommunityWriteController.dart';
import 'models/Community.dart';

class CommunityWritePage extends StatefulWidget {
  final bool isEdit; //수정일때만 true
  final Community? community; //수정일때만 받음
  final String? selectedCategory;

  const CommunityWritePage({Key? key, this.isEdit = false, this.community, this.selectedCategory}) : super(key: key);

  @override
  _CommunityWritePageState createState() => _CommunityWritePageState();
}

class _CommunityWritePageState extends State<CommunityWritePage> with SingleTickerProviderStateMixin {
  CommunityWriteController controller = Get.put(CommunityWriteController());
  TextEditingController titleController = TextEditingController();
  TextEditingController contentsController = TextEditingController();
  MultipartImgFilesController _filesController = Get.put(MultipartImgFilesController());

  late AnimationController extendedController;

  bool isFinishFileLoading = false; //파일생성 완료 전 이미지변경방지
  late Community? community;

  @override
  void initState() {
    super.initState();

    extendedController = AnimationController(vsync: this, duration: const Duration(seconds: 1), lowerBound: 0.0, upperBound: 1.0);

    controller.resetData();

    community = widget.community;

    // File f;
    _filesController.filesList.clear();
    // _filesController.filesList.add(f);

    if (widget.isEdit) {
      controller.loading(widget.community!);
      titleController.text = controller.title.value;
      contentsController.text = controller.contents.value;
      controller.checkFilledRequired();
      //파일생성
      Future.microtask(() async {
        for (int i = 0; i < controller.imgUrlFilePathList.length; i++) {
          var uri = Uri.parse(controller.imgUrlFilePathList[i]);

          var response = await get(uri);
          var documentDirectory = await getApplicationDocumentsDirectory();
          var firstPath = documentDirectory.path + "/images";
          var filePathAndName = documentDirectory.path + '/images/community' + i.toString() + getMimeType(controller.imgUrlFilePathList[i]);
          await Directory(firstPath).create(recursive: true);
          File file2 = File(filePathAndName);
          file2.writeAsBytesSync(response.bodyBytes);
          _filesController.addFiles(file2);
          controller.imgUrlFilePathList[i] = file2.path;
          controller.isFilePathList[i] = true; //url 파일 변환 확인
        }
        isFinishFileLoading = true; //모든 파일 변환 완료
      });
    } else {
      if (widget.selectedCategory != null) controller.setCategory(widget.selectedCategory!);
      isFinishFileLoading = true;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentsController.dispose();
    extendedController.dispose();
    super.dispose();
  }

  void backFunc() {
    showEditCancelDialog(okButtonColor: sheepsColorBlue);
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
                  appBar: SheepsAppBar(context, widget.isEdit ? '글 수정하기' : '글쓰기', backFunc: () {
                    backFunc();
                  }),
                  body: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                          child: ListView(
                            children: [
                              SizedBox(height: 20 * sizeUnit),
                              if (!widget.isEdit) ...[
                                Wrap(
                                  spacing: 12 * sizeUnit,
                                  runSpacing: 8 * sizeUnit,
                                  children: List.generate(communityCategoryList.length - 2, (index) {
                                    String category = communityCategoryList[index + 2];

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          controller.categoryReset();
                                          controller.setCategory(category);
                                          controller.checkFilledRequired();
                                        });
                                      },
                                      child: Obx(() => categorySelectContainer(
                                            text: category,
                                            isSelected: controller.matchingBool(category),
                                          )),
                                    );
                                  }),
                                ),
                                Obx(() {
                                  List<Widget> children = [];
                                  if (controller.isCategorySecret.value) {
                                    children = [
                                      SizedBox(height: 8 * sizeUnit),
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            svgIInCircleOutline,
                                            width: 14 * sizeUnit,
                                            color: sheepsColorRed,
                                          ),
                                          SizedBox(width: 4 * sizeUnit),
                                          Text(
                                            '비밀글은 자동으로 익명 표기됩니다.',
                                            style: SheepsTextStyle.error(),
                                          )
                                        ],
                                      ),
                                    ];
                                  }
                                  return Column(mainAxisSize: MainAxisSize.min, children: children);
                                }),
                                SizedBox(height: 20 * sizeUnit),
                              ],
                              Obx(() => sheepsTextField(
                                    context,
                                    title: '제목',
                                    controller: titleController,
                                    hintText: '제목 입력',
                                    errorText: controller.title.value.isNotEmpty && removeSpace(controller.title.value).length < 2
                                        ? '최소 2자 이상 입력해 주세요.'
                                        : removeSpace(controller.title.value).length > 40
                                            ? '제목은 40자 이하로 입력해 주세요.'
                                            : null,
                                    errorTextStyle: SheepsTextStyle.error().copyWith(fontSize: 10 * sizeUnit),
                                    onChanged: (val) {
                                      controller.title.value = val;
                                      controller.checkFilledRequired();
                                    },
                                    onPressClear: () {
                                      titleController.clear();
                                      controller.title.value = '';
                                      controller.checkFilledRequired();
                                    },
                                    borderColor: sheepsColorGreen,
                                  )),
                              SizedBox(height: 20 * sizeUnit),
                              Text.rich(
                                TextSpan(
                                  text: '본문',
                                ),
                                style: SheepsTextStyle.h3(),
                              ),
                              SizedBox(height: 12 * sizeUnit),
                              Obx(() => multiLineTextField(
                                    controller: contentsController,
                                    maxTextLength: 500,
                                    hintText: '내용 입력',
                                    borderColor: sheepsColorGreen,
                                    errorText: controller.contents.value.isNotEmpty &&
                                            controller.contents.value.replaceAll(' ', '').replaceAll('　', '').replaceAll('\u200B', '').replaceAll('\n', '').length < 10
                                        ? '최소 10자 이상 입력해 주세요.'
                                        : null,
                                    errorTextStyle: SheepsTextStyle.error().copyWith(fontSize: 10 * sizeUnit),
                                    onChange: (val) {
                                      controller.contents.value = val;
                                      controller.checkFilledRequired();
                                    },
                                  )),
                              SizedBox(height: 8 * sizeUnit),
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
                                  Text('최대 3장까지 등록 가능해요.', style: SheepsTextStyle.info2()),
                                ],
                              ),
                              SizedBox(height: 12 * sizeUnit),
                              Container(
                                height: 110 * sizeUnit,
                                child: Obx(() => ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      cacheExtent: 3,
                                      reverse: false,
                                      shrinkWrap: true,
                                      itemCount: controller.imgUrlFilePathList.length != 3 ? controller.imgUrlFilePathList.length + 1 : 3,
                                      itemBuilder: (context, index) => Card(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * sizeUnit)),
                                        elevation: 0,
                                        child: LayoutBuilder(builder: (context, constraints) {
                                          if (index == controller.imgUrlFilePathList.length) {
                                            return GestureDetector(
                                              onTap: () {
                                                SheepsBottomSheetForImg(
                                                  context,
                                                  cameraFunc: () {
                                                    if (isFinishFileLoading) {
                                                      int checkAddFile = _filesController.filesList.length;
                                                      _filesController.getImageCamera().then((value) {
                                                        if (checkAddFile != _filesController.filesList.length) {
                                                          controller.imgUrlFilePathList.add(_filesController.filesList[_filesController.filesList.length - 1].path);
                                                          controller.isFilePathList.add(true);
                                                        }
                                                      }); // 카메라에서 사진 가져오기
                                                    }
                                                  },
                                                  galleryFunc: () {
                                                    if (isFinishFileLoading) {
                                                      int checkAddFile = _filesController.filesList.length;
                                                      _filesController.getImageGallery().then((value) {
                                                        if (checkAddFile != _filesController.filesList.length) {
                                                          controller.imgUrlFilePathList.add(_filesController.filesList[_filesController.filesList.length - 1].path);
                                                          controller.isFilePathList.add(true);
                                                        }
                                                      }); // 갤러리에서 사진 가져오기
                                                    }
                                                  },
                                                );
                                              },
                                              child: Stack(
                                                alignment: Alignment.bottomRight,
                                                children: [
                                                  DottedBorder(
                                                    borderType: BorderType.RRect,
                                                    dashPattern: [6.1 * sizeUnit, 6.1 * sizeUnit],
                                                    strokeWidth: 2 * sizeUnit,
                                                    radius: Radius.circular(16 * sizeUnit),
                                                    color: sheepsColorGrey,
                                                    child: Container(
                                                      width: 98 * sizeUnit,
                                                      height: 98 * sizeUnit,
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
                                                      child: controller.isFilePathList[index]
                                                          ? Image(image: FileImage(_filesController.filesList[index]))
                                                          : getExtendedImage(controller.imgUrlFilePathList[index], 60, extendedController),
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
                                                    if (isFinishFileLoading) {
                                                      controller.imgUrlFilePathList.removeAt(index);
                                                      controller.isFilePathList.removeAt(index);
                                                      _filesController.removeFile(targetFile: _filesController.filesList[index]);
                                                    }
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
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24 * sizeUnit),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              svgIInCircleOutline,
                              width: 12 * sizeUnit,
                              height: 12 * sizeUnit,
                            ),
                            SizedBox(width: 4 * sizeUnit),
                            Text(
                              '커뮤니티 정책에 의해 부적절한 내용, 단어는 블라인드 될 수 있습니다.',
                              style: SheepsTextStyle.bWriteDate().copyWith(color: sheepsColorGrey),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20 * sizeUnit, 12 * sizeUnit, 20 * sizeUnit, 20 * sizeUnit),
                        child: Obx(() => SheepsBottomButton(
                              context: context,
                              function: () {
                                if (controller.isFilledRequired.value) {
                                  if (isFinishFileLoading) {
                                    late String category;
                                    if (controller.isCategoryCompany.value) category = '회사';
                                    if (controller.isCategorySecret.value) category = '비밀';
                                    if (controller.isCategoryPromotion.value) category = '홍보';
                                    if (controller.isCategoryFree.value) category = '자유';
                                    if (controller.isCategoryMeeting.value) category = '소모임';
                                    if (controller.isCategoryDevelopment.value) category = '개발';
                                    if (controller.isCategoryOperation.value) category = '경영';
                                    if (controller.isCategoryDesign.value) category = '디자인';
                                    if (controller.isCategoryMarketing.value) category = '마케팅';
                                    if (controller.isCategorySales.value) category = '영업';
                                    if (controller.isCategoryCollegeStudent.value) category = '대학생';

                                    showSheepsDialog(
                                      context: context,
                                      title: widget.isEdit ? '수정 완료' : '작성 완료',
                                      description: widget.isEdit ? '게시글을 수정할까요?' : '게시글을 등록할까요?',
                                      okFunc: () async {
                                        Dio dio = new Dio();
                                        dio.options.headers = {'Content-Type': 'application/json', 'user': GlobalProfile.loggedInUser.userID};

                                        if (widget.isEdit) {
                                          //게시글 수정
                                          FormData formData = FormData.fromMap({
                                            "id": widget.community!.id,
                                            "category": category,
                                            "title": controlSpace(controller.title.value),
                                            "contents": controlSpace(controller.contents.value),
                                            "accessToken": GlobalProfile.accessToken,
                                            'type': 0,
                                            "0": controller.imgUrlFilePathList.length >= 1
                                                ? await MultipartFile.fromFile(controller.imgUrlFilePathList[0], filename: getFileName(0, controller.imgUrlFilePathList[0]))
                                                : null,
                                            "1": controller.imgUrlFilePathList.length >= 2
                                                ? await MultipartFile.fromFile(controller.imgUrlFilePathList[1], filename: getFileName(1, controller.imgUrlFilePathList[1]))
                                                : null,
                                            "2": controller.imgUrlFilePathList.length >= 3
                                                ? await MultipartFile.fromFile(controller.imgUrlFilePathList[2], filename: getFileName(2, controller.imgUrlFilePathList[2]))
                                                : null,
                                          });

                                          DialogBuilder(context).showLoadingIndicator();

                                          var res;
                                          late Community modifiedCommunity;

                                          try {
                                            res = await dio.post(ApiProvider().getImgUrl + '/CommunityPost/Modify', data: formData);
                                            modifiedCommunity = Community.fromJson(json.decode(res.toString()));

                                            for (int i = 0; i < GlobalProfile.globalCommunityList.length; i++) {
                                              if (GlobalProfile.globalCommunityList[i].id == widget.community!.id) {
                                                GlobalProfile.globalCommunityList[i] = Community.fromJson(json.decode(res.toString()));
                                                modifiedCommunity = GlobalProfile.globalCommunityList[i];
                                                break;
                                              }
                                            }

                                            for (int i = 0; i < GlobalProfile.hotCommunityList.length; i++) {
                                              if (GlobalProfile.hotCommunityList[i].id == widget.community!.id) {
                                                GlobalProfile.hotCommunityList[i] = Community.fromJson(json.decode(res.toString()), isHot: true);
                                                modifiedCommunity = GlobalProfile.hotCommunityList[i];
                                                break;
                                              }
                                            }

                                            for (int i = 0; i < GlobalProfile.popularCommunityList.length; i++) {
                                              if (GlobalProfile.popularCommunityList[i].id == widget.community!.id) {
                                                GlobalProfile.popularCommunityList[i] = Community.fromJson(json.decode(res.toString()));
                                                modifiedCommunity = GlobalProfile.popularCommunityList[i];
                                                break;
                                              }
                                            }

                                            for (int i = 0; i < GlobalProfile.filteredCommunityList.length; i++) {
                                              bool isHot = false;

                                              if (GlobalProfile.filteredCommunityList[i].id == widget.community!.id) {
                                                if (GlobalProfile.filteredCommunityList[i].type == COMMUNITY_HOT_TYPE) isHot = true; // 필터 리스트에 있는 타입에 따라 hot 체크

                                                GlobalProfile.filteredCommunityList[i] = Community.fromJson(json.decode(res.toString()), isHot: isHot);
                                                modifiedCommunity = GlobalProfile.filteredCommunityList[i];
                                              }
                                            }

                                            for (int i = 0; i < GlobalProfile.searchedCommunityList.length; i++) {
                                              if (GlobalProfile.searchedCommunityList[i].id == widget.community!.id) {
                                                GlobalProfile.searchedCommunityList[i] = Community.fromJson(json.decode(res.toString()));
                                                modifiedCommunity = GlobalProfile.searchedCommunityList[i];
                                                break;
                                              }
                                            }

                                            for (int i = 0; i < GlobalProfile.myCommunityList.length; i++) {
                                              if (GlobalProfile.myCommunityList[i].id == widget.community!.id) {
                                                GlobalProfile.myCommunityList[i] = Community.fromJson(json.decode(res.toString()));
                                                modifiedCommunity = GlobalProfile.myCommunityList[i];
                                                break;
                                              }
                                            }
                                          } on DioError catch (e) {
                                            DialogBuilder(context).hideOpenDialog();
                                            throw FetchDataException(e.message ?? '');
                                          }

                                          DialogBuilder(context).hideOpenDialog();
                                          Get.back();
                                          Get.back(result: [modifiedCommunity]);
                                          showSheepsToast(context: context, text: "게시물이 수정되었습니다.");
                                        } else {
                                          //신규게시글
                                          FormData formData = FormData.fromMap({
                                            "userid": GlobalProfile.loggedInUser.userID,
                                            "category": category,
                                            "title": controlSpace(controller.title.value),
                                            "contents": controlSpace(controller.contents.value),
                                            "accessToken": GlobalProfile.accessToken,
                                            'type': 0,
                                            "0": controller.imgUrlFilePathList.length >= 1
                                                ? await MultipartFile.fromFile(controller.imgUrlFilePathList[0], filename: getFileName(0, controller.imgUrlFilePathList[0]))
                                                : null,
                                            "1": controller.imgUrlFilePathList.length >= 2
                                                ? await MultipartFile.fromFile(controller.imgUrlFilePathList[1], filename: getFileName(1, controller.imgUrlFilePathList[1]))
                                                : null,
                                            "2": controller.imgUrlFilePathList.length >= 3
                                                ? await MultipartFile.fromFile(controller.imgUrlFilePathList[2], filename: getFileName(2, controller.imgUrlFilePathList[2]))
                                                : null,
                                          });

                                          DialogBuilder(context).showLoadingIndicator();

                                          var res;
                                          late Community newCommunity;
                                          try {
                                            res = await dio.post(ApiProvider().getImgUrl + '/CommunityPost/Insert', data: formData);
                                          } on DioError catch (e) {
                                            DialogBuilder(context).hideOpenDialog();
                                            throw FetchDataException(e.message ?? '');
                                          }
                                          newCommunity = Community.fromJson(json.decode(res.toString()));
                                          GlobalProfile.globalCommunityList.insert(0, newCommunity);
                                          if (widget.selectedCategory != null && widget.selectedCategory == category) {
                                            GlobalProfile.filteredCommunityList.insert(0, newCommunity);
                                          }
                                          GlobalProfile.communityReply.clear(); // 댓글 초기화
                                          DialogBuilder(context).hideOpenDialog();
                                          showSheepsToast(context: context, text: "게시물이 등록되었습니다.");
                                          Get.back();
                                          Get.off(() => CommunityMainDetail(newCommunity));
                                        }
                                      },
                                    );
                                  } else {
                                    Get.snackbar('title', '이미지 변환중');
                                  }
                                }
                              },
                              text: widget.isEdit ? '수정 완료' : '작성 완료',
                              isOK: controller.isFilledRequired.value,
                            )),
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

  Widget categorySelectContainer({required String text, required bool isSelected}) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? sheepsColorGreen : Colors.white,
        border: Border.all(color: isSelected ? sheepsColorGreen : sheepsColorGrey, width: 1 * sizeUnit),
        borderRadius: BorderRadius.circular(16 * sizeUnit),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit, vertical: 9 * sizeUnit),
            child: Text(
              text,
              style: SheepsTextStyle.hint4Profile().copyWith(color: isSelected ? Colors.white : sheepsColorGrey),
            ),
          ),
        ],
      ),
    );
  }
}
