import 'dart:convert';

import 'package:sheeps_app/userdata/GlobalProfile.dart';

ChatRecvMessageModel chatRecvMessageModelFromJson(String str) =>
    ChatRecvMessageModel.fromJson(json.decode(str));

String chatMessageModelToJson(ChatRecvMessageModel data) =>
    json.encode(data.toJson());

class ChatRecvMessageModel {
  int chatId;
  int roomId;
  String to;
  int from;
  String fromName;
  String roomName;
  String message;
  String date;
  bool isContinue;
  String fileMessage;
  int isImage;
  int isRead;
  String updatedAt;
  String createdAt;

  ChatRecvMessageModel({
    this.chatId,
    this.roomName,
    this.roomId,
    this.to,
    this.from,
    this.fromName,
    this.message,
    this.date,
    this.isContinue,
    this.fileMessage,
    this.isImage,
    this.isRead,
    this.updatedAt,
    this.createdAt
  });

  factory ChatRecvMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatRecvMessageModel(
      chatId: json["chat_id"] as int,
      roomName : json["roomName"] as String,
      to : (json["to"] as int).toString(),
      from: json["from"] as int,
      message: json["message"] as String,
      isImage: json["isImage"] as int,
      date: json["send_date"] as String,
      updatedAt: json["updatedAt"] as String,
      createdAt: json["createdAt"] as String
    );
  }


  Map<String, dynamic> toJson() => {
    "chat_id": chatId,
    "roomId" : roomId,
    "to" : to,
    "from": from,
    "fromName" : fromName,
    "roomName": roomName,
    "message": message,
    "isImage": isImage,
    "date" : date,
    "updatedAt" : updatedAt,
    "createdAt" : createdAt,
    "accessToken" : GlobalProfile.accessToken
  };
}