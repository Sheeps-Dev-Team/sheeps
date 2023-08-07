import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:sheeps_app/Community/CommunityMainDetail.dart';
import 'package:sheeps_app/Community/CommunityWritePage.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/Community/models/CommunityController.dart';
import 'package:sheeps_app/Community/models/CommunityDetailController.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';

class PostedPage extends StatefulWidget {
  final List<Community> a_communityList;
  final String a_title;

  const PostedPage({super.key, required this.a_communityList, required this.a_title});

  // PostedPage(List<Community> community, String title) {
  //   _communityList = community;
  //   _title = title;
  // }
  @override
  _PostedPageState createState() => _PostedPageState();
}

class _PostedPageState extends State<PostedPage> with SingleTickerProviderStateMixin  {
  final CommunityController controller = Get.put(CommunityController());
  final String svgWriteIcon = 'assets/images/Community/GreenPencilWriteIcon.svg';

  ScrollController _scrollController = ScrollController();
  late AnimationController extendedController;
  List<bool> visibleList = [];
  bool isCanTapLike = true;
  int tapLikeDelayMilliseconds = 500;
  List<Community> communityList = [];

  @override
  void initState() {
    super.initState();
    communityList = widget.a_communityList;

    extendedController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
        lowerBound: 0.0,
        upperBound: 1.0);

    Get.lazyPut<CommunityDetailController>(() => CommunityDetailController());
  }

  @override
  Widget build(BuildContext context) {
    var tmp = false;
    for (int i = 0; i < communityList.length; i++) {
      visibleList.add(tmp);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: null,
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: SheepsAppBar(context,widget.a_title),
              body: communityList.length > 0
                ? ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: communityList.length,
                    itemBuilder: (BuildContext context, int index) {
                        Community community = communityList[index];

                      return communityPostCard(
                          community: community,
                          likeCheckFunc: insertCheckFor(index),
                          typeCheck: {
                            'category': community.category,
                            'color': sheepsColorLightGrey,
                          },
                          press: () async {
                            var tmp = await controller.getReply(context, community);
                            if (tmp != null) Get.to(() => CommunityMainDetail(community));
                          }
                      );
                  })
                  : noSearchResultsPage(
                  widget.a_title == '내가 쓴 글' ? '아직 쓴 글이 없어요!\n글쓰기 버튼을 눌러\n첫 게시글을 써보시겠어요?' :
                      widget.a_title == '댓글 단 글' ? '아직 댓글 단 글이 없어요!\n의견을 나누고 싶은 글이 있다면,\n댓글을 달아보세요.💬' :
                          widget.a_title == '좋아요 한 글' ? '아직 좋아요 한 글이 없어요!\n글이 마음에 든다면, 좋아요를 눌러주세요.👍' : null
              ),
              floatingActionButton:
              widget.a_title == '내가 쓴 글' ?
              FloatingActionButton(
                onPressed: () => Get.to(() => CommunityWritePage())?.then((value) => setState(() {})),
                backgroundColor: sheepsColorGreen,
                child: SvgPicture.asset(svgWriteIcon, color: Colors.white, width: 30 * sizeUnit, height: 30 * sizeUnit),
              )
              : null,
            ),
          ),
        ),
      ),
    );
  }

  bool insertCheckFor(int index) {
    bool check = false;
    for (int i = 0;
    i <  communityList[index].communityLike.length;
    i++) {
      if (communityList[index].communityLike[i].userID == GlobalProfile.loggedInUser.userID) {
        check = true;
        break;
      }
    }
    return check;
  }
}
