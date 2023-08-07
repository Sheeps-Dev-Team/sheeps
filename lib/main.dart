import 'dart:convert';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk/all.dart';
import 'package:path_provider/path_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:sheeps_app/Community/CommunityMain.dart';
import 'package:sheeps_app/TeamProfileManagement/model/Team.dart';
import 'package:sheeps_app/chat/ChatRoomPage.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/chat/models/ChatRecvMessageModel.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAbStractClass.dart';
import 'package:sheeps_app/config/NavigationNum.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/dashboard/DashBoardMain.dart';
import 'package:sheeps_app/dashboard/MyPage.dart';
import 'package:sheeps_app/login/LoginCheckPage.dart';
import 'package:sheeps_app/login/PasswordChangePage.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/notification/notificationPage.dart';
import 'package:sheeps_app/notification/models/NotiDatabase.dart';
import 'package:sheeps_app/notification/models/NotificationModel.dart';
import 'package:sheeps_app/onboarding/SplashScreen.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/profile/ProfilePage.dart';
import 'package:sheeps_app/profileModify/MyProfileModify.dart';
import 'package:sheeps_app/registration/LoginSelectPage.dart';
import 'package:sheeps_app/Recruit/RecruitPage.dart';
import 'config/SheepsTextStyle.dart';
import 'network/ApiProvider.dart';
import 'config/constants.dart';
import 'package:badges/badges.dart';


