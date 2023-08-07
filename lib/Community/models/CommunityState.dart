import 'package:get/get.dart';

class CommunityState extends GetxController{
  int communityPageState = 0;
  static const int STATE_NORMAL = 0;
  static const int STATE_JOB = 1;

  int get getState => communityPageState;

  void setState(int state){
    communityPageState = state;
    update();
  }
}
