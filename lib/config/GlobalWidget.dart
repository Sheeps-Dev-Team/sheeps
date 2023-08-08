import 'package:badges/badges.dart' as badge;
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:extended_image/extended_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/Recruit/Controller/RecruitController.dart';
import 'package:sheeps_app/profile/models/ModelLikes.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sheeps_app/Badge/model/ModelBadge.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/ConcaveDecoration.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';

class SettingColumn extends StatelessWidget {
  final String str;
  final Function myFunc;

  SettingColumn({Key? key, required this.str, required this.myFunc});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => myFunc,
      child: Container(
        color: Colors.white,
        height: 48 * sizeUnit,
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16 * sizeUnit),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  this.str,
                  style: SheepsTextStyle.b1(),
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(right: 16 * sizeUnit),
              child: SvgPicture.asset(
                svgGreyNextIcon,
                width: 16 * sizeUnit,
                height: 16 * sizeUnit,
                color: sheepsColorDarkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Container buildGotoNextPage(BuildContext context, String title) {
  return Container(
    color: Colors.white,
    height: 48 * sizeUnit,
    child: Row(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 12 * sizeUnit),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              height: 22 * sizeUnit,
              child: Text(
                title,
                style: SheepsTextStyle.b1(),
              ),
            ),
          ),
        ),
        Expanded(child: SizedBox()),
        Padding(
          padding: EdgeInsets.only(right: 16 * sizeUnit),
          child: SvgPicture.asset(
            svgGreyNextIcon,
            width: 16 * sizeUnit,
            height: 16 * sizeUnit,
          ),
        ),
      ],
    ),
  );
}

getExtendedImage(String url, int size, AnimationController controller, {bool isRounded = true}) {
  return ExtendedImage.network(
    getOptimizeImageURL(url, size),
    fit: BoxFit.fill,
    borderRadius: isRounded == true ? BorderRadius.all(Radius.circular(8.0)) : null,
    shape: BoxShape.rectangle,
    cache: true,
    loadStateChanged: (ExtendedImageState state) {
      switch (state.extendedImageLoadState) {
        case LoadState.loading:
          controller.reset();
          return Container();
        case LoadState.completed:
          controller.forward();
          return ExtendedRawImage(
            image: state.extendedImageInfo?.image,
          );
        case LoadState.failed:
          controller.reset();
          return GestureDetector(
            child: Container(),
            onTap: () {
              state.reLoadImage();
            },
          );
        default:
          controller.reset();
          return Container();
      }
    },
  );
}

PreferredSizeWidget SheepsAppBar(BuildContext context, String title,
    {String subText = '', bool isBackButton = true, Function? backFunc, List<Widget>? actions, bool bottomLine = false}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(44 * sizeUnit),
    child: AppBar(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: isBackButton
          ? Padding(
              padding: EdgeInsets.only(left: 11 * sizeUnit),
              child: GestureDetector(
                onTap: backFunc == null
                    ? () {
                        Get.back();
                      }
                    : () => backFunc(),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SvgPicture.asset(
                    svgBackArrow,
                    width: 28 * sizeUnit,
                    height: 28 * sizeUnit,
                  ),
                ),
              ),
            )
          : Container(),
      title: subText != ''
          ? RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: title,
                  style: SheepsTextStyle.appBar(),
                ),
                TextSpan(text: subText, style: SheepsTextStyle.appBar().copyWith(color: sheepsColorGrey))
              ]),
            )
          : Text(
              title,
              style: SheepsTextStyle.appBar(),
            ),
      actions: actions,
      bottom: bottomLine
          ? PreferredSize(
              child: Container(
                color: sheepsColorGrey,
                height: 1.0,
              ),
              preferredSize: Size.fromHeight(1.0),
            )
          : null,
    ),
  );
}

Widget SheepsSimpleListItemBox(BuildContext context, Widget _child) {
  return Container(
    width: 360 * sizeUnit,
    height: 48 * sizeUnit,
    color: Colors.white,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit),
      child: _child,
    ),
  );
}

showSheepsDialog(
    {required BuildContext context,
    required String title,
    String? imgUrl,
    String? description,
    String okText = '확인',
    Function? okFunc,
    Color okColor = sheepsColorGreen,
    bool isCancelButton = true,
    String cancelText = '취소하기',
    Function? cancelFunc,
    Color cancelColor = sheepsColorGrey,
    bool isBarrierDismissible = true}) {
  return showDialog(
      context: context,
      barrierDismissible: isBarrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24 * sizeUnit)),
          actions: <Widget>[
            Container(
              width: 280 * sizeUnit,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 40 * sizeUnit),
                    child: Text(
                      title,
                      style: SheepsTextStyle.dialogTitle(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  imgUrl == null
                      ? SizedBox.shrink()
                      : imgUrl == 'BasicImage'
                          ? Padding(
                              padding: EdgeInsets.only(top: 20 * sizeUnit),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: sheepsColorLightGrey,
                                  borderRadius: BorderRadius.circular(8 * sizeUnit),
                                ),
                                child: SvgPicture.asset(
                                  svgPersonalProfileBasicImage,
                                  width: 84 * sizeUnit,
                                  height: 84 * sizeUnit,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.only(top: 20 * sizeUnit),
                              child: Container(
                                color: Colors.white,
                                width: 120 * sizeUnit,
                                height: 120 * sizeUnit,
                                child: Center(
                                  child: FittedBox(
                                    child: ExtendedImage.network(getOptimizeImageURL(imgUrl, 120)),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                  description == null
                      ? SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(top: 20 * sizeUnit, left: 20 * sizeUnit, right: 20 * sizeUnit),
                          child: Text(
                            description,
                            style: SheepsTextStyle.dialogContent(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                  SizedBox(height: 40 * sizeUnit),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20 * sizeUnit),
                    child: SheepsBottomButton(
                      context: context,
                      function: okFunc == null
                          ? () {
                              Get.back();
                            }
                          : okFunc,
                      text: okText,
                      color: okColor,
                    ),
                  ),
                  isCancelButton
                      ? Padding(
                          padding: EdgeInsets.only(left: 20 * sizeUnit, right: 20 * sizeUnit, top: 12 * sizeUnit),
                          child: SheepsBottomButton(
                            context: context,
                            function: cancelFunc == null
                                ? () {
                                    Get.back();
                                  }
                                : cancelFunc,
                            text: cancelText,
                            color: cancelColor,
                          ),
                        )
                      : SizedBox.shrink(),
                  SizedBox(
                    height: 20 * sizeUnit,
                  ),
                ],
              ),
            ),
          ],
        );
      });
}

