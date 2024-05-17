// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodigo_driver_app/models/dashboard.dart';
import 'package:foodigo_driver_app/models/owner.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/order.dart';
import '../models/user.dart';
import '../repos/orders_repository.dart';
import '../repos/user_repository.dart' as repository;
import '../repos/user_repository.dart';

class UserController extends ControllerMVC {
  //List<Order> orders;
  Order orders = new Order();
  User user = new User(), driver = new User();
  Dashboard dashbrd = new Dashboard();
  Owner owner;
  List<Order> del_orders;
  bool hidePassword = true;
  bool loading = false;
  bool iswrong = false;
  GlobalKey<FormState> loginFormKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();

  TextEditingController oldpass = new TextEditingController(),
      newpass = new TextEditingController(),
      confrimnewpass = new TextEditingController();
  // FirebaseMessaging _firebaseMessaging;
  OverlayEntry loader;
  List<Dashboard> dash;
  // factory UserController() => _this ??= UserController._();
  // static UserController _this;
  // UserController._();

  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData driloc;
  LatLng driverloction;

  UserController() {
    loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    loader = Helper.overlayLoader(this.scaffoldKey.currentContext);
    // _firebaseMessaging = FirebaseMessaging.instance;
    // _firebaseMessaging.getToken().then((String _deviceToken) {
    //   user.deviceToken = _deviceToken;
    // }).catchError((e) {
    //   print('Notification not configured');
    // });
  }

  void login() async {
    final sharedPrefs = await _sharedPrefs;
    FocusScope.of(stateMVC.context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(stateMVC.context).insert(loader);
      repository.login(user).then((value) async {
        final imageBase = await imgBase();
        final imgbase = await sharedPrefs.setString("imgBase", imageBase);
        if (value != null && value.apiToken != null) {
          final fullurlimg = await sharedPrefs.setString(
              "fullimgurl", imageBase + value.s3url);
          final a = await sharedPrefs.setString("s3url", value.s3url);
          final g = await sharedPrefs.setString("spDriverID", value.id);
          final h = await sharedPrefs.setString("apiToken", value.apiToken);
          final n = await sharedPrefs.setString("name", value.name);
          final m = await sharedPrefs.setString("mobile", value.mobile);
          final e = await sharedPrefs.setString("email", value.email);
          if (g && h) {
            Navigator.of(stateMVC.context).pushNamedAndRemoveUntil(
                '/pages', (Route<dynamic> route) => false,
                arguments: 0);
            // await waitForcurrenttask(sharedPrefs.getString("spDriverID"));
          }
        } else {
          print("hi");
          // ScaffoldMessenger.of(scaffoldKey.currentContext)
          //     .showSnackBar(SnackBar(
          //   content: Text(S.of(stateMVC.context).wrong_email_or_password),
          // ));
          scaffoldKey.currentState.showSnackBar(
              SnackBar(content: Text("Email or Password Invalid")));
        }
      }).catchError((e) {
        loader.remove();
        print(e.toString());
        print(this.scaffoldKey.currentContext);
        // ScaffoldMessenger.of(this.scaffoldKey.currentContext)
        //     .showSnackBar(SnackBar(
        //   content: Text(S.of(stateMVC.context).thisAccountNotExist),
        // ));
        scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text("Email or Password Invalid")));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  void putDriverLocation(Map body) async {
    final stream = await repository.sendCurrentLocation(body);
    if (stream == null
        ? false
        : (stream["success"] == null ? false : stream["success"]))
      Fluttertoast.showToast(msg: "Success");
    // Navigator.of(stateMVC.context)
    //     .pushReplacementNamed('/pages', arguments: 0);
  }

  Future<void> waitForcurrenttask(String id, String route) async {
    //FocusScope.of(stateMVC.context).unfocus();
    if (route != 'Dashboard') {
      Overlay.of(stateMVC.context).insert(loader);
    }

    final result = await getcurrentorders(id);
    print(result);
    setState(() => orders = result == null ? null : result);
    if (result != null) {
      if (route != 'Dashboard') {
        Helper.hideLoader(loader);
      }
      final p = await Navigator.pushNamed(stateMVC.context, '/locateCustomer',
          arguments: orders);
      //print(p);
    } else {
      if (route != 'Dashboard') {
        Helper.hideLoader(loader);
        await Navigator.pushNamed(stateMVC.context, '/pages', arguments: 0);
      }
      // Navigator.of(context).pushReplacementNamed('/pages', arguments: 0);
    }
  }

  Future<void> waitForDriverData(String id) async {
    final sharedPrefs = await _sharedPrefs;
    final value = await getUserData(id);
    setState(() => driver = value == null ? User() : value);
    final imageBase = await imgBase();
    final imgbase = await sharedPrefs.setString("imgBase", imageBase);
    if (value != null && value.apiToken != null) {
      final fullurlimg =
          await sharedPrefs.setString("fullimgurl", imageBase + value.s3url);
      final n = await sharedPrefs.setString("name", value.name);
      final m = await sharedPrefs.setString("mobile", value.mobile);
      final e = await sharedPrefs.setString("email", value.email);
    }
  }

  Future<void> getwalletdata(String id) async {
    final result = await getwallet(id);
  }

  Future<void> dashboard(String id) async {
    final result = await getdashdata(id);
    setState(() => dashbrd = result == null ? null : result);
  }

  Future<void> waitFordeliveredorders(Map<String, dynamic> body) async {
    final result = await getdeliveredOrders(body);
    setState(() => del_orders = result == null ? <Order>[] : result);
  }

  Future<void> waitupdatedriverloc(Map<String, dynamic> body) async {
    final result = await updatedriverloc(body);
    // print(result);
    //setState(() => orders = result == null ? <Order>[] : result);
  }

  Future waitupdatedriverstatus(Map<String, dynamic> body) async {
    final result = await updatedriverstatus(body);
    print(result);
    return result['success'];
    //setState(() => orders = result == null ? <Order>[] : result);
  }

  Future<void> userloc() async {
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

    driloc = await location.getLocation();
    setState(() {
      driverloction = LatLng(driloc.latitude, driloc.longitude);
    });
  }

  Future<void> waitUntilPasswordcheck(Map<String, dynamic> body) async {
    final value = await checkPassword(body);
    if (value) {
      iswrong = false;
    } else {
      iswrong = true;
      // final p = await Fluttertoast.showToast(
      //     msg: "Wrong Password", gravity: ToastGravity.BOTTOM);
    }
  }

  Future<void> waitUntilPasswordUpdate(Map<String, dynamic> body) async {
    final value = await updatePassword(body);
    if (value) {
      oldpass.clear();
      newpass.clear();
      confrimnewpass.clear();
      final p = await Fluttertoast.showToast(
          msg: "Your Password is Updated Successfully",
          gravity: ToastGravity.BOTTOM);
      Navigator.pop(stateMVC.context);
    } else {
      final p = await Fluttertoast.showToast(
          msg: "Something went wrong. Please try again",
          gravity: ToastGravity.BOTTOM);
    }
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

  void waitUntilProfileUpdate(Map<String, dynamic> body) async {
    final value = await updateProfile(body);
    final p = await Fluttertoast.showToast(
        msg: !value
            ? "Error Updating Profile"
            : "Your Profile is Updated Successfully",
        gravity: ToastGravity.BOTTOM);
    final sharedPrefs = await _sharedPrefs;
    if (!value) {
    } else {
      final name = await sharedPrefs.setString("name", body['name']);
      print("name");
      final phone = await sharedPrefs.setString("email", body['email']);
      print("phone");
    }
    if (p) Navigator.pop(stateMVC.context);
  }
}
