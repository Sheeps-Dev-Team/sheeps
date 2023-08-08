import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sqflite/sqflite.dart';
import './NotificationModel.dart';

final String TableName = "NotiLogs";

class NotiDBHelper {

  NotiDBHelper._();

  static final NotiDBHelper _db = NotiDBHelper._();

  factory NotiDBHelper() => _db;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDB();
    return _database!;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'NotiDB.db');

    return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          try{
            await db.execute("CREATE TABLE $TableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, UserID INTEGER, ChatID INTEGER, type INTEGER, tableIndex INTEGER, targetIndex INTEGER, teamIndex INTEGER, time TEXT, isRead INTEGER, isSend INTEGER)");
          }
          catch(e){
            debugPrint(e.toString());
          }

        },
        onUpgrade: (db, oldVersion, newVersion){}
    );
  }

  createData(NotificationModel notiModel) async {
    final db = await database;

    var res = await db.rawInsert("INSERT INTO $TableName(UserID, ChatID, type, tableIndex, targetIndex, teamIndex, time, isRead, isSend) VALUES(?,?,?,?,?,?,?,?,?)",
        [
          notiModel.from,
          notiModel.to,
          notiModel.type,
          notiModel.tableIndex,
          notiModel.targetIndex,
          notiModel.teamIndex,
          notiModel.time,
          notiModel.isRead,
          notiModel.isSend
        ]
    );

    if(false == kReleaseMode){
      debugPrint("TABLE SIZE" + res.toString());
    }

    return res;
  }

  updateDate(int id, int isRead) async {
    final db = await database;

    var res = await db.rawUpdate('''
      UPDATE $TableName
      SET isRead = ?
      WHERE id = ?
      ''',
        [isRead, id]);
  }

  updateIsSend(int id,int isSend) async {
    final db = await database;

    var res = await db.rawUpdate('''
      UPDATE $TableName
      SET isSend = ?
      WHERE id = ?
      ''',
        [isSend, id]);
  }


  getData(int id) async {
    final db = await database;
    var res = await db.rawQuery(
        'SELECT * FROM $TableName where id = ?', [id]);
    return res.isNotEmpty ?
    NotificationModel(
      id: res.first['id'] as int,
      from: res.first['UserID'] as int,
      to: res.first['ChatID'] as int,
      type: res.first['type'] as int,
      tableIndex: res.first['tableIndex'] as int,
      targetIndex: res.first['targetIndex'] as int,
      teamIndex: res.first['teamIndex'] as int,
      time: res.first['time'] as String,
      isRead: res.first['isRead'] as int,
    )
        : null;
  }

  Future<List<NotificationModel>> getAllData() async {
    final db = await database;

    int userID = GlobalProfile.loggedInUser.userID;

    var res = await db.rawQuery('SELECT * from $TableName');
    List<NotificationModel> list  = res.isNotEmpty ? res.map((c) => NotificationModel(
      id: c['id'] as int,
      from: c['UserID'] as int,
      to: c['ChatID'] as int,
      type: c['type'] as int,
      tableIndex: c['tableIndex'] as int,
      targetIndex: c['targetIndex'] as int,
      teamIndex: c['teamIndex'] as int,
      time: c['time'] as String,
      isRead: c['isRead'] as int,
      isSend: c['isSend'] as int
    )).toList()
        : [];

    return list.reversed.toList();
  }
  deleteData(int id) async{
    final db = await database;
    var res = db.rawDelete('DELETE FROM $TableName where id = ?', [id]);
    return res;
  }

  deleteAllDatas() async {
    final db = await database;
    db.rawDelete("DELETE from $TableName");
  }

  dropTable() async{
    final db = await database;
    db.execute("DROP TABLE IF EXISTS $TableName");
    await db.execute(
        "CREATE TABLE $TableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, UserID INTEGER, ChatID INTEGER, type INTEGER, tableIndex INTEGER, targetIndex INTEGER, teamIndex INTEGER, time TEXT, isRead INTEGER, isSend INTEGER)"
    );
  }
}