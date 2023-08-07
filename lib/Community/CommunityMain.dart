import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sheeps_app/Community/CommunityCategorySettingPage.dart';

import 'package:sheeps_app/Community/CommunityMainDetail.dart';
import 'package:sheeps_app/Community/CommunityWritePage.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/Community/models/CommunityController.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/LoadingUI.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/dashboard/MyPage.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';

class CommunityMain extends StatefulWidget {
  @override
  _CommunityMainState createState() => _CommunityMainState();
}

class _CommunityMainState extends State<CommunityMain> {
  final CommunityController controller = Get.put(CommunityController());
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  final TextEditingController textEditingController = TextEditingController();
  final String svgWriteIcon = 'assets/images/Community/GreenPencilWriteIcon.svg';
  final String svgCategorySettingIcon = 'assets/images/Community/categorySettingIcon.svg';

  bool canCallOffset = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (canCallOffset) {
          canCallOffset = false;

          if (controller.isSearch) {
            controller.searchEvent(context, textEditingController.text, isOffset: true).then((value) => setState(() {}));
          } else {
            if (controller.selectedCategory.value == '전체') {
              controller.basicMaxScrollEvent().then((value) => setState(() {}));
            } else if (controller.selectedCategory.value == '인기') {
              controller.popularMaxScrollEvent().then((value) => setState(() {}));
            } else {
              controller.categoryMaxScrollEvent().then((value) => setState(() {}));
            }
          }
        }