Future SheepsBottomSheetForImg(BuildContext context, {required Function cameraFunc, required Function galleryFunc}) {
  return showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.only(
        topLeft: const Radius.circular(12),
        topRight: const Radius.circular(12),
      )),
      context: context,
      builder: (BuildContext bc) {
        return SizedBox(
          height: 136 * sizeUnit,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8 * sizeUnit),
                    child: Container(
                      width: 20 * sizeUnit,
                      height: 4 * sizeUnit,
                      decoration: BoxDecoration(
                        color: sheepsColorLightGrey,
                        borderRadius: BorderRadius.circular(2 * sizeUnit),
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => cameraFunc,
                child: Container(
                  height: 48 * sizeUnit,
                  width: 360 * sizeUnit,
                  color: Colors.white,
                  child: Center(
                    child: Text(
                      '카메라로 사진 찍기',
                      style: SheepsTextStyle.b1(),
                    ),
                  ),
                ),
              ),
              Container(color: Color(0xFFF8F8F8), height: 1 * sizeUnit),
              GestureDetector(
                onTap: () => galleryFunc,
                child: Container(
                  height: 48 * sizeUnit,
                  width: 360 * sizeUnit,
                  color: Colors.white,
                  child: Center(
                    child: Text(
                      '앨범에서 사진 선택',
                      style: SheepsTextStyle.b1(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      });
}

Widget SheepsbuildIdentifiedState(BuildContext context, int value) {
  if (value == 2) {
    return Padding(
      padding: EdgeInsets.only(left: 8 * sizeUnit),
      child: Container(
        width: 60 * sizeUnit,
        height: 40 * sizeUnit,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.circular(8 * sizeUnit),
          border: Border.all(color: sheepsColorGreen),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            '검토중',
            style: SheepsTextStyle.b3().copyWith(color: sheepsColorGreen),
          ),
        ),
      ),
    );
  } else if (value == 1) {
    return Padding(
      padding: EdgeInsets.only(left: 8 * sizeUnit),
      child: Container(
        width: 60 * sizeUnit,
        height: 40 * sizeUnit,
        decoration: BoxDecoration(
          color: sheepsColorGreen,
          borderRadius: new BorderRadius.circular(8 * sizeUnit),
          border: Border.all(color: sheepsColorGreen),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            '인증완료',
            style: SheepsTextStyle.b3().copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  } else {
    return GestureDetector(
      onTap: () {
        showSheepsDialog(
          context: context,
          title: '반려 사유',
          description: '- 흔들림, 빛반사 등으로 인한 글씨판독 불가\n- 입력된 정보와 상이한 내용의 인증서류\n- 인증 유효기간 초과\n- 기타 유효하지 않은 인증서류\n\n'
              '위와 같은 이유로 반려되었습니다.\n삭제 후 다시 등록해주세요!',
          isCancelButton: false,
        );
      },
      child: Padding(
        padding: EdgeInsets.only(left: 8 * sizeUnit),
        child: Container(
          width: 60 * sizeUnit,
          height: 40 * sizeUnit,
          decoration: BoxDecoration(
            color: sheepsColorGrey,
            borderRadius: new BorderRadius.circular(8 * sizeUnit),
            border: Border.all(color: sheepsColorGrey),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              '반려됨',
              style: SheepsTextStyle.b3().copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

Widget SheepsProfileVerificationStateIcon(BuildContext context, int state) {
  //stste 인증상태 받아옴
  final String svgVerificationCompleted = 'assets/images/Profile/VerificationCompleted.svg';
  final String svgVerificationIncomplete = 'assets/images/Profile/VerificationIncomplete.svg';
  return Padding(
    padding: EdgeInsets.only(left: 8 * sizeUnit),
    child: SvgPicture.asset(
      //인증완료 1 일때 초록아이콘
      state == 1 ? svgVerificationCompleted : svgVerificationIncomplete,
      height: 16 * sizeUnit,
      width: 16 * sizeUnit,
    ),
  );
}

Widget SheepsPersonalProfileCard(BuildContext context, UserData person, int index, {Color basicImgColor = sheepsColorBlue, required Function onTap}) {
  person.location = abbreviateForLocation(person.location); //지명 약어화 함수
  bool isLike = false;

  // 저장한 프로필 체크
  globalPersonalLikeList.forEach((element) {
    if (element.TargetID == person.userID) isLike = true;
  });

  return GestureDetector(
    onTap: () => onTap,
    child: Container(
      width: 160 * sizeUnit,
      padding: EdgeInsets.only(top: 8 * sizeUnit, left: 4 * sizeUnit, right: 4 * sizeUnit),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'personalProfile${person.userID}',
            child: Container(
              width: 156 * sizeUnit,
              height: 156 * sizeUnit,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration:
                          BoxDecoration(color: Colors.white, borderRadius: new BorderRadius.circular(28 * sizeUnit), border: Border.all(color: sheepsColorGrey, width: 0.5)),
                      child: Center(
                        child: SvgPicture.asset(
                          svgSheepsBasicProfileImage,
                          width: 88 * sizeUnit,
                          color: basicImgColor,
                        ),
                      ),
                    ),
                  ),
                  if (person.profileImgList[0].imgUrl != 'BasicImage') ...[
                    Positioned(
                      child: Container(
                        width: 156 * sizeUnit,
                        height: 156 * sizeUnit,
                        decoration: BoxDecoration(
                          borderRadius: new BorderRadius.circular(28 * sizeUnit),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(116, 125, 130, 0.1),
                              offset: Offset(1 * sizeUnit, 1 * sizeUnit),
                              blurRadius: 2 * sizeUnit,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: new BorderRadius.circular(28 * sizeUnit),
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: getOptimizeImageURL(person.profileImgList[0].imgUrl, 60),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (person.badge1 != 0) ...[
                    Positioned(
                      right: 8 * sizeUnit,
                      bottom: 8 * sizeUnit,
                      child: Container(
                        width: 32 * sizeUnit,
                        height: 32 * sizeUnit,
                        child: ClipRRect(
                          borderRadius: new BorderRadius.circular(8 * sizeUnit),
                          child: FittedBox(
                            child: SvgPicture.asset(
                              ReturnPersonalBadgeSVG(person.badge1),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  ],
                  if (person.badge2 != 0) ...[
                    Positioned(
                      right: 40 * sizeUnit,
                      bottom: 8 * sizeUnit,
                      child: Container(
                        width: 32 * sizeUnit,
                        height: 32 * sizeUnit,
                        child: ClipRRect(
                          borderRadius: new BorderRadius.circular(8 * sizeUnit),
                          child: FittedBox(
                            child: SvgPicture.asset(ReturnPersonalBadgeSVG(person.badge2)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  ],
                  if (person.badge3 != 0) ...[
                    Positioned(
                      right: 72 * sizeUnit,
                      bottom: 8 * sizeUnit,
                      child: Container(
                        width: 32 * sizeUnit,
                        height: 32 * sizeUnit,
                        child: ClipRRect(
                          borderRadius: new BorderRadius.circular(8 * sizeUnit),
                          child: FittedBox(
                            child: SvgPicture.asset(ReturnPersonalBadgeSVG(person.badge3)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  ],
                  if (isLike)
                    Positioned(
                      right: 10 * sizeUnit,
                      top: 10 * sizeUnit,
                      child: SvgPicture.asset(
                        svgFillBookMarkIcon,
                        color: sheepsColorGreen,
                        width: 28 * sizeUnit,
                        height: 28 * sizeUnit,
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8 * sizeUnit),
          Container(
            height: 22 * sizeUnit,
            width: 160 * sizeUnit,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                person.name,
                style: SheepsTextStyle.h3(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(height: 4 * sizeUnit),
          Wrap(
            runSpacing: 4 * sizeUnit,
            spacing: 4 * sizeUnit,
            children: [
              if (person.part != null && person.part.isNotEmpty) profileSmallWrapItem(person.part),
              if (person.subPart != null && person.subPart.isNotEmpty) profileSmallWrapItem(person.subPart),
              if (person.location != null && person.location.isNotEmpty) profileSmallWrapItem(person.location),
            ],
          ),
          SizedBox(height: 8 * sizeUnit),
          Container(
            height: 48 * sizeUnit,
            child: Text(
              person.information == null ? '' : person.information,
              maxLines: 3,
              style: SheepsTextStyle.b4().copyWith(height: 1.3),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget SheepsTeamProfileCard(BuildContext context, Team team, int index, {bool proposedTeam = false, required Function onTap}) {
  team.location = abbreviateForLocation(team.location); //지명약어화 함수
  bool isLike = false;

  // 저장한 프로필 체크
  globalTeamLikeList.forEach((element) {
    if (element.TargetID == team.id) isLike = true;
  });

  return GestureDetector(
    onTap: () => onTap,
    child: Container(
      width: 160 * sizeUnit,
      padding: EdgeInsets.only(top: 8 * sizeUnit, left: 4 * sizeUnit, right: 4 * sizeUnit),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'teamProfile${team.id}',
            child: Container(
              width: 156 * sizeUnit,
              height: 156 * sizeUnit,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration:
                          BoxDecoration(color: Colors.white, borderRadius: new BorderRadius.circular(28 * sizeUnit), border: Border.all(color: sheepsColorGrey, width: 0.5)),
                      child: Center(
                          child: SvgPicture.asset(
                        svgSheepsBasicProfileImage,
                        width: 88 * sizeUnit,
                      )),
                    ),
                  ),
                  if (team.profileImgList[0].imgUrl != 'BasicImage') ...[
                    Positioned(
                      child: Container(
                        width: 156 * sizeUnit,
                        height: 156 * sizeUnit,
                        decoration: BoxDecoration(
                          borderRadius: new BorderRadius.circular(28 * sizeUnit),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(116, 125, 130, 0.1),
                              offset: Offset(1 * sizeUnit, 1 * sizeUnit),
                              blurRadius: 2 * sizeUnit,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: new BorderRadius.circular(28 * sizeUnit),
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: getOptimizeImageURL(team.profileImgList[0].imgUrl, 60),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (team.badge1 != 0) ...[
                    Positioned(
                      right: 8 * sizeUnit,
                      bottom: 8 * sizeUnit,
                      child: Container(
                        width: 32 * sizeUnit,
                        height: 32 * sizeUnit,
                        child: ClipRRect(
                          borderRadius: new BorderRadius.circular(8 * sizeUnit),
                          child: FittedBox(
                            child: SvgPicture.asset(
                              ReturnTeamBadgeSVG(team.badge1),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  ],
                  if (team.badge2 != 0) ...[
                    Positioned(
                      right: 40 * sizeUnit,
                      bottom: 8 * sizeUnit,
                      child: Container(
                        width: 32 * sizeUnit,
                        height: 32 * sizeUnit,
                        child: ClipRRect(
                          borderRadius: new BorderRadius.circular(8 * sizeUnit),
                          child: FittedBox(
                            child: SvgPicture.asset(
                              ReturnTeamBadgeSVG(team.badge2),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  ],
                  if (team.badge3 != 0) ...[
                    Positioned(
                      right: 72 * sizeUnit,
                      bottom: 8 * sizeUnit,
                      child: Container(
                        width: 32 * sizeUnit,
                        height: 32 * sizeUnit,
                        child: ClipRRect(
                          borderRadius: new BorderRadius.circular(8 * sizeUnit),
                          child: FittedBox(
                            child: SvgPicture.asset(
                              ReturnTeamBadgeSVG(team.badge3),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  ],
                  if (isLike)
                    Positioned(
                      right: 10 * sizeUnit,
                      top: 10 * sizeUnit,
                      child: SvgPicture.asset(
                        svgFillBookMarkIcon,
                        color: sheepsColorBlue,
                        width: 28 * sizeUnit,
                        height: 28 * sizeUnit,
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8 * sizeUnit),
          Container(
            height: 22 * sizeUnit,
            width: 160 * sizeUnit,
            child: Text(
              team.name,
              style: SheepsTextStyle.h3(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 4 * sizeUnit),
          Wrap(
            runSpacing: 4 * sizeUnit,
            spacing: 4 * sizeUnit,
            children: [
              if (team.category != null && team.category.isNotEmpty) profileSmallWrapItem(team.category),
              if (team.location != null && team.location.isNotEmpty) profileSmallWrapItem(team.location),
            ],
          ),
          SizedBox(height: 8 * sizeUnit),
          Container(
            height: 48 * sizeUnit,
            child: Text(
              team.information,
              maxLines: 3,
              style: SheepsTextStyle.b4().copyWith(height: 1.3),
            ),
          ),
        ],
      ),
    ),
  );
}

Container profileSmallWrapItem(String text, {Color color = sheepsColorLightGrey}) {
  return Container(
    height: 16 * sizeUnit,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 4 * sizeUnit),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: SheepsTextStyle.cat1().copyWith(color: color == sheepsColorLightGrey ? sheepsColorBlack : Colors.white),
          ),
        ],
      ),
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6 * sizeUnit),
      color: color,
    ),
  );
}

Container profileBigWrapItem(String text) {
  return Container(
    height: 20 * sizeUnit,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: SheepsTextStyle.cat2(),
          ),
        ],
      ),
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16 * sizeUnit),
      color: sheepsColorLightGrey,
    ),
  );
}

Widget SheepsFilterItem(BuildContext context, String name, bool isCheck, {Color color = sheepsColorGreen}) {
  // 필터 버튼 innerShadow 설정
  final innerShadow = ConcaveDecoration(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * sizeUnit)),
    depression: 2,
    colors: [
      Color.fromRGBO(0, 0, 0, 0.5),
      Color.fromRGBO(0, 0, 0, 0),
    ],
  );

  return Stack(
    children: [
      Container(
        height: 24 * sizeUnit,
        decoration: BoxDecoration(
          border: Border.all(color: isCheck == true ? color : sheepsColorLightGrey, width: 1 * sizeUnit),
          borderRadius: BorderRadius.circular(16 * sizeUnit),
          color: isCheck == true ? color : Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 7 * sizeUnit),
              child: Text(
                name,
                style: SheepsTextStyle.b4().copyWith(
                  color: isCheck == true ? Colors.white : sheepsColorDarkGrey,
                ),
              ),
            ),
          ],
        ),
      ),
      Container(
        // innerShadow 효과 버튼
        padding: EdgeInsets.all(1 * sizeUnit), // border 맞추기 위한 패딩
        height: 24 * sizeUnit,
        decoration: isCheck ? innerShadow : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 7 * sizeUnit),
              child: Text(
                name,
                style: SheepsTextStyle.b4().copyWith(color: Colors.transparent),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget SheepsBottomButton({
  required BuildContext context,
  required Function function,
  required String text,
  Color color = sheepsColorGreen,
  bool isOK = true,
}) {
  return Container(
    width: 320 * sizeUnit,
    height: 54 * sizeUnit,
    decoration: BoxDecoration(
      color: isOK ? color : sheepsColorGrey,
      borderRadius: BorderRadius.circular(12 * sizeUnit),
    ),
    child: TextButton(
      style: ButtonStyle(shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * sizeUnit)))),
      onPressed: () => function,
      child: Text(
        text,
        style: SheepsTextStyle.button1(),
      ),
    ),
  );
}

Widget sheepsTextField(
  BuildContext context, {
  String? title,
  required TextEditingController controller,
  String? hintText,
  String? errorText,
  bool obscureText = false,
  bool autofocus = false,
  int? maxLength,
  Function? onChanged,
  Function? onSubmitted,
  Function? onPressClear,
  TextInputType keyboardType = TextInputType.text,
  Color borderColor = sheepsColorGreen,
  TextStyle? errorTextStyle,
}) {
  return Container(
    width: double.infinity,
    child: Container(
      width: double.infinity,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: SheepsTextStyle.textField(),
        decoration: InputDecoration(
          labelText: title,
          labelStyle: SheepsTextStyle.textFieldLabel(),
          hintText: hintText,
          hintStyle: SheepsTextStyle.hint(),
          errorText: errorText,
          errorStyle: errorTextStyle == null ? SheepsTextStyle.error() : errorTextStyle,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8 * sizeUnit),
          suffixIcon: controller.text.length > 0
              ? Padding(
                  padding: const EdgeInsets.all(0),
                  child: IconButton(
                      onPressed: onPressClear == null
                          ? () {
                              controller.clear();
                            }
                          : () => onPressClear,
                      icon: Icon(
                        Icons.clear,
                        color: sheepsColorDarkGrey,
                        size: 16 * sizeUnit,
                      )),
                )
              : null,
          suffixIconConstraints: BoxConstraints(maxWidth: 32 * sizeUnit, maxHeight: 32 * sizeUnit),
          errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: sheepsColorRed, width: 2 * sizeUnit)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: sheepsColorDarkGrey, width: 2 * sizeUnit)),
          focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: sheepsColorDarkGrey, width: 2 * sizeUnit)),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
            color: controller.text.length > 0 ? borderColor : sheepsColorGrey,
            width: 2 * sizeUnit,
          )),
        ),
        obscureText: obscureText,
        autofocus: autofocus,
        autocorrect: false,
        maxLength: maxLength,
        onChanged: (value) => onChanged,
        onSubmitted: (value) => onSubmitted,
      ),
    ),
  );
}

Widget SheepsAnimatedTabBar2(
  BuildContext context, {
  double? height,
  double? width,
  double? thickness,
  int duration = 500,
  Curve curve = Curves.easeInOut,
  required int barIndex,
  required List<Widget> listTabItem,
}) {
  if (height == null) height = 40 * sizeUnit;
  if (width == null) width = 320 * sizeUnit;
  if (thickness == null) thickness = 2 * sizeUnit;
  double itemWidth = width / listTabItem.length;
  return Container(
    height: height,
    child: Column(
      children: [
        Row(
          children: listTabItem
              .asMap()
              .map((index, item) => MapEntry(
                  index,
                  GestureDetector(
                    onTap: () {
                      barIndex = index;
                    },
                    child: Container(
                      width: itemWidth,
                      height: height! - thickness!,
                      color: Colors.white,
                      child: Center(child: item),
                    ),
                  )))
              .values
              .toList(),
        ),
        Row(
          children: [
            AnimatedContainer(
              width: itemWidth * barIndex,
              duration: Duration(milliseconds: duration),
              curve: curve,
            ),
            Container(
              color: sheepsColorGreen,
              width: itemWidth,
              height: thickness,
            ),
            AnimatedContainer(
              width: itemWidth * (listTabItem.length - 1 - barIndex),
              duration: Duration(milliseconds: duration),
              curve: curve,
            ),
          ],
        ),
      ],
    ),
  );
}

// ignore: must_be_immutable
class SheepsAnimatedTabBar extends StatefulWidget {
  int barIndex;
  final PageController pageController;
  final double insidePadding; //탭 사이 여백
  final List<String> listTabItemTitle; //탭 이름 리스트
  final List<double> listTabItemWidth; //각 탭 너비 리스트
  final List<bool>? listTabItemBoolean;

  SheepsAnimatedTabBar({
    Key? key,
    required this.barIndex,
    required this.pageController,
    required this.insidePadding,
    required this.listTabItemTitle,
    required this.listTabItemWidth,
    this.listTabItemBoolean,
  }) : super(key: key);

  @override
  _SheepsAnimatedTabBarState createState() => _SheepsAnimatedTabBarState();
}

class _SheepsAnimatedTabBarState extends State<SheepsAnimatedTabBar> {
  final Duration duration = Duration(milliseconds: 500);
  final Curve curve = Curves.fastOutSlowIn;
  late double insidePadding;

  late double leftPadding;
  late double rightPadding;

  late TextStyle _textStyle;

  @override
  void initState() {
    super.initState();
    _textStyle = SheepsTextStyle.h3();
    insidePadding = widget.insidePadding;
  }

  @override
  Widget build(BuildContext context) {
    leftPadding = 0;
    for (int i = 0; i < widget.barIndex; i++) {
      leftPadding = leftPadding + widget.listTabItemWidth[i] + insidePadding;
    }
    rightPadding = 0;
    for (int i = widget.listTabItemTitle.length - 1; i > widget.barIndex; i--) {
      rightPadding = rightPadding + widget.listTabItemWidth[i] + insidePadding;
    }

    return Container(
      height: 36 * sizeUnit,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: 4 * sizeUnit),
          Row(
            children: widget.listTabItemTitle
                .asMap()
                .map((index, title) => MapEntry(
                      index,
                      Row(
                        children: [
                          index > 0 ? SizedBox(width: insidePadding) : SizedBox.shrink(),
                          GestureDetector(
                            onTap: () {
                              unFocus(context);
                              widget.barIndex = index;
                              widget.pageController.animateToPage(index, duration: duration, curve: curve);
                            },
                            child: widget.listTabItemBoolean != null
                                ? badge.Badge(
                                    showBadge: widget.listTabItemBoolean![index],
                                    position: badge.BadgePosition.topEnd(top: -7 * sizeUnit, end: -7 * sizeUnit),
                                    // padding: EdgeInsets.all(3 * sizeUnit),
                                    // badgeColor: sheepsColorRed,
                                    // toAnimate: false,
                                    // elevation: 0,
                                    badgeContent: Text(''),
                                    child: Container(
                                      width: widget.listTabItemWidth[index],
                                      height: 24 * sizeUnit,
                                      color: Colors.white,
                                      child: Center(
                                        child: Text(
                                          title,
                                          style: _textStyle.copyWith(color: widget.barIndex == index ? sheepsColorBlack : sheepsColorDarkGrey),
                                          softWrap: false,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: widget.listTabItemWidth[index],
                                    height: 24 * sizeUnit,
                                    color: Colors.white,
                                    child: Center(
                                      child: Text(
                                        title,
                                        style: _textStyle.copyWith(color: widget.barIndex == index ? sheepsColorBlack : sheepsColorDarkGrey),
                                        softWrap: false,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ))
                .values
                .toList(),
          ),
          SizedBox(height: 4 * sizeUnit),
          Row(
            children: [
              AnimatedContainer(
                width: leftPadding,
                duration: duration,
                curve: curve,
              ),
              AnimatedContainer(
                color: sheepsColorBlack,
                width: widget.listTabItemWidth[widget.barIndex],
                height: 2 * sizeUnit,
                duration: duration,
                curve: curve,
              ),
              AnimatedContainer(
                width: rightPadding,
                duration: duration,
                curve: curve,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//텍스트랑 스타일 입력하면 그 텍스트가 들어갈 텍스트위젯의 사이즈를 알려줌. 뒤에 .width .height 붙여서 사용
//IOS에서 텍스트페인터가 실제보다 사이즈를 작게 가져오는 이슈 있음
Size getTextWidgetSize(String text, TextStyle style) {
  TextPainter textPainter = TextPainter(text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr, textScaleFactor: 1)
    ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}

showSheepsCustomDialog({
  Widget? title,
  required Widget contents,
  Color okButtonColor = sheepsColorGreen,
  String okText = '확인',
  Function? okFunc,
  bool isCancelButton = false,
  String cancelText = '취소하기',
  Function? cancelFunc,
  bool isBarrierDismissible = true,
}) {
  return Get.dialog(
    Center(
      child: Container(
        width: 280 * sizeUnit,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24 * sizeUnit),
          boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.25), blurRadius: 8 * sizeUnit)],
        ),
        child: DefaultTextStyle(
          style: TextStyle(decoration: TextDecoration.none),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 40 * sizeUnit),
              if (title != null) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * sizeUnit),
                  child: title,
                ),
                SizedBox(height: 20 * sizeUnit),
              ],
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20 * sizeUnit),
                child: contents,
              ),
              SizedBox(height: 40 * sizeUnit),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20 * sizeUnit),
                child: Container(
                  width: 240 * sizeUnit,
                  height: 54 * sizeUnit,
                  decoration: BoxDecoration(
                    color: okButtonColor,
                    borderRadius: BorderRadius.circular(12 * sizeUnit),
                  ),
                  child: TextButton(
                    style: ButtonStyle(shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * sizeUnit)))),
                    onPressed: okFunc == null
                        ? () {
                            Get.back();
                          }
                        : () => okFunc,
                    child: Text(
                      okText,
                      style: SheepsTextStyle.button1(),
                    ),
                  ),
                ),
              ),
              if (isCancelButton) ...[
                SizedBox(height: 12 * sizeUnit),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * sizeUnit),
                  child: Container(
                    width: 240 * sizeUnit,
                    height: 54 * sizeUnit,
                    decoration: BoxDecoration(
                      color: sheepsColorGrey,
                      borderRadius: BorderRadius.circular(12 * sizeUnit),
                    ),
                    child: TextButton(
                      style: ButtonStyle(shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * sizeUnit)))),
                      onPressed: cancelFunc == null
                          ? () {
                              Get.back();
                            }
                          : () => cancelFunc,
                      child: Text(
                        cancelText,
                        style: SheepsTextStyle.button1(),
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 20 * sizeUnit),
            ],
          ),
        ),
      ),
    ),
    barrierColor: Color.fromRGBO(204, 204, 204, 0.5),
    barrierDismissible: isBarrierDismissible,
  );
}

showAddFailDialog({required String title, Color okButtonColor = sheepsColorGreen}) {
  return showSheepsCustomDialog(
    title: Text(
      title + ' 추가에\n실패 했어요!😢',
      style: SheepsTextStyle.h1(),
      textAlign: TextAlign.center,
    ),
    contents: Column(
      children: [
        Text('중복된 내용이 있어요!', style: SheepsTextStyle.b3()),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('삭제 후 ', style: SheepsTextStyle.b3()),
            Text('재등록', style: SheepsTextStyle.h4()),
            Text(' 해 주세요.', style: SheepsTextStyle.b3()),
          ],
        ),
      ],
    ),
    okButtonColor: okButtonColor,
  );
}

showPersonalBadgeDialog({
  required int badgeID,
  Color okButtonColor = sheepsColorBlue,
}) {
  return Get.dialog(
    Center(
      child: Container(
        width: 280 * sizeUnit,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24 * sizeUnit),
          boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.25), blurRadius: 8 * sizeUnit)],
        ),
        child: DefaultTextStyle(
          style: TextStyle(decoration: TextDecoration.none),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 40 * sizeUnit),
              Container(
                height: 112 * sizeUnit,
                width: 112 * sizeUnit,
                child: Center(
                  child: SvgPicture.asset(
                    ReturnPersonalBadgeSVG(badgeID),
                    width: 100 * sizeUnit,
                  ),
                ),
              ),
              SizedBox(height: 20 * sizeUnit),
              Text(
                badgeID < EVENT_BADGE_INDEX ? PersonalBadgeDescriptionList[badgeID].Part : EventBadgeDescriptionList[badgeID - EVENT_BADGE_INDEX].Part,
                style: SheepsTextStyle.h1(),
              ),
              SizedBox(height: 8 * sizeUnit),
              Text(
                badgeID < EVENT_BADGE_INDEX ? PersonalBadgeDescriptionList[badgeID].Title : EventBadgeDescriptionList[badgeID - EVENT_BADGE_INDEX].Title,
                style: SheepsTextStyle.b4(),
              ),
              SizedBox(height: 20 * sizeUnit),
              Text(
                badgeID < EVENT_BADGE_INDEX ? PersonalBadgeDescriptionList[badgeID].Description : EventBadgeDescriptionList[badgeID - EVENT_BADGE_INDEX].Description,
                style: SheepsTextStyle.b3(),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40 * sizeUnit),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20 * sizeUnit),
                child: Container(
                  width: 240 * sizeUnit,
                  height: 54 * sizeUnit,
                  decoration: BoxDecoration(
                    color: okButtonColor,
                    borderRadius: BorderRadius.circular(12 * sizeUnit),
                  ),
                  child: TextButton(
                    style: ButtonStyle(shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * sizeUnit)))),
                    onPressed: () {
                      Get.back();
                    },
                    child: Text(
                      '확인',
                      style: SheepsTextStyle.button1(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20 * sizeUnit),
            ],
          ),
        ),
      ),
    ),
    barrierColor: Color.fromRGBO(204, 204, 204, 0.5),
  );
}

showTeamBadgeDialog({
  required int badgeID,
  Color okButtonColor = sheepsColorGreen,
}) {
  return Get.dialog(
    Center(
      child: Container(
        width: 280 * sizeUnit,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24 * sizeUnit),
          boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.25), blurRadius: 8 * sizeUnit)],
        ),
        child: DefaultTextStyle(
          style: TextStyle(decoration: TextDecoration.none),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 40 * sizeUnit),
              Container(
                height: 112 * sizeUnit,
                width: 112 * sizeUnit,
                child: Center(
                  child: SvgPicture.asset(
                    ReturnTeamBadgeSVG(badgeID),
                    width: 100 * sizeUnit,
                  ),
                ),
              ),
              SizedBox(height: 20 * sizeUnit),
              Text(
                TeamBadgeDescriptionList[badgeID].Part,
                style: SheepsTextStyle.h1(),
              ),
              SizedBox(height: 8 * sizeUnit),
              Text(
                TeamBadgeDescriptionList[badgeID].Title,
                style: SheepsTextStyle.b4(),
              ),
              SizedBox(height: 20 * sizeUnit),
              Text(
                TeamBadgeDescriptionList[badgeID].Description,
                style: SheepsTextStyle.b3(),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40 * sizeUnit),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20 * sizeUnit),
                child: Container(
                  width: 240 * sizeUnit,
                  height: 54 * sizeUnit,
                  decoration: BoxDecoration(
                    color: okButtonColor,
                    borderRadius: BorderRadius.circular(12 * sizeUnit),
                  ),
                  child: TextButton(
                    style: ButtonStyle(shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * sizeUnit)))),
                    onPressed: () {
                      Get.back();
                    },
                    child: Text(
                      '확인',
                      style: SheepsTextStyle.button1(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20 * sizeUnit),
            ],
          ),
        ),
      ),
    ),
    barrierColor: Color.fromRGBO(204, 204, 204, 0.5),
  );
}

showEnterLinkDialog({
  required String title,
  required RxString linkUrl,
  required TextEditingController controller,
  Color okButtonColor = sheepsColorGreen,
}) {
  bool isHavePrefix = false;
  String prefix = '';
  if (title == 'LinkedIn') {
    isHavePrefix = true;
    prefix = 'www.linkedin.com/in/';
    controller.text = linkUrl.value.replaceFirst(prefix, '');
  } else if (title == 'Instagram') {
    isHavePrefix = true;
    prefix = 'www.instagram.com/';
    controller.text = linkUrl.value.replaceFirst(prefix, '');
  } else if (title == 'Facebook') {
    isHavePrefix = true;
    prefix = 'www.facebook.com/';
    controller.text = linkUrl.value.replaceFirst(prefix, '');
  } else if (title == 'GitHub') {
    isHavePrefix = true;
    prefix = 'github.com/';
    controller.text = linkUrl.value.replaceFirst(prefix, '');
  } else {
    controller.text = linkUrl.value;
  }

  return Get.dialog(
    Column(
      children: [
        SizedBox(height: Get.height * 0.1),
        Container(
          width: 280 * sizeUnit,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24 * sizeUnit),
            boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.25), blurRadius: 8 * sizeUnit)],
          ),
          child: DefaultTextStyle(
            style: TextStyle(decoration: TextDecoration.none),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 40 * sizeUnit),
                Text(
                  title + ' 링크를\n입력해 주세요.',
                  style: SheepsTextStyle.h5(),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20 * sizeUnit),
                Text(
                  '링크를 입력하면 버튼이 활성화되고,\n링크를 삭제하면 비활성화 됩니다.',
                  style: SheepsTextStyle.b3(),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20 * sizeUnit),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * sizeUnit),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isHavePrefix) ...[
                        Padding(
                          padding: EdgeInsets.only(top: 12 * sizeUnit),
                          child: Text(
                            prefix,
                            style: SheepsTextStyle.b3(),
                          ),
                        ),
                      ],
                      Expanded(
                        child: Card(
                          //Material 때문..
                          elevation: 0,
                          child: StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return TextField(
                                controller: controller,
                                decoration: InputDecoration(
                                  hintText: isHavePrefix ? '입력' : '링크를 입력해 주세요.',
                                  hintStyle: SheepsTextStyle.hint4Profile(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit, vertical: 8 * sizeUnit),
                                  counterStyle: SheepsTextStyle.s3(),
                                  errorText: urlCheckErrorText(prefix + controller.text),
                                  errorStyle: SheepsTextStyle.error(),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: sheepsColorRed, width: 1 * sizeUnit),
                                    borderRadius: BorderRadius.circular(16 * sizeUnit),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: okButtonColor, width: 1 * sizeUnit),
                                    borderRadius: BorderRadius.circular(16 * sizeUnit),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: sheepsColorRed, width: 1 * sizeUnit),
                                    borderRadius: BorderRadius.circular(16 * sizeUnit),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: controller.text.length > 0 ? okButtonColor : sheepsColorGrey, width: 1 * sizeUnit),
                                    borderRadius: BorderRadius.circular(16 * sizeUnit),
                                  ),
                                ),
                                textInputAction: TextInputAction.done,
                                style: SheepsTextStyle.b3().copyWith(height: 16 / 12, color: okButtonColor),
                                autofocus: true,
                                minLines: 1,
                                maxLines: 5,
                                onChanged: (val) {
                                  setState(() {});
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40 * sizeUnit),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * sizeUnit),
                  child: Container(
                    width: 240 * sizeUnit,
                    height: 54 * sizeUnit,
                    decoration: BoxDecoration(
                      color: okButtonColor,
                      borderRadius: BorderRadius.circular(12 * sizeUnit),
                    ),
                    child: TextButton(
                      style: ButtonStyle(shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * sizeUnit)))),
                      onPressed: () {
                        if (controller.text.isEmpty) {
                          linkUrl.value = '';
                          Get.back();
                        } else if (urlCheckErrorText(prefix + controller.text) == null) {
                          linkUrl.value = prefix + controller.text.replaceFirst('https://', '').replaceFirst('http://', '');
                          Get.back();
                        }
                      },
                      child: Text(
                        '확인',
                        style: SheepsTextStyle.button1(),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20 * sizeUnit),
              ],
            ),
          ),
        ),
      ],
    ),
    barrierColor: Color.fromRGBO(204, 204, 204, 0.5),
  );
}

