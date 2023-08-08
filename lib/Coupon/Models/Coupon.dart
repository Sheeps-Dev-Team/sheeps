import 'package:flutter/material.dart';

const int COUPON_STATE_POSSIBLE = 0; // 사용 가능
const int COUPON_STATE_EXPIRY = 1; // 기간 만료
const int COUPON_STATE_COMPLETE = 2; // 사용 완료

const int COUPON_TYPE_NORMAL = 0; // 쿠폰타입 일반
const int COUPON_TYPE_LIMIT = 1; // 쿠폰타입 한정

const int COUPON_ID_CLASS101 = 1; //class 101 쿠폰
const int COUPON_ID_FAV = 2; //fav 쿠폰

class Coupon {
  int id;
  int couponID;
  String title;
  String description;
  String couponCode;
  String periodStart;
  String periodEnd;
  String useFor;
  String url;
  int state;
  int type;
  Color color;
  String createdAt;
  String updatedAt;

  Coupon({
    required this.id,
    required this.couponID,
    required this.title,
    required this.description,
    required this.couponCode,
    required this.periodStart,
    required this.periodEnd,
    required this.useFor,
    required this.url,
    required this.state,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.color,
  });

  factory Coupon.fromJson(Map<String, dynamic> json, {bool isUserID = true}) {
    String colorCode = json['coupon'][0]['MainColor'] as String;
    Color _color = Color(int.parse("0xFF" + colorCode));

    return Coupon(
      id: json['id'] as int,
      couponID: json['coupon'][0]['id'] as int,
      title: json['coupon'][0]['Title'] as String,
      description: json['coupon'][0]['Description'] as String,
      couponCode: json['coupon'][0]['CouponCode'] as String,
      periodStart: json['coupon'][0]['PeriodStart'] as String,
      periodEnd: json['coupon'][0]['PeriodEnd'] as String,
      useFor: json['coupon'][0]['UseFor'] as String,
      url: json['coupon'][0]['URL'] == null ? '' : json['coupon'][0]['URL'] as String,
      state: json['state'] == null ? 0 : json['state'] as int,
      color: _color,
      type: json['coupon'][0]['createdAt'] ??= COUPON_TYPE_NORMAL,
      createdAt: json['coupon'][0]['createdAt'] as String,
      updatedAt: json['coupon'][0]['updatedAt'] as String,
    );
  }
}
