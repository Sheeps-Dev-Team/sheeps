
import 'package:get/get.dart';

class ProfileState extends GetxController{
  RxInt barIndex = 0.obs;
  int _profilePageState = 0;
  static const int STATE_PERSON = 0;
  static const int STATE_TEAM = 1;
  static const int STATE_EXPERT = 2;
  static const int STATE_COMPANY = 3;

  int get getState => _profilePageState;

  void setState(int state){
    _profilePageState = state;
    update();
  }
}
