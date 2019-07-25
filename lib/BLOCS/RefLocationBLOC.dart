import 'dart:async';
import 'package:geolocation/BLOCS/BlocProvider.dart';
import 'package:geolocation/model/RefLocation.dart';
import 'package:geolocation/DAO/RefLocationDAO.dart';

class RefLocationBLOC implements BlocBase {
  final _refLocationController =
      StreamController<List<RefLocation>>.broadcast();
  RefLocationDAO refLocationDAO = new RefLocationDAO();
  get refLocations => _refLocationController.stream;

  @override
  void dispose() {
    _refLocationController.close();
  }

  getrefLocations() async {
    _refLocationController.sink.add(await refLocationDAO.getAllRefLocations());
  }

  refLocationsBloc() {
    getrefLocations();
  }

  delete(int id) {
    refLocationDAO.deleteRefLocation(id).then((result) {
      getrefLocations();
    });
  }

  deleteAll() {
    refLocationDAO.deleteAll().then((result) {
      getrefLocations();
    });
  }

  add(RefLocation refLocation) {
    refLocationDAO.add(refLocation).then((result) {
      getrefLocations();
    });
  }
}
