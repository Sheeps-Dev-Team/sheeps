
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:get/get.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/ListForProfileModify.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';

class SelectTeamField extends StatefulWidget {
  SelectTeamField({Key? key}) : super(key: key);

  @override
  _SelectTeamFieldState createState() => _SelectTeamFieldState();
}

class _SelectTeamFieldState extends State<SelectTeamField> {

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
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: SheepsAppBar(context, '분야 선택'),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12*sizeUnit),
              child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) => Container(height: 1*sizeUnit,color: sheepsColorGrey),
                itemCount: serviceFieldList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: (){
                      Get.back(result: [serviceFieldList[index]]);
                    },
                    child: Container(
                      height: 48*sizeUnit,
                      color: Colors.white,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          serviceFieldList[index],
                          style: SheepsTextStyle.b1(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

