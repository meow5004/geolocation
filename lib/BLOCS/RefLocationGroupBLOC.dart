import 'dart:async';
import 'package:geolocation/BLOCS/BlocProvider.dart';
import 'package:geolocation/model/RefLocationGroup.dart';
import 'package:geolocation/DAO/RefLocationGroupDAO.dart';

class RefLocationGroupBLOC implements BlocBase {
  final _refLocationGroupController =
      StreamController<List<RefLocationGroup>>.broadcast();
  RefLocationGroupDAO refLocationGroupDAO = new RefLocationGroupDAO();
  get refLocationGroups => _refLocationGroupController.stream;

  @override
  void dispose() {
    _refLocationGroupController.close();
  }

  getrefLocationGroups() async {
    _refLocationGroupController.sink
        .add(await refLocationGroupDAO.getAllGroups());
  }

  refLocationGroupsBloc() {
    getrefLocationGroups();
  }
}
