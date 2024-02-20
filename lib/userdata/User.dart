
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/MyBadge.dart';

//경력
class UserCareer {
  int id;
  int userID;
  String imgUrl;
  String contents;
  String? start;
  String? done;
  bool isNow;
  int auth;
  String createdAt;
  String updatedAt;

  UserCareer({this.auth = 0, this.contents = '', this.done = '', this.isNow = false, this.start = '', this.updatedAt = '', this.createdAt = '', this.id = 0, this.imgUrl = '', this.userID = 0});

  factory UserCareer.fromJson(Map<String, dynamic> json) {
    return UserCareer(
      id: json['PfCareerID'] as int,
      userID: json['PfCUserID'] as int,
      contents: json['PfCareerContents'] as String,
      imgUrl: json['PfCareerImgUrl'] as String,
      start: json['PfCareerStart'] == null ? null : json['PfCareerStart'] as String,
      done: json['PfCareerDone'] == null ? null : json['PfCareerDone'] as String,
      isNow: json['PfCareerNow'] == null ? false : json['PfCareerNow'] == null as bool,
      auth: json['PfCareerAuth'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

//자격증
class UserLicense {
  int id;
  int userID;
  String contents;
  String imgUrl;
  int auth;
  String createdAt;
  String updatedAt;

  UserLicense({this.auth = 0, this.contents = '', this.createdAt = '', this.updatedAt = '', this.id = 0, this.imgUrl = '', this.userID = 0});

  factory UserLicense.fromJson(Map<String, dynamic> json) {
    return UserLicense(
      id: json['PfLicenseID'] as int,
      userID: json['PfLUserID'] as int,
      contents: json['PfLicenseContents'] as String,
      imgUrl: json['PfLicenseImgUrl'] as String,
      auth: json['PfLicenseAuth'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

//수상 이력
class UserWin {
  int id;
  int userID;
  String contents;
  String imgUrl;
  int auth;
  String createdAt;
  String updatedAt;

  UserWin({this.auth = 0, this.contents = '', this.updatedAt = '', this.createdAt = '', this.id = 0, this.imgUrl = '', this.userID = 0});

  factory UserWin.fromJson(Map<String, dynamic> json) {
    return UserWin(
      id: json['PfWinID'] as int,
      userID: json['PfWUserID'] as int,
      contents: json['PfWinContents'] as String,
      imgUrl: json['PfWinImgUrl'] as String,
      auth: json['PfWinAuth'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

//학력
class UserEducation {
  int id;
  int userID;
  String contents;
  String imgUrl;
  int auth;
  String createdAt;
  String updatedAt;

  UserEducation({this.id = 0, this.userID = 0, this.contents = '', this.imgUrl = '', this.auth = 0, this.createdAt = '', this.updatedAt = ''});

  factory UserEducation.fromJson(Map<String, dynamic> json) {
    return UserEducation(
      id: json['PfUnivID'] as int,
      userID: json['PfUUserID'] as int,
      contents: json['PfUnivName'] as String,
      imgUrl: json['PfUnivImgUrl'] as String,
      auth: json['PfUnivAuth'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

class UserLink {
  int id = -1;
  int userID = -1;
  String portfolioUrl = '';
  String resumeUrl = '';
  String siteUrl = '';
  String linkedInUrl = '';
  String instagramUrl = '';
  String facebookUrl = '';
  String gitHubUrl = '';
  String notionUrl = '';
  String createdAt;
  String updatedAt;

  UserLink({
    this.id = -1,
    this.userID = -1,
    this.portfolioUrl = '',
    this.resumeUrl = '',
    this.siteUrl = '',
    this.linkedInUrl = '',
    this.instagramUrl = '',
    this.facebookUrl = '',
    this.gitHubUrl = '',
    this.notionUrl = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory UserLink.fromJson(Map<String, dynamic> json) {
    return UserLink(
      id: json['id'] as int,
      userID: json['UserID'] as int,
      portfolioUrl: json['Portfolio'] as String ?? '',
      resumeUrl: json['Resume'] as String ?? '',
      siteUrl: json['Site'] as String ?? '',
      linkedInUrl: json['LinkedIn'] as String ?? '',
      instagramUrl: json['Instagram'] as String ?? '',
      facebookUrl: json['Facebook'] as String ?? '',
      gitHubUrl: json['Github'] as String ?? '',
      notionUrl: json['Notion'] as String ?? '',
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

class UserProfileImg {
  int id;
  int userID;
  int index;
  String imgUrl;
  String createdAt;
  String updatedAt;

  UserProfileImg({
    this.id = -1,
    this.userID = -1,
    this.index = -1,
    this.imgUrl = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory UserProfileImg.fromJson(Map<String, dynamic> json) {
    return UserProfileImg(
      id: json['id'] as int,
      userID: json['UserID'] as int,
      index: json['Index'] as int,
      imgUrl: ApiProvider().getUrl + json['ImgUrl'],
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

class SampleUser {
  int userID;
  String name;
  String part;
  String location;
  UserProfileImg? profileImg;

  SampleUser({this.userID = 0, this.name = '', this.part = '', this.location = '', this.profileImg});

  factory SampleUser.fromJson(Map<String, dynamic> json) {
    List<UserProfileImg> profileImgList = [];
    profileImgList.addAll((json['PersonalPhotos'] as List).map((e) => UserProfileImg.fromJson(e)).toList());

    if(profileImgList.length == 0){
      profileImgList.add(UserProfileImg(id: -2, imgUrl: 'BasicImage'));
    }

    return SampleUser(
        userID: json['UserID'] as int,
        name: json['Name'],
        part: json['Part'],
        location: json['Location'],
        profileImg: profileImgList[0]
    );
  }
}

class UserData {
  int userID;
  String id;
  String name;
  String information;
  String job;
  String part;
  String subJob;
  String subPart;
  String location;
  String subLocation;
  String phoneNumber;
  int badge1;
  int badge2;
  int badge3;
  String createdAt;
  String updatedAt;
  String accessToken;

  List<UserProfileImg> profileImgList;

  List<BadgeModel> badgeList;

  List<UserEducation> userEducationList;
  List<UserCareer> userCareerList;
  List<UserLicense> userLicenseList;
  List<UserWin> userWinList;

  bool marketingAgree;
  String marketingAgreeTime;

  int loginType;

  UserLink? userLink;

  UserData({
    this.userID = 0,
    this.id = '',
    this.name = '',
    this.information = '',
    this.job = '',
    this.part = '',
    this.subJob = '',
    this.subPart = '',
    this.location = '',
    this.subLocation = '',
    this.profileImgList = const [],
    this.badge1 = 0,
    this.badge2 = 0,
    this.badge3 = 0,
    this.createdAt = '',
    this.updatedAt = '',
    this.accessToken = '',
    this.badgeList = const [],
    this.userCareerList = const [],
    this.userLicenseList = const [],
    this.userEducationList = const [],
    this.userWinList = const [],
    this.marketingAgree = false,
    this.marketingAgreeTime = '',
    this.loginType = 0,
    this.phoneNumber = '',
    this.userLink
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    List<UserProfileImg> profileImgList = [];
    profileImgList.addAll((json['PersonalPhotos'] as List).map((e) => UserProfileImg.fromJson(e)).toList());

    if(profileImgList.length == 0){
      profileImgList.add(UserProfileImg(id: -2, imgUrl: 'BasicImage'));//id: -2로 기본이미지 구분
    }

    return UserData(
      userID: json["UserID"] as int,
      id: json["ID"] as String,
      name: json["Name"] as String,
      information: json["Information"] as String,
      job: json["Job"] as String,
      part: json["Part"] as String,
      subJob: json["SubJob"] as String,
      subPart: json["SubPart"] as String,
      location: json["Location"] as String,
      subLocation: json["SubLocation"] as String,
      profileImgList: profileImgList,
      badge1: json["Badge1"] as int,
      badge2: json["Badge2"] as int,
      badge3: json["Badge3"] as int,
      createdAt: replaceUTCDate(json["createdAt"] as String),
      updatedAt: replaceUTCDate(json["updatedAt"] as String),
      accessToken: json["AccessToken"] == null ? '' :  json["AccessToken"] as String,
      badgeList: json['PersonalBadgeLists'] == null ? [] : (json['PersonalBadgeLists'] as List).map((e) => BadgeModel.fromJson(e)).toList(),
      userCareerList: json['profilecareers'] == null ? [] : (json['profilecareers'] as List).map((e) => UserCareer.fromJson(e)).toList(),
      userLicenseList: json['profilelicenses'] == null ? [] : (json['profilelicenses'] as List).map((e) => UserLicense.fromJson(e)).toList(),
      userWinList: json['profilewins'] == null ? [] : (json['profilewins'] as List).map((e) => UserWin.fromJson(e)).toList(),
      userEducationList: json['profileunivs'] == null ? [] : (json['profileunivs'] as List).map((e) => UserEducation.fromJson(e)).toList(),
      marketingAgree: json["MarketingAgree"] == null ? false : json["MarketingAgree"] as bool,
      marketingAgreeTime: json["MarketingAgreeTime"] == null ? "" : json["MarketingAgreeTime"] as String,
      loginType: json['Google'] == null ? 0 : json['Google'] as int,
      userLink: json['PersonalLinks'].length == 0 ? UserLink() : UserLink.fromJson(json['PersonalLinks'][0]),
    );
  }

  Map<String, dynamic> toJson() => {
        'userID': userID,
        'id': id,
        'name': name,
        'information': information,
        'job': job,
        'part': part,
        'subJob': subJob,
        'subPart': subPart,
        'location': location,
        'subLocation': subLocation,
        'badge1': badge1,
        'badge2': badge2,
        'badge3': badge3,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'accessToken': accessToken,
      };
}

UserData DummyUser = UserData(userID : 2, id: 'sadam@gmail.com', name: '사담', information: 'info', job: '개발자', part: '개발부서', subJob: '디자인', subPart: '디자인부서',
createdAt: '2024-02-01 11:11:11', updatedAt: '2024-02-01 11:11:11',phoneNumber: '010-1234-5678'
);