import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/MyBadge.dart';

class TeamAuth {
  int id;
  int teamID;
  String contents;
  String imgUrl;
  int auth;
  String createdAt;
  String updatedAt;

  TeamAuth({this.createdAt = '', this.updatedAt = '', this.teamID = 0, this.auth = 0, this.contents = '', this.id = 0, this.imgUrl = ''});

  factory TeamAuth.fromJson(Map<String, dynamic> json) {
    return TeamAuth(
      id: json['TAuthID'] as int,
      teamID: json['TATeamID'] as int,
      contents: json['TAuthContents'] as String,
      imgUrl: json['TAuthImgUrl'] as String,
      auth: json['TAuthAuth'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

class TeamWins {
  int id;
  int teamID;
  String contents;
  String imgUrl;
  int auth;
  String createdAt;
  String updatedAt;

  TeamWins({this.updatedAt = '', this.createdAt = '', this.auth = 0, this.contents = '', this.id = 0, this.imgUrl = '', this.teamID = 0});

  factory TeamWins.fromJson(Map<String, dynamic> json) {
    return TeamWins(
      id: json['TWinID'] as int,
      teamID: json['TWTeamID'] as int,
      contents: json['TWinContents'] as String,
      imgUrl: json['TWinImgUrl'] as String,
      auth: json['TWinAuth'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

class TeamPerformances {
  int id;
  int teamID;
  String contents;
  String imgUrl;
  int auth;
  String createdAt;
  String updatedAt;

  TeamPerformances({this.createdAt = '', this.updatedAt = '', this.auth = 0, this.contents = '', this.id = 0, this.imgUrl = '', this.teamID = 0});

  factory TeamPerformances.fromJson(Map<String, dynamic> json) {
    return TeamPerformances(
      id: json['TPerformID'] as int,
      teamID: json['TPTeamID'] as int,
      contents: json['TPerformContents'] as String,
      imgUrl: json['TPerformImgUrl'] as String,
      auth: json['TPerformAuth'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

class TeamLink {
  int id = -1;
  int userID = -1;
  String siteUrl = '';
  String recruitUrl = '';
  String instagramUrl = '';
  String facebookUrl = '';

  TeamLink({
    this.id = -1,
    this.userID = -1,
    this.siteUrl = '',
    this.recruitUrl = '',
    this.instagramUrl = '',
    this.facebookUrl = '',
  });

  factory TeamLink.fromJson(Map<String, dynamic> json) {
    return TeamLink(
      id: json['id'] as int,
      userID: json['UserID'] as int,
      siteUrl: json['Site'] as String,
      recruitUrl: json['Recruit'] as String,
      instagramUrl: json['Instagram'] as String,
      facebookUrl: json['Facebook'] as String,
    );
  }
}

class TeamProfileImg {
  int id;
  int userID;
  int index;
  String imgUrl;
  String createdAt;
  String updatedAt;

  TeamProfileImg({
    this.id = -1,
    this.userID = -1,
    this.index = -1,
    this.imgUrl = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory TeamProfileImg.fromJson(Map<String, dynamic> json) {
    return TeamProfileImg(
      id: json['id'] as int,
      userID: json['UserID'] as int,
      index: json['Index'] as int,
      imgUrl: ApiProvider().getUrl + json['ImgUrl'],
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

class SampleTeam {
  int id;
  String name;
  String part;
  String location;
  TeamProfileImg? profileImg;

  SampleTeam({this.id = 0, this.name = '', this.part = '', this.location = '', this.profileImg});

  factory SampleTeam.fromJson(Map<String, dynamic> json) {
    List<TeamProfileImg> profileImgList = [];

    profileImgList.addAll((json['TeamPhotos'] as List).map((e) => TeamProfileImg.fromJson(e)).toList());

    if(profileImgList.length == 0){
      profileImgList.add(TeamProfileImg(id: -2, imgUrl: 'BasicImage'));
    }

    return SampleTeam(
        id: json['id'] as int,
        name: json['Name'],
        part: json['Part'],
        location: json['Location'],
        profileImg: profileImgList[0]
    );
  }
}

class Team {
  int id;
  int leaderID;
  String name;
  String information;
  String category;
  String part;
  String location;
  String subLocation;
  int possibleJoin;
  int badge1;
  int badge2;
  int badge3;
  List<int> userList;
  String createdAt;
  String updatedAt;

  List<TeamProfileImg> profileImgList;

  List<BadgeModel> badgeList = [];

  List<TeamAuth> teamAuthList = [];
  List<TeamPerformances> teamPerformList = [];
  List<TeamWins> teamWinList = [];

  TeamLink? teamLink;

  bool isTeamMemberChange;

  Team({
    this.id = 0,
    this.leaderID = 0,
    this.name = '',
    this.information = '',
    this.category = '',
    this.part = '',
    this.location = '',
    this.subLocation = '',
    this.possibleJoin = 0,
    this.profileImgList = const [],
    this.badge1 = 0,
    this.badge2 = 0,
    this.badge3 = 0,
    this.badgeList = const [],
    this.userList = const [],
    this.createdAt = '',
    this.updatedAt = '',
    this.teamWinList = const [],
    this.teamPerformList = const [],
    this.teamAuthList = const [],
    this.teamLink,
    this.isTeamMemberChange = false
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    List<TeamProfileImg> profileImgList = [];

    profileImgList.addAll((json['TeamPhotos'] as List).map((e) => TeamProfileImg.fromJson(e)).toList());

    if(profileImgList.length == 0){
      profileImgList.add(TeamProfileImg(id: -2, imgUrl: 'BasicImage'));
    }

    List<int> teamList = [];

    List<dynamic> list = json['TeamLists'] as List;

    if (list != null) {
      for (int i = 0; i < list.length; i++) {
        Map<String, dynamic> data = (json['TeamLists'] as List)[i];
        teamList.add(data['UserID']);
      }
    }

    return Team(
      id: json["id"] as int,
      leaderID: json["LeaderID"] as int,
      name: json["Name"] as String,
      information: json["Information"] as String,
      category: json["Category"] as String,
      part: json["Part"] as String,
      location: json["Location"] as String,
      subLocation: json["SubLocation"] as String,
      possibleJoin: json["PossibleJoin"] as int,
      profileImgList: profileImgList,
      badge1: json["Badge1"] as int,
      badge2: json["Badge2"] as int,
      badge3: json["Badge3"] as int,
      userList: teamList,
      teamAuthList: json['teamauths'] == null ? [] : (json['teamauths'] as List).map((e) => TeamAuth.fromJson(e)).toList(),
      teamPerformList: json['teamperformances'] == null ? [] : (json['teamperformances'] as List).map((e) => TeamPerformances.fromJson(e)).toList(),
      teamWinList: json['teamwins'] == null ? [] : (json['teamwins'] as List).map((e) => TeamWins.fromJson(e)).toList(),
      teamLink: json['teamlinks'] == null || json['teamlinks'].length == 0 ? TeamLink() : TeamLink.fromJson(json['teamlinks'][0]),
      createdAt: replaceUTCDate(json["createdAt"] as String),
      updatedAt: replaceUTCDate(json["updatedAt"] as String),
      badgeList: [],
      isTeamMemberChange: false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'leaderID': leaderID,
        'name': name,
        'information': information,
        'category': category,
        'major': part,
        'location': location,
        'subLocation': subLocation,
        'possibleJoin': possibleJoin,
        'badge1': badge1,
        'badge2': badge2,
        'badge3': badge3,
        'userList': userList,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
