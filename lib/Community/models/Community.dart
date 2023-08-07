import 'package:flutter/material.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';

const int COMMUNITY_NORMAL_TYPE = 0; // 보통 게시글
const int COMMUNITY_POPULAR_TYPE = 1; // 인기 게시글
const int COMMUNITY_HOT_TYPE = 2; // 핫 게시글
const int COMMUNITY_NOTICE_TYPE = 100; // 공지 게시글

const List<String> basicCommunityCategoryList = ['전체', '인기', '자유', '비밀', '홍보', '회사', '소모임', '개발', '경영', '디자인', '마케팅', '영업', '대학생']; // 기본 커뮤니티 카테고리 리스트
List<String> communityCategoryList = []; // 커뮤니티 카테고리 리스트

class Community {
  int id;
  int userID;
  String category;
  String title;
  String contents;
  String? imageUrl1;
  String? imageUrl2;
  String? imageUrl3;
  String createdAt;
  String updatedAt;
  List<CommunityLike> communityLike;
  bool isShow;
  int type;
  int repliesLength;
  int declareLength;

  Community({
    required this.id,
    required this.userID,
    required this.category,
    required this.title,
    required this.contents,
    required this.imageUrl1,
    required this.imageUrl2,
    required this.imageUrl3,
    required this.createdAt,
    required this.updatedAt,
    required this.communityLike,
    required this.isShow,
    required this.type,
    required this.repliesLength,
    required this.declareLength,
  });

  factory Community.fromJson(Map<String, dynamic> json, {bool isHot = false, bool isNotice = false}) {
    int type = COMMUNITY_NORMAL_TYPE;

    if (isNotice)
      type = COMMUNITY_NOTICE_TYPE; // 공지 게시글
    else if (isHot)
      type = COMMUNITY_HOT_TYPE; // 핫 게시글
    else if ((json['community']['CommunityLikes'] as List).length - (json['declareLength'] as int ?? 0) >= minimumScoreForPopular) type = COMMUNITY_POPULAR_TYPE; // 인기 게시글

    List<CommunityLike> communityLikeList = [];
    if (json['community']['CommunityLikes'] != null) {
      for (int i = 0; i < (json['community']['CommunityLikes'] as List).length; i++) {
        Map<String, dynamic> data = (json['community']['CommunityLikes'] as List)[i];
        CommunityLike tmpLike = CommunityLike.fromJson(data);
        communityLikeList.add(tmpLike);
      }
    }

    return Community(
      id: json['community']['id'] as int,
      userID: json['community']['UserID'] as int,
      category: json['community']['Category'] as String,
      title: json['community']['Title'] as String,
      contents: json['community']['Contents'] as String,
      imageUrl1: json['community']['ImageUrl1'] == null ? null : ApiProvider().getUrl + json['community']['ImageUrl1'],
      imageUrl2: json['community']['ImageUrl2'] == null ? null : ApiProvider().getUrl + json['community']['ImageUrl2'],
      imageUrl3: json['community']['ImageUrl3'] == null ? null : ApiProvider().getUrl + json['community']['ImageUrl3'],
      createdAt: replaceUTCDate(json['community']['createdAt'] as String),
      updatedAt: replaceUTCDate(json['community']['updatedAt'] as String),
      communityLike: communityLikeList,
      isShow: json['community']['IsShow'] as bool,
      type: type,
      repliesLength: json['repliesLength'] as int,
      declareLength: json['declareLength'] as int ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userID': userID,
        'category': category,
        'title': title,
        'contents': contents,
        'imageUrl1': imageUrl1,
        'imageUrl2': imageUrl2,
        'imageUrl3': imageUrl3,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'CommunityLikes': communityLike,
        'IsShow': isShow,
        'type': type,
        'repliesLength': repliesLength,
      };
}

class CommunityReplyLight {
  int id;
  int userID;
  int postID;
  String contents;
  String createdAt;
  String updatedAt;

