
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:package_info_plus/package_info_plus.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';

class AppVersionPage extends StatefulWidget {
  PackageInfo packageInfo;

  AppVersionPage({Key? key, required this.packageInfo}) : super(key: key);

  @override
  _AppVersionPageState createState() => _AppVersionPageState();
}

class _AppVersionPageState extends State<AppVersionPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: null,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          //사용자 스케일팩터 무시
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Scaffold(
                appBar: SheepsAppBar(context, '앱 버전'),
                body: Container(
                  color: Color(0xFFF8F8F8),
                  child: Column(
                    children: [
                      SheepsSimpleListItemBox(
                        context,
                        Row(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '앱 이름',
                                style: SheepsTextStyle.b1(),
                              ),
                            ),
                            Expanded(child: SizedBox()),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.packageInfo.appName,
                                style: SheepsTextStyle.b2(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 1 * sizeUnit),
                      SheepsSimpleListItemBox(
                        context,
                        Row(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '패키지 이름',
                                style: SheepsTextStyle.b1(),
                              ),
                            ),
                            Expanded(child: SizedBox()),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.packageInfo.packageName,
                                style: SheepsTextStyle.b2(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 1 * sizeUnit),
                      SheepsSimpleListItemBox(
                        context,
                        Row(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '버전 정보',
                                style: SheepsTextStyle.b1(),
                              ),
                            ),
                            Expanded(child: SizedBox()),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.packageInfo.version,
                                style: SheepsTextStyle.b2(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 1 * sizeUnit),
                      SheepsSimpleListItemBox(
                        context,
                        Row(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '빌드 넘버',
                                style: SheepsTextStyle.b1(),
                              ),
                            ),
                            Expanded(child: SizedBox()),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.packageInfo.buildNumber,
                                style: SheepsTextStyle.b2(),
                              ),
                            ),
                          ],
                        ),
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
}
