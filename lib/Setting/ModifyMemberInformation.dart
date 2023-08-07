import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '';
import 'package:sheeps_app/Recruit/Controller/FilterController.dart';
import 'package:sheeps_app/Recruit/Controller/RecruitController.dart';
import 'package:sheeps_app/chat/models/ChatDatabase.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/notification/models/NotiDatabase.dart';
import 'package:sheeps_app/profile/models/FilterState.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';

class ModifyMemberInformation extends StatefulWidget {
  @override
  _ModifyMemberInformationState createState() => _ModifyMemberInformationState();
}

class _ModifyMemberInformationState extends State<ModifyMemberInformation> {
  final controllerForExistingPassword = TextEditingController();
  final passwordTextField = TextEditingController();
  final passwordCheckTextField = TextEditingController();

  ScrollController passwordScrollController;

  int loginType;
  String strLoginType = '';
  String loginEmail = '';

  bool isCheckPassword = false;

  bool isReady = true;

  @override
  void initState() {
    super.initState();
    loginEmail = GlobalProfile.loggedInUser.id;
    loginType = GlobalProfile.loggedInUser.loginType;
    passwordScrollController = ScrollController(initialScrollOffset: 0.0); //flutter 제공
    switch (loginType) {
      case 1:
        strLoginType = 'Google';
        break;
      case 2:
        strLoginType = 'Apple';
        break;
      case 3:
        strLoginType = 'Kakao';
        break;
      default:
        strLoginType = '이메일';
        break;
    }
  }


