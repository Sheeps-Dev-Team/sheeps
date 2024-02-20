import 'package:flutter/foundation.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/MyBadge.dart';

class PersonalBadge {
  int id;
  int BadgeID;
  int Category;
  String Part;
  int Condition;
  String createdAt;
  String updatedAt;

  PersonalBadge({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.Category,
    required this.Part,
    required this.BadgeID,
    required this.Condition,
  });

  factory PersonalBadge.fromJson(Map<String, dynamic> json) {
    return PersonalBadge(
      id: json['id'] as int,
      BadgeID: json['BadgeID'] as int,
      Category: json['Category'] as int,
      Part: json['Part'] as String,
      Condition: json['Condition'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

class PersonalBadgeDescription {
  int? index;
  String Category;
  String Title;
  String Part;
  String Description;

  PersonalBadgeDescription(this.Category, this.Part, this.Title, this.Description);
}

Future initPersonalBadge() async {
  var list = await ApiProvider().get('/Badge/SelectTable');
  PersonalBadgeTable.clear();
  if (list != null) {
    for (int i = 0; i < list.length; ++i) {
      Map<String, dynamic> data = list[i];

      PersonalBadge item = PersonalBadge.fromJson(data);
      PersonalBadgeTable.add(item);
      //await NotiDBHelper().createData(noti);
    }
  }

  for (int i = 0; i < PersonalBadgeDescriptionList.length; i++) {
    PersonalBadgeDescriptionList[i].index = i;
  }
}

const int EVENT_BADGE_INDEX = 100;

List<PersonalBadge> PersonalBadgeTable = [];

const List<int> personalBadgeProfileComp = [1, 2];
const List<int> personalBadgeCommunity = [3, 4, 5, 6];
const List<int> personalBadgeBadgeCount = [7, 8, 9];
const List<int> personalBadgeCareer = [10, 11, 12, 13, 14];
const List<int> personalBadgeGraduation = [15, 16, 17];
const List<int> personalBadgeAwardIn = [18, 19, 20, 21];
const List<int> personalBadgeAwardOut = [22];
const List<int> personalBadgeAwardCount = [23, 24, 25];
const List<int> personalBadgeCertification = [26, 27, 28, 29, 30];
const List<int> personalBadgeCertificationP = [31];
const List<int> personalBadgeCertificationB = [32];
const List<int> personalBadgeCertificationCount = [33, 34, 35];
const List<int> personalBadgeEducationG = [36];
const List<int> personalBadgeEducationB = [37];
const List<int> personalBadgeEducationCount = [38, 39, 40];
const List<int> personalBadgeAttraction = [41, 42, 43, 44];
const List<int> personalBadgeEvent = [EVENT_BADGE_INDEX + 1, EVENT_BADGE_INDEX + 2]; //이벤트

const List<int> teamBadgeProfileComp = [1, 2];
const List<int> teamBadgeBadgeCount = [3, 4, 5];
const List<int> teamBadgeCorporateType = [6, 7, 8, 9];
const List<int> teamBadgeEmployees = [10, 11, 12, 13];
const List<int> teamBadgeMembers = [14, 15, 16, 17];
const List<int> teamBadgeWorkplace = [18, 19, 20, 21];
const List<int> teamBadgeCertification = [22, 23, 24, 25, 26, 27];
const List<int> teamBadgeTask = [28, 29, 30, 31, 32];
const List<int> teamBadgeSales = [33, 34, 35, 36, 37];
const List<int> teamBadgeInvestment = [38, 39, 40, 41, 42];
const List<int> teamBadgePatent = [43, 44, 45, 46, 47];
const List<int> teamBadgeAwardIn = [48, 49, 50, 51];
const List<int> teamBadgeAwardOut = [52];
const List<int> teamBadgeAwardCount = [53, 54, 55];
const List<int> teamBadgeAttraction = [56];

void initBadgePart() {
  bool Flag = false;

  if (GlobalProfile.loggedInUser!.badgeList == null) return;

  for (int i = 0; i < GlobalProfile.loggedInUser!.badgeList.length; i++) {
    BadgeModel item = GlobalProfile.loggedInUser!.badgeList[i];
    for (int j = 0; j < PersonalBadgeTable.length; j++) {
      if (Flag) {
        Flag = false;
        break;
      }
    }
  }
  debugPrint("Personal initBadgePart Success");
}

String ReturnPersonalBadgeSVG(int id) {
  switch (id) {
    case 1:
      return 'assets/images/Badge/PersonalBadge/1_profile_comp_1.svg';
    case 2:
      return 'assets/images/Badge/PersonalBadge/2_profile_comp_2.svg';

    case 3:
      return 'assets/images/Badge/PersonalBadge/3_community_2.svg';
    case 4:
      return 'assets/images/Badge/PersonalBadge/4_community_3.svg';
    case 5:
      return 'assets/images/Badge/PersonalBadge/5_community_4.svg';
    case 6:
      return 'assets/images/Badge/PersonalBadge/6_community_5.svg';

    case 7:
      return 'assets/images/Badge/PersonalBadge/7_badge_count_3.svg';
    case 8:
      return 'assets/images/Badge/PersonalBadge/8_badge_count_4.svg';
    case 9:
      return 'assets/images/Badge/PersonalBadge/9_badge_count_5.svg';

    case 10:
      return 'assets/images/Badge/PersonalBadge/10_career_1.svg';
    case 11:
      return 'assets/images/Badge/PersonalBadge/11_career_2.svg';
    case 12:
      return 'assets/images/Badge/PersonalBadge/12_career_3.svg';
    case 13:
      return 'assets/images/Badge/PersonalBadge/13_career_4.svg';
    case 14:
      return 'assets/images/Badge/PersonalBadge/14_career_5.svg';

    case 15:
      return 'assets/images/Badge/PersonalBadge/15_graduation_2.svg';
    case 16:
      return 'assets/images/Badge/PersonalBadge/16_graduation_3.svg';
    case 17:
      return 'assets/images/Badge/PersonalBadge/17_graduation_4.svg';

    case 18:
      return 'assets/images/Badge/PersonalBadge/18_award_in_2.svg';
    case 19:
      return 'assets/images/Badge/PersonalBadge/19_award_in_3.svg';
    case 20:
      return 'assets/images/Badge/PersonalBadge/20_award_in_4.svg';
    case 21:
      return 'assets/images/Badge/PersonalBadge/21_award_in_5.svg';

    case 22:
      return 'assets/images/Badge/PersonalBadge/22_award_out.svg';

    case 23:
      return 'assets/images/Badge/PersonalBadge/23_award_count_3.svg';
    case 24:
      return 'assets/images/Badge/PersonalBadge/24_award_count_4.svg';
    case 25:
      return 'assets/images/Badge/PersonalBadge/25_award_count_5.svg';

    case 26:
      return 'assets/images/Badge/PersonalBadge/26_certification_1.svg';
    case 27:
      return 'assets/images/Badge/PersonalBadge/27_certification_2.svg';
    case 28:
      return 'assets/images/Badge/PersonalBadge/28_certification_3.svg';
    case 29:
      return 'assets/images/Badge/PersonalBadge/29_certification_4.svg';
    case 30:
      return 'assets/images/Badge/PersonalBadge/30_certification_5.svg';

    case 31:
      return 'assets/images/Badge/PersonalBadge/31_certification_P.svg';

    case 32:
      return 'assets/images/Badge/PersonalBadge/32_certification_B.svg';

    case 33:
      return 'assets/images/Badge/PersonalBadge/33_certification_count_2.svg';
    case 34:
      return 'assets/images/Badge/PersonalBadge/34_certification_count_3.svg';
    case 35:
      return 'assets/images/Badge/PersonalBadge/35_certification_count_4.svg';

    case 36:
      return 'assets/images/Badge/PersonalBadge/36_education_G.svg';

    case 37:
      return 'assets/images/Badge/PersonalBadge/37_education_B.svg';

    case 38:
      return 'assets/images/Badge/PersonalBadge/38_education_count_2.svg';
    case 39:
      return 'assets/images/Badge/PersonalBadge/39_education_count_3.svg';
    case 40:
      return 'assets/images/Badge/PersonalBadge/40_education_count_4.svg';

    case 41:
      return 'assets/images/Badge/PersonalBadge/41_attraction_2.svg';
    case 42:
      return 'assets/images/Badge/PersonalBadge/42_attraction_3.svg';
    case 43:
      return 'assets/images/Badge/PersonalBadge/43_attraction_4.svg';
    case 44:
      return 'assets/images/Badge/PersonalBadge/44_attraction_5.svg';
    case EVENT_BADGE_INDEX + 1:
      return 'assets/images/Badge/PersonalBadge/sheeps_lunching_badge.svg';
    case EVENT_BADGE_INDEX + 2:
      return 'assets/images/Badge/PersonalBadge/class_101_badge.svg';
    default:
      return '';
  }
}

class TeamBadge {
  int id;
  int BadgeID;
  int Category;
  String Part;
  int Condition;
  String createdAt;
  String updatedAt;

  TeamBadge({required this.id, required this.createdAt, required this.updatedAt, required this.Category, required this.Part, required this.BadgeID, required this.Condition});

  factory TeamBadge.fromJson(Map<String, dynamic> json) {
    return TeamBadge(
      id: json['id'] as int,
      BadgeID: json['BadgeID'] as int,
      Category: json['Category'] as int,
      Part: json['Part'] as String,
      Condition: json['Condition'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

List<TeamBadge> TeamBadgeTable = [];

Future initTeamBadge() async {
  var list = await ApiProvider().get('/Badge/SelectTeamTable');
  TeamBadgeTable.clear();
  if (list != null) {
    for (int i = 0; i < list.length; ++i) {
      Map<String, dynamic> data = list[i];

      TeamBadge item = TeamBadge.fromJson(data);
      TeamBadgeTable.add(item);
    }
  }

  for (int i = 0; i < TeamBadgeDescriptionList.length; i++) {
    TeamBadgeDescriptionList[i].index = i;
  }
}

class TeamBadgeDescription {
  int? index;
  String Category;
  String Title;
  String Part;
  String Description;
  bool? IsTeamCanSelect;

  TeamBadgeDescription(this.Category, this.Part, this.Title, this.Description);
}

String ReturnTeamBadgeSVG(int id) {
  switch (id) {
    case 1:
      return 'assets/images/Badge/TeamBadge/1_profile_comp_1.svg';
    case 2:
      return 'assets/images/Badge/TeamBadge/2_profile_comp_2.svg';

    case 3:
      return 'assets/images/Badge/TeamBadge/3_badge_count_3.svg';
    case 4:
      return 'assets/images/Badge/TeamBadge/4_badge_count_4.svg';
    case 5:
      return 'assets/images/Badge/TeamBadge/5_badge_count_5.svg';

    case 6:
      return 'assets/images/Badge/TeamBadge/6_business model_1.svg';
    case 7:
      return 'assets/images/Badge/TeamBadge/7_business model_2.svg';
    case 8:
      return 'assets/images/Badge/TeamBadge/8_business model_3.svg';
    case 9:
      return 'assets/images/Badge/TeamBadge/9_business model_4.svg';

    case 10:
      return 'assets/images/Badge/TeamBadge/10_employee_2.svg';
    case 11:
      return 'assets/images/Badge/TeamBadge/11_employee_3.svg';
    case 12:
      return 'assets/images/Badge/TeamBadge/12_employee_4.svg';
    case 13:
      return 'assets/images/Badge/TeamBadge/13_employee_5.svg';

    case 14:
      return 'assets/images/Badge/TeamBadge/14_team_2.svg';
    case 15:
      return 'assets/images/Badge/TeamBadge/15_team_3.svg';
    case 16:
      return 'assets/images/Badge/TeamBadge/16_team_4.svg';
    case 17:
      return 'assets/images/Badge/TeamBadge/17_team_5.svg';

    case 18:
      return 'assets/images/Badge/TeamBadge/18_21_CA_business.svg';
    case 19:
      return 'assets/images/Badge/TeamBadge/18_21_CA_business.svg';
    case 20:
      return 'assets/images/Badge/TeamBadge/18_21_CA_business.svg';
    case 21:
      return 'assets/images/Badge/TeamBadge/18_21_CA_business.svg';

    case 22:
      return 'assets/images/Badge/TeamBadge/22_venture.svg';
    case 23:
      return 'assets/images/Badge/TeamBadge/23_innobiz.svg';
    case 24:
      return 'assets/images/Badge/TeamBadge/24_B_lab.svg';
    case 25:
      return 'assets/images/Badge/TeamBadge/25_p_LAb.svg';
    case 26:
      return 'assets/images/Badge/TeamBadge/26_familly.svg';
    case 27:
      return 'assets/images/Badge/TeamBadge/27_business_LAB.svg';

    case 28:
      return 'assets/images/Badge/TeamBadge/28_project_1.svg';
    case 29:
      return 'assets/images/Badge/TeamBadge/29_project_2.svg';
    case 30:
      return 'assets/images/Badge/TeamBadge/30_project_3.svg';
    case 31:
      return 'assets/images/Badge/TeamBadge/31_project_4.svg';
    case 32:
      return 'assets/images/Badge/TeamBadge/32_project_5.svg';

    case 33:
      return 'assets/images/Badge/TeamBadge/33_sales_1.svg';
    case 34:
      return 'assets/images/Badge/TeamBadge/34_sales_2.svg';
    case 35:
      return 'assets/images/Badge/TeamBadge/35_sales_3.svg';
    case 36:
      return 'assets/images/Badge/TeamBadge/36_sales_4.svg';
    case 37:
      return 'assets/images/Badge/TeamBadge/37_sales_5.svg';

    case 38:
      return 'assets/images/Badge/TeamBadge/38_inve_1.svg';
    case 39:
      return 'assets/images/Badge/TeamBadge/39_inve_2.svg';
    case 40:
      return 'assets/images/Badge/TeamBadge/40_inve_3.svg';
    case 41:
      return 'assets/images/Badge/TeamBadge/41_inve_4.svg';
    case 42:
      return 'assets/images/Badge/TeamBadge/42_inve_5.svg';

    case 43:
      return 'assets/images/Badge/TeamBadge/43_patent_1.svg';
    case 44:
      return 'assets/images/Badge/TeamBadge/44_patent_2.svg';
    case 45:
      return 'assets/images/Badge/TeamBadge/45_patent_3.svg';
    case 46:
      return 'assets/images/Badge/TeamBadge/46_patent_4.svg';
    case 47:
      return 'assets/images/Badge/TeamBadge/47_patent_5.svg';

    case 48:
      return 'assets/images/Badge/TeamBadge/48_award_in_2.svg';
    case 49:
      return 'assets/images/Badge/TeamBadge/49_award_in_3.svg';
    case 50:
      return 'assets/images/Badge/TeamBadge/50_award_in_4.svg';
    case 51:
      return 'assets/images/Badge/TeamBadge/51_award_in_5.svg';

    case 52:
      return 'assets/images/Badge/TeamBadge/52_award_out.svg';

    case 53:
      return 'assets/images/Badge/TeamBadge/53_award_count_3.svg';
    case 54:
      return 'assets/images/Badge/TeamBadge/54_award_count_4.svg';
    case 55:
      return 'assets/images/Badge/TeamBadge/55_award_count_5.svg';

    case 56:
      return 'assets/images/Badge/TeamBadge/56_non smoking.svg';
    default:
      return '';
  }
}

void initAllBadge() async {
  //Badge Table Initialize
  await initPersonalBadge();
  await initTeamBadge();
  if (PersonalBadgeTable.length > 0) {
    initBadgePart();
  }
}

List<PersonalBadgeDescription> PersonalBadgeDescriptionList = [
  //index와 id와 동기화
  PersonalBadgeDescription("", "", "", ""),
  PersonalBadgeDescription("활동", "자랑중..", "프로필 완성도 70%", "나머지 프로필도 완성해 보세요!"), //1
  PersonalBadgeDescription("활동", "자랑완료", "프로필 완성도 100%", "프로필을 전부 완성했어요!"), //2

  PersonalBadgeDescription("활동", "음유시인", "커뮤니티 게시글 및 댓글 50개", "스타트업만을 위한 최초의 앱 커뮤니티!\n활동해주셔서 감사합니다.☺️"), //3
  PersonalBadgeDescription("활동", "수필작가", "커뮤니티 게시글 및 댓글 100개", "항상 당신의 이야기를 공유해줘서\n너무 감사합니다.😚"), //4
  PersonalBadgeDescription("활동", "단편소설가", "커뮤니티 게시글 및 댓글 200개", "당신만을 위한 게시판을 개설하겠습니다.\n(충성충성)"), //5
  PersonalBadgeDescription("활동", "장편소설가", "커뮤니티 게시글 및 댓글 400개", "당신은 혹시 박찬호 인가요?\n그렇다면 홍보모델로..\n-사담 홍보팀-"), //6
  PersonalBadgeDescription("활동", "뱃지 수집가", "뱃지 10개 이상", "뱃지를 10개 이상 모으셨어요!"), //7
  PersonalBadgeDescription("활동", "열혈 뱃지 수집가", "뱃지 20개 이상", "뱃지를 20개 이상 모으셨어요!"), //8
  PersonalBadgeDescription("활동", "최고 뱃지 수집가", "뱃지 50개 이상", "더는 모을 뱃지가 없는걸요?"), //9

  PersonalBadgeDescription("경력", "중고신입", "경력 1년", "겸손함과 노련미를 겸비했습니다!"), //10
  PersonalBadgeDescription("경력", "사춘기직딩", "경력 2년", "직딩도 사춘기만 넘으면 성숙해집니다!"), //11
  PersonalBadgeDescription("경력", "한창실세", "경력 3년", "업무는 이제 눈감고 발로도 가능해요!"), //12
  PersonalBadgeDescription("경력", "할거다한", "경력 5년", "마! 내가 느그 팀장이랑! 어!\n프로젝트도 하고! 어! 다했어!"), //13
  PersonalBadgeDescription("경력", "베테랑", "경력 7년 이상", "지금 내 기분이 그래. 어이가 없네?\n-사담 채용팀-"), //14

  PersonalBadgeDescription("학력", "학사", "최종 학력 학사", "양이라는 동물에 대해 공부했어요!"), //15
  PersonalBadgeDescription("학력", "석사", "최종 학력 석사", "양의 감각기관에 대해 공부했어요!"), //16
  PersonalBadgeDescription("학력", "박사", "최종 학력 박사", "양의 귀여운 코의 표면에 자라는\n솜털에 대해 공부했어요!"), //17

  PersonalBadgeDescription("수상", "일반수상", "국내 수상 상장수상", "대회에서 수상을 했어요!"), //18
  PersonalBadgeDescription("수상", "기관장", "국내 수상 기관장상", "기관장상을 받았어요! 멋지죠!"), //19
  PersonalBadgeDescription("수상", "장관", "국내 수상 장관상", "장관상을 받았어요! 나는 정말 대단해!"), //20
  PersonalBadgeDescription("수상", "대통령", "국내 수상 대통령상", "대한민국 발전에 이바지한 공로가 크므로\n이에 표창합니다.\n-양통령 양쓰-"), //21

  PersonalBadgeDescription("수상", "해외수상파", "해외 수상", "해외에서도 참지 못하고\n실력을 뽐내고 왔습니다!"), //22

  PersonalBadgeDescription("수상", "따놓은당상", "수상 횟수 3개", "어딜 가나 수상하는 저는 능력자에요!"), //23
  PersonalBadgeDescription("수상", "상장수집가", "수상 횟수 5개", "이 정도면 상 받는 게 취미라고 해도 되겠네요!"), //24
  PersonalBadgeDescription("수상", "들숨에 수, 날숨에 상", "수상 횟수 10개", "숨만 쉬어도 상을 받는 당신! 탐나는군요?\n-사담 채용팀-"), //25

  PersonalBadgeDescription("자격증", "기능사", "국가 기능사", "수준 높은 숙련기능을 보유하고 있습니다!"), //26
  PersonalBadgeDescription("자격증", "산업기사", "국가 산업기사", "기능사보다 한층 수준 높은\n숙련기능을 보유하고 있습니다!"), //27
  PersonalBadgeDescription("자격증", "기사", "국가 기사", "중세 서유럽에서의 무장기병전사(?) 입니다!"), //28
  PersonalBadgeDescription("자격증", "기능장", "국가 기능장", "분야에 대한\n최상급 숙련기능을 보유하고 있습니다!"), //29
  PersonalBadgeDescription("자격증", "기술사", "국가 기술사", "분야에 대한 고도의 전문지식과 실무경험에\n입각한 응용능력을 보유하고 있습니다!"), //31

  PersonalBadgeDescription("자격증", "국가전문자격증", "국가 전문 보유", "정부부처에서 주관하는 자격증이 있습니다!"), //31
  PersonalBadgeDescription("자격증", "민간자격증", "민간자격증 보유", "한국직업능력개발원의\n'민간자격 정보서비스'에 등록되어 있습니다!"), //32
  PersonalBadgeDescription("자격증", "자격증 다수", "자격증 3개", "나도 어디서 꿀리진 않어, 자격증이 3개니깐."), //33
  PersonalBadgeDescription("자격증", "자격증 부자", "자격증 5개", "내가 희생한 컴싸와 OMR 카드만 해도\n어느덧 세 자리..."), //34
  PersonalBadgeDescription("자격증", "자격증 왕", "자격증 7개", "네가 정말 그럴 자격이 된다고 생각해?\n응."), //35

  PersonalBadgeDescription("교육", "정부 교육 수료", "정부 교육 수료", "정부에서 주관하는 교육을 수료했어요!"), //36
  PersonalBadgeDescription("교육", "민간 교육 수료", "민간교육 수료", "민간에서 주관하는 교육을 수료했어요!"), //37
  PersonalBadgeDescription("교육", "늘새로이", "교육 횟수 2회", "새로운 걸 배운다는 것, 짜릿하더군요."), //38
  PersonalBadgeDescription("교육", "늘배움이", "교육 횟수 4회", "저희 어머니가\n배움에는 끝이 없다고 했습니다."), //39
  PersonalBadgeDescription("교육", "늘앞자리", "교육 횟수 6회", "자, 이제 사담에서 강의를 할 차례입니다.\n-사담 채용팀-"), //40

  PersonalBadgeDescription("매력", "고려", "단증 1단", "통나무 잡고, 손날치기, 이단 옆차기! 파박!"), //41
  PersonalBadgeDescription("매력", "금강", "단증 3단", "강함과 무거움을 의미하는 나의 강한 의지..."), //42
  PersonalBadgeDescription("매력", "태백", "단증 5단", "홍익인간의 정신을 담고 있는 사람입니다."), //43
  PersonalBadgeDescription("매력", "바람의 파이터", "단증 7단", "황소의 소뿔은 분필 조각처럼 부러지더군요."), //44
];

List<PersonalBadgeDescription> EventBadgeDescriptionList = [
  //index와 id와 동기화
  PersonalBadgeDescription("", "", "", ""),
  PersonalBadgeDescription("이벤트", "사담런칭기념", "회원가입", "스타트업 필수앱 사담 런칭기념 뱃지!\n초기에 가입하고 활동해주신 분들의 은혜..\n잊지않고 갚을거양 🐏"), //1
  PersonalBadgeDescription("이벤트", "CLASS101", "CLASS101 쿠폰발급 최초 1회", "사담가 발급해준 CLASS101 쿠폰으로\n저렴하게 강의를 들었어요!"), //2
];

List<TeamBadgeDescription> TeamBadgeDescriptionList = [
  TeamBadgeDescription("", "", "", ""),
  TeamBadgeDescription("활동", "팀 소개중", "프로필 완성도 70%", "높은 프로필 완성도로, 팀 모집을 더 쉽게!"), //1
  TeamBadgeDescription("활동", "팀 소개완료", "프로필 완성도 100%", "꾸준히 팀 프로필을 업데이트 해주세요.😀"), //2

  TeamBadgeDescription("활동", "팀 뱃지 10개", "뱃지 10개 이상", "팀 뱃지 10개를 모았어요!"), //3
  TeamBadgeDescription("활동", "팀 뱃지 20개", "뱃지 20개 이상", "팀 뱃지 20개를 모았어요!"), //4
  TeamBadgeDescription("활동", "팀 뱃지 50개", "뱃지 50개 이상", "팀 뱃지 50개를 모았어요! 정말 멋진 팀이에요!"), //5

  TeamBadgeDescription("경력", "개인사업자", "개인사업자 등록", "개인사업자라고 혼자하는거 아닙니다."), //6
  TeamBadgeDescription("경력", "법인사업자", "법인사업자 등록", "법인 임직원 채용은 사담"), //7
  TeamBadgeDescription("경력", "사회적기업", "사회적 기업 인증", "세상을 더 아름답게 만들어주는 사회적 기업"), //8
  TeamBadgeDescription("경력", "사업자", "사업자 인증", "사업자 인증이 완료되었습니다."), //9

  TeamBadgeDescription("경력", "소수정예", "임직원 3명 이상", "이제 삼각형은 만들 수 있어요!"), //10
  TeamBadgeDescription("경력", "성장하는중", "임직원 5명 이상", "한 달에 월급만 천만원 이상 나가요😢"), //11
  TeamBadgeDescription("경력", "돌이킬수없다", "임직원 7명 이상", "점점 든든한 기업이 되어가고 있어요!"), //12
  TeamBadgeDescription("경력", "로켓발사준비", "직원규모 10명 이상", "임직원 수 두 자리, 이제 오직 세 자리 생각뿐이다."), //13

  TeamBadgeDescription("경력", "소수정예 팀", "팀원 3명 이상", "셋이면 못할 게 없어요!"), //14
  TeamBadgeDescription("경력", "성장하는 팀", "팀원 5명 이상", "공모전, 대회를 휩쓸 준비가 되었어요."), //15
  TeamBadgeDescription("경력", "돌이킬 수 없는 팀", "팀원 7명 이상", "회사를 만들 때가 왔네요! 창업 준비는 사담에서."), //16
  TeamBadgeDescription("경력", "이정도면 회사", "팀원 10명 이상", "팀원이 어느덧 10명, 이제 지분은 10% 씩이다."), //17

  TeamBadgeDescription("경력", "사업장 보유", "사업장 보유", "팀원들을 위한 사업장이 준비되어있습니다!"), //18
  TeamBadgeDescription("경력", "wework", "wework 입주사", "wework에 입주해 있어요!"), //19
  TeamBadgeDescription("경력", "FASTFIVE", "FASTFIVE 입주사", "FASTFIVE에 입주해 있어요!"), //20
  TeamBadgeDescription("경력", "보육센터 입주", "보육센터 입주사", "보육센터에 입주해 있어요!"), //21

  TeamBadgeDescription("경력", "벤처기업", "벤처기업 인증 완료", "벤처기업 인증을 받았어요!"), //22
  TeamBadgeDescription("경력", "이노비즈", "이노비즈 인증 완료", "이노비즈 인증을 받았어요!"), //23
  TeamBadgeDescription("경력", "기업부설 연구소", "기업부설 연구소 설립 완료", "기업부설 연구소를 설립했어요!"), //24
  TeamBadgeDescription("경력", "연구전담부서", "연구전담부서 설립 완료", "연구전담부서를 보유하고 있어요!"), //25
  TeamBadgeDescription("경력", "가족친화형", "가족친화형 기업 인증 완료", "가족친화형 인증을 받았어요!"), //26
  TeamBadgeDescription("경력", "연구소 기업", "연구소 기업 인증 완료", "국가에서 인증받은 연구소 기업입니다."), //27

  TeamBadgeDescription("경력", "소소한 지원", "수행과제 1천만원 이상", "티끌 모아 태산⛰"), //28
  TeamBadgeDescription("경력", "과제의 시작", "수행과제 5천만원 이상", "내가 세금을 괜히 내는 게 아니었어.."), //29
  TeamBadgeDescription("경력", "과제가 최고", "수행과제 1억원 이상", "0의 개수만 무려 8개.."), //30
  TeamBadgeDescription("경력", "과제 없이 못살아", "수행과제 3억원 이상", "회사 성장의 든든한 동반자, 과제!"), //31
  TeamBadgeDescription("경력", "과제의 신", "수행과제 5억원 이상", "분명히 대학 때도 과제를 잘하셨죠?"), //32

  TeamBadgeDescription("경력", "매출의 시작", "연 매출 2천만원 이상", "매출발생이 얼마나 힘들었게요?"), //33
  TeamBadgeDescription("경력", "매출의 성장", "연 매출 5천만원 이상", "매출이 쭉쭉 성장하고 있군요!"), //34
  TeamBadgeDescription("경력", "억소리 나는 매출", "연 매출 1억원 이상", "손익분기점을 넘을 때 까지 파이팅!"), //35
  TeamBadgeDescription("경력", "3억소리 나는 매출", "연 매출 3억원 이상", "손익분기점 너머의 공기는 상쾌하네요."), //36
  TeamBadgeDescription("경력", "7억소리 나는 매출", "연 매출 7억원 이상", "두 자릿수 매출을 향해 파이팅!"), //37

  TeamBadgeDescription("경력", "투자의 시작", "투자유치 1천만원 이상", "회사의 성장 가능성이 보인다는 것."), //38
  TeamBadgeDescription("경력", "Pre Seed", "투자유치 5천만원 이상", "100배로 돌려드리겠습니다."), //39
  TeamBadgeDescription("경력", "Seed", "투자유치 1억원 이상", "시리즈 단계로 넘어가야 할 때."), //40
  TeamBadgeDescription("경력", "Pre Series A", "투자유치 3억원 이상", "기술력과 사업모델을 인정받은 기업이에요!"), //41
  TeamBadgeDescription("경력", "Pre Series A", "투자유치 5억원 이상", "시리즈 A를 향해.."), //42

  TeamBadgeDescription("경력", "소중한 첫 특허", "특허 1개 이상", "특허 등록증 모셔놓을 액자를 구매하세요!"), //43
  TeamBadgeDescription("경력", "특허도 자산", "특허 3개 이상", "특허의 중요성에 대해 잘 알고 계시네요!"), //44
  TeamBadgeDescription("경력", "든든한 특허", "특허 5개 이상", "탄탄한 지식재산권의 보호 기반을 만드셨네요!"), //45
  TeamBadgeDescription("경력", "특허는 곧 실력", "특허 10개 이상", "사무실 입구에 쭉 늘어놓으셨죠?"), //46
  TeamBadgeDescription("경력", "IP스타기업", "특허 20개 이상", "이제는 사내 변리사를 고용해도 되겠는걸요?"), //47

  TeamBadgeDescription("수상", "수상의 짜릿함", "수상 이력", "수상 경력을 보유하고 있어요!"), //48
  TeamBadgeDescription("수상", "기관장상 뱃지", "기관장상 수상 이력", "기관장급 수상 경력을 보유하고 있어요!"), //49
  TeamBadgeDescription("수상", "장관상 뱃지", "장관상 수상 이력", "내가 살다가 뉴스에서만 보던 장관님을 뵐 줄이야.."), //50
  TeamBadgeDescription("수상", "대통령상 뱃지", "대통령상 수상 이력", "대통령이랑 악수도 했나요? - 사담 콘텐츠 팀 -"), //51

  TeamBadgeDescription("수상", "해외파 기업", "해외수상 이력", "상장에 영어 필기체로 마구 써있어서 인증하기 힘들었어요😢 -사담 인증 팀 -"), //52

  TeamBadgeDescription("수상", "수상더하기", "수상경력 3회 이상", "수상에 수상에 수상을 더해서~"), //53
  TeamBadgeDescription("수상", "수상주의 회사", "수상경력 5회 이상", "각종 대회에서 실력을 인정받았어요!"), //54
  TeamBadgeDescription("수상", "극수상주의 회사", "수상경력 5회 이상", "분기별 수상 KPI 있는 회사."), //55

  TeamBadgeDescription("매력", "담배없는회사", "비흡연 사업장 서약 완료", "팀원 모두가 비흡연자에요!"), //56
];
