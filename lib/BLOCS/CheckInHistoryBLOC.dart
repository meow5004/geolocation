import 'dart:async';
import 'package:geolocation/BLOCS/BlocProvider.dart';
import 'package:geolocation/model/CheckinHistory.dart';
import 'package:geolocation/DAO/CheckinHistoryDAO.dart';

class CheckinHistoryBLOC implements BlocBase {
  int currentLocationId = 0;
  String currentUserId = "";
  CheckinHistoryDAO checkinHistoryDAO = new CheckinHistoryDAO();
  final _checkinHistoryController =
      StreamController<List<CheckinHistory>>.broadcast();

  get checkinHistorys => _checkinHistoryController.stream;

  @override
  void dispose() {
    _checkinHistoryController.close();
  }

  getcheckinHistorys() async {
    if (currentLocationId == 0 && currentUserId == "") {
      _checkinHistoryController.sink
          .add(await checkinHistoryDAO.getAllCheckinHistorys());
    } else {
      getcheckinHistorysByLocationIdANDuserId(currentLocationId, currentUserId);
    }
  }

  getcheckinHistorysByLocationIdANDuserId(int locationId, String userId) async {
    _checkinHistoryController.sink.add(await checkinHistoryDAO
        .getCheckinHistorysByLocationAndUser(locationId, userId));
  }

  checkinHistorysBloc() {
    getcheckinHistorys();
  }

  delete(int id) {
    checkinHistoryDAO.deleteCheckinHistory(id).then((result) {
      getcheckinHistorysByLocationIdANDuserId(currentLocationId, currentUserId);
    });
  }

  deleteAll() {
    checkinHistoryDAO.deleteAll().then((result) {
      getcheckinHistorysByLocationIdANDuserId(currentLocationId, currentUserId);
    });
  }

  add(CheckinHistory checkinHistory) {
    checkinHistoryDAO.checkIn(checkinHistory).then((result) {
      currentLocationId = checkinHistory.locationId;
      currentUserId = checkinHistory.userId;
      getcheckinHistorysByLocationIdANDuserId(currentLocationId, currentUserId);
    });
  }
}
