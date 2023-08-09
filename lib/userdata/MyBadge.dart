import 'package:sheeps_app/config/AppConfig.dart';

final int BADGE_TYPE_ACTIVE = 0;
final int BADGE_TYPE_CAREER = 1;
final int BADGE_TYPE_GRADE = 2;
final int BADGE_TYPE_PRIME = 3;
final int BADGE_TYPE_LICESENCE = 4;
final int BADGE_TYPE_EDUCATION = 5;
final int BADGE_TYPE_APPEAL = 6;
final int BADGE_TYPE_ETC = 7;

class BadgeModel{
  int id;
  int userID;
  int badgeID;
  int type;
  String createdAt;
  String updatedAt;

  BadgeModel({this.id = 0, this.userID = 0, this.badgeID = 0, this.type = 0, this.createdAt = '', this.updatedAt = ''});

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id : json['id'] == null ? 0 : json['id'] as int,
      userID: json['UserID'] as int,
      badgeID: json['BadgeID'] == null ? 0 : json['BadgeID'] as int,
      type : json['Type'] == null ? 0 : json['Type'] as int,
      createdAt: replaceUTCDate(json['createdAt']),
      updatedAt: replaceUTCDate(json['updatedAt'])
    );
  }
}

class MyBadge{
  String title;
  String description;
  String image;
  int type;

  MyBadge({this.title = '', this.description = '', this.image = '', this.type = 0});

  factory MyBadge.fromJson(Map<String, dynamic> json){
    return MyBadge(
      title : json['title'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      type: json['type'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'title' : title,
    'description' : description,
    'image' : image,
    'type' : type,
  };
}

List<MyBadge> badgeList = [];
initBadgeList(){
  String BadgeUrl = 'assets/images/Badge/';
  badgeList.add(MyBadge(title: '', description: '', image: '', type: BADGE_TYPE_ETC));
  badgeList.add(MyBadge(title: "쉽지않은 스타트업", description: "쉽지않은 스타트업 교육을 수료한\n사람들에게 수여되는 뱃지", image: BadgeUrl + "ETC.svg", type: BADGE_TYPE_ETC));
  badgeList.add(MyBadge(title: "장관상 수상자", description: "공모전에서 '장관상'에 해당하는 성격을\n수상한 사람에게 수여되는 뱃지", image: BadgeUrl + "AdministratorPrimer.svg", type: BADGE_TYPE_PRIME));
  badgeList.add(MyBadge(title: "국가기술자격 : 기술사", description: "국가 기술 자격 중 '기술사'등급의\n자격을 가진 사람에게 수여되는 뱃지", image: BadgeUrl + "NTQMagician.svg", type: BADGE_TYPE_LICESENCE));
}