class LifeCycleManager extends StatefulWidget {
  final Widget child;
  LifeCycleManager({Key key, this.child}) : super(key: key);

  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager> with WidgetsBindingObserver{

  SocketProvider socket;
  ChatGlobal _chatGlobal;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _chatGlobal = Get.put(ChatGlobal());
    socket = Get.put(SocketProvider());
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('state = $state');

    List<StoppableService> services = [
      socket,
    ];

    services.forEach((service) {
      if(state == AppLifecycleState.resumed){

        //5분 주기로 access token 을 받아온다
        if(GlobalProfile.loggedInUser != null ) {
          Future.microtask(() async {
            if (int.parse(GlobalProfile.accessTokenExpiredAt) < int.parse(DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10))) {
              var res = await ApiProvider().post('/Personal/Select/Login/Token', jsonEncode({
                "userID" : GlobalProfile.loggedInUser.userID,
                "refreshToken" : GlobalProfile.refreshToken
              }));

              if(res != null){
                GlobalProfile.accessToken = res['AccessToken'] as String;
                GlobalProfile.accessTokenExpiredAt = (res['AccessTokenExpiredAt'] as int).toString();
              }
            }
          });

          if(isRecvData == false){

            //알림 가져오기
            Future.microtask(() async {
              var notiListGet = await ApiProvider().post('/Notification/UnSendSelect', jsonEncode(
                  {
                    "userID" : GlobalProfile.loggedInUser.userID,
                  }
              ));

              if(null != notiListGet){
                for(int i = 0; i < notiListGet.length; ++i){
                  NotificationModel notificationModel = NotificationModel.fromJson(notiListGet[i]);

                  //알림 이벤트 가져오기 필요함
                  NotificationModel replaceModel;
                  if(notificationModel.type == NOTI_EVENT_TEAM_REQUEST_ACCEPT){
                    Team team = await GlobalProfile.getFutureTeamByID(notificationModel.teamIndex);

                    var res = await ApiProvider().post('/Team/WithoutTeamList', jsonEncode(
                        {
                          "to" : notificationModel.to,
                          "from" : notificationModel.from,
                          "teamID" : team.id
                        }
                    ));

                    List<int> chatList = [];

                    if(res != null){
                      for(int i = 0 ; i < res.length; ++i){
                        chatList.add(res[i]['UserID']);
                      }
                    }
                    replaceModel = await SetNotificationData(notificationModel, chatList);
                  }
                  else{
                    replaceModel = await SetNotificationData(notificationModel, null);
                  }

                  if(isSaveNoti(replaceModel)){
                    var id = await NotiDBHelper().createData(replaceModel);
                    replaceModel.id = id;
                    notiList.insert(0,replaceModel);
                  }
                }
              }

              var chatLogList = await ApiProvider().post('/ChatLog/UnSendSelect', jsonEncode(
                  {
                    "userID" : GlobalProfile.loggedInUser.userID
                  }
              ));

              if(chatLogList != null){
                for(int i = 0 ; i < chatLogList.length; ++i){
                  ChatRecvMessageModel message = ChatRecvMessageModel(
                    chatId: chatLogList[i]['id'],
                    roomName: chatLogList[i]['roomName'],
                    to: chatLogList[i]['to'].toString(),
                    from : chatLogList[i]['from'],
                    message: chatLogList[i]['message'],
                    date: chatLogList[i]['date'],
                    isRead: 0,
                    isImage: chatLogList[i]['isImage'],
                    updatedAt: replaceUTCDate(chatLogList[i]['updatedAt']),
                    createdAt: replaceUTCDate(chatLogList[i]['createdAt']),
                  );

                  if(message.isImage != 0){
                    var getImageData = await ApiProvider().post('/ChatLog/SelectImageData', jsonEncode({"id": message.isImage}));

                    if (getImageData != null) {
                      message.message = getImageData['Data'];

                      for(int i = 0 ; i < ChatGlobal.roomInfoList.length; ++i){
                        if(ChatGlobal.roomInfoList[i].roomName == message.roomName){
                          message.isRead = 0;
                          bool DoSort = true;
                          if(socket.getRoomStatus == ROOM_STATUS_CHAT){
                            DoSort = false;
                            if(ChatGlobal.currentRoomIndex == i){
                              message.isRead = 1;
                            }
                          }
                          message.isContinue = true;
                          await _chatGlobal.addChatRecvMessage(message, i, doSort: DoSort);

                          int prevIndex = ChatGlobal.roomInfoList[i].chatList.length > 2 ? ChatGlobal.roomInfoList[i].chatList.length - 2 : 0;

                          _chatGlobal.setContinue(message, prevIndex, i);
                          _chatGlobal.chatListScrollToBottom();

                        }
                      }
                    }else{
                      message.isImage = 0;
                      message.message = "로드 할 수 없는 이미지 입니다.";
                    }
                  }else{
                    for(int i = 0 ; i < ChatGlobal.roomInfoList.length; ++i){
                      if(ChatGlobal.roomInfoList[i].roomName == message.roomName){
                        message.isRead = 0;
                        bool DoSort = true;
                        if(socket.getRoomStatus == ROOM_STATUS_CHAT){
                          DoSort = false;
                          if(ChatGlobal.currentRoomIndex == i){
                            message.isRead = 1;
                          }
                        }
                        message.isContinue = true;
                        await _chatGlobal.addChatRecvMessage(message, i, doSort: DoSort);

                        int prevIndex = ChatGlobal.roomInfoList[i].chatList.length > 2 ? ChatGlobal.roomInfoList[i].chatList.length - 2 : 0;

                        _chatGlobal.setContinue(message, prevIndex, i);
                        _chatGlobal.chatListScrollToBottom();
                      }
                    }
                  }
                }
              }

              Get.appUpdate();
            });
          }else{
            isRecvData = false;
          }
        }
        service.start();
      }else if(state == AppLifecycleState.paused){
        service.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
    );
  }
}


const SystemUiOverlayStyle dark = SystemUiOverlayStyle(
  systemNavigationBarColor: Colors.white,
  systemNavigationBarDividerColor: Colors.white,
  statusBarColor: Colors.white,
  systemNavigationBarIconBrightness: Brightness.light,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
);

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
  FlutterAppBadger.updateBadgeCount(1);
}

