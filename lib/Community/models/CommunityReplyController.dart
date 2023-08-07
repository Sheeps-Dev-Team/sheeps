import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/LoadingUI.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';

class CommunityReplyController extends GetxController {
  static get to => Get.find<CommunityReplyController>();

  RxBool isReplyLike = false.obs; // 댓글 좋아요 여부
  RxBool isInputColor = false.obs; // 댓글 쓰기 컬러
  RxInt showOptionInt = 0.obs; // 대댓글 옵션 보기

  bool isCanTapLike = true; // 좋아요 함수 연속호출 방지
  bool isCanWriteReplyReply = true; // 답글 연속 쓰기 방지

  // 글쓴이 이름 set
  String setReplyReplyWriterName(Community community, CommunityReply communityReply, UserData replyReplyUser){
    String name = replyReplyUser.name;

    if(community.category == '비밀'){
      if(communityReply.userID == replyReplyUser.userID) name = '댓쓴이양';
      else name = '익명';
    }

    return name;
  }

  // 대댓글 옵션 토글
  void toggleOption(int reReplyId) {
    if (showOptionInt.value == reReplyId)
      showOptionInt(0);
    else
      showOptionInt(reReplyId);
  }

  // 텍스트 필드 글 체크
  void checkTextField(String text) {
    if (text.isEmpty)
      isInputColor(false);
    else
      isInputColor(true);
  }

  // 댓글 좋아요 체크
  void replyLikeCheck(CommunityReply communityReply) {
    communityReply.communityReplyLike.forEach((element) {
      if(element.userID == GlobalProfile.loggedInUser.userID) isReplyLike(true);
    });
  }

  // 대댓글 좋아요 체크
  bool reReplyLikeCheck(CommunityReplyReply communityReplyReply) {
    bool isLike = false;

    for (CommunityReplyReplyLike c in communityReplyReply.communityReplyReplyLike) {
      if (c.userID == GlobalProfile.loggedInUser.userID) isLike = true;
      break;
    }

    return isLike;
  }

  // 새로고침 이벤트
  Future<void> refreshEvent(Community community, CommunityReply communityReply) async{
    var tmp = await ApiProvider().post(
        '/CommunityPost/Select/Reply',
        jsonEncode({
          "replyID": communityReply.id,
        }));

    communityReply.communityReplyReply.clear();
    if (tmp == null) return;
    for (int i = 0; i < tmp.length; i++) {
      CommunityReplyReply tmpReplyReply = CommunityReplyReply.fromJson(tmp[i]);
      communityReply.communityReplyReply.add(tmpReplyReply);
    }
  }

  // 댓글 삭제 이벤트
  Future<void> replyDeleteEvent(BuildContext context, CommunityReply communityReply) async {
    if (communityReply.isShow == 0) {
      Get.back();
      Get.back();
      return showSheepsToast(context: context, text: "이미 삭제된 댓글입니다.");
    }

    if(blindCheck(declareLength: communityReply.declareLength, likeLength: communityReply.communityReplyLike.length)){
      Get.back();
      Get.back();
      return showSheepsToast(context: context, text: "블라인드 된 댓글은 삭제할 수 없습니다.");
    }

    var res = await ApiProvider().post(
        '/CommunityPost/Update/IsShow/Reply',
        jsonEncode({
          "id": communityReply.id,
          "isShow": 0,
        }));

    if (res != null) {
      communityReply.isShow = 0;
      Get.back();
      Get.back();
      showSheepsToast(context: context, text: "댓글을 삭제했습니다.");
    }
  }

  // 답글 삭제 이벤트
  Future<void> reReplyDeleteEvent(BuildContext context, CommunityReplyReply communityReplyReply) async {
    if (communityReplyReply.isShow == 0) {
      Get.back();
      return showSheepsToast(context: context, text: "이미 삭제된 답글입니다.");
    }

    if(blindCheck(declareLength: communityReplyReply.declareLength, likeLength: communityReplyReply.communityReplyReplyLike.length)){
      Get.back();
      return showSheepsToast(context: context, text: "블라인드 된 답글은 삭제할 수 없습니다.");
    }

    var res = await ApiProvider().post(
        '/CommunityPost/Update/IsShow/ReplyReply',
        jsonEncode({
          "id": communityReplyReply.id,
          "isShow": 0,
        }));

    if (res != null) {
      communityReplyReply.isShow = 0;
      showOptionInt(0); // 옵션 버튼 끄기

      Get.back();
      showSheepsToast(context: context, text: "답글을 삭제했습니다.");
    }
  }

