import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:flutter_svg/flutter_svg.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';

class BusinessInfoPage extends StatelessWidget {
  TextStyle tsHead;
  TextStyle tsBody;

  @override
  Widget build(BuildContext context) {
    tsHead = SheepsTextStyle.h4();
    tsBody = SheepsTextStyle.b4();

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
                backgroundColor: Colors.white,
                appBar: SheepsAppBar(context, '사업자 정보'),
                body: Padding(
                  padding: EdgeInsets.fromLTRB(20 * sizeUnit, 0, 20 * sizeUnit, 0),
                  child: Column(
                    children: [
                      Row(children: [SizedBox(height: 40 * sizeUnit)]),
                      SvgPicture.asset(svgSheepsGreenImageLogo, width: 100 * sizeUnit, height: 100 * sizeUnit),
                      SizedBox(
                        height: 12 * sizeUnit,
                      ),
                      SvgPicture.asset(svgSheepsGreenWriteLogo, width: 150 * sizeUnit, height: 28 * sizeUnit),
                      SizedBox(height: 40 * sizeUnit),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          infoItem('법인명','주식회사 쉽스'),
                          infoItem('대표자','진성규'),
                          infoItem('등록번호','184-86-01811'),
                          infoItem('개업연월일','2020년 7월 31일'),
                          infoItem('사업의 종류','서비스업, 창업 지원 서비스'),
                          infoItem('본점 소재지','인천광역시 연수구 송도과학로 32,\n                         IT센터 S동 2703호'),
                          infoItem('고객센터','010-6415-1468'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget infoItem(String header, String contents){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2*sizeUnit),
      child: Text.rich(TextSpan(
        text: header + ' : ',
        style: SheepsTextStyle.h4(),
        children: [
          TextSpan(
            text: contents,
            style: SheepsTextStyle.b3(),
          )
        ],
      )),
    );
  }
}