/// Create a [AndroidNotificationChannel] for heads up notifications
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  //'This channel is used for important notifications.', // description
  importance: Importance.high,
);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async{
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.white,
  ));
  //SystemChrome.setSystemUIOverlayStyle(dark);
  WidgetsFlutterBinding.ensureInitialized();

  if(myReleaseMode){
    HttpOverrides.global = new MyHttpOverrides();
  }

  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  var dir = await getApplicationDocumentsDirectory();
  applicationDocumentsDirectory = dir.path;

  // 릴리즈 버전에서 에러 확인하는 방법 -- 삭제 x
  // ErrorWidget.builder = (FlutterErrorDetails details) {
  //   bool inDebug = false;
  //   assert(() { inDebug = true; return true; }());
  //   // In debug mode, use the normal error widget which shows
  //   // the error message:
  //   if (inDebug)
  //     return ErrorWidget(details.exception);
  //   // In release builds, show a yellow-on-blue message instead:
  //   return Container(
  //     alignment: Alignment.center,
  //     child: Text(
  //       'Error! ${details.exception}',
  //       style: TextStyle(color: Colors.yellow),
  //       textDirection: TextDirection.ltr,
  //     ),
  //   );
  // };

  ByteData data = await rootBundle.load('assets/raw/certificate.pem');
  SecurityContext context = SecurityContext.defaultContext;
  context.setTrustedCertificatesBytes(data.buffer.asUint8List());

  //카카오 네이티브앱 키
  final String config = await rootBundle.loadString('assets/raw/config.json');
  final configData = await json.decode(config);

  //카카오 네이티브앱 키
  KakaoContext.clientId = configData['items'][0]['data'];

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    //기기별 사이즈 기준 측정
    sizeUnit = WidgetsBinding.instance.window.physicalSize.width/WidgetsBinding.instance.window.devicePixelRatio/360;
    debugPrint("size unit is $sizeUnit");
    super.initState();

    //다이나믹 링크 - 앱이 켜져있으며 로그인 되어 있을 때 동작
    initDynamicLinks();
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.white
    ));
    return LifeCycleManager(
      child: GetMaterialApp(
        defaultTransition: Transition.cupertino,
        debugShowCheckedModeBanner: false,
        initialRoute: '/SplashScreen',
        routes: {
          //'/': (BuildContext context) => DashBoardMain(),
          '/LoginSelectPage': (BuildContext context) => LoginSelectPage(),
          '/MainPage': (BuildContext context) => MainPage(),
          '/MyProfileModify': (BuildContext context) => MyProfileModify(),
          '/ProfilePage': (BuildContext context) => ProfilePage(),
          '/CommunityMain': (BuildContext context) => CommunityMain(),
          '/RecruitPage': (BuildContext context) => RecruitPage(),

          '/SplashScreen': (context) => SplashScreen(),

          '/certification-result': (context) => LoginCheckPage(),
          '/certification-result-PW': (context) => PasswordChangePage(),

          '/MyProfiles': (BuildContext context) => MyPage(),

          //알람 클릭시 사용하려는 코드
          '/ChatRoomPage' : (BuildContext context) => ChatRoomPage(),
          '/NotificationPage' : (BuildContext context) => TotalNotificationPage(),
        },
        navigatorKey: navigatorKey,
        theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,//기본 배경색 지정
            bottomAppBarColor: Colors.white,
            backgroundColor: Colors.white,
            dialogBackgroundColor: Colors.white,
            primaryColor: Colors.white,
            fontFamily: 'SpoqaHanSansNeo',
            textTheme: TextTheme(
                bodyText1: TextStyle(fontSize: sizeUnit)
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
            pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: ZoomPageTransitionsBuilder(),
                }
            )
        ),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        supportedLocales: [
          const Locale('ko','KR'),
        ],
      ),
    );
  }
}


