import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class RecruitLikes {
  int id;
  int userId;
  int targetId;
  String createdAt;
  String updatedAt;

  RecruitLikes({this.updatedAt,this.id,this.createdAt,this.targetId,this.userId});

  factory RecruitLikes.fromJson(Map<String, dynamic> json){
    return RecruitLikes(
      id: json['id'] as int,
      userId: json['UserID'] as int,
      targetId: json['TargetID'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

class RecruitInvite {
  int id;
  int targetID;
  int inviteID;
  int response;
  int index;
  String createdAt;
  String updatedAt;

  RecruitInvite({this.updatedAt,this.id,this.createdAt,this.targetID, this.inviteID, this.response, this.index});

  factory RecruitInvite.fromJson(Map<String, dynamic> json, {bool isUserID = true}){
    return RecruitInvite(
      id: json['id'] as int,
      targetID: isUserID ? json['UserID'] as int : json['TeamID'] as int,
      inviteID: json['InviteID'] as int,
      response: json['Response'] as int,
      index: json['TargetIndex'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

List<RecruitLikes> recruitLikesList = []; // 팀원 모집 좋아요 리스트
List<RecruitLikes> personalSeekLikesList = []; // 팀 찾기 좋아요 리스트

class RecruitInviteController extends GetxController{
  static get to => Get.find();

  RxList currRecritInviteList = [RecruitInvite()].obs;
  RecruitInvite currRecruitInvite;

  RecruitInvite get getCurrRecruitInvite => currRecruitInvite;

  void setCurrRecruitInvite(int index, {RecruitInvite recruitInvite}){
    if(recruitInvite == null){
      currRecruitInvite = currRecritInviteList[index];
    }else{
      currRecruitInvite = recruitInvite;
    }
  }

  void removeRecruitInviteCurr(int id) {

    currRecritInviteList.removeWhere((element) => element.id == id);

    update();
  }

  void responseRecruitInviteCurr(int id, dynamic recruit){

    currRecritInviteList.forEach((element) {
      if(element.id == id){
        element = recruit;
      }
    });

    update();
  }
}