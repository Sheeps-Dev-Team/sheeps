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

class CommunityWriteNoticePostPage extends StatefulWidget {
  final bool isEdit; //수정일때만 true
  final Community community; //수정일때만 받음

  const CommunityWriteNoticePostPage({Key? key, this.isEdit = false, required this.community}) : super(key: key);

  @override
  _CommunityWriteNoticePostPageState createState() => _CommunityWriteNoticePostPageState();
}

class _CommunityWriteNoticePostPageState extends State<CommunityWriteNoticePostPage> with SingleTickerProviderStateMixin {
  CommunityWriteController controller = Get.put(CommunityWriteController());
  TextEditingController titleController = TextEditingController();
  TextEditingController contentsController = TextEditingController();
  MultipartImgFilesController _filesController = Get.put(MultipartImgFilesController());

  late AnimationController extendedController;

  bool isFinishFileLoading = false; //파일생성 완료 전 이미지변경방지
  late Community community;

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
      controller.loading(widget.community);
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
                  appBar: SheepsAppBar(context, widget.isEdit ? '공지글 수정' : '공지글 쓰기', backFunc: () {
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
                              Obx(() => sheepsTextField(
                                    context,
                                    title: '제목',
                                    controller: titleController,
                                    hintText: '제목 입력(2자 이상)',
                                    errorText: controller.title.value.isNotEmpty && removeSpace(controller.title.value).length < 2 ? '너무 짧아요! 2글자 이상 작성해주세요.' : null,
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
                                    hintText: '내용을 입력해 주세요 (10자 이상)',
                                    borderColor: sheepsColorGreen,
                                    errorText: controller.contents.value.isNotEmpty &&
                                            controller.contents.value.replaceAll(' ', '').replaceAll('　', '').replaceAll('\u200B', '').replaceAll('\n', '').length < 10
                                        ? '너무 짧아요! 10글자 이상 작성해주세요.'
                                        : null,
                                    onChange: (val) {
                                      controller.contents.value = val;
                                      controller.checkFilledRequired();
                                    },
                                  )),
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
                                height: 104 * sizeUnit,
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
                        padding: EdgeInsets.all(20 * sizeUnit),
                        child: SheepsBottomButton(
                              context: context,
                              function: () {
                                if (isFinishFileLoading) {
                                  String category = '공지';

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
                                          "id": widget.community.id,
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

                                          for (int i = 0; i < GlobalProfile.noticeCommunityList.length; i++) {
                                            if (GlobalProfile.noticeCommunityList[i].id == widget.community.id) {
                                              GlobalProfile.noticeCommunityList[i] = Community.fromJson(json.decode(res.toString()), isNotice: true);
                                              modifiedCommunity = GlobalProfile.noticeCommunityList[i];
                                              break;
                                            }
                                          }

                                          for (int i = 0; i < GlobalProfile.myCommunityList.length; i++) {
                                            if (GlobalProfile.myCommunityList[i].id == widget.community.id) {
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
                                        newCommunity = Community.fromJson(json.decode(res.toString()), isNotice: true);
                                        GlobalProfile.noticeCommunityList.insert(0, newCommunity);
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
                              },
                              text: widget.isEdit ? '수정 완료' : '작성 완료',
                              isOK: true,
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

  Widget categorySelectContainer({required String text, required bool isSelected}) {
    return Container(
      height: 24 * sizeUnit,
      decoration: BoxDecoration(
        color: isSelected ? sheepsColorGreen : Colors.white,
        border: Border.all(color: isSelected ? sheepsColorGreen : sheepsColorLightGrey, width: 1 * sizeUnit),
        borderRadius: BorderRadius.circular(12 * sizeUnit),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit),
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
