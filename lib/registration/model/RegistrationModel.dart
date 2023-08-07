import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RegistrationModel {
  String _userName;
  String _userID;
  String _userPassword;
  String _userConfirmPassword;
  String _userPhoneNumber;
  String _pageState;
  String _errMsg;
  bool isValidForRegistration;
  bool isValidForNextPage;

  factory RegistrationModel.empty() {
    return RegistrationModel("","","","", "", "NAME", "", false, false);
  }

  RegistrationModel(this._userName, this._userID, this._userPassword, this._userConfirmPassword, this._userPhoneNumber, this._pageState, this._errMsg, this.isValidForRegistration, this.isValidForNextPage);


  RegistrationModel copyWith({String userName, String userID, String userPassword, String userConfirmPassword, String, phoneNumber, String pageState, String errMsg, @required isValid, @required isValidPage}){
    return RegistrationModel(
        userName ?? this._userName,
        userID ?? this._userID,
        userPassword ?? this._userPassword,
        userConfirmPassword ?? this._userConfirmPassword,
        phoneNumber ?? this._userPhoneNumber,
        pageState ?? this._pageState,
        errMsg ?? this._errMsg,
        isValid, isValidPage);
  }

  RegistrationModel.fromJson(Map<String, dynamic> parsedJson){
    this._userName = parsedJson['userName'];
    this._userID = parsedJson['userID'];
  }

  String get userName => _userName;
  String get userID => _userID;
  String get userPassword => _userPassword;
  String get userConfirmPassword => _userConfirmPassword;
  String get userPhoneNumber => _userPhoneNumber;
  String get pageState => _pageState;
  String get errMsg => _errMsg;
}

int globalUserID = 0;
String globalLoginID = '';
String globalName = '';
String globalRealName = '';
String globalPhoneNumber = '';
String globalLoginPW = '';
int globalLoginType = 0;
String globalSocialName = '';