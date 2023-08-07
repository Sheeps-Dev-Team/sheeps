import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/Community/models/CommunityDetailController.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/NavigationNum.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';

const int hotAllowRange = 2; // 핫 게시글 허용 범위

class CommunityController extends GetxController {
  static get to => Get.find<CommunityController>();
  final NavigationNum navigationNum = Get.put(NavigationNum());

  RxBool activeSearchBar = false.obs; // 검색바 활성화 여부
  bool filterActive = false; // 필터 박스 활성화 여부
  bool isSearch = false; // 검색 적용 여부
  int popularCalls = 1; // 인기 게시글 offset 호출 횟수
  RxBool isLoading = false.obs;
  RxList filteredCommunityList = [].obs;
  int addedPostForCategory = 0; // 카테고리 추가 된 글 수

  RxString selectedCategory = '전체'.obs;

  String savedSearchWord = '';//검색단어 저장용

  // 공지, 핫 게시글 add 이벤트
  int addHotList({@required List<Community> hotCommunityList, @required List<Community> communityList}){
    int addedPost = 0;

    if(hotCommunityList.isNotEmpty) {
      int num = hotAllowRange;

      if(hotCommunityList.length < hotAllowRange){
        num = hotCommunityList.length;
      }

      for(int i = 0; i < num; i++){
        communityList.add(hotCommunityList[i]);
        addedPost++; // 추가된 핫글 수
      }
    }

    return addedPost;
  }


  // 새로고침 이벤트
  Future<void> refreshEvent({String searchWord}) async{
    if(isSearch){
      GlobalProfile.searchedCommunityList.clear();
      var res = await ApiProvider().post(
          '/CommunityPost/SearchWord',
          jsonEncode({
            "index": GlobalProfile.searchedCommunityList.length,
            "searchWord": searchWord,
          }));

      if (res != null) {
        for (int i = 0; i < res.length; i++) {
          Community community = Community.fromJson(res[i]);
          GlobalProfile.searchedCommunityList.add(community);
          await GlobalProfile.getFutureUserByUserID(community.userID);
        }
      }
    } else {
      if (selectedCategory.value == '전체') {
        GlobalProfile.globalCommunityList.clear();
        await ApiProvider().get('/CommunityPost/Select').then((value) async {
          if (value != null) {
            for (int i = 0; i < value.length; ++i) {
              if(value[i]['community']['Category'] != '공지') {
                Community community = Community.fromJson(value[i]);
                GlobalProfile.globalCommunityList.add(community);
                await GlobalProfile.getFutureUserByUserID(community.userID);
              }
            }
          }
        });

        // 핫 게시글
        GlobalProfile.hotCommunityList.clear();
        await getHotCommunityList();

        // 공지
        GlobalProfile.noticeCommunityList.clear();
        await ApiProvider().get('/CommunityPost/Select/Notice').then((value) async {
          if (value != null) {
            for (int i = 0; i < value.length; i++) {
              Community community = Community.fromJson(value[i], isNotice: true);
              GlobalProfile.noticeCommunityList.add(community);
              await GlobalProfile.getFutureUserByUserID(community.userID);
            }
          }
        });

      } else if (selectedCategory.value == '인기') {
        GlobalProfile.popularCommunityList.clear();
        await ApiProvider().get('/CommunityPost/Select/Popular').then((value) async {
          if (value != null) {
            for (int i = 0; i < value.length; i++) {
              if(value[i]['community']['Category'] != '공지') {
                Community community = Community.fromJson(value[i]);
                GlobalProfile.popularCommunityList.add(community);
                await GlobalProfile.getFutureUserByUserID(community.userID);
              }
            }
          }
        });
      } else {
        await getCommunityCategoryList(isRefresh: true);
      }
    }
  }

  Future<void> getHotCommunityList() async{
    await ApiProvider().get('/CommunityPost/Select/Hot').then((value) async {
      if (value != null) {
        for (int i = 0; i < value.length; i++) {
          if(value[i]['community']['Category'] != '공지') {
            Community community = Community.fromJson(value[i], isHot: true);
            GlobalProfile.hotCommunityList.add(community);
            await GlobalProfile.getFutureUserByUserID(community.userID);
          }
        }
      }
    });
  }

