import 'package:geolocation/model/User.dart';
import 'package:geolocation/DBProvider.dart';

class UserDAO {
  DBProvider dbProvider;

  add(User newUser) async {
    final db = await DBProvider.db.database;
    //get the biggest id in the table
    var table = await db.rawQuery(
        "SELECT CASE When MAX(id) is null then 1 else MAX(id)+1 END as id FROM User");
    int id = table.first["id"];
    //insert to the table using the new id

    var raw = await db.rawInsert(
        "INSERT Into User (id,imei,userId)"
        " VALUES (?,?,?)",
        [id, newUser.imei, newUser.userId]);
    return raw;
  }

  updateUser(User newUser) async {
    final db = await DBProvider.db.database;
    var res = await db.update("User", newUser.toJson(),
        where: "id = ?", whereArgs: [newUser.id]);
    return res;
  }

  getUser(int id) async {
    final db = await DBProvider.db.database;
    var res = await db.query("User", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? User.fromJson(res.first) : null;
  }

  getUserByUserId(int userId) async {
    final db = await DBProvider.db.database;
    var res = await db.query("User", where: "userId = ?", whereArgs: [userId]);
    return res.isNotEmpty ? User.fromJson(res.first) : null;
  }

  getUserByImei(String imei) async {
    final db = await DBProvider.db.database;
    var res = await db.query("User", where: "imei = ?", whereArgs: [imei]);
    return res.isNotEmpty ? User.fromJson(res.first) : null;
  }

  Future<List<User>> getAllUsers() async {
    final db = await DBProvider.db.database;
    var res = await db.query("User");
    List<User> list =
        res.isNotEmpty ? res.map((c) => User.fromJson(c)).toList() : [];
    return list;
  }

  deleteUser(int id) async {
    final db = await DBProvider.db.database;
    return db.delete("User", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await DBProvider.db.database;
    db.delete("User");
  }
}
