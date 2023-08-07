import '';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/constants.dart';

class CommunityCategorySettingPage extends StatefulWidget {
  @override
  _CommunityCategorySettingPageState createState() => _CommunityCategorySettingPageState();
}

class _CommunityCategorySettingPageState extends State<CommunityCategorySettingPage> {
  List<DragAndDropList> _list = [];

  _onItemReorder(int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      var movedItem = _list[oldListIndex].children.removeAt(oldItemIndex);
      _list[newListIndex].children.insert(newItemIndex, movedItem);

      communityCategoryList.clear();
      communityCategoryList.addAll(['전체', '인기']);

      _list[newListIndex].children.forEach((element) {
        Key? value = element.child.key;

        communityCategoryList.add((value as ValueKey).value);
      });

      prefs.setStringList('communityCategoryList', communityCategoryList);
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = _list.removeAt(oldListIndex);
      _list.insert(newListIndex, movedList);
    });
  }

  Future<void> _initializationFunc() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _list = setList(basicCommunityCategoryList);
      communityCategoryList = [...basicCommunityCategoryList];
      prefs.setStringList('communityCategoryList', basicCommunityCategoryList);
    });
  }

  List<DragAndDropList> setList(List<String> communityCategoryList){
    return List.generate(1, (index) {
      return DragAndDropList(
          footer: _buildInfoText(),
          children: List.generate(communityCategoryList.length - 2, (index) {
            String category = communityCategoryList[index + 2];
            Key key = Key(category);

            return DragAndDropItem(
              child: Container(
                key: key,
                child: Row(
                  children: [
                    SizedBox(width: 16 * sizeUnit),
                    Container(
                      width: Get.width - 16 * sizeUnit,
                      height: 48 * sizeUnit,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: sheepsColorLightGrey))),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(category, style: SheepsTextStyle.button2()),
                          ),
                          Icon(Icons.menu, color: sheepsColorGrey),
                          SizedBox(width: 16 * sizeUnit),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }));
    });
  }

  @override
  void initState() {
    super.initState();

    _list = setList(communityCategoryList);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: null,
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: SheepsAppBar(
                context,
                '카테고리 순서 변경',
                actions: [
                  _initializationButton(),
                ],
              ),
              body: DragAndDropLists(
                onItemReorder: _onItemReorder,
                onListReorder: _onListReorder,
                lastItemTargetHeight: 16 * sizeUnit,
                lastListTargetSize: 0,
                children: _list,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText() {
    return Row(
      children: [
        SizedBox(width: 16 * sizeUnit),
        SvgPicture.asset(
          svgIInCircleOutline,
          width: 14 * sizeUnit,
          height: 14 * sizeUnit,
          color: sheepsColorGrey,
        ),
        SizedBox(width: 4 * sizeUnit),
        Text(
          '오른쪽 버튼을 누르고 있으면, 순서 변경이 가능해요!',
          style: SheepsTextStyle.b3().copyWith(color: sheepsColorGrey),
        ),
      ],
    );
  }

  Widget _initializationButton() {
    return IconButton(
      onPressed: _initializationFunc,
      icon: SvgPicture.asset(svgFilterDeselect, width: 18 * sizeUnit),
    );
  }
}
