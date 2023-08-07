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

class SelectField extends StatefulWidget {
  SelectField({Key key}) : super(key: key);

  @override
  _SelectFieldState createState() => _SelectFieldState();
}

class _SelectFieldState extends State<SelectField> {
  TextEditingController editingController = TextEditingController();

  var items = [];
  List<String> allCategory = [];
  final List<List<String>> listAllCategory = [
    FieldDevelopCategory,
    FieldGameCategory,
    FieldBusinessCategory,
    FieldServiceCategory,
    FieldFianceCategory,
    FieldDesignCategory,
    FieldAdsCategory,
    FieldTradeCategory,
    FieldMediaCategory,
    FieldLawCategory,
    FieldSellCategory,
    FieldEduCategory,
    FieldGovernmentCategory,
    FieldFoundaryCategory,
  ];

  bool isPart = false;

  @override
  void initState() {
    super.initState();
    items.addAll(FieldCategory);
    for (int i = 0; i < listAllCategory.length; i++) {
      allCategory.addAll(listAllCategory[i]);
    }
  }

  void filterSearchResults(String query) {
    List<String> dummySearchList = [];
    dummySearchList.addAll(allCategory);

    if (query.isNotEmpty) {
      List<String> dummyListData = [];
      dummySearchList.forEach((item) {
        if (item.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        isPart = true;
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        isPart = false;
        items.clear();
        items.addAll(FieldCategory);
      });
    }
  }

  void backFunc(){
    editingController.clear();
    if(isPart){
      setState(() {
        isPart = false;
        items.clear();
        items.addAll(FieldCategory);
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
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: WillPopScope(
                onWillPop: () {
                  backFunc();
                  return Future.value(false);
                },
                child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: SheepsAppBar(context, '분야 선택', backFunc: ()=>backFunc()),
                  body: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(12 * sizeUnit),
                        child: Container(
                          height: 32 * sizeUnit,
                          child: TextField(
                            textAlign: TextAlign.left,
                            controller: editingController,
                            decoration: InputDecoration(
                              hintText: '분야 검색하기',
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
                                  if (!isPart) {
                                    setState(() {
                                      items.clear();
                                      items.addAll(listAllCategory[index]);
                                      isPart = true;
                                    });
                                  } else {
                                    for (int i = 0; i < listAllCategory.length; i++) {
                                      for (int j = 0; j < listAllCategory[i].length; j++) {
                                        if (items[index] == listAllCategory[i][j]) {
                                          Get.back(
                                            result: [
                                              FieldCategory[i],
                                              listAllCategory[i][j],
                                            ],
                                          );
                                        }
                                      }
                                    }
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
                      SizedBox(height: 16 * sizeUnit),
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
