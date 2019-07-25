import 'package:flutter/material.dart';
import 'package:geolocation/res/colors.dart';
import 'package:geolocation/res/typography.dart';
import 'package:geolocation/BLOCS/RefLocationBLOC.dart';
import 'package:geolocation/BLOCS/BlocProvider.dart';
import 'package:geolocation/model/RefLocation.dart';
import 'package:flutter/services.dart';

class RegisterRefLocation extends StatefulWidget {
  @override
  RegisterRefLocationState createState() => RegisterRefLocationState();
}

class RegisterRefLocationState extends State<RegisterRefLocation>
    with AutomaticKeepAliveClientMixin<RegisterRefLocation> {
  @override
  bool get wantKeepAlive => true;

  var refname = "";
  var lat = 0.0;
  var long = 0.0;
  final nameEditingController = TextEditingController();
  final latEditingController = TextEditingController();
  final longEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final refBlock = BlocProvider.of<RefLocationBLOC>(context);

    return BlocProvider(
      bloc: RefLocationBLOC(),
      child: Scaffold(
        backgroundColor: mainBg,
        body: Container(
          margin: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.0), color: Colors.white),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Location Name",
                  style: smallText,
                ),
                _buildTextField(controller: nameEditingController),
                const SizedBox(height: 20.0),
                Text(
                  "Location Latitude",
                  style: smallText,
                ),
                _buildTextField(
                    isDouble: true, controller: latEditingController),
                const SizedBox(height: 20.0),
                Text(
                  "Location Longitude",
                  style: smallText,
                ),
                _buildTextField(
                    isDouble: true, controller: longEditingController),
                const SizedBox(height: 10.0),
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text("Reference Location Save".toUpperCase()),
                    onPressed: () async {
                      if (nameEditingController.text != null &&
                          latEditingController.text != null &&
                          longEditingController.text != null) {
                        RefLocation refLocation = new RefLocation();
                        refLocation.name = nameEditingController.text;
                        refLocation.lat =
                            double.parse(latEditingController.text);
                        refLocation.long =
                            double.parse(longEditingController.text);
                        refBlock.add(refLocation);
                        await Future.delayed(Duration(seconds: 1));
                        Navigator.of(context).pop("refresh");
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10.0),
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text("Reference Location Reset".toUpperCase()),
                    onPressed: () async {
                      refBlock.deleteAll();
                      await Future.delayed(Duration(seconds: 1));
                      Navigator.of(context).pop("refresh");
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextField _buildTextField(
      {bool obscureText = false,
      bool isDouble = false,
      TextEditingController controller}) {
    return isDouble
        ? TextField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              BlacklistingTextInputFormatter(new RegExp('[\\-|\\ ]'))
            ],
            obscureText: obscureText,
            controller: controller,
          )
        : TextField(
            obscureText: obscureText,
            controller: controller,
          );
  }
}