showEditCancelDialog({Color okButtonColor = sheepsColorGreen, int numberOfBack = 1}) {
  return showSheepsCustomDialog(
    title: Text(
      '작성을\n취소하시겠어요?',
      style: SheepsTextStyle.h1(),
      textAlign: TextAlign.center,
    ),
    contents: Text('확인을 누르시면 작성한 내용이 모두 삭제되고\n이전 페이지로 이동합니다.', style: SheepsTextStyle.b3(), textAlign: TextAlign.center),
    okFunc: () {
      Get.back();
      for (int i = 0; i < numberOfBack; i++) {
        Get.back();
      }
    },
    okButtonColor: okButtonColor,
    isCancelButton: true,
  );
}

Widget multiLineTextField({
  int? maxTextLength,
  TextEditingController? controller,
  String? hintText,
  String? errorText,
  Function? onChange,
  Color borderColor = sheepsColorGreen,
  bool isOneLine = false,
  TextStyle? errorTextStyle,
}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: SheepsTextStyle.hint4Profile(),
      errorText: errorText,
      errorStyle: errorTextStyle == null ? SheepsTextStyle.error() : errorTextStyle,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit, vertical: 8 * sizeUnit),
      counterStyle: SheepsTextStyle.s3(),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: sheepsColorRed, width: 1 * sizeUnit),
        borderRadius: BorderRadius.circular(16 * sizeUnit),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: sheepsColorRed, width: 1 * sizeUnit),
        borderRadius: BorderRadius.circular(16 * sizeUnit),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: 1 * sizeUnit),
        borderRadius: BorderRadius.circular(16 * sizeUnit),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
            color: controller == null
                ? sheepsColorGrey
                : controller.text.length > 0
                    ? borderColor
                    : sheepsColorGrey,
            width: 1 * sizeUnit),
        borderRadius: BorderRadius.circular(16 * sizeUnit),
      ),
      //constraints: BoxConstraints(minHeight: 32 * sizeUnit),
    ),
    textInputAction: isOneLine ? TextInputAction.done : TextInputAction.newline,
    style: SheepsTextStyle.b3().copyWith(height: 16 / 12),
    minLines: 1,
    maxLines: isOneLine ? 1 : 100,
    maxLength: maxTextLength,
    onChanged: onChange == null ? null : (value) => onChange(value),
  );
}

