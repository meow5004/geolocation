import 'dart:async';
import 'package:geolocation/BLOCS/BlocProvider.dart';
import 'package:geolocation/model/User.dart';
import 'package:geolocation/DAO/UserDAO.dart';

class UserBLOC implements BlocBase {
  UserDAO userDAO = new UserDAO();
  final _userController = StreamController<User>.broadcast();

  get users => _userController.stream;

  @override
  void dispose() {
    _userController.close();
  }

  usersBloc(imei) {
    getUserByImei(imei);
  }

  add(User user) {
    userDAO.add(user);
    getUserByImei(user.imei);
  }

  getUserByImei(String imei) async {
    _userController.sink.add(await userDAO.getUserByImei(imei));
  }
}
