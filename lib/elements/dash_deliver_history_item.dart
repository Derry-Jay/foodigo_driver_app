import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_driver_app/helpers/helper.dart';
import 'package:geocoder/geocoder.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/order_controller.dart';
import '../models/order.dart';

class DashdeliverHistory extends StatefulWidget {
  final Order order;
  DashdeliverHistory({Key key, @required this.order}) : super(key: key);
  @override
  State<StatefulWidget> createState() => OrderItemWidgetState();
}

class OrderItemWidgetState extends StateMVC<DashdeliverHistory> {
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

  void getData() async {
    final sharedPrefs = await _sharedPrefs;
    _con.waitForUserData(widget.order.userID);
    // _con.waitForHotelData(widget.order.hotelID);
    _con.waitForDriverData(sharedPrefs.getString("spDriverID"));
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
                              Text("Earnings : ",
                                  style: TextStyle(
                                      color: Color(0xff181c02),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              Text((widget.order.deliveryFee).toString(),
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
                      Row(
                        children: [
                          Text(
                              "Duration :" +
                                  (Helper.travelTime(
                                          widget.order.resLoc,
                                          widget.order.driLoc,
                                          widget.order.resLoc,
                                          widget.order.cusLoc))
                                      .roundToDouble()
                                      .toString() +
                                  " mins",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff200303))),
                          SizedBox(width: width / 20),
                          Text(
                              "Distance : " +
                                  (Helper.getDistanceFromLatLonInKm(
                                              widget.order.resLoc,
                                              widget.order.driLoc) +
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
            // Row(children: [
            //   OutlinedButton(
            //       onPressed: () async {
            //         final sharedPrefs = await _sharedPrefs;
            //         Map<String, dynamic> body = {
            //           "order_id": widget.order.id,
            //           "driver_id": sharedPrefs.getString("spDriverID"),
            //           "driver_lat": _con.driver.location.latitude.toString(),
            //           "driver_lang": _con.driver.location.longitude.toString()
            //         };
            //         //print(body['order_id']);
            //         _con.waitUntilRejecttOrder(body);
            //         // print("${widget.order.resLoc.latitude}"
            //         //         " and "
            //         //         "${widget.order.resLoc.longitude}" +
            //         //     " AND " +
            //         //     "${widget.order.driLoc.latitude}"
            //         //         " and "
            //         //         "${widget.order.driLoc.longitude}"
            //         //         " and "
            //         //         "${widget.order.cusLoc.latitude}"
            //         //         " and "
            //         //         "${widget.order.cusLoc.longitude}");
            //       },
            //       style: ButtonStyle(
            //         shape: MaterialStateProperty.all(RoundedRectangleBorder(
            //             borderRadius: BorderRadius.only(
            //                 bottomLeft: Radius.circular(size / 100)))),
            //         side: MaterialStateProperty.all(
            //             BorderSide(color: Color(0xffa11414))),
            //       ),
            //       child: Container(
            //           height: height / 25,
            //           child: Center(
            //             child: Text("REJECT",
            //                 style: TextStyle(
            //                     fontWeight: FontWeight.w700,
            //                     color: Color(0xffa11414))),
            //           ),
            //           width: width / 2.62144)),
            //   OutlinedButton(
            //     onPressed: () async {
            //       final sharedPrefs = await _sharedPrefs;
            //       // print(_con.driver);
            //       // print(_con.driver.location.latitude);
            //       // print(_con.driver.location.longitude);
            //       Map<String, dynamic> body = {
            //         "order_id": widget.order.id,
            //         "driver_id": sharedPrefs.getString("spDriverID"),
            //         "driver_lat": _con.driver.location.latitude.toString(),
            //         "driver_lang": _con.driver.location.longitude.toString()
            //       };
            //       _con.waitUntilAcceptOrder(body, widget.order);
            //     },
            //     // color: Colors.greenAccent,
            //     child: Container(
            //         child: Center(
            //           child: Text("ACCEPT",
            //               style: TextStyle(
            //                   fontWeight: FontWeight.w700,
            //                   color: Colors.white)),
            //         ),
            //         width: width / 2.76),
            //     style: ButtonStyle(
            //         minimumSize:
            //             MaterialStateProperty.all(Size.square(size / 25)),
            //         shape: MaterialStateProperty.all(RoundedRectangleBorder(
            //             borderRadius: BorderRadius.only(
            //                 bottomRight: Radius.circular(size / 200)))),
            //         side: MaterialStateProperty.all(
            //             BorderSide(color: Color(0xffa11414))),
            //         foregroundColor: MaterialStateProperty.all(Colors.white),
            //         backgroundColor:
            //             MaterialStateProperty.all(Color(0xffa11414))),
            //   )
            // ], crossAxisAlignment: CrossAxisAlignment.end)
          ], crossAxisAlignment: CrossAxisAlignment.start),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(size / 100)),
            color: Color(0xfff7f7f7),
          ),
        ),
        elevation: 0,
        margin: EdgeInsets.symmetric(
            horizontal: width / 25, vertical: height / 60));
  }
}