  // '전체' 스크롤 이벤트
  Future<void> basicMaxScrollEvent() async{
    var tmp = await ApiProvider().post(
        '/CommunityPost/SelectOffset',
        jsonEncode({
          "index": GlobalProfile.globalCommunityList.length,
        }));

    if (tmp != null) {
      for (int i = 0; i < tmp.length; i++) {
        if(tmp[i]['community']['Category'] != '공지') {
          bool contain = false;

          // 공지글 때문에 중복이 들어올 수 있어서 중복제거
          for(int j = 0; j < GlobalProfile.globalCommunityList.length; j++){
            if(GlobalProfile.globalCommunityList[j].id == tmp[i]['community']['id']){
              contain = true;
              break;
            }
          }

          if(!contain) {
            Community community = Community.fromJson(tmp[i]);
            GlobalProfile.globalCommunityList.add(community);
            await GlobalProfile.getFutureUserByUserID(community.userID);
          }
        }
      }
    }
  }

  // '카테고리' 스크롤 이벤트
  Future<void> categoryMaxScrollEvent() async{
    var tmp = await ApiProvider().post(
        '/CommunityPost/Select/Offset/Category',
        jsonEncode({
          "index": GlobalProfile.filteredCommunityList.length - addedPostForCategory,
          'category': selectedCategory.value,
        }));

    if (tmp != null) {
      for (int i = 0; i < tmp.length; i++) {
        Community community = Community.fromJson(tmp[i]);
        GlobalProfile.filteredCommunityList.add(community);
        await GlobalProfile.getFutureUserByUserID(community.userID);
      }

      filteredCommunityList(GlobalProfile.filteredCommunityList);
    }
  }

  // '인기' 스크롤 이벤트
  Future<void> popularMaxScrollEvent() async{
    var tmp = await ApiProvider().post(
        '/CommunityPost/Select/Offset/Popular',
        jsonEncode({
          "index": popularCalls,
        }));

    if (tmp != null) {
      for (int i = 0; i < tmp.length; i++) {
        Community community = Community.fromJson(tmp[i]);
        GlobalProfile.popularCommunityList.add(community);
        await GlobalProfile.getFutureUserByUserID(community.userID);
      }

      if(tmp.length > 0) popularCalls++; // 호출 횟수 추가
    }
  }

  // 타입 체크
  Map<String, dynamic> typeCheck(Community community){
    String category = community.category;
    Color color = sheepsColorLightGrey;

    if(community.type == COMMUNITY_NOTICE_TYPE) {
      color = sheepsColorGreen;
      category = '공지';
    } else if(community.type == COMMUNITY_HOT_TYPE) {
      color = sheepsColorBlack;
      category = 'HOT';
    } else if(community.type == COMMUNITY_POPULAR_TYPE){
      color = sheepsColorBlue;
      if(selectedCategory.value == '전체') category = '인기';
    }

    return {'category': category, 'color': color};
  }

  // 검색 이벤트
  Future<void> searchEvent(BuildContext context, String searchWord, {bool isOffset = false}) async{
    searchWord = controlSpace(searchWord); // 공백 제거
    savedSearchWord = searchWord;
    if (searchWord.isEmpty || searchWord.length < 2) {
      showSheepsToast(context: context, text: "최소 두 글자 이상을 입력해 주세요.");
      return;
    }

    if(!isOffset) isLoading(true);

    isSearch = true;
    if(!isOffset) GlobalProfile.searchedCommunityList.clear(); // offset 호출이 아닐 경우만 clear

    var res = await ApiProvider().post(
        '/CommunityPost/SearchWord',
        jsonEncode({
          "index": GlobalProfile.searchedCommunityList.length,
          "searchWord": searchWord,
        }));

    if (res != null) {
      for (int i = 0; i < res.length; i++) {
        Community community = Community.fromJson(res[i]);
        GlobalProfile.searchedCommunityList.add(community);
        await GlobalProfile.getFutureUserByUserID(community.userID);
      }
    }

    if(!isOffset) isLoading(false);
  }

