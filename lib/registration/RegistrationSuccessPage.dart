
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/registration/IdentityVerificationPage.dart';

class RegistrationSuccessPage extends StatefulWidget {
  final int state; //1 성공 2 실패
  RegistrationSuccessPage({Key? key, required this.state}) : super(key: key);

  @override
  _RegistrationSuccessPageState createState() => _RegistrationSuccessPageState();
}

class _RegistrationSuccessPageState extends State<RegistrationSuccessPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: (){
          return Future.value(false);
        },
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
          child: Scaffold(
            body: Container(
              color: Colors.white,
              child: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            widget.state == 1 ? svgSheepsCuteImageLogo : svgSheepsXeyeImageLogo,
                            color: widget.state == 1 ? sheepsColorGreen : sheepsColorRed,
                            width: 145 * sizeUnit,
                            height: 105 * sizeUnit,
                          ),
                          Row(
                            children: [
                              SizedBox(height: 20 * sizeUnit)
                            ]
                          ),
                          Text(
                            widget.state == 1 ? '회원가입 완료!' : '회원가입 실패!',
                            style: TextStyle(fontSize: 20 * sizeUnit, color: sheepsColorDarkGrey, height: 1.4),
                          ),
                          SizedBox(height: 20 * sizeUnit),
                          Text(
                            widget.state == 1 ? '본인인증으로\n모든 서비스를\n이용해보세요.' : '한번만 다시\n시도해 주세요.',
                            style: SheepsTextStyle.h5(),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20*sizeUnit),
                      child: SheepsBottomButton(
                        context: context,
                        function: () {
                          if (widget.state == 1) {
                            Get.off(() => IdentityVerificationPage(identityStatus: IdentityStatus.SignUP));//1 가입
                          } else {
                            Get.back();
                          }
                        },
                        text: widget.state == 1 ? '본인인증 진행' : '다시 가입하기',
                      ),
                    ),
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
