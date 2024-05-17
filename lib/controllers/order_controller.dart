import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodigo_driver_app/models/accept_order.dart';
import 'package:foodigo_driver_app/models/food_order.dart';
import 'package:foodigo_driver_app/models/order.dart';
import 'package:foodigo_driver_app/models/order_status.dart';
import 'package:foodigo_driver_app/models/order_status_check.dart';
import 'package:foodigo_driver_app/models/paymentHistory.dart';
import 'package:foodigo_driver_app/models/response.dart';
import 'package:foodigo_driver_app/models/restaurant.dart';
import 'package:foodigo_driver_app/models/user.dart';
import 'package:foodigo_driver_app/pages/amount_collect.dart';
import 'package:foodigo_driver_app/pages/order_tracking_page.dart';
import 'package:foodigo_driver_app/repos/orders_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/food.dart';
import '../repos/orders_repository.dart';
import '../repos/user_repository.dart';

class OrderController extends ControllerMVC {
  User user = new User(), driver = new User();
  Restaurant hotel = new Restaurant();
  OrderStatusid orderstatus = new OrderStatusid();
  List<Order> orders;
  List<Paymenthistory> paymentHistory;
  List<bool> checked = [];
  Order order;
  var orderstatusid;
  bool orderpick = false;
  bool reachres = false;
  bool orderpack = false;
  bool nearres = false;
  bool nearcus = false;
  GoogleMapController controller;
  Set<Marker> markers = <Marker>{};
  Set<Polyline> polyLines = <Polyline>{};
  List<LatLng> polylineCoordinates = <LatLng>[];
  PolylinePoints polylinePoints = PolylinePoints();
  CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(0.0, 0.0), zoom: 17);
  List<Food> orderedFood;
  List ordfood;
  // Food orderedFood = new Food();
  AcceptOrder data;
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData driloc;
  Position currentLocation;
  LatLng driverloction;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();

  Future<void> waitForOrders(Map<String, dynamic> body) async {
    if (body['page'] == "1") {
      setState(() {
        orders = [];
      });
    }
    final result = await getDriverOrders(body);
    if (result != null) {
      setState(() {
        result.forEach((value) {
          orders.add(value);
        });
      });
    }

    // setState(() => orders = result == null ? <Order>[] : result);
  }

  Future<void> waitFordeliveredorders(Map<String, dynamic> body) async {
    // if (body['page'] == "1") {
    //   setState(() {
    //     orders = [];
    //   });
    // }
    final result = await getdeliveredOrders(body);
    // if (result != null) {
    //   setState(() {
    //     result.forEach((value) {
    //       orders.add(value);
    //     });
    //   });
    // }
    setState(() => orders = result == null ? <Order>[] : result);
  }

  Future<void> waitForPaymenthistory(Map<String, dynamic> body) async {
    if (body['page'] == "1") {
      setState(() {
        paymentHistory = [];
      });
    }
    final result = await getpaymentHistory(body);
    if (result != null) {
      setState(() {
        result.forEach((value) {
          paymentHistory.add(value);
        });
      });
    }
    // setState(
    //     () => paymentHistory = result == null ? <Paymenthistory>[] : result);
  }

  void waitForfooddetails(String id) async {
    final result = await getfooddetails(id);
    setState(() => ordfood = result == null ? null : result);
    //print(ordfood);
  }

  Future<void> waitForUserData(String id) async {
    final value = await getUserData(id);
    setState(() => user = value == null ? User() : value);
  }

  Future<void> waitForHotelData(String id) async {
    final value = await getHotelData(id);
    setState(() => hotel = value == null ? Restaurant() : value);
  }

  void waitUntilAcceptOrder(Map<String, dynamic> body, Order order) async {
    print('locate');
    final value = await acceptOrder(body);
    if (value != null && value.status && value.response.success) {
      print('locate');
      final p = await Navigator.pushNamed(stateMVC.context, '/locateCustomer',
          arguments: order);
      //print(p);
    } else if (!value.status) {
      Fluttertoast.showToast(msg: "Another driver accepted try another one");
      final p =
          await Navigator.pushNamed(stateMVC.context, '/pages', arguments: 1);
    }
  }

  void waitUntilRejecttOrder(Map<String, dynamic> body) async {
    final value = await rejectOrder(body);
    if (value != null && value.status && value.response.success) {
      final p =
          await Navigator.pushNamed(stateMVC.context, '/pages', arguments: 1);
    } else if (!value.status) {
      final p =
          await Navigator.pushNamed(stateMVC.context, '/pages', arguments: 1);
    }
  }

  void waitForDriverData(String id) async {
    final value = await getUserData(id);
    setState(() => driver = value == null ? User() : value);
  }

  Future<void> waitUntilUpdateLocation(Map<String, dynamic> body) async {
    final value = await updateDriverLocation(body);
    setState(() =>
        data = value == null ? AcceptOrder(Response("", false), false) : value);
  }

  Future<void> waitUntilorderstatuschange(
      Map<String, dynamic> body, String orderid) async {
    final value = await orderstatuschange(body, orderid);
    if (value['success']) {
      return value['success'];
    }
  }

  void waitFororderstatus(String id) async {
    final value = await orderstatusfetch(id);
    //setState(() => orderstatusid = value.toString());
    setState(() => orderstatus = value == null ? OrderStatusid() : value);
  }

  void movto_otp(String id, String route, String amount) async {
    if (route == 'OTP') {
      await Navigator.pushNamed(stateMVC.context, '/otpconfrim', arguments: id);
    } else if (route == 'Amount') {
      // await Navigator.pushNamed(stateMVC.context, '/amountconfrim',
      //     arguments: amount);
      await Navigator.push(
          stateMVC.context,
          new MaterialPageRoute(
            builder: (BuildContext context) => new Amountconfrim(
              amount: amount,
              orderid: id,
            ),
          ));
    }
  }

  void waitUntilOrderDelivered(Map<String, dynamic> body) async {
    final value = await orderDelivered(body);
    if (value['success']) {
      final p =
          await Navigator.pushNamed(stateMVC.context, '/pages', arguments: 0);
    }
  }

  Future<void> driverloc() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        //return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        // return;
      }
    }

    currentLocation = await Geolocator.getCurrentPosition();

    // driloc = await location.getLocation();
    setState(() {
      driverloction =
          LatLng(currentLocation.latitude, currentLocation.longitude);
      // driverloction = LatLng(driloc.latitude, driloc.longitude);
    });
  }

  void getconnect_status(context) async {
    print("ConnectivityResult.mobile");
    var connectivityResult = await (Connectivity().checkConnectivity());
    print(ConnectivityResult.mobile);
    if (connectivityResult == ConnectivityResult.none) {
      // I am connected to a mobile network.
      _showalert(context);
    } else {
      // timer.cancel();
    }
  }

  _showalert(context) async {
    showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text(
              'Network Status',
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            content: new Text(
              'You are not connect with internet',
              style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  getconnect_status(context);
                },
                child: new Text('Ok'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
