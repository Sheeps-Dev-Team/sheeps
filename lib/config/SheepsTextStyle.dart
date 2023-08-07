import 'package:flutter/material.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';

class SheepsTextStyle {
  static TextStyle sizeUnitStandard(BuildContext context) {
    return TextStyle(
      fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
    );
  }

  static TextStyle h1() {
    return TextStyle(
      color: sheepsColorBlack,
      fontSize: 28 * sizeUnit,
      fontWeight: FontWeight.bold,
      height: 1.2,
    );
  }

  static TextStyle h2() {
    return TextStyle(
      color: sheepsColorBlack,
      fontSize: 20 * sizeUnit,
      fontWeight: FontWeight.bold,
      height: 1.2,
    );
  }

  static TextStyle h3() {
    return TextStyle(
      color: sheepsColorBlack,
      fontSize: 16*sizeUnit,
      fontWeight: FontWeight.bold,
      height: 1.2,
    );
  }

  static TextStyle h4() {
    return TextStyle(
      color: sheepsColorBlack,
      fontSize: 12 * sizeUnit,
      fontWeight: FontWeight.bold,
      height: 1.2,
    );
  }

  static TextStyle h5() {
    return TextStyle(
      color: sheepsColorBlack,
      fontSize: 24 * sizeUnit,
      fontWeight: FontWeight.bold,
      height: 1.2,
    );
  }

  static TextStyle hProfile() {
    return TextStyle(
      color: Color(0xFFFFFFFF), 
      fontSize: 16 * sizeUnit,
      fontWeight: FontWeight.bold,
      height: 1.2,
    );
  }

  static TextStyle b0() {
    return TextStyle(
      color: sheepsColorGrey,
      fontSize: 20 * sizeUnit,
      fontWeight: FontWeight.normal,
      height: 1.4,
    );
  }

  static TextStyle b1() {
    return TextStyle(
      color: sheepsColorBlack,
      fontSize: 16 * sizeUnit,
      fontWeight: FontWeight.normal,
    );
  }

  static TextStyle b2() {
    return TextStyle(
      color: sheepsColorDarkGrey,
      fontSize: 16 * sizeUnit,
      fontWeight: FontWeight.normal,
      height: 1.5,
    );
  }

  static TextStyle b3() {
    return TextStyle(
      color: sheepsColorBlack,
      fontSize: 12 * sizeUnit,
      fontWeight: FontWeight.normal,
    );
  }

  static TextStyle b4() {
    return TextStyle(
      color: sheepsColorDarkGrey,
      fontSize: 12 * sizeUnit,
      fontWeight: FontWeight.normal,
    );
  }

  static TextStyle bProfile() {
    return TextStyle(
      color: Colors.white,
      fontSize: 12 * sizeUnit,
      height: 1.2,
    );
  }

  static TextStyle bWriter() {
    return TextStyle(
      color: sheepsColorBlack,
      fontSize: 10 * sizeUnit,
    );
  }

  static TextStyle bWriteDate() {
    return TextStyle(
      color: Color(0xFFBEBEBE),
      fontSize: 10 * sizeUnit,
    );
  }

  static TextStyle appBar() {
    return TextStyle(
      color: sheepsColorBlack,
      fontSize: 16 * sizeUnit,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle hint() {
    return TextStyle(
      color: sheepsColorGrey,
      fontSize: 16 * sizeUnit,
      height: 1.2,
    );
  }

  static TextStyle hint4Profile() {
    return TextStyle(
      color: sheepsColorGrey,
      fontSize: 12 * sizeUnit,
      height: 1.2,
    );
  }

  static TextStyle error() {
    return TextStyle(
      color: sheepsColorRed,
      fontSize: 12 * sizeUnit,
      height: 1.2
    );
  }

  static TextStyle textField() {
    return TextStyle(
      color: sheepsColorBlack,
      fontSize: 16 * sizeUnit,
      height: 1.2,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle textFieldLabel() {
    return TextStyle(
      color: sheepsColorDarkGrey,
      fontSize: 16 * sizeUnit,
      height: 0.7,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle button1() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16 * sizeUnit,
      color: Color(0xFFFFFFFF),
      height: 1.2,
    );
  }

  static TextStyle button2() {
    return TextStyle(
      color: sheepsColorBlack,
      fontSize: 16 * sizeUnit,
    );
  }

  static TextStyle info1() {
    return TextStyle(
      color: sheepsColorDarkGrey,
      fontSize: 12 * sizeUnit,
    );
  }

  static TextStyle info2() {
    return TextStyle(
      color: sheepsColorDarkGrey,
      fontSize: 10 * sizeUnit,
      fontWeight: FontWeight.normal,
    );
  }

  static TextStyle infoStrong() {
    return TextStyle(
      color: sheepsColorGreen,
      fontSize: 12 * sizeUnit,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle s1() {
    return TextStyle(
      color: sheepsColorGreen,
      fontSize: 12 * sizeUnit,
    );
  }

  static TextStyle s2() {
    return TextStyle(
      color: sheepsColorGreen,
      fontSize: 10 * sizeUnit,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle s3() {
    return TextStyle(
      color: sheepsColorDarkGrey,
      fontSize: 10 * sizeUnit,
    );
  }

  static TextStyle cat1() {
    return TextStyle(
      color: sheepsColorBlack,
      fontSize: 10 * sizeUnit,
      height: 1.4,
    );
  }

  static TextStyle cat2() {
    return TextStyle(
      color: sheepsColorBlack,
      fontSize: 12 * sizeUnit,
      height: 1.4,
    );
  }

  static TextStyle dialogTitle() {
    return TextStyle(
      color: sheepsColorBlack,
      fontSize: 24 * sizeUnit,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle dialogContent() {
    return TextStyle(
      color: sheepsColorBlack,
      fontSize: 12 * sizeUnit,
    );
  }

  static TextStyle navigationBarTitle() {
    return TextStyle(
      color: sheepsColorBlack,
      fontSize: 10 * sizeUnit,
      height: 1.3,
    );
  }

  static TextStyle splashCopyright(){
    return TextStyle(
      color: sheepsColorGreen,
      fontSize: 10 * sizeUnit,
      height: 12/10,
    );
  }

  static TextStyle boardContents(){
    return TextStyle(
      color: sheepsColorBlack,
      fontSize: 16 * sizeUnit,
      height: 1.75,
    );
  }

  static TextStyle badgeTitle() {
    return TextStyle(
      color: sheepsColorBlack,
      fontSize: 14 * sizeUnit,
      fontWeight: FontWeight.normal,
      height: 1.2,
    );
  }

  static TextStyle toast(){
    return TextStyle(
      color: Colors.white,
      fontSize: 14 * sizeUnit,
      fontWeight: FontWeight.normal,
      height: 1.2,
    );
  }

  static TextStyle couponLabel(){
    return TextStyle(
      color: Colors.white,
      fontSize: 16 * sizeUnit,
      fontWeight: FontWeight.bold,
      height: 1.2,
    );
  }

  static TextStyle couponCode(){
    return TextStyle(
      color: sheepsColorGreen,
      fontSize: 18 * sizeUnit,
      fontWeight: FontWeight.bold,
      height: 1.2,
    );
  }

  static TextStyle couponPeriod(){
    return TextStyle(
      color: sheepsColorDarkGrey,
      fontSize: 8 * sizeUnit,
      fontWeight: FontWeight.normal,
      height: 1.2,
    );
  }

}