  // 답글 쓰기 함수
  Future<void> reReplySubmitFunc({
    required BuildContext context,
    required TextEditingController textEditingController,
    required CommunityReply communityReply,
    required Community community,
    required ScrollController scrollController,
  }) async {
    if (isInputColor.value) {

      if (isCanWriteReplyReply) {
        isCanWriteReplyReply = false; // 중복 쓰기 제거

        DialogBuilder(context).showLoadingIndicator();

        // 커뮤니티 삭제 되었을 시
        var jsonCommunity = await ApiProvider().post(
            '/CommunityPost/PostSelect',
            jsonEncode({
              "id": community.id,
            }));

        if (jsonCommunity == null) {
          for (int i = 0; i < GlobalProfile.globalCommunityList.length; i++) {
            if (GlobalProfile.globalCommunityList[i].id == community.id) {
              GlobalProfile.globalCommunityList.removeAt(i);
              break;
            }
          }

          DialogBuilder(context).hideOpenDialog();

          showSheepsDialog(
            context: context,
            title: '삭제된 게시글입니다.',
            description: '삭제된 게시글이에요.',
            okFunc: () {
              Get.back();
              Get.back();
              Get.back();
            },
            isCancelButton: false,
            isBarrierDismissible: false,
          );
          return;
        }

        var res = await ApiProvider().post(
            '/CommunityPost/InsertReplyReply',
            jsonEncode({
              "userID": GlobalProfile.loggedInUser.userID,
              "replyID": communityReply.id,
              "contents": controlSpace(textEditingController.text),
            }));

        if(res != null) {
          // 답글 새로고침
          var tmp = await ApiProvider().post(
              '/CommunityPost/Select/Reply',
              jsonEncode({
                "replyID": communityReply.id,
              }));
          if (tmp == null) return;
          communityReply.communityReplyReply.clear();
          for (int i = 0; i < tmp.length; i++) {
            CommunityReplyReply tmpReplyReply = CommunityReplyReply.fromJson(tmp[i]);
            communityReply.communityReplyReply.add(tmpReplyReply);
          }
        }

        DialogBuilder(context).hideOpenDialog();

        textEditingController.clear(); // 텍스트 필드 깨끗이
        FocusManager.instance.primaryFocus?.unfocus(); // 포커스 해제

        // 스크롤 밑으로
        Timer(Duration(milliseconds: 100), () {
          scrollController.animateTo(scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        });

        // 연속 호출 방지
        Future.delayed(Duration(milliseconds: 500), () {
          isCanWriteReplyReply = true;
        });
      }
    }
  }

  // 댓글 좋아요 함수
  Future<void> replyLikeFunc(CommunityReply communityReply) async {
    if(blindCheck(declareLength: communityReply.declareLength, likeLength: communityReply.communityReplyLike.length)) return;

    if (isCanTapLike) {
      isCanTapLike = false; // 연속 호출 방지

      var result = await ApiProvider().post(
          '/CommunityPost/InsertReplyLike',
          jsonEncode({
            "userID": GlobalProfile.loggedInUser.userID,
            "replyID": communityReply.id,
          }));

      if (!isReplyLike.value) {
        if (result != null) {
          CommunityReplyLike user = InsertReplyLike.fromJson(result).item;
          communityReply.communityReplyLike.add(user);

          isReplyLike(true);
        }
      } else {
        int idx = -1;

        if (result != null) {
          for (int i = 0; i < communityReply.communityReplyLike.length; i++) {
            if (communityReply.communityReplyLike[i].userID == GlobalProfile.loggedInUser.userID) {
              idx = i;
              break;
            }
          }

          if (idx != -1) communityReply.communityReplyLike.removeAt(idx); // 리스트에서 좋아요 삭제

          isReplyLike(false);
        }
      }

      // 연속 호출 방지
      Future.delayed(Duration(milliseconds: 500), () {
        isCanTapLike = true;
      });
    }
  }

  // 답글 좋아요 함수
  Future<void> reReplyLikeFunc(CommunityReplyReply communityReplyReply, bool isReReplyLike) async {
    if (isCanTapLike) {
      isCanTapLike = false; // 연속 호출 방지

      var result = await ApiProvider().post(
          '/CommunityPost/InsertReplyReplyLike',
          jsonEncode({
            "userID": GlobalProfile.loggedInUser.userID,
            "replyreplyID": communityReplyReply.id,
          }));

      if (!isReReplyLike) {
        if (result != null) {
          CommunityReplyReplyLike user = InsertReplyReplyLike.fromJson(result).item;
          communityReplyReply.communityReplyReplyLike.add(user);

          isReReplyLike = true;
        }
      } else {
        int idx = -1;

        if (result != null) {
          for (int i = 0; i < communityReplyReply.communityReplyReplyLike.length; i++) {
            if (communityReplyReply.communityReplyReplyLike[i].userID == GlobalProfile.loggedInUser.userID) {
              idx = i;
              break;
            }
          }

          if (idx != -1) communityReplyReply.communityReplyReplyLike.removeAt(idx); // 리스트에서 좋아요 삭제

          isReReplyLike = false;
        }
      }

      // 연속 호출 방지
      Future.delayed(Duration(milliseconds: 500), () {
        isCanTapLike = true;
      });
    }
  }
}