class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static List<Widget> _widgetOptions = <Widget>[
    DashBoardMain(),
    ProfilePage(),
    RecruitPage(),
    CommunityMain(),
    ChatRoomPage(),
  ];

  final navigationNum = Get.put(NavigationNum());
  final chatGlobal = Get.put(ChatGlobal());

  final String svgHomeIcon = 'assets/images/NavigationBar/HomeIcon.svg';
  final String svgProfileIcon = 'assets/images/NavigationBar/ProfileIcon.svg';
  final String svgCommunityIcon = 'assets/images/NavigationBar/CommunityIcon.svg';
  final String svgChatRoomIcon = 'assets/images/NavigationBar/ChatRoomIcon.svg';
  final String svgTeamRecruitIcon = 'assets/images/NavigationBar/TeamRecruitIcon.svg';

  static DateTime currentBackPressTime;
  _isEnd(){
    DateTime now = DateTime.now();
    if(currentBackPressTime == null || now.difference(currentBackPressTime) > Duration(seconds: 2)){
      currentBackPressTime = now;
      showSheepsToast(context: context, text: '뒤로 가기를 한 번 더 입력하시면 종료됩니다.');

      return false;
    }
    return true;
  }

  String _authStatus = 'Unknown';
  Future<void> initPlugin() async{
    try {
      final TrackingStatus status =
      await AppTrackingTransparency.trackingAuthorizationStatus;
      setState(() => _authStatus = '$status');
      // If the system can show an authorization request dialog
      if (status == TrackingStatus.notDetermined) {
        // Show a custom explainer dialog before the system dialog
        final TrackingStatus status = await AppTrackingTransparency.requestTrackingAuthorization();
        setState(() => _authStatus = '$status');
      }
    } on PlatformException {
      setState(() => _authStatus = 'PlatformException was thrown');
    }

    final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
    print("UUID: $uuid");
  }

  @override
  void initState() {
    // TODO: implement initState
    if(Platform.isIOS){
      WidgetsBinding.instance.addPostFrameCallback((_) => initPlugin());
    }


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnitStandard(context).fontSize;

    return WillPopScope(
      onWillPop: ()async {
        if (navigationNum.getNum() == DASHBOARD_MAIN_PAGE) {
          bool result = _isEnd();
          return await Future.value(result);
        } else {
          navigationNum.setNum(DASHBOARD_MAIN_PAGE);
          return Future.value(false);
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Obx(() =>
                Scaffold(
                  body: _widgetOptions[navigationNum.getNum()],
                  bottomNavigationBar: Container(
                    height: 56*sizeUnit,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(width: 0.5 * sizeUnit, color: sheepsColorGrey)),
                    ),
                    child:
                    BottomNavigationBar(
                      elevation: 0.0,
                      backgroundColor: Colors.white,
                      showSelectedLabels: false,
                      showUnselectedLabels: false,
                      type: BottomNavigationBarType.fixed,
                      onTap: (index) {
                        navigationNum.setNum(index);
                      },
                      currentIndex: navigationNum.getNum(),
                      items: [
                        BottomNavigationBarItem(
                            icon: Column(
                              children: [
                                SvgPicture.asset(
                                  svgHomeIcon,
                                  height: 18*sizeUnit,
                                  color: navigationNum.getNum() == DASHBOARD_MAIN_PAGE ? sheepsColorBlack : sheepsColorGrey,
                                ),
                                SizedBox(height: 6*sizeUnit),
                                Text('홈',style: SheepsTextStyle.navigationBarTitle().copyWith(
                                    color: navigationNum.getNum() == DASHBOARD_MAIN_PAGE ? sheepsColorBlack : sheepsColorGrey
                                )),
                                SizedBox(height: 4*sizeUnit),
                              ],
                            ),
                            label: '홈'
                        ),
                        BottomNavigationBarItem(
                            icon: Column(
                              children: [
                                SvgPicture.asset(
                                  svgProfileIcon,
                                  height: 18*sizeUnit,
                                  color: navigationNum.getNum() == PROFILE_PAGE ? sheepsColorBlack : sheepsColorGrey,
                                ),
                                SizedBox(height: 6*sizeUnit),
                                Text('프로필',style: SheepsTextStyle.navigationBarTitle().copyWith(
                                    color: navigationNum.getNum() == PROFILE_PAGE ? sheepsColorBlack : sheepsColorGrey
                                )),
                                SizedBox(height: 4*sizeUnit),
                              ],
                            ),
                            label: '프로필'
                        ),
                        BottomNavigationBarItem(
                            icon: Column(
                              children: [
                                SvgPicture.asset(
                                  svgTeamRecruitIcon,
                                  width: 18*sizeUnit,
                                  height: 18*sizeUnit,
                                  color: navigationNum.getNum() == TEAM_RECRUIT_PAGE ? sheepsColorBlack : sheepsColorGrey,
                                ),
                                SizedBox(height: 6*sizeUnit),
                                Text('리쿠르트',style: SheepsTextStyle.navigationBarTitle().copyWith(
                                    color: navigationNum.getNum() == TEAM_RECRUIT_PAGE ? sheepsColorBlack : sheepsColorGrey
                                )),
                                SizedBox(height: 4*sizeUnit),
                              ],
                            ),
                            label: '리쿠르트'
                        ),
                        BottomNavigationBarItem(
                            icon: Column(
                              children: [
                                SvgPicture.asset(
                                  svgCommunityIcon,
                                  height: 18*sizeUnit,
                                  color: navigationNum.getNum() == COMMUNITY_MAIN_PAGE ? sheepsColorBlack : sheepsColorGrey,
                                ),
                                SizedBox(height: 6*sizeUnit),
                                Text('커뮤니티',style: SheepsTextStyle.navigationBarTitle().copyWith(
                                    color: navigationNum.getNum() == COMMUNITY_MAIN_PAGE ? sheepsColorBlack : sheepsColorGrey
                                )),
                                SizedBox(height: 4*sizeUnit),
                              ],
                            ),
                            label: '커뮤니티'
                        ),
                        BottomNavigationBarItem(
                            icon: Column(
                              children: [
                                Badge(
                                  badgeContent : Text(
                                    chatGlobal.getMessageTotalCount() > 99
                                        ? '99+'
                                        : chatGlobal.getMessageTotalCount().toString(),
                                    style: TextStyle(fontSize: 9*sizeUnit, color: Colors.white, height: 1.35, fontWeight: FontWeight.bold),
                                  ),
                                  badgeColor: sheepsColorRed,
                                  elevation: 0,
                                  toAnimate: false,
                                  shape: BadgeShape.circle,
                                  padding: chatGlobal.getMessageTotalCount() > 9
                                      ? EdgeInsets.all(3.5*sizeUnit)
                                      : EdgeInsets.all(6*sizeUnit),
                                  position: chatGlobal.getMessageTotalCount() > 9
                                      ? BadgePosition(bottom: 8, start: 11)
                                      : BadgePosition(bottom: 5, start: 11),
                                  showBadge: chatGlobal.getMessageTotalCount() == 0 ? false : true,
                                  child: SvgPicture.asset(
                                    svgChatRoomIcon,
                                    width: 18*sizeUnit,
                                    height: 18*sizeUnit,
                                    color: navigationNum.getNum() == CHATROOM_PAGE ? sheepsColorBlack : sheepsColorGrey,
                                  ),
                                ),
                                SizedBox(height: 6*sizeUnit),
                                Text('채팅',style: SheepsTextStyle.navigationBarTitle().copyWith(
                                    color: navigationNum.getNum() == CHATROOM_PAGE ? sheepsColorBlack : sheepsColorGrey
                                )),
                                SizedBox(height: 4*sizeUnit),
                              ],
                            ),
                            label: '채팅'
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