  // 카테고리 리스트 받아오기
  Future<void> getCommunityCategoryList({bool isRefresh = false}) async{
    if(!isRefresh) isLoading(true);
    GlobalProfile.filteredCommunityList.clear();
    addedPostForCategory = 0;

    int num = hotAllowRange; // 핫 게시글 허용범위

    // 핫 게시글 받기
    var hotCommunityList =  await ApiProvider().post('/CommunityPost//Select/Category/Hot',jsonEncode({
      "category": selectedCategory.value,
    }));

    if(hotCommunityList != null){
      if(hotCommunityList.length < hotAllowRange){
        num = hotCommunityList.length;
      }

      for(int i = 0;  i < num; i ++) {
        Community hotCommunity = Community.fromJson(hotCommunityList[i], isHot: true);
        GlobalProfile.filteredCommunityList.add(hotCommunity);
        await GlobalProfile.getFutureUserByUserID(hotCommunity.userID);
        addedPostForCategory++; // 추가된 핫글 수
      }
    }

    var res =  await ApiProvider().post('/CommunityPost/Select/Category',jsonEncode({
      "category": selectedCategory.value,
    }));

    if(res != null){
      for(int i = 0;  i < res.length; i ++) {
        Community community = Community.fromJson(res[i]);
        GlobalProfile.filteredCommunityList.add(community);
        await GlobalProfile.getFutureUserByUserID(community.userID);
      }
    }

    if(!isRefresh) isLoading(false);
  }

  // 댓글 받아오기
  Future<dynamic> getReply(BuildContext context, Community community) async{
    var tmp = await ApiProvider().post('/CommunityPost/PostSelect',jsonEncode({
      "id": community.id,
    }));

    if (tmp == null) {
      for(int i = 0; i < GlobalProfile.globalCommunityList.length; i++){
        if(GlobalProfile.globalCommunityList[i].id == community.id){
          GlobalProfile.globalCommunityList.removeAt(i);
          break;
        }
      }

      showSheepsDialog(
        context: context,
        title: '삭제된 게시글입니다.',
        description: '삭제된 게시물이에요.',
        isCancelButton: false,
      );
      return tmp;
    }

    GlobalProfile.communityReply = [];

    for (int i = 0; i < tmp.length; i++) {
      Map<String, dynamic> data = tmp[i];
      CommunityReply tmpReply = CommunityReply.fromJson(data);
      await GlobalProfile.getFutureUserByUserID(tmpReply.userID);
      GlobalProfile.communityReply.add(tmpReply);
    }

    // 댓글 갯수 동기화
    syncRepliesLength(communityList: GlobalProfile.globalCommunityList, community: community);
    syncRepliesLength(communityList: GlobalProfile.popularCommunityList, community: community);
    syncRepliesLength(communityList: GlobalProfile.hotCommunityList, community: community);
    syncRepliesLength(communityList: GlobalProfile.filteredCommunityList, community: community);
    syncRepliesLength(communityList: GlobalProfile.searchedCommunityList, community: community);
    syncRepliesLength(communityList: GlobalProfile.myCommunityList, community: community);

    return tmp;
  }

  // 좋아요 여부 체크
  bool likeCheckFunc(Community community) {
    bool isLike = false;

    for (CommunityLike c in community.communityLike) {
      if (c.userID == GlobalProfile.loggedInUser.userID) {
        isLike = true;
        break;
      }
    }

    return isLike;
  }

  // 카테고리 체인지
  void changeCategory(String category) {
    selectedCategory(category);
  }

  // 바텀 네비게이션 눌렀을 때 스크롤 이벤트 함수
  Widget navScrollEvent(ScrollController scrollController) {
    if (navigationNum.getNum() == navigationNum.getPastNum()) {
      if (scrollController.hasClients) {
        Future.microtask(() => scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut));
        navigationNum.setNormalPastNum(-1);
      }
    }
    return SizedBox(width: navigationNum.forSetState.value * 0);
  }
}