//프로필 위 아래 그라데이션
Widget gradationBox() {
  return Container(
    width: 360 * sizeUnit,
    height: 360 * sizeUnit,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromRGBO(0, 0, 0, 0.2),
          Color.fromRGBO(0, 0, 0, 0.08),
          Color.fromRGBO(0, 0, 0, 0),
          Color.fromRGBO(0, 0, 0, 0),
          Color.fromRGBO(0, 0, 0, 0),
          Color.fromRGBO(0, 0, 0, 0),
          Color.fromRGBO(0, 0, 0, 0),
          Color.fromRGBO(0, 0, 0, 0),
          Color.fromRGBO(0, 0, 0, 0),
          Color.fromRGBO(0, 0, 0, 0),
          Color.fromRGBO(0, 0, 0, 0),
          Color.fromRGBO(0, 0, 0, 0),
          Color.fromRGBO(0, 0, 0, 0),
          Color.fromRGBO(0, 0, 0, 0.03),
          Color.fromRGBO(0, 0, 0, 0.08)
        ],
      ),
    ),
  );
}

Widget noSearchResultsPage(String? descriptionText) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SvgPicture.asset(svgGreySheepEyeX, width: 120 * sizeUnit, height: 88 * sizeUnit, color: sheepsColorLightGrey),
      SizedBox(height: 20 * sizeUnit),
      Center(
          child: Text(
        descriptionText == null ? '검색한 결과가 없습니다.\n다른 방법으로 다시 시도해 보세요!' : descriptionText,
        style: SheepsTextStyle.b4(),
        textAlign: TextAlign.center,
      )),
    ],
  );
}

