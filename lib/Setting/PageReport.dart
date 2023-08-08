
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:get/get.dart';

import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/Setting/model/PageReportController.dart';

const int reportForCommunity = 0; // 커뮤니티 신고
const int reportForReply = 1; // 댓글 신고
const int reportForReplyReply = 2; // 답글 신고

class PageReport extends StatefulWidget {
  final int userID;
  final String classification;
  final String reportedID;
  final int postType;
  final Community? community;
  final CommunityReply? communityReply;
  final CommunityReplyReply? communityReplyReply;

  PageReport({Key? key, required this.userID, required this.classification, required this.reportedID, this.postType = 0, this.community, this.communityReply, this.communityReplyReply})
      : super(key: key);

  @override
  _PageReportState createState() => _PageReportState();
}

class _PageReportState extends State<PageReport> {
  final TextEditingController textEditingController = TextEditingController();
  final PageReportController controller = Get.put(PageReportController());

  int? userID;
  String? classification;
  String? reportedID;
  int? postType;
  Community? community;
  CommunityReply? communityReply;
  CommunityReplyReply? communityReplyReply;

  bool? isContents;

  @override
  void initState() {
    userID = widget.userID;
    classification = widget.classification;
    reportedID = widget.reportedID;
    postType = widget.postType;
    community = widget.community;
    communityReply = widget.communityReply;
    communityReplyReply = widget.communityReplyReply;
    isContents = false;
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: null,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => unFocus(context), // 텍스트 포커스 해제
                child: Scaffold(
                  appBar: SheepsAppBar(context, '신고하기', bottomLine: true),
                  body: SingleChildScrollView(
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: reportList.length,
                              itemBuilder: (context, index) => reportItem(reportList[index], index),
                            ),
                            SizedBox(height: 30 * sizeUnit),
                            reportContentWidget(),
                            SizedBox(height: 140 * sizeUnit),
                          ],
                        ),
                        Obx(() => bottomButton(context))
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Positioned bottomButton(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: Container(
        width: 360 * sizeUnit,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20 * sizeUnit, vertical: 20 * sizeUnit),
        child: SheepsBottomButton(
          context: context,
          isOK: controller.reportTitle.value.isNotEmpty && (controller.reportContent.value.isEmpty || controller.reportContent.value.length >= 10),
          function: () {
            if (controller.reportTitle.value.isNotEmpty && (controller.reportContent.value.isEmpty || controller.reportContent.value.length >= 10)) {
              showSheepsCustomDialog(
                title: Text(
                  "신고 하시겠어요?",
                  style: SheepsTextStyle.dialogTitle().copyWith(height: 1.2, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                contents: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
                    children: [
                      TextSpan(text: '허위 신고 시\n'),
                      TextSpan(text: '관리자에 의해 제재 ', style: SheepsTextStyle.b3().copyWith(fontWeight: FontWeight.bold)),
                      TextSpan(text: '받을 수 있습니다.'),
                    ],
                  ),
                ),
                okText: '제출하기',
                okButtonColor: sheepsColorBlue,
                okFunc: () => controller.submitReport(
                  context,
                  classification: classification!,
                  reportedID: reportedID!,
                  contents: textEditingController.text,
                  postType: postType!,
                  userID: userID!,
                  community: community!,
                  communityReply: communityReply!,
                  communityReplyReply: communityReplyReply!,
                ),
              );
            }
          },
          text: '신고하기',
        ),
      ),
    );
  }

  Padding reportContentWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('신고 내용', style: SheepsTextStyle.h3()),
          SizedBox(height: 12 * sizeUnit),
          Obx(() => multiLineTextField(
                controller: textEditingController,
                hintText: '내용을 입력해 주세요  (최소 10자 이상)',
                onChange: (value) => controller.reportContent(value),
                errorText: controller.reportContent.value.isNotEmpty && controller.reportContent.value.length < 10 ? '너무 짧아요! 최소 10글자 이상 작성해주세요.' : null,
                maxTextLength: 500,
              )),
        ],
      ),
    );
  }

  Widget reportItem(String reportTitle, int index) {
    return Column(
      children: [
        Obx(() => RadioListTile(
              value: reportTitle,
              title: Text(reportTitle, style: SheepsTextStyle.b1()),
              activeColor: sheepsColorGreen,
              groupValue: controller.reportTitle.value,
              onChanged: (value) {
                controller.reportTitle(value);
                controller.type = index;
              },
            )),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
          height: 1 * sizeUnit,
          width: double.infinity,
          color: sheepsColorGrey,
        )
      ],
    );
  }
}
