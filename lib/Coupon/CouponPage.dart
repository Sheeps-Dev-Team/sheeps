import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sheeps_app/Coupon/Models/Coupon.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import '../network/ApiProvider.dart';
import '../userdata/GlobalProfile.dart';

class CouponPage extends StatefulWidget {
  const CouponPage({Key? key}) : super(key: key);

  @override
  _CouponPageState createState() => _CouponPageState();
}

class _CouponPageState extends State<CouponPage> {
  List<Coupon> couponList = [];

  void loadCoupon() async {
    couponList.clear();
    var res = await ApiProvider().post(
        '/Personal/Select/Coupon',
        jsonEncode({
          "userID": GlobalProfile.loggedInUser.userID,
        }));

    if (res != null) {
      for (int i = 0; i < res.length; i++) {
        couponList.add(Coupon.fromJson(res[i]));
      }
    }

    //사용불가 쿠폰 하단으로
    List<Coupon> tmpList = [];

    for(int i = couponList.length-1; i >= 0; i--){
      if(couponList[i].state != COUPON_STATE_POSSIBLE){
        tmpList.insert(0, couponList[i]);
        couponList.removeAt(i);
      }
    }

    couponList.addAll(tmpList);

    setState(() {});
  }

  void couponFunc(BuildContext context, Coupon coupon){

    if(coupon.url.isNotEmpty){
      showSheepsDialog(
        context: context,
        title: '사용하시겠어요?',
        description: '사용처로 이동되며,\n쿠폰코드를 등록해 사용하세요.',
        okText: '사용하기',
        okFunc: (){
          Get.back();
          launch(coupon.url);
        },
        isCancelButton: true,
      );
    } else {
      switch (coupon.couponID){
        case COUPON_ID_FAV :
          {
            showSheepsCustomDialog(
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '사용하시겠어요?',
                    style: SheepsTextStyle.dialogTitle(),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6*sizeUnit),
                  Text(
                    '*본 쿠폰은 직원 확인용입니다.',
                    style: SheepsTextStyle.h4(),
                  ),
                ],
              ),
              contents: Text(
                '한 번 사용한 쿠폰은\n재사용 할 수 없어요!',
                style: SheepsTextStyle.dialogContent(),
                textAlign: TextAlign.center,
              ),
              okText: '직원확인',
              okFunc: (){
                Get.back();
                showSheepsDialog(
                  context: context,
                  title: '직원 확인',
                  description: '직원이신가요?\n직원 확인을 마치면 쿠폰은 사용 완료로 변경됩니다.',
                  okText: '직원 확인',
                  okFunc: () async {
                    //사용완료 요청
                    var res = await ApiProvider().post(
                        '/Personal/Update/Coupon/State',
                        jsonEncode({
                          'id': coupon.id,
                          'state': COUPON_STATE_COMPLETE,
                          "userID": GlobalProfile.loggedInUser.userID,
                        }));

                    Get.back();

                    //사용완료 성공시
                    if (res != null) {
                      loadCoupon();
                    } else {
                      showSheepsDialog(context: context, title: '쿠폰 사용 실패', description: '쿠폰 사용에 문제가 발생했어요!\n직원에게 문의해주세요!', okColor: sheepsColorRed);
                    }
                  },
                );
              },
              isCancelButton: true,
            );
          }
          break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadCoupon();
  }

  @override
  Widget build(BuildContext context) {
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
                appBar: SheepsAppBar(context, '쿠폰함'),
                body: Column(
                  children: [
                    _buildTwoButton(),
                    _buildListView(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Expanded _buildListView() {
    return Expanded(
      child: ListView.builder(
        itemCount: couponList.length,
        itemBuilder: (context, index) {
          return couponListItem(couponList[index]);
        },
      ),
    );
  }

  Widget couponListItem(Coupon coupon) {
    String periodStart = coupon.periodStart.substring(0, 4) + '.' + coupon.periodStart.substring(4, 6) + '.' + coupon.periodStart.substring(6);
    String periodEnd = coupon.periodEnd.substring(0, 4) + '.' + coupon.periodEnd.substring(4, 6) + '.' + coupon.periodEnd.substring(6);
    String period = periodStart + '~' + periodEnd;

    //기간만료 날짜 비교. 사용완료면 안함
    if (coupon.state != COUPON_STATE_COMPLETE) {
      DateTime now = DateTime.now();
      String month = now.month.toString();
      if (now.month < 10) month = '0' + month;
      String day = now.day.toString();
      if (now.day < 10) day = '0' + day;
      String dateNow = now.year.toString() + month + day;

      if (dateNow.compareTo(coupon.periodEnd) == 1) coupon.state = COUPON_STATE_EXPIRY;
    }

    if (coupon.state == COUPON_STATE_COMPLETE) {
      period = period + ' (사용완료)';
    } else if (coupon.state == COUPON_STATE_EXPIRY) {
      period = period + ' (기간만료)';
    }
    return GestureDetector(
      onTap: (){
        if(coupon.state == COUPON_STATE_POSSIBLE) couponFunc(context, coupon);
      },
      child: Container(
        width: 360 * sizeUnit,
        height: 104 * sizeUnit,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: sheepsColorGrey, width: 0.5 * sizeUnit),
        ),
        child: Row(
          children: [
            Container(
              width: 128 * sizeUnit,
              color: coupon.state == COUPON_STATE_POSSIBLE ? coupon.color : sheepsColorGrey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: 96 * sizeUnit, maxHeight: 16 * sizeUnit),
                    child: Image.asset(
                      'assets/images/Coupon/' + coupon.useFor + '.png', //png 파일명 사용처랑 맞출것
                    ),
                  ),
                  SizedBox(height: 12 * sizeUnit),
                  Text(coupon.description, style: SheepsTextStyle.couponLabel()),
                ],
              ),
            ),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final boxHeight = constraints.constrainHeight();
                final dashWidth = 2 * sizeUnit;
                final dashHeight = 4 * sizeUnit;
                final dashCount = (boxHeight / (2 * dashHeight)).floor();
                return Flex(
                  children: List.generate(dashCount, (_) {
                    return SizedBox(
                      width: dashWidth,
                      height: dashHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: coupon.state == COUPON_STATE_POSSIBLE ? coupon.color : sheepsColorGrey,
                        ),
                      ),
                    );
                  }),
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  direction: Axis.vertical,
                );
              },
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.only(left: 24 * sizeUnit, top: 12 * sizeUnit),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(coupon.title, style: SheepsTextStyle.h4().copyWith(color: coupon.state == COUPON_STATE_POSSIBLE ? coupon.color : sheepsColorGrey)),
                    SizedBox(height: 10 * sizeUnit),
                    Text('쿠폰코드', style: SheepsTextStyle.s2().copyWith(color: sheepsColorGrey)),
                    SizedBox(height: 4 * sizeUnit),
                    Text(coupon.couponCode, style: SheepsTextStyle.couponCode().copyWith(color: coupon.state == COUPON_STATE_POSSIBLE ? coupon.color : sheepsColorGrey)),
                    SizedBox(height: 10 * sizeUnit),
                    Text(period, style: SheepsTextStyle.couponPeriod()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTwoButton() {
    int canUseCouponCount = 0;
    couponList.forEach((element) {if(element.state == COUPON_STATE_POSSIBLE) canUseCouponCount++;});
    return Container(
      height: 36 * sizeUnit,
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 8 * sizeUnit),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: sheepsColorLightGrey))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('사용 가능 쿠폰 $canUseCouponCount개', style: SheepsTextStyle.h4()),
          GestureDetector(
            onTap: (){
             //쿠폰등록 페이지
            },
            child: Text('쿠폰등록', style: SheepsTextStyle.h4()),
          ),
        ],
      ),
    );
  }
}
