
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sheeps_app/Recruit/Controller/FilterController.dart';
import 'package:sheeps_app/Recruit/Controller/RecruitController.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sheeps_app/Setting/BusinessInfoPage.dart';
import 'package:sheeps_app/Setting/DetailAlarmPage.dart';
import 'package:sheeps_app/Setting/ModifyMemberInformation.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/NavigationNum.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/profile/models/FilterState.dart';

class AppSetting extends StatefulWidget {
  final PackageInfo packageInfo;

  AppSetting({Key? key, required this.packageInfo}) : super(key: key);

  @override
  _AppSettingState createState() => _AppSettingState();
}

class _AppSettingState extends State<AppSetting> {

  NavigationNum navigationNum = Get.put(NavigationNum());

  @override
  void initState() {
    super.initState();
    setState(() {
      Future.microtask(() async {
        AllNotification = await getNotiByStatus();
      });
    });

    Get.put(FilterController()); // 리쿠르트 필터 컨트롤러
    Get.put(FilterStateForPersonal()); // 프로필 필터 컨트롤러
  }

  @override
  Widget build(BuildContext context) {
    SocketProvider socket = SocketProvider.to;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: null,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Scaffold(
                backgroundColor: Color(0xFFF8F8F8),
                appBar: SheepsAppBar(context, '앱 설정'),
                body: ListView(
                  children: [
                    Container(
                      width: 360 * sizeUnit,
                      height: 32 * sizeUnit,
                      color: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit),
                        child: Row(
                          children: [
                            Text(
                              '기본 설정',
                              style: SheepsTextStyle.h4(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(()=>DetailAlarmPage());
                      },
                      child: Container(
                        color: Colors.white,
                        height: 48 * sizeUnit,
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 12 * sizeUnit),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '푸시 알림 설정',
                                  style: SheepsTextStyle.b1(),
                                ),
                              ),
                            ),
                            Expanded(child: SizedBox()),
                            Padding(
                              padding: EdgeInsets.only(right: 16 * sizeUnit),
                              child: SvgPicture.asset(
                                svgGreyNextIcon,
                                width: 16 * sizeUnit,
                                height: 16 * sizeUnit,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 1 * sizeUnit),
                    GestureDetector(
                      onTap: () {
                        Get.to(()=>ModifyMemberInformation());
                      },
                      child: buildGotoNextPage(context, '비밀번호 변경'),
                    ),
                    Container(
                      width: 360 * sizeUnit,
                      height: 32 * sizeUnit,
                      color: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit),
                        child: Row(
                          children: [
                            Text(
                              '서비스 정보',
                              style: SheepsTextStyle.h4(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        launch(sheepsHomePageUrl);
                      },
                      child: buildGotoNextPage(context, 'SHEEPS.kr'),
                    ),
                    SizedBox(height: 1 * sizeUnit),
                    GestureDetector(
                      onTap: () {
                        launch(sheepsKakaoTalkChannel);
                      },
                      child: buildGotoNextPage(context, '문의 하기'),
                    ),
                    SizedBox(height: 1 * sizeUnit),
                    GestureDetector(
                      onTap: () {
                        Get.to(()=>BusinessInfoPage());
                      },
                      child: buildGotoNextPage(context, '사업자 정보'),
                    ),
                    Container(
                      width: 360 * sizeUnit,
                      height: 32 * sizeUnit,
                      color: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit),
                        child: Row(
                          children: [
                            Text(
                              '약관 안내',
                              style: SheepsTextStyle.h4(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        launch(sheepsTermsOfServiceUrl);
                      },
                      child: buildGotoNextPage(context, '서비스 이용약관'),
                    ),
                    SizedBox(height: 1 * sizeUnit),
                    GestureDetector(
                      onTap: (){
                        launch(sheepsPrivacyPolicyUrl);
                      },
                      child: buildGotoNextPage(context, '개인정보 처리방침'),
                    ),
                    SizedBox(height: 1 * sizeUnit),
                    GestureDetector(
                      onTap: () {
                        launch(sheepsCommunityGuideUrl);
                      },
                      child: buildGotoNextPage(context, '커뮤니티 정책'),
                    ),
                    SizedBox(height: 1 * sizeUnit),
                    GestureDetector(
                      onTap: () {
                        launch(sheepsMarketingAgreementUrl);
                      },
                      child: buildGotoNextPage(context, '마케팅 수신동의'),
                    ),
                    SizedBox(height: 12 * sizeUnit),
                    GestureDetector(
                        onTap: () async {
                          Function okFunc = () async {
                            FilterController filterController = Get.put(FilterController());
                            FilterStateForPersonal filterStateForPersonal = Get.put(FilterStateForPersonal());
                            RecruitController recruitController = Get.put(RecruitController());

                            filterController.recruitLogoutEvent(); // 리쿠르트 로그아웃 이벤트
                            filterStateForPersonal.profileFilterLogoutEvent(); // 프로필 필터 로그아웃 이벤트

                            await globalLogout(true,socket);
                          };

                          Function cancelFunc = () {
                            Get.back();
                          };

                          showSheepsDialog(
                            context: context,
                            title: '로그아웃',
                            description: '로그아웃 시\n채팅과 알림에 대한 내용이 지워져요.\n\n로그아웃 하시겠어요?',
                            okText: '할래요',
                            okFunc: okFunc,
                            cancelText: '좀 더 둘러볼래요',
                            cancelFunc: cancelFunc,
                          );
                        },
                        child: buildGotoNextPage(context, '로그아웃')),
                    SizedBox(height: 8 * sizeUnit),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal : 12*sizeUnit),
                      child: Text('- 앱 버전 ' + widget.packageInfo.version ?? '', style: SheepsTextStyle.info2()),
                    ),
                    SizedBox(height: 40 * sizeUnit),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
