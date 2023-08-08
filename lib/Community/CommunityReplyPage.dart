import 'dart:convert';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sheeps_app/Community/CommunityMainDetail.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/Community/models/CommunityReplyController.dart';
import 'package:sheeps_app/Setting/PageReport.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/profile/DetailProfile.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';

class CommunityReplyPage extends StatefulWidget {
  final Community community;
  final CommunityReply communityReply;

  const CommunityReplyPage({Key? key, required this.communityReply, required this.community}) : super(key: key);

  @override
  _CommunityReplyPageState createState() => _CommunityReplyPageState();
}

class _CommunityReplyPageState extends State<CommunityReplyPage> {
  final CommunityReplyController controller = Get.put(CommunityReplyController());
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final String grey3dot = 'assets/images/Community/Grey3dot.svg';
  final String thumbIcon = 'assets/images/Public/GreyThumbIcon.svg';
  final String commentIcon = 'assets/images/Public/GreySpeechBubble.svg';

  late Community community;
  late CommunityReply communityReply;
  late UserData replyUser;
  GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey();
  bool isAlarm = false;

  @override
  void initState() {
    super.initState();

    community = widget.community;
    communityReply = widget.communityReply;
    replyUser = GlobalProfile.getUserByUserID(communityReply.userID);

    controller.replyLikeCheck(communityReply); // 댓글 좋아요 체크
    textEditingController.addListener(() => controller.checkTextField(removeSpace(textEditingController.text))); // 텍스트 필드 글 체크

    Future.microtask(() async {
      var res = await ApiProvider().post('/CommunityPost/Select/ReplySubscribe', jsonEncode({"replyID": communityReply.id, "userID": GlobalProfile.loggedInUser!.userID}));

      if (res != null) {
        isAlarm = true;
      }
    }).then((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      backgroundColor: sheepsColorGreen,
      color: Colors.white,
      key: refreshKey,
      onRefresh: () => controller.refreshEvent(community, communityReply).then((value) => setState(() {})),
      child: WillPopScope(
        onWillPop: null,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
            child: Container(
              color: Colors.white,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () {
                    unFocus(context); // 텍스트 포커스 해제
                    if (controller.showOptionInt.value != 0) controller.showOptionInt(0);
                  },
                  child: Scaffold(
                    appBar: customAppBar(context),
                    body: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                SizedBox(height: 20 * sizeUnit),
                                replyItem(),
                                SizedBox(height: 12 * sizeUnit),
                                reReplyListView(),
                                SizedBox(height: 20 * sizeUnit),
                              ],
                            ),
                          ),
                        ),
                        customTextField(context),
                        SizedBox(height: 20 * sizeUnit),
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

  Widget customTextField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      child: Container(
        constraints: BoxConstraints(maxHeight: 60 * sizeUnit),
        decoration: BoxDecoration(
          border: Border.all(color: sheepsColorGrey),
          borderRadius: BorderRadius.circular(16 * sizeUnit),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: textEditingController,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                style: SheepsTextStyle.b3(),
                decoration: InputDecoration(
                  hintText: '답글 내용을 입력해주세요.',
                  hintStyle: SheepsTextStyle.hint4Profile(),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.only(left: 12 * sizeUnit, bottom: 8 * sizeUnit, top: 8 * sizeUnit, right: 8 * sizeUnit),
                ),
                maxLength: 200,
                // buildCounter: (context, {currentLength, isFocused, maxLength}) => null,
              ),
            ),
            GestureDetector(
              onTap: () {
                controller
                    .reReplySubmitFunc(
                      context: context,
                      textEditingController: textEditingController,
                      communityReply: communityReply,
                      community: community,
                      scrollController: scrollController,
                    )
                    .then((value) => setState(() {}));
              },
              child: Obx(() => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 4 * sizeUnit, right: 8 * sizeUnit),
                      child: Container(
                        width: 22 * sizeUnit,
                        height: 32 * sizeUnit,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: controller.isInputColor.value ? sheepsColorGreen : sheepsColorGrey,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_upward,
                            size: 16 * sizeUnit,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget reReplyListView() {
    if (communityReply.communityReplyReply.isEmpty)
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
        child: Column(
          children: [
            Container(
              height: 1,
              color: sheepsColorLightGrey,
            ),
            SizedBox(height: 9 * sizeUnit),
            Text('답글이 없습니다.', style: SheepsTextStyle.b3()),
          ],
        ),
      );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      child: Container(
        padding: EdgeInsets.fromLTRB(16 * sizeUnit, 12 * sizeUnit, 16 * sizeUnit, 20 * sizeUnit),
        decoration: BoxDecoration(color: sheepsColorLightGrey, borderRadius: BorderRadius.circular(15 * sizeUnit)),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: communityReply.communityReplyReply.length,
          itemBuilder: (context, index) {
            UserData reReplyUser = GlobalProfile.getUserByUserID(communityReply.communityReplyReply[index].userID);
            CommunityReplyReply communityReplyReply = communityReply.communityReplyReply[index];

            return reReplyItem(reReplyUser, communityReplyReply, index == (communityReply.communityReplyReply.length - 1));
          },
        ),
      ),
    );
  }

  Widget reReplyItem(UserData reReplyUser, CommunityReplyReply communityReplyReply, bool isLast) {
    bool isReReplyLike = controller.reReplyLikeCheck(communityReplyReply);

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12 * sizeUnit),
            Row(
              children: [
                Expanded(
                  child: Text(
                    controller.setReplyReplyWriterName(community, communityReply, reReplyUser),
                    style: SheepsTextStyle.h4().copyWith(color: community.category == '비밀' && communityReplyReply.userID == GlobalProfile.loggedInUser!.userID ? sheepsColorGreen : sheepsColorBlack),
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.toggleOption(communityReplyReply.id),
                  child: SvgPicture.asset(grey3dot),
                ),
              ],
            ),
            SizedBox(height: 12 * sizeUnit),
            if (communityReplyReply.isShow == normalReply) ...[
              if (blindCheck(declareLength: communityReplyReply.declareLength, likeLength: communityReplyReply.communityReplyReplyLike.length))
                replyExceptionText(isBlind: true, isReply: false)
              else
                Text(
                  communityReplyReply.contents,
                  style: SheepsTextStyle.b3().copyWith(height: 14 / 12),
                ),
            ] else ...[
              replyExceptionText(isReply: false)
            ],
            SizedBox(height: 12 * sizeUnit),
            Row(
              children: [
                Text(timeCheck(communityReplyReply.updatedAt), style: SheepsTextStyle.info2()),
                SizedBox(width: 8 * sizeUnit),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async {
                    if (communityReplyReply.isShow == normalReply && !blindCheck(declareLength: communityReplyReply.declareLength, likeLength: communityReplyReply.communityReplyReplyLike.length)) {
                      await controller.reReplyLikeFunc(communityReplyReply, isReReplyLike);
                      setState(() {});
                    }
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        thumbIcon,
                        width: 18 * sizeUnit,
                        height: 18 * sizeUnit,
                        color: isReReplyLike ? sheepsColorGreen : sheepsColorGrey,
                      ),
                      SizedBox(width: 8 * sizeUnit),
                      Text(
                        communityReplyReply.communityReplyReplyLike.length > 99 ? '99+' : communityReplyReply.communityReplyReplyLike.length.toString(),
                        style: SheepsTextStyle.s3().copyWith(color: isReReplyLike ? sheepsColorGreen : sheepsColorGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isLast) ...[
              SizedBox(height: 12 * sizeUnit),
              Container(height: 1, width: double.infinity, color: sheepsColorGrey),
            ],
          ],
        ),
        Obx(
          () => controller.showOptionInt.value == communityReplyReply.id
              ? Positioned(
                  top: 30 * sizeUnit,
                  right: 0 * sizeUnit,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (GlobalProfile.loggedInUser!.userID == communityReplyReply.userID) ...[
                        reReplyShapeButton(
                          communityReplyReply,
                          text: '삭제하기',
                          textColor: sheepsColorRed,
                          press: () => showSheepsCustomDialog(
                            title: Text(
                              "'답글'을 삭제\n하시겠어요?",
                              style: SheepsTextStyle.dialogTitle().copyWith(height: 1.2, fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                            contents: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
                                children: [
                                  TextSpan(text: '삭제된 답글은 '),
                                  TextSpan(text: '복구', style: SheepsTextStyle.b3().copyWith(fontWeight: FontWeight.bold)),
                                  TextSpan(text: '되지 않습니다!'),
                                ],
                              ),
                            ),
                            okText: '삭제하기',
                            okButtonColor: sheepsColorBlue,
                            okFunc: () => controller.reReplyDeleteEvent(context, communityReplyReply).then((value) => setState(() {})),
                          ),
                        ),
                      ] else ...[
                        if (community.category != '비밀') ...[
                          reReplyShapeButton(
                            communityReplyReply,
                            text: '프로필 보기',
                            press: () => Get.to(() => DetailProfile(index: 0, user: GlobalProfile.getUserByUserID(reReplyUser.userID))),
                          ),
                          SizedBox(height: 4 * sizeUnit),
                        ],
                        reReplyShapeButton(
                          communityReplyReply,
                          textColor: sheepsColorRed,
                          text: '신고하기',
                          press: () => Get.to(() => PageReport(
                                userID: GlobalProfile.loggedInUser!.userID,
                                reportedID: communityReplyReply.id.toString(),
                                classification: 'Community',
                                postType: reportForReplyReply,
                                communityReplyReply: communityReplyReply,
                              ))?.then((value) => setState(() {})),
                        ),
                      ],
                    ],
                  ),
                )
              : Container(),
        ),
      ],
    );
  }

  GestureDetector reReplyShapeButton(CommunityReplyReply communityReplyReply, {required Function press, required String text, Color textColor = sheepsColorBlack}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => press,
      child: Container(
        height: 22 * sizeUnit,
        padding: EdgeInsets.symmetric(horizontal: 6 * sizeUnit),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * sizeUnit),
          border: Border.all(color: sheepsColorGrey),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: SheepsTextStyle.b4().copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget replyItem() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(community.category == '비밀' ? '익명' : replyUser.name,
              style: SheepsTextStyle.h3().copyWith(color: community.category == '비밀' && communityReply.userID == GlobalProfile.loggedInUser!.userID ? sheepsColorGreen : sheepsColorBlack)),
          SizedBox(height: 12 * sizeUnit),
          if (communityReply.isShow == normalReply) ...[
            if (blindCheck(declareLength: communityReply.declareLength, likeLength: communityReply.communityReplyLike.length))
              replyExceptionText(isBlind: true, bigFont: true)
            else
              Text(
                communityReply.contents,
                style: SheepsTextStyle.b3().copyWith(height: 14 / 12),
              ),
          ] else ...[
            replyExceptionText(bigFont: true)
          ],
          SizedBox(height: 12 * sizeUnit),
          Row(
            children: [
              Text(timeCheck(communityReply.updatedAt), style: SheepsTextStyle.b4()),
              SizedBox(width: 8 * sizeUnit),
              Obx(() => customIconButton(
                  icon: thumbIcon,
                  text: communityReply.communityReplyLike.length > 99 ? '99+' : communityReply.communityReplyLike.length.toString(),
                  color: controller.isReplyLike.value ? sheepsColorGreen : sheepsColorDarkGrey,
                  press: () {
                    if (communityReply.isShow == normalReply && !blindCheck(declareLength: communityReply.declareLength, likeLength: communityReply.communityReplyLike.length)) {
                      controller.replyLikeFunc(communityReply);
                    }
                  })),
              SizedBox(width: 12 * sizeUnit),
              customIconButton(
                icon: commentIcon,
                text: communityReply.communityReplyReply.length > 99 ? '99+' : communityReply.communityReplyReply.length.toString(),
                press: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget customIconButton({required String icon, required String text, Color color = sheepsColorDarkGrey, required Function press}) {
    return GestureDetector(
      onTap: () => press,
      behavior: HitTestBehavior.translucent,
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
            width: 24 * sizeUnit,
            height: 24 * sizeUnit,
            color: color,
          ),
          SizedBox(width: 8 * sizeUnit),
          Text(
            text,
            style: SheepsTextStyle.badgeTitle().copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget customAppBar(BuildContext context) {
    return SheepsAppBar(
      context,
      '댓글',
      actions: [
        GestureDetector(
          onTap: () async {
            var res = await ApiProvider().post('/CommunityPost/Update/ReplySubscribe', jsonEncode({"replyID": communityReply.id, "userID": GlobalProfile.loggedInUser!.userID}));

            if (res['item'] == 1) {
              isAlarm = false;
            } else {
              isAlarm = true;
            }
            setState(() {});
          },
          child: SvgPicture.asset(
            isAlarm ? 'assets/images/Chat/alarmOn.svg' : 'assets/images/Chat/alarmOff.svg',
            width: 20 * sizeUnit,
            height: 20 * sizeUnit,
            color: isAlarm ? null : sheepsColorDarkGrey,
          ),
        ),
        SizedBox(
          width: 4 * sizeUnit,
        ),
        Padding(
          padding: EdgeInsets.only(right: 12 * sizeUnit),
          child: GestureDetector(
            onTap: () => Get.dialog(_settingDialog(), barrierColor: Color.fromRGBO(204, 204, 204, 0.5)),
            child: SvgPicture.asset(
              grey3dot,
              width: 28 * sizeUnit,
              height: 28 * sizeUnit,
            ),
          ),
        ),
      ],
      bottomLine: true,
    );
  }

  Widget _settingDialog() {
    bool isMe = GlobalProfile.loggedInUser!.userID == replyUser.userID;

    return GestureDetector(
      onTap: () => Get.back(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SizedBox.expand(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8 * sizeUnit, horizontal: 12 * sizeUnit),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 32 * sizeUnit,
                    height: 32 * sizeUnit,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.clear,
                      size: 20 * sizeUnit,
                      color: sheepsColorDarkGrey,
                    ),
                  ),
                ),
                SizedBox(height: 19 * sizeUnit),
                if (isMe) ...[
                  SizedBox(height: 12 * sizeUnit),
                  customShapeButton(
                    text: '삭제하기',
                    color: Color(0xFFFF3D00),
                    press: () {
                      showSheepsCustomDialog(
                        title: Text(
                          "'댓글'을 삭제\n하시겠어요?",
                          style: SheepsTextStyle.dialogTitle().copyWith(height: 1.2, fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        contents: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
                            children: [
                              TextSpan(text: '삭제된 댓글은 '),
                              TextSpan(text: '복구', style: SheepsTextStyle.b3().copyWith(fontWeight: FontWeight.bold)),
                              TextSpan(text: '되지 않습니다!'),
                            ],
                          ),
                        ),
                        okText: '삭제하기',
                        okButtonColor: sheepsColorBlue,
                        okFunc: () => controller.replyDeleteEvent(context, communityReply).then((value) => setState(() {})),
                      );
                    },
                  ),
                ] else ...[
                  if (community.category != '비밀') ...[
                    customShapeButton(
                      text: '프로필 보기',
                      press: () {
                        Get.back();
                        Get.to(() => DetailProfile(index: 0, user: replyUser));
                      },
                    ),
                    SizedBox(height: 12 * sizeUnit),
                  ],
                  customShapeButton(
                    text: '신고하기',
                    color: Color(0xFFFF3D00),
                    press: () {
                      Get.back();
                      Get.to(
                        () => PageReport(
                          userID: GlobalProfile.loggedInUser!.userID,
                          reportedID: communityReply.id.toString(),
                          classification: 'Community',
                          postType: reportForReply,
                          communityReply: communityReply,
                        ),
                      )?.then((value) => setState(() {}));
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
