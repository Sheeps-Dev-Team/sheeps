import 'package:flutter/material.dart';

//파일명 코딩규약 지킬것.

const Color sheepsColorBlack = Color(0xFF222222);
const Color sheepsColorRed = Color(0xFFF77777);
const Color sheepsColorGreen = Color(0xFF61C680);
const Color sheepsColorLightGrey = Color(0xFFEEEEEE);
const Color sheepsColorGrey = Color(0xFFCCCCCC);
const Color sheepsColorDarkGrey = Color(0xFF888888);
const Color sheepsColorBlue = Color(0xFF5C88DA);

const Duration kAnimationDuration = Duration(milliseconds: 200);

const int LOGIN_TYPE_SHEEPS = 0;
const int LOGIN_TYPE_GOOGLE = 1;
const int LOGIN_TYPE_APPLE = 2;
const int LOGIN_TYPE_KAKAO = 3;

const int MAX_USER_PROFILE_IMG = 5;
const int MAX_TEAM_PROFILE_IMG = 5;

const int DASHBOARD_MAIN_PAGE = 0;
const int PROFILE_PAGE = 1;
const int TEAM_RECRUIT_PAGE = 2;
const int COMMUNITY_MAIN_PAGE = 3;
const int CHATROOM_PAGE = 4;

const int minimumDeclareForBlind = 3; // 블라인드 최소 신고 갯수
const int minimumScoreForPopular = 5; // 커뮤니티 인기글 최소 점수

const String sheepsHomePageUrl = 'https://www.sheeps.kr';//쉽스 홈페이지
const String sheepsKakaoTalkChannel = 'http://pf.kakao.com/_eGYas/chat';//문의하기 카카오톡채널 채팅
const String sheepsTermsOfServiceUrl = 'https://www.sheeps.kr/legal/user-agreement'; // 서비스 이용약관
const String sheepsPrivacyPolicyUrl = 'https://www.sheeps.kr/legal/privacy-policy'; // 개인정보 처리방침
const String sheepsCommunityGuideUrl = 'https://www.sheeps.kr/legal/community-guide'; // 커뮤니티 정책
const String sheepsMarketingAgreementUrl = 'https://www.sheeps.kr/legal/marketing-agreement'; // 마케팅 수신동의

const int RECRUIT_LIMIT_PERSON = 2;
const int RECRUIT_LIMIT_TEAM = 3;

const int MAX_CREATE_TEAM_LENGTH = 3; // 팀 최대 생성 가능 갯수

const nullInt = -100;