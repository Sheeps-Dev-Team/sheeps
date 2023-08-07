import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/Setting/PageReport.dart';
import 'package:sheeps_app/network/ApiProvider.dart';

const List<String> reportList = [
  '토픽에 맞지 않는 글',
  '욕설 / 비하발언',
  '특정인 비방',
  '개인사생활 침해',
  '19+ 만남 / 채팅유도',
  '음란물',
  '게시글 / 댓글 도배',
  '홍보 및 광고',
  '닉네임 신고',
  '기타',
];

class PageReportController extends GetxController {
  RxString reportTitle = ''.obs;
  RxString reportContent = ''.obs;
  int type = 0; // 신고 이유

  // type reportTitle => int
  // postType = 커뮤니티, 댓글, 답글 => int
  Future<void> submitReport(
    BuildContext context, {
    @required String classification,
    @required int userID,
    @required String reportedID,
    @required String contents,
    int postType,
    Community community,
    CommunityReply communityReply,
    CommunityReplyReply communityReplyReply,
  }) async {
    if (classification == 'ChatRoom') {
      var res = await ApiProvider().post(
          '/Room/Declare',
          jsonEncode({
            "userID": userID,
            "roomName": reportedID,
            "contents": contents,
            "type": type,
          }));

      if (res != null) {
        showSheepsToast(context: context, text: '신고되었습니다.');
        Get.back();
        Get.back();
      }
    } else if (classification == 'Community') {
      var res = await ApiProvider().post(
          '/CommunityPost/Declare',
          jsonEncode({
            "userID": userID,
            "targetID": reportedID,
            "contents": contents,
            "type": type,
            "postType": postType,
          }));

      if (res != null) {
        // 중복 신고가 아닐 때
        if (res[1]) {
          if (postType == reportForCommunity)
            community.declareLength++; // 커뮤니티 신고 갯수 추가
          else if (postType == reportForReply)
            communityReply.declareLength++; // 댓글 신고 갯수 추가
          else if (postType == reportForReplyReply) communityReplyReply.declareLength++; // 답글 신고 갯수 추가
          showSheepsToast(context: context, text: "신고되었습니다.");
        } else {
          showSheepsToast(context: context, text: "이미 신고한 글입니다.");
        }

        if (postType != reportForReplyReply) Get.back();
        Get.back();
        Get.back();
      }
    } else {
      showSheepsToast(context: context, text: "신고 과정에 오류가 발생했습니다.");
    }
  }
}
