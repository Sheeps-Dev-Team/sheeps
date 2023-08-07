
import 'package:get/get.dart';

class ChatRoomState extends GetxController{
  int chatRoomPageState = 0;
  static const int PERSON_AND_TEAM = 0;
  static const int INTERVIEW = 1;
  static const int EXPERT = 2;

  int get getState => chatRoomPageState;

  void setState(int state){
    chatRoomPageState = state;
    update();
  }
}