Widget pickDateContainer({required String text, Color color = sheepsColorGreen, bool isNeedDay = false}) {
  return Container(
    height: 32 * sizeUnit,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: text.isNotEmpty ? color : sheepsColorGrey, width: 1 * sizeUnit),
      borderRadius: BorderRadius.circular(16 * sizeUnit),
    ),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit),
            child: Text(
              text.isNotEmpty
                  ? text
                  : isNeedDay
                      ? '년.월.일'
                      : 'YYYY.MM',
              style: SheepsTextStyle.hint4Profile().copyWith(color: text.isNotEmpty ? color : sheepsColorGrey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget dragAndDropList({
  required List list,
  required int id, //같은 페이지 내 다른 드래그 리스트랑 구별
}) {
  Widget authItem(String contents, int auth) {
    return Row(
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: 260 * sizeUnit),
          child: Text(
            cutAuthInfo(contents),
            style: SheepsTextStyle.b3(),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 4 * sizeUnit),
        SvgPicture.asset(
          auth == 0 ? svgIInCircle : svgCheckInCircle,
          width: 20 * sizeUnit,
          height: 20 * sizeUnit,
          color: auth == 0
              ? sheepsColorRed
              : auth == 1
                  ? sheepsColorBlue
                  : sheepsColorGrey,
        ),
      ],
    );
  }

  Widget GreyBorderContainer({String? icon, required Color iconColor, Function? tapIcon, required Widget child}) {
    return Container(
      width: 328 * sizeUnit,
      height: 32 * sizeUnit,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: sheepsColorGrey, width: 1 * sizeUnit),
        borderRadius: BorderRadius.circular(16 * sizeUnit),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            SizedBox(width: 5 * sizeUnit),
            GestureDetector(
              onTap: tapIcon == null ? () {} : () => tapIcon(),
              child: SvgPicture.asset(
                icon,
                width: 22 * sizeUnit,
                height: 22 * sizeUnit,
                color: iconColor,
              ),
            ),
            SizedBox(width: 4 * sizeUnit),
          ] else ...[
            SizedBox(width: 12 * sizeUnit),
          ],
          child,
        ],
      ),
    );
  }

  const int idUnit = 10000;

  return ListView.builder(
    physics: NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemCount: list.length + 1,
    itemBuilder: (context, index) {
      double blankSize = 0;
      if (index == list.length) {
        blankSize = 15 * sizeUnit;
        return DragTarget<int>(
          builder: (context, inputIndex, l) {
            return AnimatedContainer(duration: Duration(milliseconds: 100), height: blankSize);
          },
          onWillAccept: (data) {
            int tmp = data!;
            int dataId = 0;
            do {
              tmp = tmp - idUnit;
              dataId++;
            } while (tmp >= idUnit);

            if (dataId == id) {
              blankSize = 40 * sizeUnit;
              return true;
            } else {
              return false;
            }
          },
          onLeave: (data) {
            blankSize = 15 * sizeUnit;
          },
          onAccept: (data) {
            blankSize = 15 * sizeUnit;
            int tmp = data;
            int dataId = 0;
            do {
              tmp = tmp - idUnit;
              dataId++;
            } while (tmp >= idUnit);
            if (dataId == id) {
              int inIndex = data - (idUnit * id);
              if (index != inIndex) {
                blankSize = 40 * sizeUnit;
              }
              var tmp = list[inIndex];
              list.removeAt(inIndex);
              list.insert(index - 1, tmp);
            }
          },
        );
      }
      return Draggable(
        data: 10000 * id + index, //id를 1만 곱해서 인덱스랑 더함
        child: Padding(
          padding: EdgeInsets.only(top: index == 0 ? 0 : 8 * sizeUnit),
          child: DragTarget<int>(
            builder: (context, inputIndex, l) {
              return Column(
                children: [
                  AnimatedContainer(duration: Duration(milliseconds: 100), height: blankSize),
                  GreyBorderContainer(
                    icon: svgMinusInCircle,
                    iconColor: sheepsColorRed,
                    tapIcon: () {
                      list.removeAt(index);
                    },
                    child: authItem(list[index].contents, list[index].auth),
                  ),
                ],
              );
            },
            onWillAccept: (data) {
              int tmp = data!;
              int dataId = 0;
              do {
                tmp = tmp - idUnit;
                dataId++;
              } while (tmp >= idUnit);
              if (dataId == id) {
                blankSize = 40 * sizeUnit;
                return true;
              } else {
                return false;
              }
            },
            onLeave: (data) {
              blankSize = 0;
            },
            onAccept: (data) {
              blankSize = 0;
              int tmp = data;
              int dataId = 0;
              do {
                tmp = tmp - idUnit;
                dataId++;
              } while (tmp >= idUnit);
              if (dataId == id) {
                int inIndex = data - (idUnit * id);
                if (index != inIndex) {
                  blankSize = 40 * sizeUnit;
                }
                var tmp = list[inIndex];
                list.removeAt(inIndex);
                if (inIndex > index) {
                  list.insert(index, tmp);
                } else {
                  list.insert(index - 1, tmp);
                }
              }
            },
          ),
        ),
        feedback: DefaultTextStyle(
          style: TextStyle(decoration: TextDecoration.none),
          child: GreyBorderContainer(
            icon: svgMinusInCircle,
            iconColor: sheepsColorRed,
            child: authItem(list[index].contents, list[index].auth),
          ),
        ),
        childWhenDragging: SizedBox.shrink(),
      );
    },
  );
}

