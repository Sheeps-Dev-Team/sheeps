import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/network/CustomException.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:sheeps_app/userdata/GlobalProfile.dart';

enum Status { LOADING, COMPLETED, ERROR }

class ApiProvider {
  final String _baseUrl = myReleaseMode == true ? "http://192.168.2.168:" : "http://192.168.2.168:"; //서버 붙는 위치
  final String port = myReleaseMode == true ? "50105" : "50105";                       //기본 포트 50004~50007 LoadBalencer
  final String imgPort = myReleaseMode == true ? "50105" : "50105";                    //이미지 포트
  final String chatPort = myReleaseMode == true ? "50106" : "50106";                   //채팅 포트
  //final String _baseUrl = "http://121.172.129.206:50000"; //서버 붙는 위치
  String get getUrl => _baseUrl + port;
  String get getImgUrl => _baseUrl + imgPort;
  String get getChatUrl => _baseUrl + chatPort;

  //get
  Future<dynamic> get(String url) async {
    var responseJson;

    var uri = Uri.parse(_baseUrl + port + url);

    HttpClient httpClient = new HttpClient();
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    IOClient ioClient = new IOClient(httpClient);

    try {
      final response = await ioClient.get(uri,
      headers: {
        'Content-Type' : 'application/json',
        'user' : GlobalProfile.loggedInUser == null ? 'sheepsToken' : GlobalProfile.loggedInUser!.userID.toString(),
        'accessToken' : GlobalProfile.accessToken!
      },);

      if(response.body == "" || response.body == null) return null;

      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('인터넷 접속이 원활하지 않습니다.');
    }
    return responseJson;
  }

  //post
  Future<dynamic> post(String url, dynamic data, {bool isChat = false}) async{
    var responseJson;

    String tarPort = false == isChat ? port : chatPort;

    var uri = Uri.parse(_baseUrl + tarPort + url);

    HttpClient httpClient = new HttpClient();
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    IOClient ioClient = new IOClient(httpClient);

    try {
      final response = await ioClient.post(uri,
          headers: {
            'Content-Type' : 'application/json',
            'user' : GlobalProfile.loggedInUser == null ? 'sheepsToken' : GlobalProfile.loggedInUser!.userID.toString(),
            'accessToken' : GlobalProfile.accessToken == null ? '' : GlobalProfile.accessToken!
          },
          body: data,
          encoding: Encoding.getByName('utf-8'));

      if(response.body == "" || response.body == null) return null;

      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('인터넷 접속이 원활하지 않습니다');
    }

    return responseJson;
  }

  dynamic _httpClientResponse(HttpClientResponse response) async {
    switch (response.statusCode) {
      case 200:
        String reply = await response.transform(utf8.decoder).join();
        var responseJson = jsonDecode(reply);
        if(!kReleaseMode) print(responseJson);
        return responseJson;
      case 400:
        String reply = await response.transform(utf8.decoder).join();
        BadRequestException(reply);
        return null;
      case 401: //토큰 정보 실패
        String reply = await response.transform(utf8.decoder).join();
        BadRequestException(reply);
        return null;
      case 403:
        String reply = await response.transform(utf8.decoder).join();
        BadRequestException(reply);
        return null;
      case 404: //토큰 정보 실패
        String reply = await response.transform(utf8.decoder).join();
        BadRequestException(reply);
        return null;
      case 500:
        return null;
      default:
      //throw FetchDataException('Error occured while Communication with Server with StatusCode : ${response.statusCode}');
        FetchDataException('Error occured while Communication with Server with StatusCode : ${response.statusCode}');
        return null;
    }
  }

  dynamic _response(http.Response response) {
      switch (response.statusCode) {
        case 200:
          var responseJson = json.decode(response.body.toString());
          if(!kReleaseMode) print(responseJson);
          return responseJson;
        case 400:
          //throw BadRequestException(response.body.toString());
          BadRequestException(response.body.toString());
          return null;
        case 401: //토큰 정보 실패
          BadRequestException(response.body.toString());
          return null;
        case 403:
          //throw UnauthorisedException(response.body.toString());
          BadRequestException(response.body.toString());
          return null;
        case 404: //토큰 정보 실패
          BadRequestException(response.body.toString());
          return null;
        case 500:
          return null;
        default:
        //throw FetchDataException('Error occured while Communication with Server with StatusCode : ${response.statusCode}');
          FetchDataException('Error occured while Communication with Server with StatusCode : ${response.statusCode}');
          return null;
    }
  }
}