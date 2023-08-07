
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';

class DetailProfileController {
  final int companion = 0; // 반려

  // 개인 프로픨 변수
  List<UserEducation> userEducationList = [];
  List<UserCareer> userCareerList = [];
  List<UserLicense> userLicenseList = [];
  List<UserWin> userWinList = [];
  bool showUserUrl = true;

  // 팀 프로필 변수
  List<TeamAuth> teamAuthList = [];
  List<TeamPerformances> teamPerformList = [];
  List<TeamWins> teamWinList = [];
  bool showTeamUrl = true;
  bool isTeamMember = false;

  // 개인 프로필 데이터 set
  void personalProfileDataSet(UserData user) {
    userEducationList.clear();
    userCareerList.clear();
    userLicenseList.clear();
    userWinList.clear();
    showUserUrl = true;

    user.userEducationList.forEach((element) {
      if (element.auth != companion) userEducationList.add(element);
    });

    user.userCareerList.forEach((element) {
      if (element.auth != companion) userCareerList.add(element);
    });

    user.userLicenseList.forEach((element) {
      if (element.auth != companion) userLicenseList.add(element);
    });

    user.userWinList.forEach((element) {
      if (element.auth != companion) userWinList.add(element);
    });

    // 이력 링크가 하나도 없으면
    if (user.userLink.portfolioUrl.isEmpty &&
        user.userLink.resumeUrl.isEmpty &&
        user.userLink.siteUrl.isEmpty &&
        user.userLink.linkedInUrl.isEmpty &&
        user.userLink.instagramUrl.isEmpty &&
        user.userLink.facebookUrl.isEmpty &&
        user.userLink.gitHubUrl.isEmpty &&
        user.userLink.notionUrl.isEmpty) showUserUrl = false;
  }

  // 팀 프로필 데이터 set
  void teamProfileDataSet(Team team) {
    teamAuthList.clear();
    teamPerformList.clear();
    teamWinList.clear();
    showTeamUrl = true;
    isTeamMember = false;

    team.teamAuthList.forEach((element) {
      if (element.auth != companion) teamAuthList.add(element);
    });

    team.teamPerformList.forEach((element) {
      if (element.auth != companion) teamPerformList.add(element);
    });

    team.teamWinList.forEach((element) {
      if (element.auth != companion) teamWinList.add(element);
    });

    // 이력 링크가 하나도 없으면
    if (team.teamLink.siteUrl.isEmpty && team.teamLink.recruitUrl.isEmpty && team.teamLink.instagramUrl.isEmpty && team.teamLink.facebookUrl.isEmpty) showTeamUrl = false;

    // 팀 멤버인지 체크
    // print(team.leaderID);
    team.userList.forEach((element) {
      if(element == GlobalProfile.loggedInUser.userID) {
        return isTeamMember = true;
      }
    });
  }
}