  CommunityReplyLight({
    required this.id,
    required this.userID,
    required this.postID,
    required this.contents,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommunityReplyLight.fromJson(Map<String, dynamic> json) {
    return CommunityReplyLight(
      id: json['id'] as int,
      userID: json['UserID'] as int,
      postID: json['PostID'] as int,
      contents: json['Contents'] as String,
      createdAt: replaceUTCDate(json['createdAt'] as String),
      updatedAt: replaceUTCDate(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'UserID': userID,
        'PostID': postID,
        'Contexts': contents,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class InsertReplyReplyLike {
  CommunityReplyReplyLike item;
  bool created;

  InsertReplyReplyLike({
    required this.item,
    required this.created,
  });

  factory InsertReplyReplyLike.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json['item'];
    CommunityReplyReplyLike tmpLike = CommunityReplyReplyLike.fromJson(data);

    return InsertReplyReplyLike(
      item: tmpLike,
      created: json['created'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'item': item,
        'created': created,
      };
}

class InsertReplyLike {
  CommunityReplyLike item;
  bool created;

  InsertReplyLike({
    required this.item,
    required this.created,
  });

  factory InsertReplyLike.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json['item'];
    CommunityReplyLike tmpLike = CommunityReplyLike.fromJson(data);

    return InsertReplyLike(
      item: tmpLike,
      created: json['created'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'item': item,
        'created': created,
      };
}

class InsertLike {
  CommunityLike item;
  bool created;

  InsertLike({
    required this.item,
    required this.created,
  });

  factory InsertLike.fromJson(Map<String, dynamic> json) {
    // if ((json['created'] as bool) == false) return null;

    Map<String, dynamic> data = json['item'];
    CommunityLike tmpLike = CommunityLike.fromJson(data);

    return InsertLike(
      item: tmpLike,
      created: json['created'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'item': item,
        'created': created,
      };
}

class CommunityLike {
  int id;
  int userID;
  int postID;
  String createdAt;
  String updatedAt;

  CommunityLike({
    required this.id,
    required this.userID,
    required this.postID,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommunityLike.fromJson(Map<String, dynamic> json) {
    return CommunityLike(
      id: json['id'] as int,
      userID: json['UserID'] as int,
      postID: json['PostID'] as int,
      createdAt: replaceUTCDate(json['createdAt'] as String),
      updatedAt: replaceUTCDate(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'UserID': userID,
        'PostID': postID,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class CommunityReplyLike {
  int id;
  int userID;
  int replyID;
  String createdAt;
  String updatedAt;

  CommunityReplyLike({
    required this.id,
    required this.userID,
    required this.replyID,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommunityReplyLike.fromJson(Map<String, dynamic> json) {
    return CommunityReplyLike(
      id: json['id'] as int,
      userID: json['UserID'] as int,
      replyID: json['ReplyID'] as int,
      createdAt: replaceUTCDate(json['createdAt'] as String),
      updatedAt: replaceUTCDate(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'UserID': userID,
        'ReplyID': replyID,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class CommunityReply {
  int id;
  int userID;
  int postID;
  String contents;
  String createdAt;
  String updatedAt;
  List<CommunityReplyLike> communityReplyLike;
  List<CommunityReplyReply> communityReplyReply;
  int isShow;
  int declareLength;

  CommunityReply({
    required this.id,
    required this.userID,
    required this.contents,
    required this.createdAt,
    required this.updatedAt,
    required this.postID,
    required this.communityReplyLike,
    required this.communityReplyReply,
    required this.isShow,
    required this.declareLength,
  });

  factory CommunityReply.fromJson(Map<String, dynamic> json) {
    List<CommunityReplyLike> communityReplyLikeList = [];

    if (json['CommunityReplyLikes'] != null) {
      for (int i = 0; i < (json['CommunityReplyLikes'] as List).length; i++) {
        Map<String, dynamic> data = (json['CommunityReplyLikes'] as List)[i];
        CommunityReplyLike tmpReply = CommunityReplyLike.fromJson(data);
        communityReplyLikeList.add(tmpReply);
      }
    }

    List<CommunityReplyReply> communityReplyReplyList = [];

    if (json['CommunityReplyReplies'] != null) {
      for (int i = 0; i < (json['CommunityReplyReplies'] as List).length; i++) {
        Map<String, dynamic> data = (json['CommunityReplyReplies'] as List)[i];
        CommunityReplyReply tmpReplyReply = CommunityReplyReply.fromJson(data);
        GlobalProfile.getFutureUserByUserID(tmpReplyReply.userID);
        communityReplyReplyList.add(tmpReplyReply);
      }
    }

    return CommunityReply(
      id: json['id'] as int,
      userID: json['UserID'] as int,
      postID: json['PostID'] as int,
      contents: json['Contents'] as String,
      createdAt: replaceUTCDatetest(json['createdAt'] as String),
      updatedAt: replaceUTCDatetest(json['updatedAt'] as String),
      communityReplyLike: communityReplyLikeList,
      communityReplyReply: communityReplyReplyList,
      isShow: json['IsShow'] as int ?? 1,
      declareLength: json['CommunityReplyDeclares'] != null ? (json['CommunityReplyDeclares'] as List).length : 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userID': userID,
        'contents': contents,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'CommunityReplyLikes': communityReplyLike,
        'CommunityReplyReplies': communityReplyReply,
        'isShow': isShow,
      };
}

class CommunityReplyReplyLike {
  int id;
  int userID;
  int replyReplyID;
  String createdAt;
  String updatedAt;

  CommunityReplyReplyLike({
    required this.id,
    required this.userID,
    required this.replyReplyID,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommunityReplyReplyLike.fromJson(Map<String, dynamic> json) {
    return CommunityReplyReplyLike(
      id: json['id'] as int,
      userID: json['UserID'] as int,
      replyReplyID: json['ReplyReplyID'] as int,
      createdAt: replaceUTCDate(json['createdAt'] as String),
      updatedAt: replaceUTCDate(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'UserID': userID,
        'ReplyReplyID': replyReplyID,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class CommunityReplyReply {
  int id;
  int userID;
  int replyID;
  String contents;
  String createdAt;
  String updatedAt;
  List<CommunityReplyReplyLike> communityReplyReplyLike;
  int isShow;
  int declareLength;

  CommunityReplyReply({
    required this.id,
    required this.userID,
    required this.contents,
    required this.createdAt,
    required this.updatedAt,
    required this.replyID,
    required this.communityReplyReplyLike,
    required this.isShow,
    required this.declareLength,
  });

  factory CommunityReplyReply.fromJson(Map<String, dynamic> json) {
    List<CommunityReplyReplyLike> tmp = [];

    if (json['CommunityReplyReplyLikes'] != null) {
      for (int i = 0; i < (json['CommunityReplyReplyLikes'] as List).length; i++) {
        Map<String, dynamic> data = (json['CommunityReplyReplyLikes'] as List)[i];
        CommunityReplyReplyLike tmpReply = CommunityReplyReplyLike.fromJson(data);
        tmp.add(tmpReply);
      }
    }

    return CommunityReplyReply(
      id: json['id'] as int,
      userID: json['UserID'] as int,
      replyID: json['ReplyID'] as int,
      contents: json['Contents'] as String,
      createdAt: replaceUTCDatetest(json['createdAt'] as String),
      updatedAt: replaceUTCDatetest(json['updatedAt'] as String),
      communityReplyReplyLike: tmp,
      isShow: json['IsShow'] as int ?? 1,
      declareLength: json['CommunityReplyReplyDeclares'] != null ? (json['CommunityReplyReplyDeclares'] as List).length : 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userID': userID,
        'contents': contents,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'CommunityReplyReplyLikes': communityReplyReplyLike,
        'isShow': isShow,
      };
}

//프로필 수정에서 인증 중, 반려, 인증 완료를 나누기 위한 status
enum IdentifiedType { Reject, Complete, Proceed }

bool insertCheckForFilterAfterSelect(int userID, int index) {
  bool check = false;
  for (int i = 0; i < GlobalProfile.filteredCommunityList[index].communityLike.length; i++) {
    if (GlobalProfile.filteredCommunityList[index].communityLike[i].userID == userID) {
      check = true;
      break;
    }
  }
  return check;
}

bool searchWordInsertCheck(int userID, int index) {
  bool check = false;
  for (int i = 0; i < GlobalProfile.searchedCommunityList[index].communityLike.length; i++) {
    if (GlobalProfile.searchedCommunityList[index].communityLike[i].userID == userID) {
      check = true;
      break;
    }
  }
  return check;
}

bool popularCommunityInsertCheck(int userID, int index) {
  bool check = false;
  for (int i = 0; i < GlobalProfile.popularCommunityList[index].communityLike.length; i++) {
    if (GlobalProfile.popularCommunityList[index].communityLike[i].userID == userID) {
      check = true;
      break;
    }
  }
  return check;
}

bool insertReplyCheck(int userID, int index) {
  bool check = false;
  for (int i = 0; i < GlobalProfile.communityReply[index].communityReplyLike.length; i++) {
    if (GlobalProfile.communityReply[index].communityReplyLike[i].userID == userID) {
      check = true;
      break;
    }
  }
  return check;
}

bool insertReplyReplyCheck(int userID, int index, int index2) {
  bool check = false;
  for (int i = 0; i < GlobalProfile.communityReply[index].communityReplyReply[index2].communityReplyReplyLike.length; i++) {
    if (GlobalProfile.communityReply[index].communityReplyReply[index2].communityReplyReplyLike[i].userID == userID) {
      check = true;
      break;
    }
  }
  return check;
}

// 댓글 갯수 올려주기 동기화
void syncRepliesLength({required List<Community> communityList, required Community community}) {
  for (int i = 0; i < communityList.length; i++) {
    if (communityList[i].id == community.id) {
      communityList[i].repliesLength = GlobalProfile.communityReply.length;
    }
  }
}