Widget sheepsSelectContainer({required String text, required bool isSelected, Color color = sheepsColorGreen}) {
  return Container(
    height: 32 * sizeUnit,
    decoration: BoxDecoration(
      color: isSelected ? color : Colors.white,
      border: Border.all(color: isSelected ? color : sheepsColorGrey, width: 1 * sizeUnit),
      borderRadius: BorderRadius.circular(16 * sizeUnit),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10 * sizeUnit),
          child: Text(
            text,
            style: SheepsTextStyle.hint4Profile().copyWith(color: isSelected ? Colors.white : sheepsColorGrey),
          ),
        ),
      ],
    ),
  );
}

Widget multipleSelectionWrap({required List<String> inputList, required List selectedList, required int maxSelect, bool isCanSelectAll = false, Color color = sheepsColorGreen}) {
  return Wrap(
    spacing: 10 * sizeUnit,
    runSpacing: 10 * sizeUnit,
    children: inputList.map((String text) {
      int _maxSelect = isCanSelectAll ? inputList.length : maxSelect;
      return GestureDetector(
        onTap: () {
          bool isRemove = false;
          for (int i = 0; i < selectedList.length; i++) {
            if (text == selectedList[i]) {
              selectedList.removeAt(i);
              isRemove = true;
              break;
            }
          }
          if (selectedList.length < _maxSelect && !isRemove) {
            selectedList.add(text);
          }
        },
        child: Obx(() {
          bool isSelected = false;
          for (int i = 0; i < selectedList.length; i++) {
            if (text == selectedList[i]) {
              isSelected = true;
            }
          }
          return sheepsSelectContainer(text: text, isSelected: isSelected, color: color);
        }),
      );
    }).toList(),
  );
}

