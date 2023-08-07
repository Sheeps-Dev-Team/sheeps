import 'package:flutter/material.dart';

class CommunityPost with ChangeNotifier {
  String CommunityPostTopic = null;
  String CommunityPostTitle = null;
  String CommunityPostDescription= null;
  String CommunityPostWriter = null;
  int CommunityPostLikes = 0;
  int CommunityPostReply = 0;
  bool CommunityPostBlack = false;

  //댓글
  String ReplyImageURL = null;
  String ReplyName = null;
  String ReplyDescription = null;
  String ReplyTime = null;
  int ReplyLikes = 0;
  int ReplyOfReply = 0;

  List<String>CommunityPostImageURL = [];
}