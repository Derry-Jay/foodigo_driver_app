import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_driver_app/controllers/user_controller.dart';
import 'package:foodigo_driver_app/elements/CircularLoadingWidget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverLocationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DriverLocationPageState();
}

class DriverLocationPageState extends StateMVC<DriverLocationPage> {
  UserController _con;
  var currentLocation, myIcon;
  GoogleMapController _controller;
  LatLng curLoc;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  Set<Marker> markers = <Marker>{};
  MediaQueryData get dimensions => MediaQuery.of(context);
  double get height => dimensions.size.height;
  double get width => dimensions.size.width;
  double get size => sqrt(pow(height, 2) + pow(width, 2));
  DriverLocationPageState() : super(UserController()) {
    _con = controller;
  }
  _getLocation() async {
    myIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(20, 20)), 'assets/images/map_marker.png');
    var location = new Location();
    try {
      currentLocation = await location.getLocation();
      print("locationLatitude: ${currentLocation.latitude}");
      print("locationLongitude: ${currentLocation.longitude}");
      setState(
          () {}); //rebuild the widget after getting the current location of the user
    } on Exception {
      currentLocation = null;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  void _currentLocation() async {
    final controller = _controller;
    LocationData currentLocation;
    var location = new Location();
    try {
      currentLocation = await location.getLocation();
      setState(() {
        curLoc = LatLng(currentLocation.latitude, currentLocation.longitude);
        print("s");
        markers.add(Marker(
            markerId: MarkerId("Current Location"),
            icon: myIcon,
            position: curLoc));
      });
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: 17.0,
        ),
      ));
      final sharedPrefs = await _sharedPrefs;
      Map<String, dynamic> body = {
        "id": sharedPrefs.getString("spDriverID"),
        "lat": curLoc.latitude.toString(),
        "lang": curLoc.longitude.toString(),
        "api_token": sharedPrefs.getString("apiToken")
      };
      print(body.keys.toList());
      _con.putDriverLocation(body);
    } on Exception {
      currentLocation = null;
      setState(() {
        curLoc = LatLng(0.0, 0.0);
      });
      print(curLoc);
    }
  }

  @override
  void initState() {
    _getLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        curLoc == null && currentLocation == null
            ? CircularLoadingWidget(
                // height: height / 2,
                )
            : GoogleMap(
                markers: markers,
                myLocationEnabled: true,
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                    target: currentLocation != null
                        ? LatLng(
                            currentLocation.latitude, currentLocation.longitude)
                        : curLoc),
                // onCameraMove: (cp) {
                //   print(cp.target);
                // },
              ),
        // TextButton(
        //     onPressed: () async {
        //     },
        //     child: Container(
        //         width: double.infinity,
        //         height: height / 16,
        //         padding: EdgeInsets.symmetric(
        //             vertical: height / 64, horizontal: width / 10),
        //         child: Center(
        //             child: Text("MARK MY LOCATION",
        //                 style: TextStyle(
        //                     color: Colors.white,
        //                     fontSize: 18,
        //                     fontWeight: FontWeight.w700))),
        //         decoration: BoxDecoration(
        //             color: Color(0xffa11414),
        //             borderRadius:
        //                 BorderRadius.all(Radius.circular(size / 160))))),
        // TextButton(
        //     onPressed: () {},
        //     child: Text("MARK MY LOCATION",
        //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)))
      ], alignment: Alignment.bottomCenter),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: height / 10),
        child: InkWell(
            child: Image.asset("assets/images/map_button.png"),
            onTap: _currentLocation),
      ),
    );
  }
}
