

import 'dart:io' as IO;
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sheeps_app/Event/event_page.dart';
import 'package:sheeps_app/Event/model/event.dart';import 'package:sheeps_app/network/ApiProvider.dart';

const int BANNER_TYPE_EXTERNAL = 1;//외부 브라우저로
const int BANNER_TYPE_INTERNAL = 2;//내부 페이지로
const int BANNER_TYPE_NOACTION = 3;//액션없음

//서버 통신용
class WebBanner {
  int id;
  String title;
  String description;
  String webURL;
  String imgURL;
  int index;
  String createdAt;
  String updatedAt;

  WebBanner({this.id = 0, this.title = '', this.description = '', this.webURL = '', this.imgURL = '', this.index = 0, this.createdAt = '', this.updatedAt = ''});

  factory WebBanner.fromJson(Map<String, dynamic> json){
    return WebBanner(
      id : json['id'] as int,
      title: json['Title'],
      description: json['Description'],
      webURL: json['WebURL'],
      imgURL: ApiProvider().getUrl + '/BannerPhotos/' + json['ImgURL'],
      index: json['Index'] as int,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt']
    );
  }
}

List<WebBanner> globalWebBannerList = [];

Future<void> setWebBannerData() async {
  var res = await ApiProvider().get('/Banner/List');

  for(int i = 0 ; i < res.length; ++i){
    globalWebBannerList.add(WebBanner.fromJson(res[i]));
  }
}

//클라이언트 용
class ClientBanner {
  final int type;
  final String imgURL;
  final String webURL;

  ClientBanner({this.type = 0, this.imgURL = '', this.webURL = ''});
}

List<ClientBanner> globalClientBannerList = [];

Future<void> setClientBannerData() async {

  //파일로부터 데이터를 가져옴
  IO.Directory dir = await getApplicationDocumentsDirectory();
  String path = '${dir.path}/txt/bannerFile.txt';

  String txtData = '';
  if(await IO.File(path).exists()){
    Uint8List bytes = IO.File(path).readAsBytesSync();
    txtData =  String.fromCharCodes(bytes);
  }else{
    txtData = await loadAsset('assets/txt/bannerFile.txt');
  }

  List<String> enter = txtData.split('\n');

  for(int i = 0 ; i < enter.length; ++i){
    List<String> split = enter[i].split('|');

    if(split.length != 3) continue;

    int type = int.parse(split[2]);
    switch(type){
      case BANNER_TYPE_EXTERNAL:
        globalClientBannerList.add(ClientBanner(type: type, imgURL: 'assets/images/DashBoard/' + split[0], webURL: split[1]));
        break;
      case BANNER_TYPE_INTERNAL:
        globalClientBannerList.add(ClientBanner(type: type, imgURL: 'assets/images/DashBoard/' + split[0], webURL: split[1]));
        break;
      case BANNER_TYPE_NOACTION:
        globalClientBannerList.add(ClientBanner(type: type, imgURL: 'assets/images/DashBoard/' + split[0], webURL: ''));
        break;
    }

  }
}

Future<String> loadAsset(String path) async{
  return rootBundle.loadString(path);
}

void bannerInternalFunction(String webURL){
  switch(webURL){
    case 'Class101Event1' :
      {
        Get.to(()=>EventPage(event: eventClass101));
      }
      break;
    case 'FAVEvent' :
      {
        Get.to(()=>EventPage(event: eventFav));
      }
      break;
  }
}