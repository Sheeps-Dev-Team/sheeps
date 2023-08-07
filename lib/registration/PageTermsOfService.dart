import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';


import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/registration/RegistrationPage.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/registration/model/RegistrationModel.dart';

class PageTermsOfService extends StatefulWidget {
  final int loginType;

  PageTermsOfService({Key key, @required this.loginType}) : super(key: key);

  @override
  _PageTermsOfServiceState createState() => _PageTermsOfServiceState();
}

class _PageTermsOfServiceState extends State<PageTermsOfService> {
  bool isMustAgree;
  bool isServiceAgree;
  bool isPrivacyAgree;
  bool isCommunityAgree;
  bool isMarketingAgree;
  bool isAllAgree;

  @override
  void initState() {
    isMustAgree = false;
    isServiceAgree = false;
    isPrivacyAgree = false;
    isCommunityAgree = false;
    isMarketingAgree = false;
    isAllAgree = false;

    super.initState();
  }

  void nextFunc() {
    switch (widget.loginType) {
      case LOGIN_TYPE_SHEEPS:
        {
          Get.off(() => RegistrationPage(isMarketingAgree: isMarketingAgree, loginType: LOGIN_TYPE_SHEEPS));
        }
        break;
      case LOGIN_TYPE_GOOGLE:
        {
          ApiProvider().post('/Personal/Update/Marketing', jsonEncode({"id": globalLoginID, "marketingAgree": isMarketingAgree}));
          Get.off(() => RegistrationPage(loginType: LOGIN_TYPE_GOOGLE));
        }
        break;
      case LOGIN_TYPE_APPLE:
        {
          ApiProvider().post('/Personal/Update/Marketing', jsonEncode({"id": globalLoginID, "marketingAgree": isMarketingAgree}));
          Get.off(() => RegistrationPage(loginType: LOGIN_TYPE_APPLE));
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isServiceAgree && isPrivacyAgree && isCommunityAgree) {
      isMustAgree = true;
    } else {
      isMustAgree = false;
    }
    if (isServiceAgree && isPrivacyAgree && isCommunityAgree && isMarketingAgree) {
      isAllAgree = true;
    } else {
      isAllAgree = false;
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: null,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시,
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: SheepsAppBar(context, '약관 동의'),
                body: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 20 * sizeUnit, right: 16 * sizeUnit),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 68 * sizeUnit),
                              Row(
                                children: [
                                  SizedBox(width: 6 * sizeUnit),
                                  Text(
                                    '약관을 확인해 주세요.',
                                    style: SheepsTextStyle.h1(),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20 * sizeUnit),
                              Row(
                                children: [
                                  SizedBox(width: 6 * sizeUnit),
                                  Text(
                                    '쉽스를 안전하게 이용하기 위한 약관이에요.\n약관 동의 후 회원가입을 시작합니다.',
                                    style: SheepsTextStyle.b2().copyWith(height: 1.5),
                                  ),
                                ],
                              ),
                              SizedBox(height: 48 * sizeUnit),
                              GestureDetector(
                                onTap: () {
                                  if (isAllAgree) {
                                    isServiceAgree = false;
                                    isPrivacyAgree = false;
                                    isCommunityAgree = false;
                                    isMarketingAgree = false;
                                  } else {
                                    isServiceAgree = true;
                                    isPrivacyAgree = true;
                                    isCommunityAgree = true;
                                    isMarketingAgree = true;
                                  }
                                  setState(() {});
                                },
                                child: Container(
                                  width: 320 * sizeUnit,
                                  height: 32 * sizeUnit,
                                  color: Colors.white,
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        svgCheck,
                                        height: 16 * sizeUnit,
                                        width: 16 * sizeUnit,
                                        color: isAllAgree ? sheepsColorGreen : sheepsColorGrey,
                                      ),
                                      SizedBox(width: 8 * sizeUnit),
                                      Text(
                                        '전체 동의하기',
                                        style: SheepsTextStyle.h2().copyWith(height: 1.2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 4 * sizeUnit),
                              Divider(
                                thickness: 2 * sizeUnit,
                                color: isAllAgree ? sheepsColorGreen : sheepsColorGrey,
                              ),
                              SizedBox(height: 16 * sizeUnit),
                              Row(
                                children: [
                                  SizedBox(width: 24 * sizeUnit),
                                  GestureDetector(
                                    onTap: () {
                                      isServiceAgree = !isServiceAgree;
                                      setState(() {});
                                    },
                                    child: Container(
                                      width: 280 * sizeUnit,
                                      height: 32 * sizeUnit,
                                      color: Colors.white,
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            //인증완료 1 일때 초록아이콘
                                            svgCheck,
                                            height: 16 * sizeUnit,
                                            width: 16 * sizeUnit,
                                            color: isServiceAgree ? sheepsColorGreen : sheepsColorGrey,
                                          ),
                                          SizedBox(width: 8 * sizeUnit),
                                          Text(
                                            '서비스 이용약관',
                                            style: SheepsTextStyle.h3(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4 * sizeUnit),
                                  GestureDetector(
                                    onTap: () {
                                      launch(sheepsTermsOfServiceUrl);
                                    },
                                    child: SvgPicture.asset(
                                      svgGreyNextIcon,
                                      width: 16 * sizeUnit,
                                      height: 16 * sizeUnit,
                                      color: sheepsColorGrey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10 * sizeUnit),
                              Row(
                                children: [
                                  SizedBox(width: 24 * sizeUnit),
                                  GestureDetector(
                                    onTap: () {
                                      isPrivacyAgree = !isPrivacyAgree;
                                      setState(() {});
                                    },
                                    child: Container(
                                      width: 280 * sizeUnit,
                                      height: 32 * sizeUnit,
                                      color: Colors.white,
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            //인증완료 1 일때 초록아이콘
                                            svgCheck,
                                            height: 16 * sizeUnit,
                                            width: 16 * sizeUnit,
                                            color: isPrivacyAgree ? sheepsColorGreen : sheepsColorGrey,
                                          ),
                                          SizedBox(width: 8 * sizeUnit),
                                          Text(
                                            '개인정보 처리방침',
                                            style: SheepsTextStyle.h3(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4 * sizeUnit),
                                  GestureDetector(
                                    onTap: () {
                                      launch(sheepsPrivacyPolicyUrl);
                                    },
                                    child: SvgPicture.asset(
                                      svgGreyNextIcon,
                                      width: 16 * sizeUnit,
                                      height: 16 * sizeUnit,
                                      color: sheepsColorGrey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10 * sizeUnit),
                              Row(
                                children: [
                                  SizedBox(width: 24 * sizeUnit),
                                  GestureDetector(
                                    onTap: () {
                                      isCommunityAgree = !isCommunityAgree;
                                      setState(() {});
                                    },
                                    child: Container(
                                      width: 280 * sizeUnit,
                                      height: 32 * sizeUnit,
                                      color: Colors.white,
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            //인증완료 1 일때 초록아이콘
                                            svgCheck,
                                            height: 16 * sizeUnit,
                                            width: 16 * sizeUnit,
                                            color: isCommunityAgree ? sheepsColorGreen : sheepsColorGrey,
                                          ),
                                          SizedBox(width: 8 * sizeUnit),
                                          Text(
                                            '커뮤니티 정책',
                                            style: SheepsTextStyle.h3(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4 * sizeUnit),
                                  GestureDetector(
                                    onTap: () {
                                      launch(sheepsCommunityGuideUrl);
                                    },
                                    child: SvgPicture.asset(
                                      svgGreyNextIcon,
                                      width: 16 * sizeUnit,
                                      height: 16 * sizeUnit,
                                      color: sheepsColorGrey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10 * sizeUnit),
                              Row(
                                children: [
                                  SizedBox(width: 24 * sizeUnit),
                                  GestureDetector(
                                    onTap: () {
                                      isMarketingAgree = !isMarketingAgree;
                                      setState(() {});
                                    },
                                    child: Container(
                                      width: 280 * sizeUnit,
                                      height: 32 * sizeUnit,
                                      color: Colors.white,
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            //인증완료 1 일때 초록아이콘
                                            svgCheck,
                                            height: 16 * sizeUnit,
                                            width: 16 * sizeUnit,
                                            color: isMarketingAgree ? sheepsColorGreen : sheepsColorGrey,
                                          ),
                                          SizedBox(width: 8 * sizeUnit),
                                          Text(
                                            '혜택 알림 수신동의 (선택)',
                                            style: SheepsTextStyle.h3(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4 * sizeUnit),
                                  GestureDetector(
                                    onTap: () {
                                      launch(sheepsMarketingAgreementUrl);
                                    },
                                    child: SvgPicture.asset(
                                      svgGreyNextIcon,
                                      width: 16 * sizeUnit,
                                      height: 16 * sizeUnit,
                                      color: sheepsColorGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20 * sizeUnit),
                      child: SheepsBottomButton(
                          context: context,
                          function: () {
                            if (isMustAgree) {
                              if (isMarketingAgree) {
                                nextFunc();
                              } else {
                                showSheepsCustomDialog(
                                  contents: Text(
                                    '쉽스의 혜택 알림 수신에 동의하시면\n새로운 기능 안내, 프로필 맞춤정보,\n다양한 할인 혜택 등 도움이 되는\n정보를 받아볼 수 있습니다.\n\n회원님께 좋은것만 드리는데..👉🏻👈🏻\n동의하시겠어요?',
                                    style: SheepsTextStyle.b3(),
                                    textAlign: TextAlign.center,
                                  ),
                                  okText: '물론이죠 😇',
                                  cancelText: '아니오',
                                  isCancelButton: true,
                                  okButtonColor: sheepsColorBlue,
                                  cancelFunc: () {
                                    Get.back();
                                    nextFunc();
                                  },
                                  okFunc: () {
                                    isMarketingAgree = true;
                                    Get.back();
                                    nextFunc();
                                    showSheepsToast(context: context, text: '혜택 알림 수신에 동의하셨습니다.');
                                  },
                                );
                              }
                            }
                          },
                          text: "다음",
                          isOK: isMustAgree),
                    )
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
