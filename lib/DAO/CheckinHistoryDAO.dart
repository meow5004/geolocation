import 'package:geolocation/model/CheckinHistory.dart';
import 'package:geolocation/DBProvider.dart';


class CheckinHistoryDAO {
 DBProvider dbProvider;

  checkIn(CheckinHistory newCheckinHistory) async {
    final db = await DBProvider.db.database;
    //get the biggest id in the table
    var table = await db.rawQuery(
        "SELECT CASE When MAX(id) is null then 1 else MAX(id)+1 END as id FROM CheckinHistory");
    int id = table.first["id"];
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into CheckinHistory (id,locationId,checkTime,userId)"
        " VALUES (?,?,?,?)",
        [
          id,
          newCheckinHistory.locationId,
          newCheckinHistory.checkTime,
          newCheckinHistory.userId
        ]);
    return raw;
  }

  updateCheckinHistory(CheckinHistory newCheckinHistory) async {
    final db = await DBProvider.db.database;
    var res = await db.update("CheckinHistory", newCheckinHistory.toJson(),
        where: "id = ?", whereArgs: [newCheckinHistory.id]);
    return res;
  }

  getCheckinHistory(int id) async {
    final db = await DBProvider.db.database;
    var res =
        await db.query("CheckinHistory", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? CheckinHistory.fromJson(res.first) : null;
  }

  Future<List<CheckinHistory>> getCheckinHistorysByLocationAndUser(
      int locationId, String userId) async {
    final db = await DBProvider.db.database;
    var res = await db.query("CheckinHistory",
        where: "locationId = ? AND userId = ?",
        whereArgs: [locationId, userId]);

    List<CheckinHistory> list = res.isNotEmpty
        ? res.map((c) => CheckinHistory.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<CheckinHistory>> getAllCheckinHistorys() async {
    final db = await DBProvider.db.database;
    var res = await db.query("CheckinHistory");
    List<CheckinHistory> list = res.isNotEmpty
        ? res.map((c) => CheckinHistory.fromJson(c)).toList()
        : [];
    return list;
  }

  deleteCheckinHistory(int id) async {
    final db = await DBProvider.db.database;
    return db.delete("CheckinHistory", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await DBProvider.db.database;
    db.delete("CheckinHistory");
  }
}
