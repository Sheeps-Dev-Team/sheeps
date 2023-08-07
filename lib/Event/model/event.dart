import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sheeps_app/Coupon/CouponPage.dart';
import 'package:sheeps_app/Coupon/Models/Coupon.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/MyBadge.dart';
import 'package:url_launcher/url_launcher.dart';

class Event {
  String img1 = '';
  String img2 = '';
  Color backgroundColor = Colors.white;
  Color buttonColor = Colors.white;
  Color buttonTextColor = sheepsColorBlack;
  Function buttonFunc = () {};
  Widget bottomWidget = SizedBox.shrink();

  Event({
    @required this.img1,
    @required this.img2,
    @required this.buttonFunc,
    @required this.bottomWidget,
    @required this.backgroundColor,
    @required this.buttonTextColor,
    @required this.buttonColor,
  });
}

final Event eventClass101 = Event(
  img1: 'assets/images/Event/1_class101_event_page_1.png',
  img2: 'assets/images/Event/1_class101_event_page_2.png',
  backgroundColor: Colors.black,
  buttonColor: Colors.blue,
  buttonTextColor: Colors.black,
  bottomWidget: SizedBox.shrink(),
  buttonFunc: (BuildContext context) async {
    //발급조건 체크
    if (GlobalProfile.loggedInUser.profileImgList[0].imgUrl != 'BasicImage') {
      var res = await ApiProvider().post(
          '/Personal/Insert/Coupon',
          jsonEncode({
            "userID": GlobalProfile.loggedInUser.userID,
            "type": COUPON_TYPE_NORMAL,
            "couponID": COUPON_ID_CLASS101,
          }));

      if (res == null) {
        showSheepsToast(context: context, text: '쿠폰 발급에 문제가 생겼어요. 다시 시도해주세요.');
        return;
      }

      String result = res['res'] as String;

      if (result == 'SUCCESS') {
        showSheepsDialog(
          context: context,
          title: '쿠폰이 발급되었어요!🎉',
          description: '마이페이지에서\n쿠폰함을 확인해주세요!',
          okText: '쿠폰 보러 가기',
          okFunc: () {
            Get.back();
            Get.to(() => CouponPage());
          },
          isCancelButton: false,
        );

        var res = await ApiProvider().post(
            '/Badge/Get/EventBadge',
            jsonEncode({
              "id": 2, //클래스 101 뱃지
              "userID": GlobalProfile.loggedInUser.userID
            }));

        if (res != null) {
          GlobalProfile.loggedInUser.badgeList.add(BadgeModel.fromJson(res));
        }
      } else if (result == 'ALREADY') {
        showSheepsDialog(
          context: context,
          title: '이미 발급된\n쿠폰이에요!😳 ',
          description: '마이페이지에서\n쿠폰함을 확인해주세요!',
          okText: '쿠폰 보러 가기',
          okFunc: () {
            Get.back();
            Get.to(() => CouponPage());
          },
          isCancelButton: false,
        );
      } else if (result == 'LIMIT') {
        showSheepsDialog(
          context: context,
          title: '쿠폰이 모두 소진 되었어요!\n쿠폰이에요!😳 ',
          description: '마이페이지에서\n쿠폰함을 확인해주세요!',
          okText: '확인',
          isCancelButton: false,
        );
      } else {
        showSheepsToast(context: context, text: '오류가 발생했습니다.');
      }
    } else {
      showSheepsDialog(
        context: context,
        title: '쿠폰을\n받을 수 없어요!😢',
        description: '발급 조건을 확인해주세요!',
        isCancelButton: false,
      );
    }
  },
);

final Event eventFav = Event(
  img1: 'assets/images/Event/2_fav_1.png',
  img2: 'assets/images/Event/2_fav_2.png',
  backgroundColor: Color(0xFFDAC6B0),
  buttonColor: Colors.white,
  buttonTextColor: Colors.black,
  buttonFunc: (BuildContext context) async {
    //발급 가능 체크, 가능 true, 불가능 false
    var res = await ApiProvider().post(
        '/Personal/Check/Coupon/Remained',
        jsonEncode({
          "id": COUPON_ID_FAV,
        }));

    void deadline(){
      showSheepsDialog(
        context: context,
        title: '쿠폰이 모두\n소진되었어요😳 ',
        description: '본 이벤트는 선착순 마감으로 종료되었어요\n다음 이벤트를 기대해주세요!',
        okText: '확인',
        isCancelButton: false,
      );
    }

    if(!res){
      deadline();
      return;
    }

    bool demand1 = false;
    bool demand2 = false;
    bool isOK = false;

    var tmp = await ApiProvider().post(
        '/CommunityPost/SelectUser',
        jsonEncode({
          "userID": GlobalProfile.loggedInUser.userID,
        }));
    if (tmp != null) {
      if (tmp.length > 0) demand1 = true;
    }

    GlobalProfile.loggedInUser.userEducationList.forEach((education) {
      if(education.auth == 1){
        if(education.contents.contains('인하대')) demand2 = true;
      }
    });

    if(demand1 && demand2) isOK = true;

    //발급조건 체크
    if (isOK) {
      var res = await ApiProvider().post(
          '/Personal/Insert/Coupon',
          jsonEncode({
            "userID": GlobalProfile.loggedInUser.userID,
            "type": COUPON_TYPE_NORMAL,
            "couponID": COUPON_ID_FAV,
          }));

      if (res == null) {
        showSheepsToast(context: context, text: '쿠폰 발급에 문제가 생겼어요. 다시 시도해주세요.');
        return;
      }

      String result = res['res'] as String;

      if (result == 'SUCCESS') {
        showSheepsDialog(
          context: context,
          title: '쿠폰이 발급되었어요!🎉',
          description: '마이페이지에서\n쿠폰함을 확인해주세요!',
          okText: '쿠폰 보러 가기',
          okFunc: () {
            Get.back();
            Get.to(() => CouponPage());
          },
          isCancelButton: false,
        );
      } else if (result == 'ALREADY') {
        showSheepsDialog(
          context: context,
          title: '이미 발급된\n쿠폰이에요!😳 ',
          description: '마이페이지에서\n쿠폰함을 확인해주세요!',
          okText: '쿠폰 보러 가기',
          okFunc: () {
            Get.back();
            Get.to(() => CouponPage());
          },
          isCancelButton: false,
        );
      } else if (result == 'LIMIT') {
        deadline();
      } else {
        showSheepsToast(context: context, text: '쿠폰 발급에 문제가 생겼어요. 다시 시도해주세요.');
      }
    } else {
      showSheepsDialog(
        context: context,
        title: '쿠폰을\n받을 수 없어요!😢',
        description: '발급 조건을 확인해주세요!',
        isCancelButton: false,
      );
    }
  },
  bottomWidget: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      GestureDetector(
        onTap: () async {
          //쿠폰 id
          var res = await ApiProvider().post(
              '/Personal/Select/ContentsURL',
              jsonEncode({
                'id': COUPON_ID_FAV,
              }));
          String url = res['ContentsURL'] as String;

          launch(url);
        },
        child: Container(
          width: 360*sizeUnit,
          height: 30*sizeUnit,
          color: sheepsColorLightGrey,
          child: Center(
            child: Container(
              width: 108*sizeUnit,
              height: 30*sizeUnit,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15*sizeUnit),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '동영상 보러가기',
                    style: SheepsTextStyle.h4().copyWith(color: Color(0xFF00A0E9)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      Image.asset(
        'assets/images/Event/2_fav_3.png',
        width: 360 * sizeUnit,
      ),
    ],
  ),
);
