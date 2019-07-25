import 'package:geolocation/model/RefLocationGroup.dart';
import 'package:geolocation/DBProvider.dart';

class RefLocationGroupDAO {
  DBProvider dbProvider;
  Future<List<RefLocationGroup>> getAllGroups() async {
    final db = await DBProvider.db.database;
    var res = await db.query("RefLocationGroup");
    List<RefLocationGroup> list = res.isNotEmpty
        ? res.map((c) => RefLocationGroup.fromJson(c)).toList()
        : [];
    return list;
  }
}
