import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/Community/CommunityMainDetail.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:transparent_image/transparent_image.dart';

Widget SheepsCommunityItem({
  @required BuildContext context,
  @required Community community,
  @required int index,
  @required AnimationController extendedController,
  @required bool isLike,
  @required bool isMorePhoto,
  @required Function tapPhotoFunc,
  @required Function tapLikeFunc,
}) {
  return Container(
    height: 141 * sizeUnit,
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit, vertical: 8 * sizeUnit),
          child: Container(
            height: 124 * sizeUnit,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 18 * sizeUnit,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit, vertical: 1.5 * sizeUnit),
                    child: Text(
                      community.category == null ? "null" : "${community.category}",
                      textAlign: TextAlign.center,
                      style: SheepsTextStyle.cat1(),
                    ),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: new BorderRadius.circular(4 * sizeUnit),
                    color: sheepsColorLightGrey,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8 * sizeUnit),
                  child: GestureDetector(
                    onTap: () async {
                      var tmp = await ApiProvider().post(
                          '/CommunityPost/PostSelect',
                          jsonEncode({
                            "id": community.id,
                          }));

                      if (tmp == null) {
                        showSheepsDialog(
                          context: context,
                          title: '삭제된 게시글입니다.',
                          description: '삭제된 게시물이에요.',
                          isCancelButton: false,
                        );
                        return;
                      }

                      GlobalProfile.communityReply = [];
                      for (int i = 0; i < tmp.length; i++) {
                        Map<String, dynamic> data = tmp[i];
                        CommunityReply tmpReply = CommunityReply.fromJson(data);
                        GlobalProfile.communityReply.add(tmpReply);
                      }

                      Get.to(() => CommunityMainDetail(community));
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 72 * sizeUnit,
                          width: 268 * sizeUnit,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 260 * sizeUnit,
                                height: 16 * sizeUnit,
                                child: Text(
                                  community.title == null ? "null" : '${community.title}',
                                  overflow: TextOverflow.ellipsis,
                                  style: SheepsTextStyle.h4(),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 8 * sizeUnit),
                                child: Container(
                                  width: 260 * sizeUnit,
                                  height: 48 * sizeUnit,
                                  child: Text(
                                    community.contents == null ? "null" : '${community.contents}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                    style: SheepsTextStyle.b4().copyWith(
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Stack(
                          children: [
                            if (community.imageUrl1 != null) ...[
                              Positioned(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 60 * sizeUnit,
                                    height: 60 * sizeUnit,
                                    decoration: BoxDecoration(
                                      color: sheepsColorGrey,
                                      borderRadius: new BorderRadius.circular(8 * sizeUnit),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color.fromRGBO(116, 125, 130, 0.1),
                                          offset: Offset(1 * sizeUnit, 1 * sizeUnit),
                                          blurRadius: 2 * sizeUnit,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                        child: SvgPicture.asset(
                                      svgPersonalProfileBasicImage,
                                      width: 84 * sizeUnit,
                                      height: 84 * sizeUnit,
                                      color: Colors.white,
                                    )),
                                  ),
                                ),
                              ),
                              Positioned(
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width: 60 * sizeUnit,
                                      height: 60 * sizeUnit,
                                      decoration: BoxDecoration(
                                        borderRadius: new BorderRadius.circular(8 * sizeUnit),
                                        boxShadow: [
                                          new BoxShadow(
                                            color: Color.fromRGBO(166, 125, 130, 0.2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: new BorderRadius.circular(8 * sizeUnit),
                                        child: FittedBox(
                                          fit: BoxFit.cover,
                                          child: FadeInImage.memoryNetwork(
                                            placeholder: kTransparentImage,
                                            image: getOptimizeImageURL(community.imageUrl1, 60),
                                          ),
                                        ),
                                      ),
                                    )),
                              ),
                              if (community.imageUrl2 != null) ...[
                                GestureDetector(
                                  onTap: tapPhotoFunc,
                                  child: AnimatedContainer(
                                      duration: Duration(seconds: 1000),
                                      curve: Curves.easeInOut,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(8 * sizeUnit)),
                                            ),
                                            width: 60 * sizeUnit,
                                            height: 60 * sizeUnit,
                                            child: ClipRRect(
                                              borderRadius: new BorderRadius.circular(8 * sizeUnit),
                                              child: AnimatedOpacity(
                                                duration: Duration(milliseconds: 300),
                                                opacity: isMorePhoto ? 0.8 : 0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(8 * sizeUnit)),
                                                    color: Color.fromARGB(204, 0, 0, 0),
                                                  ),
                                                  width: 60 * sizeUnit,
                                                  height: 60 * sizeUnit,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      ClipRRect(
                                                        child: Text(
                                                          community.imageUrl3 == null ? "+1" : "+2",
                                                          style: SheepsTextStyle.h4().copyWith(color: Colors.white),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                )
                              ],
                            ] else ...[
                              SizedBox.shrink()
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12 * sizeUnit),
                  child: Container(
                    width: 336 * sizeUnit,
                    height: 14 * sizeUnit,
                    child: Row(
                      children: [
                        Container(
                          height: 14 * sizeUnit,
                          child: Center(
                            child: Text(
                              community.category == "비밀"
                                  ? "익명"
                                  : GlobalProfile.getUserByUserID(community.userID) == null
                                      ? GlobalProfile.getUserByUserIDAndloggedInUser(community.userID) != null
                                          ? '${GlobalProfile.getUserByUserIDAndloggedInUser(community.userID).name}'
                                          : "null"
                                      : "${GlobalProfile.getUserByUserID(community.userID).name}",
                              style: SheepsTextStyle.bWriter(),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 8 * sizeUnit),
                            child: Container(
                              height: 14 * sizeUnit,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  timeCheck(community.updatedAt),
                                  //'${GlobalProfile.getCommunityByIndex(index).updatedAt}',
                                  style: SheepsTextStyle.bWriteDate(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.transparent,
                            onTap: tapLikeFunc,
                            child: Container(
                              height: 14 * sizeUnit,
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/Community/like.svg',
                                    width: 14 * sizeUnit,
                                    height: 14 * sizeUnit,
                                    color: isLike ? sheepsColorGreen : sheepsColorDarkGrey,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 4 * sizeUnit),
                                    child: Container(
                                      height: 14 * sizeUnit,
                                      child: Center(
                                        child: Text(
                                          community.communityLike.length > 99 ? "99+" : '${community.communityLike.length}',
                                          style: isLike ? SheepsTextStyle.s2() : SheepsTextStyle.s3(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8 * sizeUnit),
                          child: Container(
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/images/Community/comment.svg',
                                  width: 14 * sizeUnit,
                                  height: 14 * sizeUnit,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 4 * sizeUnit),
                                  child: Container(
                                    height: 14 * sizeUnit,
                                    child: Center(
                                      child: Text(
                                        community.repliesLength > 99 ? "99+" : '${community.repliesLength}',
                                        style: SheepsTextStyle.s3(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 1 * sizeUnit,
          color: Color(0xffe5e5e5),
        ),
      ],
    ),
  );
}
