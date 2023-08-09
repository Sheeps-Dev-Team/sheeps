import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';

class AuthFileUploadPage extends StatefulWidget {
  final String appBarTitle;
  final File? authFile;

  const AuthFileUploadPage({Key? key, required this.appBarTitle, required this.authFile}) : super(key: key);

  @override
  _AuthFileUploadPageState createState() => _AuthFileUploadPageState();
}

class _AuthFileUploadPageState extends State<AuthFileUploadPage> {
  File? tmpFile;

  @override
  void initState() {
    super.initState();
    if (widget.authFile != null) {
      tmpFile = widget.authFile;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: WillPopScope(
              onWillPop: null,
              child: Scaffold(
                appBar: SheepsAppBar(context, widget.appBarTitle),
                body: Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await SheepsBottomSheetForImg(
                                context,
                                cameraFunc: () async {
                                  XFile? f = await ImagePicker().pickImage(source: ImageSource.camera);
                                  if (f == null) return;
                                  tmpFile = File(f.path);
                                  setState(() {});
                                  Get.back();
                                },
                                galleryFunc: () async {
                                  XFile? f = await ImagePicker().pickImage(source: ImageSource.gallery);
                                  if (f == null) return;

                                  int fileSize = (await f.readAsBytes()).lengthInBytes;

                                  if (isBigFile(fileSize)) return;

                                  tmpFile = File(f.path);
                                  setState(() {});
                                  Get.back();
                                },
                              );
                            },
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              dashPattern: [6 * sizeUnit, 6 * sizeUnit],
                              strokeWidth: 2 * sizeUnit,
                              radius: Radius.circular(16 * sizeUnit),
                              color: sheepsColorGrey,
                              child: Container(
                                width: 280 * sizeUnit,
                                height: 396 * sizeUnit,
                                constraints: BoxConstraints(maxHeight: Get.height*0.55),//세로길이 짧은 폰을 위해
                                decoration: BoxDecoration(
                                  color: sheepsColorLightGrey,
                                  borderRadius: BorderRadius.all(Radius.circular(16 * sizeUnit)),
                                  image: tmpFile != null ? DecorationImage(image: FileImage(tmpFile!), fit: BoxFit.contain) : null,
                                ),
                                child: tmpFile == null
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              svgSheepsGreenImageLogo,
                                              width: 145 * sizeUnit,
                                              color: Colors.white,
                                            ),
                                            SizedBox(height: 12 * sizeUnit),
                                            Text(
                                              '이곳을 눌러 사진을 올려주세요!',
                                              style: SheepsTextStyle.b2().copyWith(color: sheepsColorGrey),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          Row(children: [SizedBox(height: 28 * sizeUnit)]),
                          Text(
                            '파일 형식은 사진만 가능해요!\nEX) JPG, JPEG, PNG 등',
                            style: SheepsTextStyle.b2(),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20 * sizeUnit),
                      child: SheepsBottomButton(
                        context: context,
                        function: () {
                          Get.back(result: [tmpFile]);
                        },
                        text: '확인',
                        color: sheepsColorBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
