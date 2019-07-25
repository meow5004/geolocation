import 'package:geolocation/model/RefLocation.dart';
import 'package:geolocation/DBProvider.dart';

class RefLocationDAO {
  DBProvider dbProvider;
  add(RefLocation newRefLocation) async {
    final db = await DBProvider.db.database;
    //get the biggest id in the table
    var table = await db.rawQuery(
        "SELECT CASE When MAX(id) is null then 1 else MAX(id)+1 END as id FROM RefLocation");
    int id = table.first["id"];
    //insert to the table using the new id

    var raw = await db.rawInsert(
        "INSERT Into RefLocation (id,name,lat,long,groupId)"
        " VALUES (?,?,?,?,?)",
        [
          id,
          newRefLocation.name,
          newRefLocation.lat,
          newRefLocation.long,
          newRefLocation.groupId
        ]);
    return raw;
  }

  updateRefLocation(RefLocation newRefLocation) async {
    final db = await DBProvider.db.database;
    var res = await db.update("RefLocation", newRefLocation.toJson(),
        where: "id = ?", whereArgs: [newRefLocation.id]);
    return res;
  }

  getRefLocation(int id) async {
    final db = await DBProvider.db.database;
    var res = await db.query("RefLocation", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? RefLocation.fromJson(res.first) : null;
  }

  Future<List<RefLocation>> getRefLocationsByLocation(int locationId) async {
    final db = await DBProvider.db.database;
    var res = await db.query("RefLocation",
        where: "locationId = ? ", whereArgs: [locationId]);

    List<RefLocation> list =
        res.isNotEmpty ? res.map((c) => RefLocation.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<RefLocation>> getAllRefLocations() async {
    final db = await DBProvider.db.database;
    var res = await db.query("RefLocation");
    List<RefLocation> list =
        res.isNotEmpty ? res.map((c) => RefLocation.fromJson(c)).toList() : [];
    return list;
  }

  deleteRefLocation(int id) async {
    final db = await DBProvider.db.database;
    return db.delete("RefLocation", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await DBProvider.db.database;
    db.delete("RefLocation");
  }
}