  @override
  void dispose() {
    controllerForExistingPassword.dispose();
    passwordTextField.dispose();
    passwordCheckTextField.dispose();

    passwordScrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: null,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: GestureDetector(
                onTap: () {
                  unFocus(context);
                },
                child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: SheepsAppBar(context, '비밀번호 변경'),
                  body: Padding(
                    padding: EdgeInsets.fromLTRB(20 * sizeUnit, 0, 20 * sizeUnit, 0),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            controller: passwordScrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [SizedBox(height: 8 * sizeUnit)]),
                                Row(
                                  children: [
                                    Text(
                                      '로그인 유형 : ',
                                      style: SheepsTextStyle.h3(),
                                    ),
                                    Text(
                                      strLoginType,
                                      style: SheepsTextStyle.h3(),
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () async {

                                        var res = await ApiProvider().post('/Team/Check/LeaderTeam', jsonEncode({
                                          "userID" : GlobalProfile.loggedInUser.userID
                                        }));

                                        if(res != null){
                                          //팀장인 팀이 없으면
                                          if(res == true){
                                            Function cancelFunc = () async {
                                              await ApiProvider().post('/Personal/Exit/Member', jsonEncode({
                                                "userID" : GlobalProfile.loggedInUser.userID,
                                                "userName" : GlobalProfile.loggedInUser.name,
                                              }));

                                              Get.back();
                                              FilterController filterController = Get.put(FilterController());
                                              FilterStateForPersonal filterStateForPersonal = Get.put(FilterStateForPersonal());
                                              RecruitController recruitController = Get.put(RecruitController());

                                              filterController.recruitLogoutEvent(); // 리쿠르트 로그아웃 이벤트
                                              filterStateForPersonal.profileFilterLogoutEvent(); // 프로필 필터 로그아웃 이벤트
                                              SocketProvider socket = SocketProvider.to;

                                              ChatDBHelper().dropTable();
                                              NotiDBHelper().dropTable();

                                              Fluttertoast.showToast(msg: '회원 탈퇴가 정상적으로 되었습니다.', toastLength: Toast.LENGTH_SHORT);

                                              await globalLogout(true,socket);
                                            };

                                            showSheepsDialog(
                                              context: context,
                                              title: '탈퇴 하시겠어요?',
                                              description: '탈퇴 하실 경우 모든 정보가 삭제 됩니다.\n\n• 전문가와 함께 문제를 \n해결할 수 있는 "전문가 서비스"\n• 다양한 창업 노하우 컨텐츠\n• 지금도 생성되는 창업자들의 커뮤니티\n\n이외에도 창업에 도움되는 기능과\n컨텐츠들이 업데이트 될 예정이예요.\n그래도 탈퇴하시겠어요?',
                                              okText: '더 활동할래요!',
                                              cancelText: '탈퇴하기',
                                              cancelFunc: cancelFunc
                                            );
                                          }else{
                                            showSheepsDialog(
                                                context: context,
                                                title: '팀이 있으시네요!',
                                                description: '팀장인 팀이 있는 경우,\n탈퇴하기는 불가능해요',
                                                okText: '확인',
                                                isCancelButton: false
                                            );
                                          }
                                        }
                                      },
                                      child: Text(
                                        "회원탈퇴",
                                        style: SheepsTextStyle.b4(),
                                      ),
                                    )
                                  ],
                                ),
                                loginType == null ? SizedBox(height: 20 * sizeUnit) : SizedBox.shrink(),
                                loginType == null
                                    ? Text(
                                  '로그인 이메일 : ' + GlobalProfile.loggedInUser.id,
                                  style: SheepsTextStyle.h3(),
                                )
                                    : SizedBox.shrink(),
                                SizedBox(height: 40 * sizeUnit),
                                sheepsTextField(
                                  context,
                                  title: '기존 비밀번호',
                                  controller: controllerForExistingPassword,
                                  hintText: '기존 비밀번호를 입력하세요.',
                                  obscureText: true,
                                  onChanged: (val) {
                                    setState(() {});
                                  },
                                ),
                                SizedBox(height: 40 * sizeUnit),
                                sheepsTextField(
                                  context,
                                  title: '비밀번호',
                                  controller: passwordTextField,
                                  hintText: '8자 이상 입력해주세요.',
                                  errorText: validPasswordErrorText(passwordTextField.text) == 'empty' ? null : validPasswordErrorText(passwordTextField.text),
                                  obscureText: true,
                                  onChanged: (val) {
                                    validPasswordErrorText(passwordTextField.text) == null &&
                                        validPasswordConfirmErrorText(passwordTextField.text, passwordCheckTextField.text) == null
                                        ? isCheckPassword = true
                                        : isCheckPassword = false;
                                    setState(() {

                                      if(isCheckPassword == false){
                                        if (passwordScrollController.hasClients) {
                                          passwordScrollController.jumpTo(
                                            passwordScrollController.position.maxScrollExtent,
                                          );
                                        }
                                      }
                                    });
                                  },
                                  onPressClear: () {
                                    passwordTextField.clear();
                                    isCheckPassword = false;
                                    setState(() {});
                                  },
                                ),
                                SizedBox(height: 20*sizeUnit),
                                sheepsTextField(
                                  context,
                                  title: '비밀번호 확인',
                                  controller: passwordCheckTextField,
                                  hintText: '비밀번호를 한 번 더 입력해주세요.',
                                  errorText: validPasswordConfirmErrorText(passwordTextField.text, passwordCheckTextField.text),
                                  obscureText: true,
                                  onChanged: (val) {
                                    validPasswordErrorText(passwordTextField.text) == null &&
                                        validPasswordConfirmErrorText(passwordTextField.text, passwordCheckTextField.text) == null
                                        ? isCheckPassword = true
                                        : isCheckPassword = false;
                                    setState(() {
                                      if(isCheckPassword == false){
                                        if (passwordScrollController.hasClients) {
                                          passwordScrollController.jumpTo(
                                            passwordScrollController.position.maxScrollExtent,
                                          );
                                        }
                                      }
                                    });
                                  },
                                  onPressClear: () {
                                    passwordCheckTextField.clear();
                                    isCheckPassword = false;
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20 * sizeUnit),
                          child: SheepsBottomButton(
                            context: context,
                            function: () async {
                              unFocus(context);
                              if(isReady){
                                isReady = false;
                                Future.delayed(Duration(milliseconds: 500),()=>isReady = true);

                                if (isCheckPassword && (controllerForExistingPassword.text != null && controllerForExistingPassword.text != "")) {
                                  var res = await ApiProvider().post('/Personal/Select/ChangePassword',
                                      jsonEncode({"userID": GlobalProfile.loggedInUser.userID, "password": controllerForExistingPassword.text, "newpassword": passwordTextField.text}));

                                  if (res['res'] == "HAVENT_PASSWORD") {
                                    showSheepsToast(context: context, text: '소셜로 가입된 아이디입니다.\n비밀번호 변경이 불가능합니다.');
                                    controllerForExistingPassword.text = '';
                                    passwordTextField.text = '';
                                    passwordCheckTextField.text = '';
                                  } else if (res['res'] == "NOT_RIGHT") {
                                    showSheepsToast(context: context, text: '기존 비밀번호가 일치하지 않습니다.\n확인 후 다시 시도 해주세요.');
                                    controllerForExistingPassword.text = '';
                                  } else {
                                    showSheepsToast(context: context, text: '비밀번호 변경이 완료되었습니다.');
                                    controllerForExistingPassword.text = '';
                                    passwordTextField.text = '';
                                    passwordCheckTextField.text = '';
                                  }
                                }
                              }
                            },
                            text: '수정 완료',
                            isOK: isCheckPassword && controllerForExistingPassword.text.isNotEmpty,
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
      ),
    );
  }
}
