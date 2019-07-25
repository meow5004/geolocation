import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path/path.dart';

class DBProvider {
  DBProvider._();
  DBProvider();
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "geolocationWacoalData.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE CheckinHistory ("
          "id INTEGER PRIMARY KEY,"
          "locationId int,"
          "checkTime TEXT,"
          "userId TEXT"
          ")");
      await db.execute("CREATE TABLE RefLocationGroup ("
          "id INTEGER PRIMARY KEY,"
          "name TEXT"
          ")");
      await db.rawInsert(
          "INSERT Into RefLocationGroup (id,name)"
          " VALUES (?,?)",
          [1, "WACOAL"]);
      await db.execute("CREATE TABLE RefLocation ("
          "id INTEGER PRIMARY KEY,"
          "name TEXT,"
          "lat DOUBLE,"
          "long DOUBLE,"
          "groupId int"
          ")");
      await db.rawInsert(
          "INSERT Into RefLocation (id,name,lat,long,groupId)"
          " VALUES (?,?,?,?,?)",
          [1, "WACOAL A", 13.691195, 100.514055, 1]);
      await db.rawInsert(
          "INSERT Into RefLocation (id,name,lat,long,groupId)"
          " VALUES (?,?,?,?,?)",
          [2, "WACOAL B", 13.691606, 100.514528, 1]);
      await db.rawInsert(
          "INSERT Into RefLocation (id,name,lat,long,groupId)"
          " VALUES (?,?,?,?,?)",
          [3, "WACOAL C", 13.692007, 100.514952, 1]);

      await db.execute("CREATE TABLE User ("
          "id INTEGER PRIMARY KEY,"
          "imei TEXT,"
          "userId TEXT"
          ")");
    });
  }
}
