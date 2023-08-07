
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';


import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/registration/LoginSelectPage.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static DateTime currentBackPressTime;

  _isEnd() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      showSheepsToast(context: context, text: '뒤로 가기를 한 번 더 입력하시면 종료됩니다.');
      return false;
    }
    return true;
  }

  int currentPage = 0;

  List<BoardContents> listBoardContents = [];

  AnimatedContainer buildDot({int index}) {
    return AnimatedContainer(
      duration: kAnimationDuration,
      margin: EdgeInsets.only(right: 4 * sizeUnit),
      height: 8 * sizeUnit,
      width: currentPage == index ? 24 * sizeUnit : 8 * sizeUnit,
      decoration: BoxDecoration(
        color: currentPage == index ? sheepsColorGreen : sheepsColorLightGrey,
        borderRadius: BorderRadius.circular(4 * sizeUnit),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    listBoardContents = [
      BoardContents(
        icon: 'assets/images/LoginReg/BoardRocket.svg',
        title1: '쉽스에 모여있는',
        title2: '미래의 유니콘들',
        contents: [
          TextSpan(text: '쉽스는 '),
          TextSpan(
            text: '쉽지않은 스타트업',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: '의 줄임말이에요.\n'),
          TextSpan(text: '예비・초기 스타트업에서 필요한\n'),
          TextSpan(
            text: '모든 것들을 준비했어요!\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: '다음으로 넘겨보세요 👉🏼'),
        ],
      ),
      BoardContents(
        icon: 'assets/images/LoginReg/BoardProfile.svg',
        title1: '프로필로 만나는',
        title2: '팀원들과 전문가',
        contents: [
          TextSpan(text: '마음에 드는 프로필과 '),
          TextSpan(
            text: '자유롭게 대화하세요.\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: '열정 넘치는 멋진 사람들이 아주 많답니다!\n'),
          TextSpan(text: '법률・세무・특허 등 전문가분들도 있어요 💼'),
        ],
      ),
      BoardContents(
        icon: 'assets/images/LoginReg/BoardTeam.svg',
        title1: '팀원을 가장',
        title2: '빠르게 모집',
        title3: '하는 방법',
        contents: [
          TextSpan(text: '프로필을 뒤적이고, '),
          TextSpan(
            text: '초대를 쓱 💌\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: '초대 리스트에서, '),
          TextSpan(
            text: '선택을 싹 ✅',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      BoardContents(
        icon: 'assets/images/LoginReg/BoardCommunity.svg',
        title1: '일반 회사와 다른,',
        title2: '우리들의 이야기',
        contents: [
          TextSpan(text: '일반, 직군별 카테고리로\n'),
          TextSpan(text: '잡담은 물론 현업 이야기까지!\n'),
          TextSpan(text: '오프라인 네트워킹보다 '),
          TextSpan(
            text: '더 솔직한 공간.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      BoardContents(
        icon: 'assets/images/LoginReg/BoardChat.svg',
        title1: '이 모든 서비스가,',
        title2: '채팅으로 간편',
        title3: '하게',
        contents: [
          TextSpan(text: '이야기를 나눠보고 싶다면,\n'),
          TextSpan(
            text: '무제한으로 채팅',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: '을 보내보세요!'),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return  AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: () async {
          bool result = _isEnd();
          return await Future.value(result);
        },
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Scaffold(
                body: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * sizeUnit),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 430 * sizeUnit,
                        child: Column(
                          children: [
                            Container(
                              height: 288 * sizeUnit,
                              child: PageView.builder(
                                  onPageChanged: (value) {
                                    setState(() {
                                      currentPage = value;
                                    });
                                  },
                                  itemCount: listBoardContents.length,
                                  itemBuilder: (context, index) => ContentsContainer(boardContents: listBoardContents[index]),
                              ),
                            ),
                            Row(
                              children: [
                                SizedBox(height: 60 * sizeUnit),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                listBoardContents.length,
                                    (index) => buildDot(index: index),
                              ),
                            ),
                            SizedBox(height: 20 * sizeUnit),
                            SheepsBottomButton(
                              context: context,
                              function: () {
                                Get.off(() => LoginSelectPage());
                              },
                              text: '시작하기',
                            ),
                          ],
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
    );
  }
}

class ContentsContainer extends StatelessWidget {
  final BoardContents boardContents;

  ContentsContainer({Key key, this.boardContents});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 16*sizeUnit),
            SvgPicture.asset(
              boardContents.icon,
              height: 40 * sizeUnit,
            ),
          ],
        ),
        SizedBox(height: 28 * sizeUnit),
        Text(
          boardContents.title1,
          style: SheepsTextStyle.h1(),
        ),
        Row(
          children: [
            Text(
              boardContents.title2,
              style: SheepsTextStyle.h1().copyWith(backgroundColor: Color.fromRGBO(97, 197, 128, 0.3)),
            ),
            Text(
              boardContents.title3 == null ? '' : boardContents.title3,
              style: SheepsTextStyle.h1(),
            ),
          ],
        ),
        SizedBox(height: 28 * sizeUnit),
        RichText(
          text: TextSpan(
            style: SheepsTextStyle.boardContents(),
            children: boardContents.contents,
          ),
        ),
      ],
    );
  }
}

class BoardContents {
  String icon;
  String title1;
  String title2;
  String title3 = '';
  List<InlineSpan> contents;

  BoardContents({@required this.icon, @required this.title1, @required this.title2, this.title3, @required this.contents});
}
