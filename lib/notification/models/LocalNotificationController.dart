import 'package:get/get.dart';
import 'package:sheeps_app/notification/models/LocalNotification.dart';

class LocalNotificationController extends GetxController {
  static LocalNotificationController get to => Get.find();

  LocalNotification localNotification = LocalNotification();
}