Widget sheepsCheckBox(String text, bool isCheck, {Color color = sheepsColorGreen}) {
  return Container(
    color: Colors.white,
    child: Row(
      children: [
        Container(
          width: 16 * sizeUnit,
          height: 16 * sizeUnit,
          decoration: BoxDecoration(
            border: Border.all(color: isCheck ? color : sheepsColorGrey, width: 1 * sizeUnit),
            borderRadius: BorderRadius.circular(4 * sizeUnit),
          ),
          child: Center(
            child: SvgPicture.asset(
              svgCheck,
              width: 8 * sizeUnit,
              color: isCheck ? color : Colors.transparent,
            ),
          ),
        ),
        SizedBox(width: 8 * sizeUnit),
        Text(
          text,
          style: SheepsTextStyle.hint4Profile().copyWith(color: isCheck ? color : sheepsColorGrey),
        ),
      ],
    ),
  );
}

Widget authItem(String contents, int auth, {Color iconColor = sheepsColorGreen}) {
  return Container(
    color: Colors.white,
    child: Row(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '・ ',
              style: SheepsTextStyle.b3(),
            ),
            Container(
              constraints: BoxConstraints(maxWidth: 280 * sizeUnit),
              child: Text(
                cutAuthInfo(contents),
                style: SheepsTextStyle.b3(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(width: 4 * sizeUnit),
        SvgPicture.asset(
          svgCheckInCircle,
          width: 20 * sizeUnit,
          height: 20 * sizeUnit,
          color: auth == 1 ? iconColor : sheepsColorGrey,
        ),
      ],
    ),
  );
}

Widget linkItem({
  required String title,
  required String linkUrl,
  Color color = sheepsColorBlue,
}) {
  return GestureDetector(
    onTap: () => launch('https://' + linkUrl),
    child: Container(
      height: 32 * sizeUnit,
      decoration: BoxDecoration(
        color: linkUrl.isNotEmpty ? color : Colors.white,
        border: Border.all(color: linkUrl.isNotEmpty ? Colors.transparent : sheepsColorGrey, width: 1 * sizeUnit),
        borderRadius: BorderRadius.circular(16 * sizeUnit),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10 * sizeUnit),
            child: Text(
              title,
              style: SheepsTextStyle.b3().copyWith(color: linkUrl.isNotEmpty ? Colors.white : sheepsColorGrey),
            ),
          ),
        ],
      ),
    ),
  );
}

Text replyExceptionText({bool isBlind = false, bool isReply = true, bool bigFont = false}) {
  String replyState = isReply ? '댓글' : '답글';

  return Text.rich(
    TextSpan(
      style: bigFont ? SheepsTextStyle.badgeTitle().copyWith(color: sheepsColorDarkGrey) : SheepsTextStyle.b3().copyWith(height: 14 / 12, color: sheepsColorDarkGrey),
      children: [
        if (!isBlind)
          TextSpan(
              text: '삭제', style: bigFont ? SheepsTextStyle.badgeTitle().copyWith(color: sheepsColorRed) : SheepsTextStyle.b3().copyWith(height: 14 / 12, color: sheepsColorRed)),
        if (isBlind)
          TextSpan(
              text: '신고 누적으로 블라인드',
              style: bigFont ? SheepsTextStyle.badgeTitle().copyWith(color: sheepsColorRed) : SheepsTextStyle.b3().copyWith(height: 14 / 12, color: sheepsColorRed)),
        TextSpan(text: '된 $replyState 입니다.'),
      ],
    ),
  );
}

Text communityExceptionText({bool bigFont = false}) {
  return Text.rich(
    TextSpan(
      style: bigFont ? SheepsTextStyle.h3() : SheepsTextStyle.info2().copyWith(height: 1.4),
      children: [
        TextSpan(
            text: '신고 누적으로 블라인드', style: bigFont ? SheepsTextStyle.h3().copyWith(color: sheepsColorRed) : SheepsTextStyle.info2().copyWith(height: 1.4, color: sheepsColorRed)),
        TextSpan(text: '된 글 입니다.'),
      ],
    ),
  );
}

bool blindCheck({required declareLength, required likeLength}) {
  bool result = false;

  if (declareLength >= minimumDeclareForBlind && declareLength > likeLength) result = true;
  return result;
}