        // offset 중복 호출 방지
        Future.delayed(Duration(milliseconds: 300), () {
          canCallOffset = true;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    textEditingController.text = controller.savedSearchWord;
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    focusNode.dispose();
    textEditingController.dispose();
    if (controller.filterActive == true) controller.filterActive = false;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: null,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), // 사용자 스케일팩터 무시
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => unFocus(context), // 텍스트 포커스 해제
                child: Scaffold(
                  backgroundColor: Colors.white,
                  body: Column(
                    children: [
                      Obx(() => controller.navScrollEvent(scrollController)), // 하단 네비게이션 스크롤 이벤트
                      topBar(),
                      categoryBar(),
                      Expanded(
                        child: communityPostListView(),
                      ),
                    ],
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () => Get.to(() => CommunityWritePage(selectedCategory: controller.selectedCategory.value))?.then((value) => setState(() {})),
                    backgroundColor: sheepsColorGreen,
                    child: SvgPicture.asset(svgWriteIcon, color: Colors.white, width: 30 * sizeUnit, height: 30 * sizeUnit),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget communityPostListView() {
    List<Community> communityList = [];
    int addedPost = 0; // 몇 개 들어갔나 체크용

    // 검색 시
    if (controller.isSearch) {
      if (controller.selectedCategory.value == '전체')
        communityList = GlobalProfile.searchedCommunityList.where((element) => element.category != '공지').toList();
      else if (controller.selectedCategory.value == '인기')
        communityList = GlobalProfile.searchedCommunityList.where((element) => element.type == COMMUNITY_POPULAR_TYPE).toList();
      else // 카테고리일 때
        communityList = GlobalProfile.searchedCommunityList.where((element) => element.category == controller.selectedCategory.value).toList();
    } else {
      if (controller.selectedCategory.value == '전체') {
        // 공지글 추가
        if (GlobalProfile.noticeCommunityList.isNotEmpty) {
          communityList.addAll(GlobalProfile.noticeCommunityList);
          addedPost += GlobalProfile.noticeCommunityList.length;
        }

        addedPost += controller.addHotList(hotCommunityList: GlobalProfile.hotCommunityList, communityList: communityList); // 핫 리스트 추가해주기
        communityList.addAll(GlobalProfile.globalCommunityList);
      } else if (controller.selectedCategory.value == '인기')
        communityList = GlobalProfile.popularCommunityList;
      else {
        addedPost += controller.addedPostForCategory;
        communityList = GlobalProfile.filteredCommunityList; // 카테고리일 때
      }
    }

    // 전체 OR 인기 게시글
    return Obx(
      () => sheepsCustomRefreshIndicator(
        onRefresh: () => controller.refreshEvent(searchWord: textEditingController.text).then((value) => setState(() {})),
        child: controller.isLoading.value
            ? Center(child: CircularProgressIndicator(color: sheepsColorGreen))
            : communityList.length == 0
                ? noSearchResultsPage(null)
                : ListView.builder(
                    controller: scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: communityList.length,
                    itemBuilder: (context, index) {
                      Community community = communityList[index];
                      bool lastAddedPost = index == addedPost - 1;

                      // 디테일 커뮤니티 페이지 이동 함수
                      Future<void> goToDetail() async {
                        DialogBuilder(context).showLoadingIndicator();
                        var tmp = await controller.getReply(context, community);
                        DialogBuilder(context).hideOpenDialog();

                        if (tmp != null) Get.to(() => CommunityMainDetail(community))?.then((value) => setState(() {}));
                      }

                      if (community.category == '공지') return communityNoticePostCard(community: community, lastAddedPost: lastAddedPost, press: goToDetail);

                      return communityPostCard(
                        community: community,
                        lastAddedPost: lastAddedPost,
                        likeCheckFunc: controller.likeCheckFunc(community),
                        typeCheck: controller.typeCheck(community),
                        press: goToDetail,
                      );
                    },
                  ),
      ),
    );
  }

  Widget communityNoticePostCard({required Community community, required bool lastAddedPost, required Function press}) {
    return GestureDetector(
      onTap: () => press,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (GlobalProfile.noticeCommunityList.length >= 2 && community.id == GlobalProfile.noticeCommunityList[0].id) ...[
            Positioned(
              right: 10 * sizeUnit,
              child: Container(
                height: (38 * sizeUnit) * 2,
                child: SvgPicture.asset(
                  svgSheepsBasicProfileImage,
                  height: 100 * sizeUnit,
                  fit: BoxFit.cover,
                ),
              ),
            )
          ],
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
            decoration: BoxDecoration(
              color: sheepsColorGreen.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(color: sheepsColorLightGrey, width: lastAddedPost ? 4 * sizeUnit : 1 * sizeUnit),
              ),
            ),
            child: Row(
              children: [
                profileSmallWrapItem('공지', color: sheepsColorGreen),
                SizedBox(width: 8 * sizeUnit),
                Container(
                  constraints: BoxConstraints(maxWidth: 230 * sizeUnit),
                  child: Text(
                    community.title,
                    style: SheepsTextStyle.h4(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Spacer(),
                Container(
                  height: 38 * sizeUnit,
                  child: SvgPicture.asset(
                    svgSheepsBasicProfileImage,
                    width: 60 * sizeUnit,
                    fit: BoxFit.cover,
                    color: GlobalProfile.noticeCommunityList.length <= 1 ? sheepsColorGreen : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container categoryBar() {
    return Container(
      height: 48 * sizeUnit,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: sheepsColorLightGrey)),
      ),
      child: ListView.builder(
        itemCount: communityCategoryList.length + 2,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          double padding = 12;
          if (index == 0) padding = 16;
          if (index == communityCategoryList.length) return categorySettingItem();
          if (index == communityCategoryList.length + 1) return SizedBox(width: 16 * sizeUnit);
          return categoryItem(communityCategoryList[index], padding, index == 1);
        },
      ),
    );
  }

  Widget categoryItem(String category, double padding, bool isPopular) {
    return GestureDetector(
      onTap: () async {
        controller.changeCategory(category);
        if (controller.selectedCategory.value != '전체' && controller.selectedCategory.value != '인기') {
          await controller.getCommunityCategoryList();
        } else {
          GlobalProfile.filteredCommunityList.clear();
        }

        // 위젯 변경 후 스크롤 상단으로 이동
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients && scrollController.position.pixels != 0) {
            scrollController.jumpTo(0.1);
          }
        });

        setState(() {});
      },
      child: Obx(() => Center(
            child: Container(
              height: 32 * sizeUnit,
              margin: EdgeInsets.only(left: padding * sizeUnit),
              padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16 * sizeUnit),
                border: Border.all(
                  color: category == controller.selectedCategory.value
                      ? sheepsColorGreen
                      : isPopular
                          ? sheepsColorBlue
                          : sheepsColorDarkGrey,
                ),
                color: category == controller.selectedCategory.value ? sheepsColorGreen : Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category,
                    style: SheepsTextStyle.bProfile().copyWith(
                        color: category == controller.selectedCategory.value
                            ? Colors.white
                            : isPopular
                                ? sheepsColorBlue
                                : sheepsColorDarkGrey),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Widget categorySettingItem() {
    return GestureDetector(
      onTap: () {
        List<String> prevList = [...communityCategoryList];

        Get.to(() => CommunityCategorySettingPage())?.then((value) {
          // 카테고리 순서가 바뀌었는지 확인 (i가 2인 이유는 전체, 인기 때문)
          for (int i = 2; i < prevList.length; i++) {
            if (prevList[i] != communityCategoryList[i]) {
              showSheepsToast(context: context, text: '적용되었습니다.');
              setState(() {});
              break;
            }
          }
        });
      },
      child: Center(
        child: Container(
          height: 32 * sizeUnit,
          margin: EdgeInsets.only(left: 12 * sizeUnit),
          padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16 * sizeUnit),
            border: Border.all(color: sheepsColorDarkGrey),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(svgCategorySettingIcon),
            ],
          ),
        ),
      ),
    );
  }

  Widget topBar() {
    return Obx(() => Container(
          width: double.infinity,
          height: 44 * sizeUnit,
          child: Row(
            children: [
              SizedBox(width: 16 * sizeUnit),
              // 검색 창 뜰때
              if (controller.activeSearchBar.value) ...[
                Expanded(
                  child: Container(
                    height: 28 * sizeUnit,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: sheepsColorLightGrey,
                      borderRadius: BorderRadius.circular(16 * sizeUnit),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8 * sizeUnit),
                          child: SvgPicture.asset(
                            svgGreyMagnifyingGlass,
                            width: 16 * sizeUnit,
                            height: 16 * sizeUnit,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              hintText: '커뮤니티 검색',
                              border: InputBorder.none,
                              hintStyle: SheepsTextStyle.info1(),
                              isDense: true,
                              contentPadding: EdgeInsets.only(left: 8 * sizeUnit),
                            ),
                            style: SheepsTextStyle.b3(),
                            onSubmitted: (value) async {
                              await controller.searchEvent(context, value);
                              setState(() {});
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8 * sizeUnit),
                          child: IconButton(
                            onPressed: () {
                              textEditingController.clear();
                              controller.isSearch = false;
                              controller.activeSearchBar.value = false;
                              GlobalProfile.searchedCommunityList.clear();

                              // 위젯 변경 후 스크롤 상단으로 이동
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (scrollController.hasClients && scrollController.position.pixels != 0) {
                                  scrollController.jumpTo(0.1);
                                }
                              });

                              setState(() {});
                            },
                            constraints: BoxConstraints(maxWidth: 16 * sizeUnit, maxHeight: 16 * sizeUnit),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            iconSize: 16 * sizeUnit,
                            color: sheepsColorDarkGrey,
                            icon: Icon(Icons.clear),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ] else ...[
                Text(
                  '커뮤니티',
                  style: SheepsTextStyle.h2(),
                ),
                Spacer(),
                InkWell(
                  onTap: () {
                    controller.activeSearchBar.value = true;
                    focusNode.requestFocus();
                  },
                  child: SvgPicture.asset(
                    svgGreyMagnifyingGlass,
                    color: sheepsColorDarkGrey,
                    width: 28 * sizeUnit,
                    height: 28 * sizeUnit,
                  ),
                ),
              ],
              SizedBox(
                width: 12 * sizeUnit,
              ),
              GestureDetector(
                onTap: () => Get.to(() => MyPage())?.then((value) => setState(() {})),
                child: SvgPicture.asset(
                  svgGreyMyPageButton,
                  width: 28 * sizeUnit,
                  height: 28 * sizeUnit,
                ),
              ),
              SizedBox(
                width: 12 * sizeUnit,
              ),
            ],
          ),
        ));
  }
}
