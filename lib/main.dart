import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocation/BLOCS/CheckInHistoryBLOC.dart';
import 'package:geolocation/BLOCS/RefLocationBLOC.dart';
import 'package:geolocation/BLOCS/UserBLOC.dart';
import 'package:geolocation/model/RefLocation.dart';
import 'package:geolocation/registerRefLocation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:intl/intl.dart';

import 'BLOCS/BlocProvider.dart';

import 'model/CheckinHistory.dart';
import 'model/User.dart';

import 'package:geolocation/res/colors.dart';
import 'package:geolocation/res/typography.dart';

void main() {
  runApp(
    BlocProvider(
      bloc: CheckinHistoryBLOC(),
      child: BlocProvider(
        bloc: RefLocationBLOC(),
        child: BlocProvider(
          bloc: UserBLOC(),
          child: new MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double checkInableDistance = 100.0;

  StreamController<Position> positionStreamController =
      StreamController<Position>.broadcast();
  StreamController<double> distanceRefFromHereStreamController =
      StreamController<double>.broadcast();
  StreamController<RefLocation> referenceDroplistStreamController =
      StreamController<RefLocation>.broadcast();
  StreamController<Placemark> refPlacemarkStreamController =
      StreamController<Placemark>.broadcast();

  Stream<Position> positionStream;
  Stream<double> distanceRefFromHereStream;
  Stream<RefLocation> referenceDroplistStream;
  Stream<Placemark> refPlacemarkStream;

  List<RefLocation> refPositionList = new List();

  var dateFormat = DateFormat('dd-MM-yyyy – kk:mm:ss');
  var geolocator = Geolocator();
  var locationOptions = LocationOptions(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
      timeInterval: 1000);
  var imei;
  String error;
/*   GeolocationStatus _permission; */

  bool currentWidget = true;

  Image image1;

  @override
  void dispose() {
    positionStreamController.close();
    distanceRefFromHereStreamController.close();
    referenceDroplistStreamController.close();
    refPlacemarkStreamController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    positionStream = positionStreamController.stream;
    distanceRefFromHereStream = distanceRefFromHereStreamController.stream;
    referenceDroplistStream = referenceDroplistStreamController.stream;
    refPlacemarkStream = refPlacemarkStreamController.stream;

    //positionStream.addStream(geolocator.getPositionStream(locationOptions));
    //delayed after widget complete
    Future.delayed(Duration(seconds: 3), () async {
      positionStreamController.sink.add(await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation));
      RefLocationBLOC refbloc = BlocProvider.of<RefLocationBLOC>(context);
      refbloc.getrefLocations();
    });
  }

  @override
  Widget build(BuildContext context) {
    CheckinHistoryBLOC checkInbloc =
        BlocProvider.of<CheckinHistoryBLOC>(context);
    RefLocationBLOC refbloc = BlocProvider.of<RefLocationBLOC>(context);
    UserBLOC userbloc = BlocProvider.of<UserBLOC>(context);
    ImeiPlugin.getImei.then((imei) {
      userbloc.getUserByImei(imei);
    });

    //checkInbloc.getcheckinHistorysByLocationIdANDuserId();
    refbloc.getrefLocations();
    //first time load
/*     referenceDroplistStream.stream.listen((RefLocation ref) {
      debugPrint("refhere${ref.name}");
    }); */

/* referenceDroplistStream.stream.listen(onData) */
    return MaterialApp(
      theme: ThemeData.light(),
      home: Builder(
        builder: (context) => Scaffold(
          backgroundColor: mainBg,
          body: Container(
            margin: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.0), color: Colors.white),
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child:
                    buildWidgetColumn(context, checkInbloc, refbloc, userbloc)),
          ),
        ),
      ),
    );
  }

  Widget buildWidgetColumn(context, checkInbloc, refbloc, userbloc) {
    /*  if (_currentLocation == null) {
            widgets = new List();
          } else {
            widgets = [
              new Image.network("https://maps.googleapis.com/maps/api/staticmap?" +
                  "center=${_refPostion.latitude},${_refPostion.longitude}" +
                  "&zoom=18&size=640x400&key=AIzaSyBw_T2wCQGqWBEdF4UzMAuoQX_DCemYpQw")
            ];
          } */
    return StreamBuilder(
      stream: userbloc.users,
      builder: (context, user) {
        List<Widget> widgets = new List();
        if (user.hasData && user != null) {
          String userId = user.data.userId;
          widgets.add(buildLocationRefreshButton(context));
          widgets.add(showUser(context, userId));
          widgets.add(regisRefLocationButton(context, checkInbloc, refbloc));
          widgets.add(
            const SizedBox(height: 20.0),
          );
          widgets.add(buildCheckInButton(context, checkInbloc, userId));
          widgets.add(buildResetButton(context, checkInbloc));
          widgets.addAll(buildRefPlaceMarkText(context, checkInbloc));
          widgets.addAll(
              showCurrentLocationAndDistanceFromRef(context, checkInbloc));
          widgets.add(refDropList(context, checkInbloc, refbloc, userId));
          widgets.add(showCheckInHistory(context, checkInbloc));
          /*   widgets.add(showPermission(context, checkInbloc)); */

          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: widgets);
        } else {
          final userIdCon = TextEditingController();
          return Container(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Text("please register before Use"),
                  Text(
                    "UserId ",
                    style: smallText,
                  ),
                  TextField(
                    controller: userIdCon,
                  ),
                  const SizedBox(height: 10.0),
                  SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Text("User Id save ".toUpperCase()),
                      onPressed: () async {
                        if (userIdCon.text != null) {
                          userbloc
                              .add(
                            ImeiPlugin.getImei.then((imei) {
                              return new User(
                                  userId: userIdCon.text, imei: imei);
                            }),
                          )
                              .then((addValue) {
                            setState(() {});
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  List<RefLocation> fillLocation() {
    var refPositionList = new List<RefLocation>();
    refPositionList.add(
        new RefLocation(name: "wacoal", lat: 13.6914706, long: 100.5140012));
    refPositionList.add(
        new RefLocation(name: "B'Chill", lat: 13.6755488, long: 100.532705));
    return refPositionList;
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(),
    );
  }

//build main widget
  Widget buildCheckInButton(context, checkInbloc, userId) {
    return new StreamBuilder(
      stream: distanceRefFromHereStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot != null) {
          if (snapshot.data <= checkInableDistance) {
            return new Center(
              child: SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text('check in', style: smallText),
                    onPressed: () {
                      CheckinHistory newHis = new CheckinHistory(
                          checkTime: dateFormat.format(DateTime.now()),
                          locationId: 1,
                          userId: userId);
                      checkInbloc.add(newHis);
                    },
                  )),
            );
          } else {
            return Text("Too far from check-in Location", style: smallText);
          }
        } else {
          return Text("Cant fetch location Data", style: smallText);
        }
      },
    );
  }

  Widget buildResetButton(context, checkInbloc) {
    return new Center(
      child: SizedBox(
        width: double.infinity,
        child: RaisedButton(
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          child: Text('Reset Check-in History', style: smallText),
          onPressed: () {
            checkInbloc.deleteAll();
          },
        ),
      ),
    );
  }

  List<Widget> buildRefPlaceMarkText(context, checkInbloc) {
    List<Widget> wid = List();
    wid.add(new StreamBuilder(
      stream: refPlacemarkStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          Placemark _refPlacemark = snapshot.data;
          return new Text(
              'Ref location: ${_refPlacemark.name} ${_refPlacemark.locality} ${_refPlacemark.subLocality} ${_refPlacemark.thoroughfare} ${_refPlacemark.subThoroughfare} ${_refPlacemark.subAdministrativeArea} ${_refPlacemark.country} \n${_refPlacemark.position}',
              style: smallText);
        } else {
          return new Text("");
        }
      },
    ));

/*       new FutureBuilder(
        future: initPlatformState(), // a Future<String> or null
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return new Text(
                _refPlacemark.length > 0
                    ? 'Ref location: ${_refPlacemark[0].name} ${_refPlacemark[0].locality} ${_refPlacemark[0].subLocality} ${_refPlacemark[0].thoroughfare} ${_refPlacemark[0].subThoroughfare} ${_refPlacemark[0].subAdministrativeArea} ${_refPlacemark[0].country} \n${_refPlacemark[0].position}'
                    : 'Error: $error\n',
                style: smallText);
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ), */
/*     ); */

    return wid;
  }

  List<Widget> showCurrentLocationAndDistanceFromRef(context, checkInbloc) {
    List<Widget> wid = List();
    wid.add(
      new StreamBuilder(
        stream: positionStream,
        builder: (context, snapshot) {
          Position curPos = snapshot.data;
          if (curPos != null) {
            return StreamBuilder(
              stream: referenceDroplistStream,
              builder: (refcontext, refsnapshot) {
                var refPos = refsnapshot.data;
                if (refPos != null) {
                  calculateDistance(curPos, refPos);
                }

                Position current = snapshot.data;
                return Text(
                    "Current Location lat :${current.latitude} long : ${current.longitude}",
                    style: smallText);
              },
            );
          } else {
            return Text("No Location Data Detected!", style: smallText);
          }
        },
      ),
    );
    wid.add(
      new StreamBuilder(
        stream: distanceRefFromHereStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot != null) {
            return Text(
                "Distance from here to ref :${snapshot.data.toStringAsFixed(2)} m",
                style: smallText);
          } else {
            return Text("", style: smallText);
          }
        },
      ),
    );
    return wid;
  }

  Widget showCheckInHistory(context, checkInbloc) {
    return Container(
      child: StreamBuilder(
          stream: referenceDroplistStream,
          builder: (refcontext, refsnapshot) {
            return StreamBuilder<List<CheckinHistory>>(
              stream: checkInbloc.checkinHistorys,
              builder: (BuildContext context,
                  AsyncSnapshot<List<CheckinHistory>> snapshot) {
                if (snapshot.hasData && snapshot != null) {
                  return new ListView.builder(
                    shrinkWrap: true,
                    itemCount:
                        snapshot.data == null ? 1 : snapshot.data.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        // return the header
                        return new ListTile(
                          title: Text(refsnapshot.data.name),
                        );
                      }
                      index -= 1;
                      if (index < snapshot.data.length + 1) {
                        CheckinHistory item = snapshot.data[index];
                        return ListTile(
                          title: Text(
                            "Check In On ${item.checkTime}",
                            style: smallText,
                          ),
                          leading:
                              Text(item.userId.toString(), style: smallText),
                        );
                      } else {
                        return Text("some problem occured");
                      }
                    },
                  );
                } else {
                  return Center(child: Text("No History", style: smallText));
                }
              },
            );
          }),
    );
  }

