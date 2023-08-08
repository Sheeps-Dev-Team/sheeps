class ModelLikes {
  int id;
  int UserID;
  int TargetID;
  String createdAt;
  String updatedAt;

  ModelLikes({required this.updatedAt,required this.id,required this.createdAt,required this.TargetID,required this.UserID});

  factory ModelLikes.fromJson(Map<String, dynamic> json){
    return ModelLikes(
      id: json['id'] as int,
      UserID: json['UserID'] as int,
      TargetID: json['TargetID'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

List<ModelLikes> globalPersonalLikeList = [];
List<ModelLikes> globalTeamLikeList = [];