// 리쿠르트 포스트 카드
Widget sheepsRecruitPostCard({required bool isRecruit, required Function dataSetFunc, required Function press, required RecruitController controller}) {
  dataSetFunc(); // 포스트 카드 데이터 set

  return GestureDetector(
    onTap: () => press(),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      width: 360 * sizeUnit,
      height: 132 * sizeUnit,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: sheepsColorGrey, width: 0.5))),
      child: Row(
        children: [
          Container(
            width: 100 * sizeUnit,
            height: 100 * sizeUnit,
            decoration: BoxDecoration(
              border: Border.all(color: sheepsColorGrey, width: 0.5),
              borderRadius: BorderRadius.circular(16 * sizeUnit),
            ),
            child: Hero(
              tag: isRecruit ? 'teamMemberRecruit${controller.id}' : 'personalSeekTeam${controller.id}',
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 60 * sizeUnit,
                    child: SvgPicture.asset(
                      svgSheepsBasicProfileImage,
                      width: 60 * sizeUnit,
                      color: isRecruit ? sheepsColorGreen : sheepsColorBlue,
                    ),
                  ),
                  if (controller.photoURL != 'BasicImage') ...[
                    Container(
                      width: 100 * sizeUnit,
                      height: 100 * sizeUnit,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16 * sizeUnit),
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                            image: getOptimizeImageURL(controller.photoURL, 60),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (controller.isLike) ...[
                    Positioned(
                      top: 4 * sizeUnit,
                      right: 4 * sizeUnit,
                      child: SvgPicture.asset(
                        svgFillBookMarkIcon,
                        width: 28 * sizeUnit,
                        color: isRecruit ? sheepsColorBlue : sheepsColorGreen,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(width: 20 * sizeUnit),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(controller.name, style: SheepsTextStyle.h3()),
                    Text(
                      controller.state,
                      style: SheepsTextStyle.bWriter().copyWith(
                        color: isRecruit
                            ? controller.state == '모집마감'
                                ? sheepsColorGrey
                                : sheepsColorGreen
                            : controller.state == '구직중'
                                ? sheepsColorBlue
                                : sheepsColorGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4 * sizeUnit),
                Wrap(
                  runSpacing: 4 * sizeUnit,
                  spacing: 4 * sizeUnit,
                  children: [
                    if (controller.firstWrapList[0].isNotEmpty) recruitWrapItem(controller.firstWrapList[0], isRecruit: isRecruit, isColor: !isRecruit),
                    if (controller.firstWrapList[1].isNotEmpty) recruitWrapItem(controller.firstWrapList[1]),
                    if (controller.firstWrapList[2].isNotEmpty) recruitWrapItem(controller.firstWrapList[2]),
                  ],
                ),
                SizedBox(height: 6 * sizeUnit),
                Text(
                  controller.title,
                  style: SheepsTextStyle.b3().copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6 * sizeUnit),
                Wrap(
                  runSpacing: 4 * sizeUnit,
                  spacing: 4 * sizeUnit,
                  children: [
                    if (controller.secondWrapList[0].isNotEmpty) recruitWrapItem(controller.secondWrapList[0], isRecruit: isRecruit, isColor: isRecruit),
                    if (controller.secondWrapList[1].isNotEmpty) recruitWrapItem(controller.secondWrapList[1]),
                    if (controller.secondWrapList[2].isNotEmpty) recruitWrapItem(controller.secondWrapList[2]),
                    if (controller.secondWrapList[3].isNotEmpty) recruitWrapItem(controller.secondWrapList[3]),
                    if (controller.secondWrapList[4].isNotEmpty) recruitWrapItem(controller.secondWrapList[4]),
                    if (isRecruit) ...[
                      if (controller.secondWrapList[5].isNotEmpty) recruitWrapItem(controller.secondWrapList[5]),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Container recruitWrapItem(String text, {bool isRecruit = true, bool isColor = false}) {
  return Container(
    height: 16 * sizeUnit,
    padding: EdgeInsets.symmetric(horizontal: 4 * sizeUnit),
    decoration: BoxDecoration(
      color: isColor
          ? isRecruit
              ? sheepsColorGreen
              : sheepsColorBlue
          : sheepsColorLightGrey,
      borderRadius: BorderRadius.circular(6 * sizeUnit),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: SheepsTextStyle.bWriter().copyWith(color: isColor ? Colors.white : sheepsColorBlack),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

// 새로고침 위젯
Widget sheepsCustomRefreshIndicator({required Widget child, required Future<void> onRefresh(), Color indicatorColor = sheepsColorGreen}) {
  return CustomRefreshIndicator(
    onRefresh: () async {
      await onRefresh();
      return Future.delayed(const Duration(milliseconds: 500));
    },
    builder: (
      BuildContext context,
      Widget child,
      IndicatorController indicatorController,
    ) {
      return AnimatedBuilder(
        animation: indicatorController,
        builder: (BuildContext context, _) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
// !indicatorController.isDragging && !indicatorController.isHiding && !indicatorController.isIdle
              !indicatorController.isDragging && !indicatorController.isIdle
                  ? Positioned(
                      top: 18 * sizeUnit * indicatorController.value,
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
                        ),
                      ),
                    )
                  : Container(),
              Transform.translate(
                offset: Offset(0, 55 * sizeUnit * indicatorController.value),
                child: Container(
                  color: Colors.white,
                  child: child,
                ),
              ),
            ],
          );
        },
      );
    },
    child: child,
  );
}

Widget customShapeButton({required Function press, required String text, Color color = Colors.black}) {
  return GestureDetector(
    onTap: () => press(),
    child: Container(
      height: 32 * sizeUnit,
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 8 * sizeUnit),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * sizeUnit),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            blurRadius: 1,
          ),
        ],
      ),
      child: Text(text, style: SheepsTextStyle.b3().copyWith(color: color)),
    ),
  );
}

Widget communityPostCard(
    {required Community community, bool lastAddedPost = false, required bool likeCheckFunc, required Map<String, dynamic> typeCheck, required Function press}) {
  UserData user = GlobalProfile.getUserByUserID(community.userID); // 유저정보 가져오기
  bool isLike = likeCheckFunc; // 좋아요 여부 체크
  Map<String, dynamic> communityType = typeCheck; // 타입 체크

  return GestureDetector(
    onTap: () => press(),
    child: Container(
      padding: EdgeInsets.all(16 * sizeUnit),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: sheepsColorLightGrey, width: lastAddedPost ? 4 * sizeUnit : 1 * sizeUnit),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    profileSmallWrapItem(communityType['category'], color: communityType['color']),
                    SizedBox(width: 8 * sizeUnit),
                    Expanded(
                      child: blindCheck(declareLength: community.declareLength, likeLength: community.communityLike.length)
                          ? Container()
                          : Text(
                              community.title,
                              style: SheepsTextStyle.h4(),
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  ],
                ),
                SizedBox(height: 8 * sizeUnit),
                SizedBox(
                  height: 28 * sizeUnit,
                  child: blindCheck(declareLength: community.declareLength, likeLength: community.communityLike.length)
                      ? communityExceptionText()
                      : Text(
                          community.contents,
                          style: SheepsTextStyle.info2().copyWith(height: 1.4),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                SizedBox(height: 8 * sizeUnit),
                Row(
                  children: [
                    Text(community.category == '비밀' ? '익명' : user.name,
                        style: SheepsTextStyle.bWriter()
                            .copyWith(color: community.category == '비밀' && community.userID == GlobalProfile.loggedInUser.userID ? sheepsColorGreen : sheepsColorBlack)),
                    SizedBox(width: 12 * sizeUnit),
                    Text(timeCheck(community.updatedAt), style: SheepsTextStyle.bWriteDate()),
                    SizedBox(width: 12 * sizeUnit),
                    SvgPicture.asset(
                      'assets/images/Community/like.svg',
                      width: 12 * sizeUnit,
                      height: 12 * sizeUnit,
                      color: isLike ? sheepsColorGreen : sheepsColorDarkGrey,
                    ),
                    SizedBox(width: 2 * sizeUnit),
                    Text(
                      community.communityLike.length > 99 ? '99+' : community.communityLike.length.toString(),
                      style: SheepsTextStyle.bWriter().copyWith(color: isLike ? sheepsColorGreen : sheepsColorDarkGrey),
                    ),
                    SizedBox(width: 6 * sizeUnit),
                    SvgPicture.asset(
                      'assets/images/Community/comment.svg',
                      width: 12 * sizeUnit,
                      height: 12 * sizeUnit,
                    ),
                    SizedBox(width: 2 * sizeUnit),
                    Text(
                      community.repliesLength > 99 ? '99+' : community.repliesLength.toString(),
                      style: SheepsTextStyle.bWriter().copyWith(color: sheepsColorDarkGrey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!blindCheck(declareLength: community.declareLength, likeLength: community.communityLike.length))
            if (community.imageUrl1 != null) buildCommunityProfileImg(community),
        ],
      ),
    ),
  );
}

Container buildCommunityProfileImg(Community community) {
  return Container(
    width: 72 * sizeUnit,
    height: 72 * sizeUnit,
    margin: EdgeInsets.only(left: 20 * sizeUnit),
    decoration: BoxDecoration(
      border: Border.all(width: 0.5 * sizeUnit, color: sheepsColorGrey),
      borderRadius: BorderRadius.circular(12 * sizeUnit),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        SvgPicture.asset(
          svgSheepsBasicProfileImage,
          width: 40 * sizeUnit,
        ),
        Container(
          width: 72 * sizeUnit,
          height: 72 * sizeUnit,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12 * sizeUnit),
            child: community.imageUrl1 == null
                ? const SizedBox.shrink()
                : FittedBox(
                    fit: BoxFit.cover,
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: getOptimizeImageURL(community.imageUrl1!, 60),
                    ),
                  ),
          ),
        ),
      ],
    ),
  );
}

// 새로운 팀을 만들고 싶으신가요? 위젯
Widget createTeamCard({required Function press, bool shortCard = false}) {
  return GestureDetector(
    onTap: () => press(),
    child: Stack(
      children: [
        Positioned(
// bottom: 68 * sizeUnit,
          bottom: shortCard ? 68 * sizeUnit : 148 * sizeUnit,
          right: 20 * sizeUnit,
          child: SvgPicture.asset(
            svgArrowInCircle,
            width: 30 * sizeUnit,
            height: 30 * sizeUnit,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20 * sizeUnit, vertical: 20 * sizeUnit),
          margin: EdgeInsets.all(5 * sizeUnit),
          width: 156 * sizeUnit,
          height: 156 * sizeUnit,
          decoration: BoxDecoration(
            color: Color.fromRGBO(97, 198, 128, 0.05),
            borderRadius: BorderRadius.circular(28 * sizeUnit),
          ),
          child: Text.rich(
            TextSpan(
              style: SheepsTextStyle.h3().copyWith(height: 22 / 16),
              children: [
                TextSpan(text: '새로운 팀', style: TextStyle(color: sheepsColorGreen)),
                TextSpan(text: '을\n만들고\n싶으신가요?'),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Future<dynamic> fullTeamDialog(int leaderTeamLength) {
  return showSheepsCustomDialog(
    title: Text(
      '이미 팀이\n$leaderTeamLength개가 있어요!',
      style: SheepsTextStyle.h5(),
      textAlign: TextAlign.center,
    ),
    contents: Text(
      '현재 원활한 서비스를 위해\n최대 $MAX_CREATE_TEAM_LENGTH개의 팀까지만 생성할 수 있어요.',
      style: SheepsTextStyle.b3(),
      textAlign: TextAlign.center,
    ),
    okText: '확인',
    okButtonColor: sheepsColorGreen,
    okFunc: () => Get.back(),
  );
}

// 바텀 버튼 그림자
BoxShadow bottomButtonBoxShadow() {
  return BoxShadow(
    offset: Offset(2, -3),
    blurRadius: 2,
    color: Color.fromRGBO(0, 0, 0, 0.22),
  );
}
