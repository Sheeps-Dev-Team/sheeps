import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';


import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';
import 'package:sheeps_app/Community/CommunityWriteNoticePostPage.dart';
import 'package:sheeps_app/chat/ImageScaleUpPage.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/LoadingUI.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/Community/CommunityReplyPage.dart';
import 'package:sheeps_app/Community/CommunityWritePage.dart';
import 'package:sheeps_app/Community/models/CommunityDetailController.dart';
import 'package:sheeps_app/Setting/PageReport.dart';
import 'package:sheeps_app/profile/DetailProfile.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/User.dart';
import 'models/Community.dart';

const int deletedReply = 0; // 삭제된 댓글
const int normalReply = 1; // 정상 댓글

class CommunityMainDetail extends StatefulWidget {
  // Community a_community;
  final Community a_community;

  const CommunityMainDetail(this.a_community);

  // CommunityMainDetail(Community community) {
  //   a_community = community;
  // }

  @override
  _CommunityMainDetailState createState() => _CommunityMainDetailState();
}

class _CommunityMainDetailState extends State<CommunityMainDetail> with SingleTickerProviderStateMixin {
  final CommunityDetailController controller = Get.put(CommunityDetailController());
  final communityReplyController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final String grey3dot = 'assets/images/Community/Grey3dot.svg';
  final String grey2dot = 'assets/images/Community/Grey2dot.svg';
  final String GreyThumbIcon = 'assets/images/Public/GreyThumbIcon.svg';
  final String GreySpeechBubble = 'assets/images/Public/GreySpeechBubble.svg';
  final String sheepsGreyImageAndWriteLogo = 'assets/images/Public/sheepsGreyImageAndWriteLogo.svg';
  final String GreenThumb = 'assets/images/Public/GreenThumb.svg';

  int replyReplyInt = -1;
  bool keyboardState = false;
  late Community _community;
  late UserData user;

  GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey();
  late AnimationController extendedController;
  bool isCanTapLike = true; // 좋아요 연속 호출 방지
  bool isCanWriteReply = true; // 댓글 연속으로 쓰기 방지
  int tapLikeDelayMilliseconds = 500;
  bool isBlind = false; // 커뮤니티 글 블라인드 여부

  List<String> urlList = [];

  bool isAlarm = false;

  bool isReady = true;

  @override
  void initState() {
    super.initState();
    _community = widget.a_community;
    user = GlobalProfile.getUserByUserID(_community.userID);
    var keyboardVisibilityController = KeyboardVisibilityController();

    keyboardState = keyboardVisibilityController.isVisible;
    keyboardVisibilityController.onChange.listen((bool visible) {
      keyboardState = visible;
    });

    extendedController = AnimationController(vsync: this, duration: const Duration(seconds: 1), lowerBound: 0.0, upperBound: 1.0);
    if (_community.imageUrl1 != null) urlList.add(_community.imageUrl1!);
    if (_community.imageUrl2 != null) urlList.add(_community.imageUrl2!);
    if (_community.imageUrl3 != null) urlList.add(_community.imageUrl3!);

    isAlarm = true;

    // Future.microtask(() async {
    //   var res = await ApiProvider().post('/CommunityPost/Select/Subscribe', jsonEncode({"postID": _community.id, "userID": GlobalProfile.loggedInUser!.userID}));
    //
    //   if (res != null) {
    //     isAlarm = true;
    //   }
    // }).then((value) {
    //   setState(() {});
    // });

    // controller.communityLikeCheck(_community, GlobalProfile.loggedInUser!.userID);

    communityReplyController.addListener(() {
      controller.checkTextField(removeSpace(communityReplyController.text));
    });
  }

