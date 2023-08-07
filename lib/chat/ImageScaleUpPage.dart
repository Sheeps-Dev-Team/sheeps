
import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/LoadingUI.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import '';
import 'package:get/get.dart';

class ImageScaleUpPage extends StatefulWidget {
  final String fileString;
  final String title;
  final bool isFile;

  const ImageScaleUpPage({Key? key, required this.fileString,required this.title, this.isFile = true}) : super(key: key);

  @override
  _ImageScaleUpPageState createState() => _ImageScaleUpPageState();
}

class _ImageScaleUpPageState extends State<ImageScaleUpPage> with SingleTickerProviderStateMixin {
  AnimationController? extendedController;

  @override
  void initState() {
    super.initState();
    extendedController = AnimationController(vsync: this, duration: const Duration(seconds: 1), lowerBound: 0.0, upperBound: 1.0);
  }

  @override
  void dispose() {
    super.dispose();
    extendedController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: null,
        child: Container(
          color: Colors.black,
          child: Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.black,
                leading: Padding(
                  padding: EdgeInsets.only(left: 11 * sizeUnit),
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SvgPicture.asset(
                        svgBackArrow,
                        width: 28 * sizeUnit,
                        height: 28 * sizeUnit,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )),
            body: Column(
              children: [
                Expanded(
                  child: widget.isFile ? fileImageBody() : networkImageBody(),
                ),
                buildsSaveIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget networkImageBody() {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Image.network(
        widget.fileString,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Padding(
            padding: EdgeInsets.all(8.0 * sizeUnit),
            child: Center(
              child: CircularProgressIndicator(
                color: sheepsColorGreen,
              ),
            ),
          );
        },
      ),
    );
  }

  Container fileImageBody() {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
            //image: MemoryImage(base64Decode(message.message)),
            image: FileImage(File(widget.fileString)),
            fit: BoxFit.contain),
      ),
    );
  }

  Widget buildsSaveIcon() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8 * sizeUnit),
      width: double.infinity,
      color: Colors.black,
      child: GestureDetector(
        onTap: () {
          DialogBuilder(context).showLoadingIndicator();
          ImageGallerySaver.saveFile(widget.fileString)?.then((value) {
            DialogBuilder(context).hideOpenDialog();
            showSheepsToast(context: context, text: "사진 저장 완료");
          });
        },
        child: SvgPicture.asset(
          svgSaveIcon,
          width: 40 * sizeUnit,
          height: 40 * sizeUnit,
        ),
      ),
    );
  }
}
