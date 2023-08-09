
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/ListForProfileModify.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';

class SelectArea extends StatefulWidget {
  SelectArea({Key? key}) : super(key: key);

  @override
  _SelectAreaState createState() => _SelectAreaState();
}

class _SelectAreaState extends State<SelectArea> {
  TextEditingController editingController = TextEditingController();
  List<String> items = [];
  List<String> allLocation = [];
  final List<List<String>> listAllLocation = [
    AreaSeoulCategory,
    AreaInCheonCategory,
    AreaGyongGiCategory,
    AreaKangWonCategory,
    AreaChungSouthCategory,
    AreaChungNorthCategory,
    AreaSejongCategory,
    AreaDaejeonCategory,
    AreaGyeongsangNorthCategory,
    AreaGyeongsangSouthCategory,
    AreaDaeguCategory,
    AreaBusanCategory,
    AreaJeonNorthCategory,
    AreaJeonSouthCategory,
    AreaGwangjuCategory,
    AreaUlsanCategory,
    AreaJejuCategory,
    AreaAbroad,
  ];

  bool isLocal = false;
  bool isSearch = false;

  String location = '';
  String subLocation = '';

  @override
  void initState() {
    super.initState();
    items.addAll(AreaCategory);
    for (int i = 0; i < AreaCategory.length; i++) {
      for(int j = 0; j < listAllLocation[i].length; j++){
        String tmpLocation = AreaCategory[i] + ' ' + listAllLocation[i][j];
        allLocation.add(tmpLocation);
      }
    }
  }

  void filterSearchResults(String query) {
    List<String> dummySearchList = [];
    dummySearchList.addAll(allLocation);

    if (query.isNotEmpty) {
      isSearch = true;
      List<String> dummyListData = [];
      dummySearchList.forEach((item) {
        if (item.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        isLocal = true;
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      isSearch = false;
      setState(() {
        isLocal = false;
        items.clear();
        items.addAll(AreaCategory);
      });
    }
  }

  void backFunc(){
    editingController.clear();
    if(isLocal){
      setState(() {
        isLocal = false;
        location = '';
        subLocation = '';
        items.clear();
        items.addAll(AreaCategory);
      });
    }else{
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: GestureDetector(
        onTap: () {
          unFocus(context);
        },
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: SheepsAppBar(context, '지역 선택', backFunc: ()=>backFunc()),
            body: WillPopScope(
              onWillPop: () {
                backFunc();
                return Future.value(false);
              },
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12 * sizeUnit),
                    child: Container(
                      height: 32 * sizeUnit,
                      child: TextField(
                        textAlign: TextAlign.left,
                        controller: editingController,
                        decoration: InputDecoration(
                          hintText: '지역 검색하기',
                          hintStyle: SheepsTextStyle.b4(),
                          prefixIcon: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8 * sizeUnit),
                            child: SvgPicture.asset(
                              svgGreyMagnifyingGlass,
                              width: 16 * sizeUnit,
                              height: 16 * sizeUnit,
                            ),
                          ),
                          fillColor: sheepsColorLightGrey,
                          filled: true,
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 2 * sizeUnit),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8 * sizeUnit)),
                            borderSide: BorderSide(width: 1, color: sheepsColorGreen),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8 * sizeUnit)),
                            borderSide: BorderSide(width: 1, color: sheepsColorLightGrey),
                          ),
                        ),
                        onChanged: (value) {
                          filterSearchResults(value);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                      child: ListView.separated(
                        separatorBuilder: (BuildContext context, int index) => Container(
                          height: 1 * sizeUnit,
                          color: sheepsColorGrey,
                        ),
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              if (!isLocal) {
                                setState(() {
                                  location = items[index];
                                  items.clear();
                                  items.addAll(listAllLocation[index]);
                                  isLocal = true;
                                });
                              } else {
                                if(!isSearch){
                                  subLocation = items[index];
                                } else {
                                  int tmp = items[index].indexOf(' ');
                                  location = items[index].substring(0,tmp);
                                  subLocation = items[index].substring(tmp+1);
                                }

                                Get.back(
                                  result: [
                                    location,
                                    subLocation,
                                  ],
                                );
                              }
                            },
                            child: Container(
                              height: 48 * sizeUnit,
                              color: Colors.white,
                              child: Row(
                                children: [
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '${items[index]}',
                                        style: SheepsTextStyle.b1(),
                                      )),
                                  Expanded(child: SizedBox()),
                                  SvgPicture.asset(
                                    svgGreyNextIcon,
                                    width: 16 * sizeUnit,
                                    height: 16 * sizeUnit,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
