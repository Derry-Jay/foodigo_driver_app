import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_driver_app/helpers/helper.dart';
import 'package:foodigo_driver_app/pages/driver_tasks_page.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_platform_interface/location_platform_interface.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:location/location.dart';
import '../controllers/order_controller.dart';
import '../models/order.dart';

class OrderItemWidget extends StatefulWidget {
  final Order order;
  final LatLng driloc;
  OrderItemWidget({Key key, @required this.order, this.driloc})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => OrderItemWidgetState();
  static DriverTasksPageState of(BuildContext context) =>
      context.findAncestorStateOfType<DriverTasksPageState>();
}

class OrderItemWidgetState extends StateMVC<OrderItemWidget> {
  DriverTasksPageState dts;
  OrderController _con;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  MediaQueryData get dimensions => MediaQuery.of(context);
  double get height => dimensions.size.height;
  double get width => dimensions.size.width;
  double get size => sqrt(pow(height, 2) + pow(width, 2));
  OrderItemWidgetState() : super(OrderController()) {
    _con = controller;
  }
  var del_address;
  var res_address;
  bool check = false;
  bool isloading = false;

  void getData() async {
    final sharedPrefs = await _sharedPrefs;
    await _con.waitForUserData(widget.order.userID);
    await _con.waitForHotelData(widget.order.hotelID);
    // _con.waitForDriverData(sharedPrefs.getString("spDriverID"));
    // final del_coord = new Coordinates(
    //     widget.order.cusLoc.latitude, widget.order.cusLoc.longitude);
    // var addresses =
    //     await Geocoder.local.findAddressesFromCoordinates(del_coord);
    // del_address = addresses.first;
    // final res_coord = new Coordinates(
    //     widget.order.resLoc.latitude, widget.order.resLoc.longitude);
    // var addresses1 =
    //     await Geocoder.local.findAddressesFromCoordinates(res_coord);
    // res_address = addresses1.first;
    setState(() {
      check = true;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  //   getData();
  // }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
          child: Column(children: <Widget>[
            Container(
                child: Column(
                    children: [
                      Row(children: [
                        Container(
                            child: Text("#" + widget.order.id,
                                style: TextStyle(
                                    color: Color(0xff1d1707),
                                    fontWeight: FontWeight.w600)),
                            margin: EdgeInsets.only(top: height / 200)),
                        Container(
                            child: Row(children: [
                              Text("Approx Earnings : ",
                                  style: TextStyle(
                                      color: Color(0xff181c02),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              Text("₹ ${widget.order.deliveryFee.toString()}",
                                  style: TextStyle(
                                      color: Color(0xff181c02),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold))
                            ]),
                            decoration: BoxDecoration(
                                color: Color(0xffbad600),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(size / 200))),
                            padding: EdgeInsets.symmetric(
                                horizontal: width / 50, vertical: height / 200))
                      ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                      Text(_con.user.name == null ? "" : _con.user.name,
                          style: TextStyle(
                              color: Color(0xff1d1707),
                              fontWeight: FontWeight.w600)),
                      SizedBox(height: height / 100),
                      Text("Delivery Address".toUpperCase(),
                          style: TextStyle(
                              color: Color(0xff676666),
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                      SizedBox(height: height / 128),
                      // Text(check ? _con.user.name.toString() : '...',
                      //     style: TextStyle(
                      //         color: Color(0xff110202),
                      //         fontWeight: FontWeight.w500,
                      //         fontSize: 14)),
                      // SizedBox(height: height / 80),
                      Text(
                          check
                              ? widget.order.deliveryaddress.toString()
                              : '...',
                          style: TextStyle(
                              color: Color(0xff110202),
                              fontWeight: FontWeight.w500,
                              fontSize: 14)),
                      SizedBox(height: height / 80),
                      Text("PICK UP LOCATION",
                          style: TextStyle(
                              color: Color(0xff676666),
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                      SizedBox(height: height / 128),
                      Text(check ? _con.hotel.name.toString() : '...',
                          style: TextStyle(
                              color: Color(0xff110202),
                              fontWeight: FontWeight.w500)),
                      SizedBox(height: height / 100),
                      Text(check ? widget.order.resaddress.toString() : '...',
                          style: TextStyle(
                              color: Color(0xff110202),
                              fontWeight: FontWeight.w500)),
                      SizedBox(height: height / 100),
                      Text(
                          widget.order.paymentmethod == 'razorpay'
                              ? "Payment Mode : Online"
                              : "Payment Mode : Cash",
                          style: TextStyle(
                              color: Color(0xff110202),
                              fontWeight: FontWeight.w700)),
                      SizedBox(height: height / 100),
                      Row(
                        children: [
                          Text(
                              "Duration : " +
                                  (Helper.travelTime(
                                          widget.order.resLoc,
                                          widget.driloc,
                                          widget.order.resLoc,
                                          widget.order.cusLoc))
                                      .roundToDouble()
                                      .toString() +
                                  "mins",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff200303))),
                          SizedBox(width: width / 20),
                          Text(
                              "Distance : " +
                                  (Helper.getDistanceFromLatLonInKm(
                                              widget.order.resLoc,
                                              widget.driloc) +
                                          Helper.getDistanceFromLatLonInKm(
                                              widget.order.resLoc,
                                              widget.order.cusLoc))
                                      .roundToDouble()
                                      .toString() +
                                  " Kms",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff200303)))
                        ],
                      ),
                      SizedBox(
                        height: height / 50,
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly),
                padding: EdgeInsets.only(left: width / 50)),
            Row(children: [
              OutlinedButton(
                  onPressed: () async {
                    final sharedPrefs = await _sharedPrefs;
                    Map<String, dynamic> body = {
                      "order_id": widget.order.id,
                      "driver_id": sharedPrefs.getString("spDriverID"),
                      "driver_lat": widget.driloc.latitude.toString(),
                      "driver_lang": widget.driloc.longitude.toString()
                    };
                    //print(body['order_id']);
                    _con.waitUntilRejecttOrder(body);
                    // print("${widget.order.resLoc.latitude}"
                    //         " and "
                    //         "${widget.order.resLoc.longitude}" +
                    //     " AND " +
                    //     "${widget.driloc.latitude}"
                    //         " and "
                    //         "${widget.driloc.longitude}"
                    //         " and "
                    //         "${widget.order.cusLoc.latitude}"
                    //         " and "
                    //         "${widget.order.cusLoc.longitude}");
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(size / 100)))),
                    side: MaterialStateProperty.all(
                        BorderSide(color: Color(0xffa11414))),
                  ),
                  child: Container(
                      height: height / 25,
                      child: Center(
                        child: Text("REJECT",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xffa11414))),
                      ),
                      width: width / 2.62144)),
              OutlinedButton(
                onPressed: () async {
                  setState(() {
                    isloading = true;
                  });
                  final sharedPrefs = await _sharedPrefs;
                  print("_con.driver");

                  // print(_con.driver.location.latitude);
                  // print(_con.driver.location.longitude);
                  Map<String, dynamic> body = {
                    "order_id": widget.order.id,
                    "user_id": sharedPrefs.getString("spDriverID"),
                    "driver_lat": widget.driloc.latitude.toString(),
                    "driver_lang": widget.driloc.longitude.toString()
                  };

                  await _con.waitUntilAcceptOrder(body, widget.order);
                  setState(() {
                    isloading = false;
                  });
                },
                // color: Colors.greenAccent,
                child: Container(
                    child: Center(
                      child: Text(isloading ? "Processing..." : "ACCEPT",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                    width: width / 2.76),
                style: ButtonStyle(
                    minimumSize:
                        MaterialStateProperty.all(Size.square(size / 25)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(size / 200)))),
                    side: MaterialStateProperty.all(BorderSide(
                        color:
                            isloading ? Color(0xff817C7C) : Color(0xffa11414))),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor: isloading
                        ? MaterialStateProperty.all(Color(0xff817C7C))
                        : MaterialStateProperty.all(Color(0xffa11414))),
              )
            ], crossAxisAlignment: CrossAxisAlignment.end)
          ], crossAxisAlignment: CrossAxisAlignment.start),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(size / 100)),
            color: Color(0xfff7f7f7),
          ),
        ),
        elevation: 0,
        margin: EdgeInsets.symmetric(
            horizontal: width / 25, vertical: height / 32));
  }
}
