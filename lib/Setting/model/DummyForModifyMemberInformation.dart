import 'package:flutter/cupertino.dart';

class ModifiedMemberInformation with ChangeNotifier {
  String ID = "";
  String ExistingPassword = "";
  String NewPassword = "";
  String ConfirmedNewPassword = "";
  bool IfConfirmPassword = false;
  bool IfComplete = false;

  ModifiedMemberInformation({this.ConfirmedNewPassword,this.ExistingPassword,this.ID,this.NewPassword});

  String getID() => ID;
  String getExistingPassword() => ExistingPassword;
  String getNewPassword() => NewPassword;
  String getConfirmedNewPassword() => ConfirmedNewPassword;
  bool getIfConfirmPassword() => IfConfirmPassword;
  bool getIfComplete() => IfComplete;

  void ChangeID (String value) {
    ID = value;
    notifyListeners();
  }
  void ChangeExistingPassword (String value) {
    ExistingPassword = value;
    notifyListeners();
  }
  void ChangeNewPassword (String value) {
    NewPassword = value;
    notifyListeners();
  }
  void ChangeConfirmedNewPassword (String value) {
    ConfirmedNewPassword = value;
    notifyListeners();
  }
  void MakeIfCompleteOn() {
    IfComplete = true;
    notifyListeners();
  }
  void MakeIfCompleteOff() {
    IfComplete = false;
    notifyListeners();
  }
  void ChangeIfConfirmPassword(bool value) {
    IfConfirmPassword = value;
    notifyListeners();
  }

}

