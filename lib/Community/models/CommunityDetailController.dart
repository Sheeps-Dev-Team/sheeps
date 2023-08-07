import 'dart:convert';

import 'package:get/get.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';

class CommunityDetailController extends GetxController{
  static get to => Get.find<CommunityDetailController>();
  bool isCanTapLike = true; // 연속 호출 방지
  RxBool isCommunityLike = false.obs; // 커뮤니티 글 좋아요 여부
  RxInt currentPage = 0.obs; // 사진 페이지
  RxList showReplyList = [].obs; // 대댓글 보여주는 리스트
  RxBool isInputColor = false.obs; // 댓글 쓰기 컬러

  // 글쓴이 이름 set
  String setReplyWriterName(Community community, UserData replyUser){
    String name = replyUser.name;

    if(community.category == '비밀'){
      if(community.userID == replyUser.userID) name = '글쓴이양';
       else name = '익명';
    }

    return name;
  }

  // 삭제된 게시글 동기화
  void syncDeletedList({required List<Community> communityList, required Community community}){
    for (int i = 0; i < communityList.length; i++) {
      if (communityList[i].id == community.id) {
        communityList.removeAt(i);
        break;
      }
    }
  }

  // 좋아요 삽입 동기화
  void syncLikeListOnInsert({required List<Community> communityList, required Community community,  required CommunityLike tmpLike}){
    for (int i = 0; i < communityList.length; i++) {
      if (communityList[i].id == community.id) {
        communityList[i].communityLike.add(tmpLike);
      }
    }
  }

  // 좋아요 삭제 동기화
  void syncLikeListOnDelete({required List<Community> communityList, required Community community}){
    for (int i = 0; i < communityList.length; i++) {
      int idx1 = -1;
      int idx2 = -1;

      if (communityList[i].id == community.id) {
        idx1 = i;

        for (int j = 0; j < communityList[idx1].communityLike.length; j++) {
          if ((communityList[idx1].communityLike[j].userID) == GlobalProfile.loggedInUser.userID) {
            idx2 = j;
            break;
          }
        }
        if (idx2 != -1) communityList[idx1].communityLike.removeAt(idx2);

      }
    }

  }

  // 텍스트 필드 글 체크
  void checkTextField(String text){
    if(text.isEmpty) isInputColor(false);
    else isInputColor(true);
  }

  // 대댓글 토글
  void toggleReReply(CommunityReply communityReply){
    if (showReplyList.contains(communityReply.id))
      showReplyList.remove(communityReply.id);
    else
      showReplyList.add(communityReply.id);
  }

  // 사진 페이지 set
  void setCurrentPage(int value){
    currentPage(value);
  }

  // 좋아요 함수
  Future<void> replyLikeFunc(CommunityReply communityReply, bool isReplyLike) async {
    if (isCanTapLike) {
      isCanTapLike = false; // 연속 호출 방지

      var result = await ApiProvider().post(
          '/CommunityPost/InsertReplyLike',
          jsonEncode({
            "userID": GlobalProfile.loggedInUser.userID,
            "replyID": communityReply.id,
          }));

      if (!isReplyLike) {
        if (result != null) {
          CommunityReplyLike user = InsertReplyLike.fromJson(result).item;
          communityReply.communityReplyLike.add(user);
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
        }
      }
    }

    // 연속 호출 방지
    Future.delayed(Duration(milliseconds: 500), () {
      isCanTapLike = true;
    });
  }

  // 댓글 좋아요 체크
  bool replyLikeCheck(CommunityReply communityReply){
    bool isReplyLike = false;

    communityReply.communityReplyLike.forEach((element) {
      if(element.userID == GlobalProfile.loggedInUser.userID) isReplyLike = true;
    });

    return isReplyLike;
  }

  // 좋아요 체크
  void communityLikeCheck(Community _community,  int userID) {
    isCommunityLike(false);

    for (int i = 0; i < _community.communityLike.length; i++) {
      if (_community.communityLike[i].userID == userID) {
        isCommunityLike(true);
        break;
      }
    }
  }

}