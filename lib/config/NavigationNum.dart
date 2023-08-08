import 'package:get/get.dart';

class NavigationNum extends GetxController{
  static NavigationNum get to => Get.find();

  RxDouble forSetState = 0.0.obs;
  RxInt pastNum = 0.obs;
  final _num = 0.obs;

  int getNum() => _num.value;
  int getPastNum() => pastNum.value;

  void setNum(int num){
    pastNum.value = _num.value;
    _num.value = num;
    forSetState(forSetState.value + 0.1);
    update();
  }
  void setPastNum(int num){
    pastNum.value = num;
  }

  void setNormalPastNum(int num) {
    pastNum.value = num;
  }

  @override
  void onInit() {
    _num.value = 0;
    pastNum.value = -1;
    super.onInit();
  }
}

