import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_driver_app/helpers/helper.dart';
import 'package:foodigo_driver_app/models/paymentHistory.dart';
import 'package:geocoder/geocoder.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/order_controller.dart';
import '../models/order.dart';

class PaymenthistoryWidget extends StatefulWidget {
  final Paymenthistory paymenthistory;
  PaymenthistoryWidget({Key key, @required this.paymenthistory})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => OrderItemWidgetState();
}

class OrderItemWidgetState extends StateMVC<PaymenthistoryWidget> {
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

  // void getData() async {
  //   final sharedPrefs = await _sharedPrefs;
  //   _con.waitForUserData(widget.order.userID);
  //   // _con.waitForHotelData(widget.order.hotelID);
  //   _con.waitForDriverData(sharedPrefs.getString("spDriverID"));
  //   final del_coord = new Coordinates(
  //       widget.order.cusLoc.latitude, widget.order.cusLoc.longitude);
  //   var addresses =
  //       await Geocoder.local.findAddressesFromCoordinates(del_coord);
  //   del_address = addresses.first;
  //   final res_coord = new Coordinates(
  //       widget.order.resLoc.latitude, widget.order.resLoc.longitude);
  //   var addresses1 =
  //       await Geocoder.local.findAddressesFromCoordinates(res_coord);
  //   res_address = addresses1.first;
  //   setState(() {
  //     check = true;
  //   });
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getData();
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
                            child: Row(children: [
                              Text("Successfull ",
                                  style: TextStyle(
                                      color: Color(0xff181c02),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                            ]),
                            decoration: BoxDecoration(
                                color: Color(0xffbad600),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(size / 200))),
                            padding: EdgeInsets.symmetric(
                                horizontal: width / 50, vertical: height / 200))
                      ], mainAxisAlignment: MainAxisAlignment.end),
                      Text(
                          "Amount : ₹ ${widget.paymenthistory.amount.toString()}",
                          style: TextStyle(
                              color: Color(0xffa11414),
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700)),
                      SizedBox(height: height / 100),
                      Text("Mode of Pay".toUpperCase(),
                          style: TextStyle(
                              color: Color(0xff676666),
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                      SizedBox(height: height / 128),
                      Text(
                          widget.paymenthistory.method.toUpperCase().toString(),
                          style: TextStyle(
                              color: Color(0xff110202),
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                      SizedBox(height: height / 80),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Balance",
                                  style: TextStyle(
                                      color: Color(0xff676666),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: height / 80),
                              Text(
                                  "₹ ${widget.paymenthistory.balance.toString()}",
                                  style: TextStyle(
                                      color: Color(0xff110202),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                            ],
                          ),
                          SizedBox(width: width / 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Date & Time",
                                  style: TextStyle(
                                      color: Color(0xff676666),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: height / 80),
                              Text(widget.paymenthistory.paid_date.toString(),
                                  style: TextStyle(
                                      color: Color(0xff110202),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: height / 50,
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly),
                padding: EdgeInsets.only(left: width / 50)),
          ], crossAxisAlignment: CrossAxisAlignment.start),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(size / 100)),
            color: Color(0xfff7f7f7),
          ),
        ),
        elevation: 0,
        margin: EdgeInsets.symmetric(
            horizontal: width / 25, vertical: height / 40));
  }
}