  @override
  void dispose() {
    extendedController.dispose();
    communityReplyController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isBlind = blindCheck(declareLength: _community.declareLength, likeLength: _community.communityLike.length);

    return RefreshIndicator(
      backgroundColor: sheepsColorGreen,
      color: Colors.white,
      key: refreshKey,
      onRefresh: () async {
        // var tmp = await ApiProvider().post(
        //     '/CommunityPost/PostSelect',
        //     jsonEncode({
        //       "id": _community.id,
        //     }));
        //
        // GlobalProfile.communityReply = [];
        // if (tmp == null) return;
        // for (int i = 0; i < tmp.length; i++) {
        //   Map<String, dynamic> data = tmp[i];
        //   CommunityReply tmpReply = CommunityReply.fromJson(data);
        //   GlobalProfile.communityReply.add(tmpReply);
        // }
        //
        // syncRepliesLength(communityList: GlobalProfile.globalCommunityList, community: _community);
        // syncRepliesLength(communityList: GlobalProfile.popularCommunityList, community: _community);
        // syncRepliesLength(communityList: GlobalProfile.hotCommunityList, community: _community);
        // syncRepliesLength(communityList: GlobalProfile.filteredCommunityList, community: _community);
        // syncRepliesLength(communityList: GlobalProfile.searchedCommunityList, community: _community);
        // syncRepliesLength(communityList: GlobalProfile.myCommunityList, community: _community);
        // setState(() {});
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: WillPopScope(
          onWillPop: null,
          child: KeyboardDismissOnTap(
            child: Container(
              color: Colors.white,
              child: SafeArea(
                child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: SheepsAppBar(
                    context,
                    '',
                    actions: [
                      GestureDetector(
                        onTap: () async {
                          // var res = await ApiProvider().post('/CommunityPost/Update/Subscribe', jsonEncode({"postID": _community.id, "userID": GlobalProfile.loggedInUser!.userID}));
                          //
                          // if (res['item'] == 1) {
                          //   isAlarm = false;
                          // } else {
                          //   isAlarm = true;
                          // }
                          // setState(() {});
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
                      // GestureDetector(
                      //   onTap: () => Get.dialog(_settingDialog(), barrierColor: Color.fromRGBO(204, 204, 204, 0.5)),
                      //   child: Padding(
                      //     padding: EdgeInsets.only(right: 12 * sizeUnit),
                      //     child: SvgPicture.asset(
                      //       grey3dot,
                      //       width: 28 * sizeUnit,
                      //       height: 28 * sizeUnit,
                      //     ),
                      //   ),
                      // ),
                    ],
                    bottomLine: true,
                  ),
                  body: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          controller: scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20 * sizeUnit),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    profileSmallWrapItem(_community.category),
                                    SizedBox(height: 8 * sizeUnit),
                                    isBlind ? communityExceptionText(bigFont: true) : Text(_community.title, style: SheepsTextStyle.h3()),
                                    SizedBox(height: 8 * sizeUnit),
                                    Row(
                                      children: [
                                        Container(
                                          child: Text(
                                            _community.category == "비밀" ? "익명" : user.name,
                                            style: SheepsTextStyle.b3()
                                                .copyWith(color: _community.category == '비밀' && _community.userID == GlobalProfile.loggedInUser!.userID ? sheepsColorGreen : sheepsColorBlack),
                                          ),
                                        ),
                                        SizedBox(width: 4 * sizeUnit),
                                        Text(
                                          timeCheck(_community.updatedAt),
                                          style: SheepsTextStyle.b3().copyWith(color: sheepsColorDarkGrey),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12 * sizeUnit),
                                    if (!isBlind)
                                      Container(
                                        child: Text(_community.contents, style: SheepsTextStyle.badgeTitle().copyWith(height: 17 / 14)),
                                      ),
                                    SizedBox(height: 20 * sizeUnit),
                                  ],
                                ),
                              ),
                              if (!isBlind) urlList.length > 0 ? getImgWidget() : SizedBox.shrink(),
                              SizedBox(height: 12 * sizeUnit),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    likeAndCommentButton(), // 좋아요, 댓글 버튼
                                    if (!isBlind)
                                      Container(
                                        height: 4 * sizeUnit,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(
                                            urlList.length,
                                                (index) => Obx(() => AnimatedContainer(
                                              duration: Duration(milliseconds: 100),
                                              margin: EdgeInsets.symmetric(horizontal: 2 * sizeUnit),
                                              width: 4 * sizeUnit,
                                              height: 4 * sizeUnit,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: index == controller.currentPage.value ? sheepsColorGreen : sheepsColorGrey,
                                              ),
                                            )),
                                          ),
                                        ),
                                      ),
                                    // Expanded(
                                    //   child: Row(
                                    //     children: [
                                    //       Spacer(),
                                    //       GestureDetector(
                                    //         onTap: () {
                                    //           if (isReady) {
                                    //             isReady = false;
                                    //             Future.delayed(Duration(milliseconds: 800), () => isReady = true);
                                    //             shareCommunity();
                                    //           }
                                    //         },
                                    //         child: SvgPicture.asset(
                                    //           svgShareBox,
                                    //           width: 20 * sizeUnit,
                                    //           height: 20 * sizeUnit,
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12 * sizeUnit),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                                child: Divider(height: 1, color: sheepsColorGrey),
                              ),
                              replyListView(),
                              SizedBox(height: 20 * sizeUnit),
                            ],
                          ),
                        ),
                      ),
                      // Container(
                      //   width: 360 * sizeUnit,
                      //   padding: EdgeInsets.only(bottom: 20 * sizeUnit),
                      //   color: Colors.white,
                      //   child: Row(
                      //     children: [
                      //       SizedBox(width: 12 * sizeUnit),
                      //       Container(
                      //           width: 336 * sizeUnit,
                      //           constraints: BoxConstraints(maxHeight: 60 * sizeUnit),
                      //           decoration: BoxDecoration(
                      //             border: Border.all(color: sheepsColorGrey),
                      //             borderRadius: BorderRadius.circular(18 * sizeUnit),
                      //           ),
                      //           child: Row(
                      //             children: [
                      //               Flexible(
                      //                 child: TextField(
                      //                   controller: communityReplyController,
                      //                   maxLines: null,
                      //                   textInputAction: TextInputAction.newline,
                      //                   style: SheepsTextStyle.b3(),
                      //                   decoration: InputDecoration(
                      //                     hintText: '댓글 내용을 입력해주세요',
                      //                     hintStyle: SheepsTextStyle.hint4Profile(),
                      //                     isDense: true,
                      //                     contentPadding: EdgeInsets.only(left: 12 * sizeUnit),
                      //                     focusedBorder: InputBorder.none,
                      //                     enabledBorder: InputBorder.none,
                      //                   ),
                      //                   maxLength: 200,
                      //                   // buildCounter: (context, {currentLength, isFocused, maxLength}) => null,
                      //                 ),
                      //               ),
                      //               InkWell(
                      //                 onTap: () async {
                      //                   // if (controller.isInputColor.value) {
                      //                   //   if (isCanWriteReply) {
                      //                   //     isCanWriteReply = false;
                      //                   //
                      //                   //     DialogBuilder(context).showLoadingIndicator();
                      //                   //
                      //                   //     var jsonCommunity = await ApiProvider().post(
                      //                   //         '/CommunityPost/PostSelect',
                      //                   //         jsonEncode({
                      //                   //           "id": _community.id,
                      //                   //         }));
                      //                   //
                      //                   //     if (jsonCommunity == null) {
                      //                   //       DialogBuilder(context).hideOpenDialog();
                      //                   //
                      //                   //       controller.syncDeletedList(communityList: GlobalProfile.globalCommunityList, community: _community);
                      //                   //       controller.syncDeletedList(communityList: GlobalProfile.popularCommunityList, community: _community);
                      //                   //       controller.syncDeletedList(communityList: GlobalProfile.hotCommunityList, community: _community);
                      //                   //       controller.syncDeletedList(communityList: GlobalProfile.filteredCommunityList, community: _community);
                      //                   //       controller.syncDeletedList(communityList: GlobalProfile.searchedCommunityList, community: _community);
                      //                   //       controller.syncDeletedList(communityList: GlobalProfile.myCommunityList, community: _community);
                      //                   //
                      //                   //       showSheepsDialog(
                      //                   //         context: context,
                      //                   //         title: '삭제된 게시글입니다.',
                      //                   //         description: '삭제된 게시글이에요.',
                      //                   //         okFunc: () {
                      //                   //           Get.back();
                      //                   //           Get.back();
                      //                   //         },
                      //                   //         isCancelButton: false,
                      //                   //         isBarrierDismissible: false,
                      //                   //       );
                      //                   //       return;
                      //                   //     }
                      //                   //
                      //                   //     await ApiProvider().post(
                      //                   //         '/CommunityPost/InsertReply',
                      //                   //         jsonEncode({
                      //                   //           "userID": GlobalProfile.loggedInUser!.userID,
                      //                   //           "postID": _community.id,
                      //                   //           "contents": controlSpace(communityReplyController.text),
                      //                   //         }));
                      //                   //
                      //                   //     var tmp = await ApiProvider().post(
                      //                   //         '/CommunityPost/PostSelect',
                      //                   //         jsonEncode({
                      //                   //           "id": _community.id,
                      //                   //         }));
                      //                   //     if (tmp == null) return;
                      //                   //     GlobalProfile.communityReply = [];
                      //                   //     for (int i = 0; i < tmp.length; i++) {
                      //                   //       Map<String, dynamic> data = tmp[i];
                      //                   //       CommunityReply tmpReply = CommunityReply.fromJson(data);
                      //                   //       GlobalProfile.communityReply.add(tmpReply);
                      //                   //     }
                      //                   //
                      //                   //     DialogBuilder(context).hideOpenDialog();
                      //                   //
                      //                   //     // 댓글 갯수 올려주기
                      //                   //     syncRepliesLength(communityList: GlobalProfile.globalCommunityList, community: _community);
                      //                   //     syncRepliesLength(communityList: GlobalProfile.popularCommunityList, community: _community);
                      //                   //     syncRepliesLength(communityList: GlobalProfile.hotCommunityList, community: _community);
                      //                   //     syncRepliesLength(communityList: GlobalProfile.filteredCommunityList, community: _community);
                      //                   //     syncRepliesLength(communityList: GlobalProfile.searchedCommunityList, community: _community);
                      //                   //     syncRepliesLength(communityList: GlobalProfile.myCommunityList, community: _community);
                      //                   //
                      //                   //     FocusManager.instance.primaryFocus?.unfocus();
                      //                   //     SystemChannels.textInput.invokeMethod('TextInput.hide');
                      //                   //
                      //                   //     communityReplyController.clear(); // 텍스트 필드 클리어
                      //                   //     FocusManager.instance.primaryFocus?.unfocus(); // 포커스 해제
                      //                   //     SystemChannels.textInput.invokeMethod('TextInput.hide');
                      //                   //
                      //                   //     // 스크롤 밑으로
                      //                   //     Timer(Duration(milliseconds: 100), () {
                      //                   //       scrollController.animateTo(scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                      //                   //     });
                      //                   //
                      //                   //     // 연속 호출 방지
                      //                   //     Future.delayed(Duration(milliseconds: tapLikeDelayMilliseconds), () {
                      //                   //       isCanWriteReply = true;
                      //                   //     });
                      //                   //
                      //                   //     setState(() {});
                      //                   //   }
                      //                   // }
                      //
                      //                   setState(() {
                      //
                      //                   });
                      //                 },
                      //                 child: Obx(() => Container(
                      //                   margin: EdgeInsets.only(left: 4 * sizeUnit, right: 8 * sizeUnit),
                      //                   width: 22 * sizeUnit,
                      //                   height: 32 * sizeUnit,
                      //                   decoration: BoxDecoration(
                      //                     shape: BoxShape.circle,
                      //                     color: controller.isInputColor.value ? sheepsColorGreen : sheepsColorGrey,
                      //                   ),
                      //                   child: Center(
                      //                     child: Icon(
                      //                       Icons.arrow_upward,
                      //                       size: 16 * sizeUnit,
                      //                       color: Colors.white,
                      //                     ),
                      //                   ),
                      //                 )),
                      //               )
                      //             ],
                      //           )),
                      //     ],
                      //   ),
                      // ),
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

  Widget replyListView() {
    if (GlobalProfile.communityReply.isEmpty)
      return Padding(
        padding: EdgeInsets.only(top: 9 * sizeUnit),
        child: Center(child: Text('댓글이 없습니다.', style: SheepsTextStyle.b3())),
      );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: GlobalProfile.communityReply.length,
          itemBuilder: (BuildContext context, int index) {
            UserData replyUser = GlobalProfile.getUserByUserID(GlobalProfile.communityReply[index].userID);
            CommunityReply communityReply = GlobalProfile.communityReply[index];

            return replyItem(replyUser, communityReply);
          }),
    );
  }

  Widget replyItem(UserData replyUser, CommunityReply communityReply) {
    bool isReplyLike = controller.replyLikeCheck(communityReply);

    return GestureDetector(
      onTap: () {
        Get.to(() => CommunityReplyPage(communityReply: communityReply, community: _community));
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12 * sizeUnit),
          Text(
            controller.setReplyWriterName(_community, replyUser),
            style: SheepsTextStyle.h4().copyWith(color: _community.category == '비밀' && communityReply.userID == GlobalProfile.loggedInUser!.userID ? sheepsColorGreen : sheepsColorBlack),
          ),
          SizedBox(height: 12 * sizeUnit),
          if (communityReply.isShow == normalReply) ...[
            if (blindCheck(declareLength: communityReply.declareLength, likeLength: communityReply.communityReplyLike.length))
              replyExceptionText(isBlind: true)
            else
              Text(
                communityReply.contents,
                style: SheepsTextStyle.b3().copyWith(height: 14 / 12),
              ),
          ] else ...[
            replyExceptionText(),
          ],
          SizedBox(height: 12 * sizeUnit),
          Row(
            children: [
              Text(timeCheck(communityReply.updatedAt), style: SheepsTextStyle.info2()),
              SizedBox(width: 8 * sizeUnit),
              GestureDetector(
                onTap: () async {
                  if (communityReply.isShow == normalReply && !blindCheck(declareLength: communityReply.declareLength, likeLength: communityReply.communityReplyLike.length)) {
                    await controller.replyLikeFunc(communityReply, isReplyLike);
                    setState(() {});
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      GreyThumbIcon,
                      width: 18 * sizeUnit,
                      height: 18 * sizeUnit,
                      color: isReplyLike ? sheepsColorGreen : sheepsColorDarkGrey,
                    ),
                    SizedBox(width: 8 * sizeUnit),
                    Text(
                      communityReply.communityReplyLike.length > 99 ? '99+' : communityReply.communityReplyLike.length.toString(),
                      style: SheepsTextStyle.s3().copyWith(color: isReplyLike ? sheepsColorGreen : sheepsColorDarkGrey),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8 * sizeUnit),
              GestureDetector(
                onTap: () {
                  if (communityReply.communityReplyReply.isEmpty) {
                    Get.to(() => CommunityReplyPage(communityReply: communityReply, community: _community));
                  } else {
                    controller.toggleReReply(communityReply);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      GreySpeechBubble,
                      width: 18 * sizeUnit,
                      height: 18 * sizeUnit,
                      color: sheepsColorDarkGrey,
                    ),
                    SizedBox(width: 8 * sizeUnit),
                    Text(
                      communityReply.communityReplyReply.length.toString(),
                      style: SheepsTextStyle.info2(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 대댓글 리스트 뷰
          if (communityReply.communityReplyReply.isNotEmpty) ...[
            Obx(() => controller.showReplyList.contains(communityReply.id)
                ? GestureDetector(
              onTap: () {
                Get.to(() => CommunityReplyPage(communityReply: communityReply, community: _community));
              },
              child: Container(
                margin: EdgeInsets.only(top: 7 * sizeUnit),
                padding: EdgeInsets.all(12 * sizeUnit),
                decoration: BoxDecoration(
                  color: sheepsColorLightGrey,
                  borderRadius: BorderRadius.circular(15 * sizeUnit),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: communityReply.communityReplyReply.length,
                  itemBuilder: (context, index) => replyReplyItem(communityReply.communityReplyReply[index], communityReply, index == communityReply.communityReplyReply.length - 1),
                ),
              ),
            )
                : Container())
          ],
          SizedBox(height: 12 * sizeUnit),
          Container(
            width: double.infinity,
            height: 1,
            color: sheepsColorLightGrey,
          )
        ],
      ),
    );
  }

  Widget replyReplyItem(CommunityReplyReply communityReplyReply, CommunityReply communityReply, bool isLast) {
    return Column(
      children: [
        Row(
          children: [
            Column(
              children: [
                SvgPicture.asset("assets/images/Community/ReplyIcon.svg"),
                SizedBox(height: 4 * sizeUnit),
              ],
            ),
            SizedBox(width: 8 * sizeUnit),
            Text(
              _community.category == '비밀' ? '익명' : GlobalProfile.getUserByUserID(communityReplyReply.userID).name,
              style: SheepsTextStyle.h4().copyWith(color: _community.category == '비밀' && communityReplyReply.userID == GlobalProfile.loggedInUser!.userID ? sheepsColorGreen : sheepsColorBlack),
            ),
            SizedBox(width: 8 * sizeUnit),
            Text(
              timeCheck(communityReplyReply.updatedAt),
              style: SheepsTextStyle.info2(),
            ),
          ],
        ),
        SizedBox(height: 4 * sizeUnit),
        Row(
          children: [
            SizedBox(width: 16 * sizeUnit),
            if (communityReplyReply.isShow == normalReply) ...[
              Expanded(
                child: blindCheck(declareLength: communityReplyReply.declareLength, likeLength: communityReplyReply.communityReplyReplyLike.length)
                    ? replyExceptionText(isBlind: true, isReply: false)
                    : Text(
                  communityReplyReply.contents,
                  style: SheepsTextStyle.b3().copyWith(height: 14 / 12),
                ),
              ),
            ] else ...[
              replyExceptionText(isReply: false)
            ],
          ],
        ),
        if (!isLast) SizedBox(height: 12 * sizeUnit),
      ],
    );
  }

  Widget likeAndCommentButton() {
    return Expanded(
      child: Row(
        children: [
          InkWell(
            splashColor: Colors.transparent,
            onTap: () async {
              if (!isBlind) {
                if (isCanTapLike) {
                  isCanTapLike = false;
                  if (controller.isCommunityLike.value == false) {
                    var result = await ApiProvider().post('/CommunityPost/InsertLike', jsonEncode({"userID": GlobalProfile.loggedInUser!.userID, "postID": _community.id}));

                    if (result != null) {
                      CommunityLike tmpLike = InsertLike.fromJson(result).item;

                      // 리스트 동기화
                      controller.syncLikeListOnInsert(communityList: GlobalProfile.noticeCommunityList, community: _community, tmpLike: tmpLike);
                      controller.syncLikeListOnInsert(communityList: GlobalProfile.globalCommunityList, community: _community, tmpLike: tmpLike);
                      controller.syncLikeListOnInsert(communityList: GlobalProfile.popularCommunityList, community: _community, tmpLike: tmpLike);
                      controller.syncLikeListOnInsert(communityList: GlobalProfile.hotCommunityList, community: _community, tmpLike: tmpLike);
                      controller.syncLikeListOnInsert(communityList: GlobalProfile.filteredCommunityList, community: _community, tmpLike: tmpLike);
                      controller.syncLikeListOnInsert(communityList: GlobalProfile.searchedCommunityList, community: _community, tmpLike: tmpLike);
                      controller.syncLikeListOnInsert(communityList: GlobalProfile.myCommunityList, community: _community, tmpLike: tmpLike);

                      controller.isCommunityLike.value = true;
                    }
                  } else {
                    await ApiProvider().post('/CommunityPost/InsertLike', jsonEncode({"userID": GlobalProfile.loggedInUser!.userID, "postID": _community.id}));

                    // 리스트 동기화
                    controller.syncLikeListOnDelete(communityList: GlobalProfile.globalCommunityList, community: _community);
                    controller.syncLikeListOnDelete(communityList: GlobalProfile.noticeCommunityList, community: _community);
                    controller.syncLikeListOnDelete(communityList: GlobalProfile.popularCommunityList, community: _community);
                    controller.syncLikeListOnDelete(communityList: GlobalProfile.hotCommunityList, community: _community);
                    controller.syncLikeListOnDelete(communityList: GlobalProfile.filteredCommunityList, community: _community);
                    controller.syncLikeListOnDelete(communityList: GlobalProfile.searchedCommunityList, community: _community);
                    controller.syncLikeListOnDelete(communityList: GlobalProfile.myCommunityList, community: _community);

                    controller.isCommunityLike.value = false;
                  }

                  Future.delayed(Duration(milliseconds: tapLikeDelayMilliseconds), () {
                    isCanTapLike = true;
                  });
                }
              }
            },
            child: Obx(() => Container(
              color: Colors.white,
              child: Row(
                children: [
                  SvgPicture.asset(
                    GreyThumbIcon,
                    width: 24 * sizeUnit,
                    height: 24 * sizeUnit,
                    color: controller.isCommunityLike.value ? sheepsColorGreen : sheepsColorDarkGrey,
                  ),
                  SizedBox(width: 8 * sizeUnit),
                  Text(
                    ((_community.communityLike.length) > 99) ? "99+" : '${_community.communityLike.length}',
                    style: SheepsTextStyle.badgeTitle().copyWith(color: controller.isCommunityLike.value ? sheepsColorGreen : sheepsColorDarkGrey),
                  ),
                ],
              ),
            )),
          ),
          SizedBox(width: 12 * sizeUnit),
          Row(
            children: [
              SvgPicture.asset(
                GreySpeechBubble,
                width: 24 * sizeUnit,
                height: 24 * sizeUnit,
              ),
              SizedBox(width: 8 * sizeUnit),
              Text(
                (GlobalProfile.communityReply.length) > 99 ? "99+" : '${GlobalProfile.communityReply.length}',
                style: SheepsTextStyle.badgeTitle().copyWith(color: sheepsColorDarkGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _settingDialog() {
    bool isMe = widget.a_community.userID == GlobalProfile.loggedInUser!.userID;

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
                  customShapeButton(
                    text: '수정하기',
                    press: () {
                      void syncPost(value) {
                        _community = value[0];
                        urlList.clear();
                        if (_community.imageUrl1 != null) urlList.add(_community.imageUrl1!);
                        if (_community.imageUrl2 != null) urlList.add(_community.imageUrl2!);
                        if (_community.imageUrl3 != null) urlList.add(_community.imageUrl3!);
                      }

                      if (isBlind) {
                        Get.back();
                        return showSheepsToast(context: context, text: "블라인드 된 글은 수정할 수 없습니다.");
                      }

                      Get.back();
                      // 공지글일 때
                      if (_community.category == '공지') {
                        Get.to(() => CommunityWriteNoticePostPage(isEdit: true, community: _community))?.then((value) {
                          if (value != null) {
                            setState(() {
                              syncPost(value);
                            });
                          }
                        });
                      } else {
                        Get.back();
                        Get.to(() => CommunityWritePage(isEdit: true, community: _community))?.then((value) {
                          if (value != null) {
                            setState(() {
                              syncPost(value);
                            });
                          }
                        });
                      }
                    },
                  ),
                  SizedBox(height: 12 * sizeUnit),
                  customShapeButton(
                    text: '삭제하기',
                    color: Color(0xFFFF3D00),
                    press: () {
                      if (isBlind) {
                        Get.back();
                        return showSheepsToast(context: context, text: "블라인드 된 글은 삭제할 수 없습니다.");
                      }
                      showSheepsCustomDialog(
                        title: Text(
                          "'게시글'을 삭제\n하시겠어요?",
                          style: SheepsTextStyle.dialogTitle().copyWith(height: 1.2, fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        contents: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
                            children: [
                              TextSpan(text: '삭제된 글은 '),
                              TextSpan(text: '복구', style: SheepsTextStyle.b3().copyWith(fontWeight: FontWeight.bold)),
                              TextSpan(text: '되지 않습니다!'),
                            ],
                          ),
                        ),
                        okText: '삭제하기',
                        okButtonColor: sheepsColorBlue,
                        okFunc: () async {
                          await ApiProvider().post(
                              '/CommunityPost/Delete',
                              jsonEncode({
                                "id": _community.id,
                              }));

                          for (int i = 0; i < GlobalProfile.noticeCommunityList.length; i++) {
                            if (GlobalProfile.noticeCommunityList[i].id == _community.id) {
                              GlobalProfile.noticeCommunityList.removeAt(i);
                              break;
                            }
                          }

                          for (int i = 0; i < GlobalProfile.globalCommunityList.length; i++) {
                            if (GlobalProfile.globalCommunityList[i].id == _community.id) {
                              GlobalProfile.globalCommunityList.removeAt(i);
                              break;
                            }
                          }

                          for (int i = 0; i < GlobalProfile.hotCommunityList.length; i++) {
                            if (GlobalProfile.hotCommunityList[i].id == _community.id) {
                              GlobalProfile.hotCommunityList.removeAt(i);
                              break;
                            }
                          }

                          for (int i = 0; i < GlobalProfile.popularCommunityList.length; i++) {
                            if (GlobalProfile.popularCommunityList[i].id == _community.id) {
                              GlobalProfile.popularCommunityList.removeAt(i);
                              break;
                            }
                          }

                          for (int i = 0; i < GlobalProfile.filteredCommunityList.length; i++) {
                            if (GlobalProfile.filteredCommunityList[i].id == _community.id) {
                              GlobalProfile.filteredCommunityList.removeAt(i);
                              break;
                            }
                          }

                          for (int i = 0; i < GlobalProfile.searchedCommunityList.length; i++) {
                            if (GlobalProfile.searchedCommunityList[i].id == _community.id) {
                              GlobalProfile.searchedCommunityList.removeAt(i);
                              break;
                            }
                          }

                          for (int i = 0; i < GlobalProfile.myCommunityList.length; i++) {
                            if (GlobalProfile.myCommunityList[i].id == _community.id) {
                              GlobalProfile.myCommunityList.removeAt(i);
                              break;
                            }
                          }

                          showSheepsToast(context: context, text: "게시글을 삭제했습니다.");
                          Get.back();
                          Get.back();
                          Get.back();
                        },
                      );
                    },
                  ),
                ] else ...[
                  if (_community.category != '비밀') ...[
                    customShapeButton(
                      text: '프로필 보기',
                      press: () {
                        Get.back();
                        Get.to(() => DetailProfile(index: 0, user: user));
                      },
                    ),
                    SizedBox(height: 12 * sizeUnit),
                  ],
                  if (_community.category != '공지') ...[
                    customShapeButton(
                      text: '신고하기',
                      color: Color(0xFFFF3D00),
                      press: () {
                        Get.back();
                        Get.to(
                              () => PageReport(
                            userID: GlobalProfile.loggedInUser!.userID,
                            reportedID: _community.id.toString(),
                            classification: 'Community',
                            postType: reportForCommunity,
                            community: _community,
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getImgWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit),
      child: Container(
          height: 328 * sizeUnit,
          color: Colors.white,
          child: PageView.builder(
            onPageChanged: (value) => controller.setCurrentPage(value),
            itemCount: urlList.length,
            itemBuilder: (context, index) => buildImgWidget(index),
          )),
    );
  }

  Widget buildImgWidget(int index) {
    return GestureDetector(
      onTap: () {
        Get.to(
              () => ImageScaleUpPage(
            fileString: urlList[index],
            title: '',
            isFile: false,
          ),
          transition: Transition.fadeIn,
          fullscreenDialog: true,
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.0 * sizeUnit),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                Positioned(
                  child: Container(
                    width: 328 * sizeUnit,
                    height: 328 * sizeUnit,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8 * sizeUnit),
                      child: FittedBox(
                        child: getExtendedImage(urlList[index], 60, extendedController),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  child: Container(
                    width: 328 * sizeUnit,
                    height: 328 * sizeUnit,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8 * sizeUnit),
                      child: FittedBox(
                        child: FadeInImage.memoryNetwork(
                          placeholder: kTransparentImage,
                          image: getOptimizeImageURL(urlList[index], 0),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void shareCommunity() async {
    DialogBuilder(context).showLoadingIndicator();
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://sheepsapp.page.link',
        link: Uri.parse('https://sheepsapp.page.link/community?id=${_community.id}'),
        androidParameters: AndroidParameters(
          packageName: 'kr.noteasy.sheeps_app',
          minimumVersion: 1, //실행 가능 최소 버전
        ),
        iosParameters: IOSParameters(
          bundleId: 'kr.noteasy.sheepsApp',
          minimumVersion: '1.0',
          appStoreId: '1558625011',
        ));

    // final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    // final Uri shortUrl = shortDynamicLink.shortUrl;
    final Uri shortUrl = parameters.link;

    String name = _community.title;

    DialogBuilder(context).hideOpenDialog();
    Share.share('커뮤니티 글 보기\n$name\n$shortUrl', subject: '스타트업 필수 앱! 사담!\n');
  }
}

class UrlLauncher {
  void launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
