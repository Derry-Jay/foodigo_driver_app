import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:foodigo_driver_app/controllers/order_controller.dart';
import 'package:foodigo_driver_app/elements/CircularLoadingWidget.dart';
import 'package:foodigo_driver_app/elements/deliver_order_item_widget.dart';
import 'package:foodigo_driver_app/models/order.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:location/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverTasksPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DriverTasksPageState();
}

class DriverTasksPageState extends StateMVC<DriverTasksPage> {
  OrderController _con;
  int page = 1;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  MediaQueryData get dimensions => MediaQuery.of(context);
  double get height => dimensions.size.height;
  double get width => dimensions.size.width;
  double get size => sqrt(pow(height, 2) + pow(width, 2));
  DriverTasksPageState() : super(OrderController()) {
    _con = controller;
  }
  final firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'Foodigo2021Driver', // id
    'Foodigo', // title
    'Foodigofooddeliveryapp', // description
    importance: Importance.high,
    enableVibration: true,
    // priority: Priority.Max,
    enableLights: true,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('loud_notification'),
  );
  AndroidNotificationDetails androidPlatformChannel =
      AndroidNotificationDetails(
    'Foodigo2021Driver',
    'Foodigo',
    'Foodigofooddeliveryapp',
    // color: Color.fromARGB(255, 0, 0, 0),
    importance: Importance.high,
    playSound: true,
    priority: Priority.high,
    sound: RawResourceAndroidNotificationSound('loud_notification'),
    showWhen: false,
  );

  LatLng driverloc;
  bool loaddata = false;
  bool swith = false;
  bool walletactive = true;
  Location location = new Location();
  Future<void> getData() async {
    final sharedPrefs = await _sharedPrefs;
    print("latitude");
    print(sharedPrefs.getString("latitude"));
    // await _con.driverloc();
    // LocationData driloc = await location.getLocation();
    String lat = sharedPrefs.getString("latitude");
    String long = sharedPrefs.getString("longitude");
    driverloc = LatLng(double.tryParse(lat), double.tryParse(long));
    Map<String, dynamic> body = {
      "user_id": sharedPrefs.getString("spDriverID"),
      "latitude": lat, //_con.driverloction.latitude.toString(),
      "longitude": long, //_con.driverloction.longitude.toString(),
      "radius": '500',
      "page": "1"
    };
    await _con.waitForOrders(body);
    print("checking");
    setState(() {
      loaddata = true;
    });
  }

  void setValues() async {
    final sharedPrefs = await _sharedPrefs;
    setState(() {
      swith = sharedPrefs.containsKey("state")
          ? sharedPrefs.getBool("state")
          : false;
      walletactive = sharedPrefs.containsKey("waletactive")
          ? sharedPrefs.getBool("waletactive")
          : true;
      // c = sharedPrefs.containsKey("flag") ? sharedPrefs.getInt("flag") : 0;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _con.getconnect_status(context);
    firebaseMessaging.setForegroundNotificationPresentationOptions(
        sound: true, badge: true, alert: true);
    firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);
    var initialzationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/logo');
    var initializationSettings =
        InitializationSettings(android: initialzationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification.title == 'Order accepted by another driver') {
        getData();
        // flutterLocalNotificationsPlugin.show(
        //     notification.hashCode,
        //     notification.title,
        //     notification.body,
        //     NotificationDetails(
        //       android: AndroidNotificationDetails(
        //         channel.id,
        //         channel.name,
        //         channel.description,
        //         icon: android?.smallIcon,
        //       ),
        //     ));
      } else if (notification.title == 'New order just arrived') {
        getData();
        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channel.description,
                  icon: android?.smallIcon,
                  playSound: true,
                  priority: Priority.high,
                  sound:
                      RawResourceAndroidNotificationSound('loud_notification'),
                ),
              ));
        }
      } else {
        getData();
        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channel.description,
                  icon: android?.smallIcon,
                  playSound: true,
                  priority: Priority.high,
                  sound:
                      RawResourceAndroidNotificationSound('loud_notification'),
                ),
              ));
        }
      }
    });
    setValues();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: getList(_con.orders),
    );
  }

  Widget getList(List<Order> orders) {
    return !walletactive
        ? Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: Text(
                "Your account is blocked Please pay the amount to activate",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffa11414)),
                textAlign: TextAlign.center,
              ),
            ),
          )
        : !swith
            ? Center(
                child: Text(
                  "You are offline",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffa11414)),
                ),
              )
            : loaddata == false
                ? CircularLoadingWidget()
                : orders.length == 0
                    ? Center(
                        child: Text(
                          "No Orders Found",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffa11414)),
                        ),
                      )
                    : LazyLoadScrollView(
                        scrollDirection: Axis.vertical,
                        onEndOfPage: () async {
                          final sharedPrefs = await _sharedPrefs;
                          print("object");
                          page++;
                          await _con.driverloc();
                          Map<String, dynamic> body = {
                            "user_id": sharedPrefs.getString("spDriverID"),
                            "latitude": _con.driverloction.latitude.toString(),
                            "longitude":
                                _con.driverloction.longitude.toString(),
                            "radius": '500',
                            "page": page.toString()
                          };
                          await _con.waitForOrders(body);
                        },
                        child: RefreshIndicator(
                          onRefresh: getData,
                          child: Scrollbar(
                            child: ListView.builder(
                                itemCount: orders.length,
                                itemBuilder: (context, index) {
                                  // if (index == orders.length - 1) {
                                  //   return Center(child: CircularLoadingWidget());
                                  // } else {
                                  return OrderItemWidget(
                                      order: _con.orders[index],
                                      driloc: driverloc //_con.driverloction,
                                      );
                                  // }
                                }),
                          ),
                        ),
                      );
  }

  @override
  void didUpdateWidget(DriverTasksPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    getData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print(AppLifecycleState.values);
    print(_con.orders.isEmpty && state == AppLifecycleState.paused);
    if (state == AppLifecycleState.resumed) getData();
    // else
    //   print(state);
  }
}
