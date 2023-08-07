import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ConnectNode{
  static const String END_POINT = "http://121.172.129.206:50002";

  static Future<void> fetchMultipart({@required String path, @required File file}) async{
    http.MultipartRequest _request = http.MultipartRequest("POST", Uri.parse("$END_POINT$path"));
    _request.files.add(
      new http.MultipartFile(
          'PhotoUrl',
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: "flutterImg${DateTime.now().millisecond}.jpg",
    )
    );
    await _request.send();
    return;
  }
  //여기가 쓰이는 것입 !!!!!!!



  static Future<void> fetchMultipartArr({@required String path, @required List<File> files}) async{
    http.MultipartRequest _request = http.MultipartRequest("POST", Uri.parse("$END_POINT$path"));
    //header 추가
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'user': 'codeforgeek'
    };
    files.forEach((File file) {
      _request.headers.addAll(headers); //header add
      _request.files.add(
          new http.MultipartFile(
            'PhotoUrls',
            file.readAsBytes().asStream(),
            file.lengthSync(),
            filename: "flutterImg${DateTime.now().millisecond}.jpg",
          )
      );
    });
    await _request.send();
    return;
  }

}