/*   Widget showPermission(context, checkInbloc) {
    return new Center(
        child: new Text(
            _permission == GeolocationStatus.granted
                ? 'Has permission : Yes'
                : "Has permission : No",
            style: smallText));
  } */

  Widget regisRefLocationButton(context, checkInbloc, refbloc) {
    return new Center(
      child: RaisedButton(
        child: Text('Add new Referenced Place'),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RegisterRefLocation())).then((onValue) {
            refbloc.getrefLocations();
          });
        },
      ),
    );
  }

  Widget refDropList(context, checkInbloc, refbloc, userId) {
    var droplistStream = new StreamBuilder<List<RefLocation>>(
        stream: refbloc.refLocations,
        builder: (refcontext, refsnapshot) {
          if (refsnapshot.hasData && refsnapshot != null) {
            if (refsnapshot.data.length > 0) {
              //first trigger
              triggerDropDown(refsnapshot.data[0], checkInbloc, userId);
              return StreamBuilder<RefLocation>(
                stream: referenceDroplistStream,
                initialData: refsnapshot.data[0],
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return Center(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: snapshot.data.id.toString(),
                      onChanged: (String newValue) {
                        for (RefLocation location in refsnapshot.data) {
                          if (location.id == int.parse(newValue)) {
                            triggerDropDown(location, checkInbloc, userId);
                          }
                        }
                      },
                      items: refsnapshot.data
                          .map<DropdownMenuItem<String>>((RefLocation value) {
                        return DropdownMenuItem<String>(
                          value: value.id.toString(),
                          child: Text(value.name),
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            } else {
              return Text("no Reference data found");
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });

    return droplistStream;
  }

  Widget buildLocationRefreshButton(context) {
    return new Align(
      alignment: Alignment.topRight,
      child: new RawMaterialButton(
        onPressed: () async {
          positionStreamController.sink.add(await Geolocator()
              .getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.bestForNavigation));
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Refresh',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              'Location',
              style: TextStyle(color: Colors.white),
            ),
            Icon(
              Icons.refresh,
              color: Colors.white,
              size: 35.0,
            ),
          ],
        ),
        shape: new CircleBorder(),
        elevation: 2.0,
        fillColor: Colors.blue,
        padding: const EdgeInsets.all(15.0),
      ),
    );
  }

  void triggerDropDown(
      RefLocation location, CheckinHistoryBLOC checkInbloc, String userId) {
    referenceDroplistStreamController.sink.add(location);
    geolocator
        .placemarkFromCoordinates(location.lat, location.long)
        .then((onValue) => refPlacemarkStreamController.sink.add(onValue[0]));
    checkInbloc.getcheckinHistorysByLocationIdANDuserId(location.id, userId);
  }

  void calculateDistance(Position curPos, RefLocation refPos) {
    geolocator
        .distanceBetween(
            curPos.latitude, curPos.longitude, refPos.lat, refPos.long)
        .then((result) {
      distanceRefFromHereStreamController.sink.add(result);
    });
  }

  Widget showUser(context, userId) {
    return Text("Current User Id : $userId");
  }
}
