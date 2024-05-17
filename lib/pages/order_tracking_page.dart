import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:foodigo_driver_app/controllers/order_controller.dart';
import 'package:foodigo_driver_app/elements/bottom_sheet.dart';
import 'package:foodigo_driver_app/helpers/helper.dart';
import 'package:foodigo_driver_app/models/order.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location_platform_interface/location_platform_interface.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../repos/orders_repository.dart';

class OrderTrackingPage extends StatefulWidget {
  final Order order;
  OrderTrackingPage({Key key, @required this.order}) : super(key: key);

  @override
  OrderTrackingPageState createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends StateMVC<OrderTrackingPage>
    with AutomaticKeepAliveClientMixin {
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  Helper hp;
  OrderController _con;
  Location location = new Location();
  LocationData customerLocation, driverLocation, hotelLocation;
  BitmapDescriptor driverIcon, customerIcon, hotelIcon;
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  OrderTrackingPageState() : super(OrderController()) {
    _con = controller;
  }
  bool loaddata = false;
  Timer timer;
  double kms;
  String traveltime;
  bool loadkm = false;
  // bool orderpick = false;
  // bool reachres = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _con.getconnect_status(context);
    initialstatusset();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => setstatus());
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => locsetstatus());
    print(widget.order.orderstatusid);
    hp = Helper.of(context);
    Future.delayed(Duration.zero, () {
      getData();
    });
    fetchdata();
  }

  void fetchdata() async {
    await _con.waitForfooddetails(widget.order.id);
    await _con.waitForUserData(widget.order.userID);
    await _con.waitForHotelData(widget.order.hotelID);
    setState(() {
      loaddata = true;
    });
  }

  void initialstatusset() async {
    if (widget.order.orderstatusid == '4') {
      setState(() {
        _con.reachres = true;
      });
    } else if (widget.order.orderstatusid == '6') {
      setState(() {
        _con.reachres = true;
        _con.orderpack = true;
        _con.orderpick = true;
      });
    } else if (widget.order.orderstatusid == '5') {
      setState(() {
        _con.reachres = true;
        _con.orderpack = true;
      });
    }
    await _con.driverloc();
    traveltime = Helper.travelTime(widget.order.resLoc, _con.driverloction,
            widget.order.resLoc, widget.order.cusLoc)
        .round()
        .toString();
    kms = Helper.getDistanceFromLatLonInKm(
            widget.order.resLoc, _con.driverloction) +
        Helper.getDistanceFromLatLonInKm(
                widget.order.resLoc, widget.order.cusLoc)
            .round();
    setState(() {
      loadkm = true;
    });
  }

  void setstatus() async {
    //print('timer working');
    await _con.waitFororderstatus(widget.order.id);
    if (_con.orderstatus.orderstatusid == '4') {
      setState(() {
        _con.reachres = true;
      });
    } else if (_con.orderstatus.orderstatusid == '6') {
      setState(() {
        _con.orderpick = true;
      });
    } else if (_con.orderstatus.orderstatusid == '5') {
      setState(() {
        _con.orderpack = true;
      });
    }
  }

  void locsetstatus() async {
    await _con.driverloc();
    setState(() {
      kms = Helper.getDistanceFromLatLonInKm(
              widget.order.resLoc, _con.driverloction) +
          Helper.getDistanceFromLatLonInKm(
                  widget.order.resLoc, widget.order.cusLoc)
              .round();
    });
    if (_con.orderstatus.orderstatusid != '4' &&
        _con.orderstatus.orderstatusid != '6' &&
        _con.orderstatus.orderstatusid != '5') {
      double locdata1 =
          Helper.distanceInMeters(_con.driverloction, widget.order.resLoc)
              .round()
              .toDouble();
      if (locdata1 <= 500) {
        setState(() {
          _con.nearres = true;
        });
      }
    } else if (_con.orderstatus.orderstatusid == '6') {
      double locdata1 =
          Helper.distanceInMeters(_con.driverloction, widget.order.cusLoc)
              .round()
              .toDouble();
      if (locdata1 <= 500) {
        setState(() {
          _con.nearcus = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    super.build(context);
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {},
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Color(0xfffbfbfb),
            title: Text("Delivery Status"),
            // leading: IconButton(
            //   onPressed: () {},
            //   icon: Icon(
            //     Icons.time_to_leave,
            //   ),
            // ),
            elevation: 0),
        bottomNavigationBar: OutlinedButton(
          onPressed: () async {
            // _con.waitUntilgetotp();

            // setState(() {
            //   _con.reachres = true;
            // });
            // _con.orderpick
            //     ? _con.waitUntilgetotp()
            //     : bottomsheet();
            if (_con.orderstatus.orderstatusid != '4' &&
                _con.orderstatus.orderstatusid != '6' &&
                _con.orderstatus.orderstatusid != '5') {
              _con.nearres ? orderaction() : null;
            } else if (_con.orderstatus.orderstatusid == '4' ||
                _con.orderstatus.orderstatusid == '5') {
              orderaction();
            } else if (_con.orderstatus.orderstatusid == '6') {
              _con.nearcus ? orderaction() : null;
              //orderaction();
            }
            // print(Helper.distanceInMeters(
            //         _con.driverloction, widget.order.resLoc)
            //     .round()
            //     .toDouble()
            //     .toString());
            // print(_con.driverloction.latitude.toString());
          },
          // color: Colors.greenAccent,
          child: Container(
            child: Center(
              child: Text(
                  _con.orderpick
                      ? "ENTER CUSTOMER OTP"
                      : _con.orderpack
                          ? "ORDER PICKED"
                          : _con.reachres
                              ? "ORDER PICKED"
                              : "REACHED RESTAURANT",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
            width: width,
            height: height / 13,
          ),
          style: ButtonStyle(
              //minimumSize: double.infinity,
              side: MaterialStateProperty.all(
                  BorderSide(color: Color(0xffa11414))),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              backgroundColor: MaterialStateProperty.all(_con.orderpick
                  ? _con.nearcus
                      ? Color(0xffa11414)
                      : Color(0xff817C7C)
                  : _con.orderpack
                      ? Color(0xffa11414)
                      : _con.reachres
                          ? Color(0xff817C7C)
                          : _con.nearres
                              ? Color(0xffa11414)
                              : Color(0xff817C7C))),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                height: height / 2.8,
                child: GoogleMap(
                  initialCameraPosition: _con.initialCameraPosition,
                  onMapCreated: onMapCreated,
                  markers: _con.markers,
                  polylines: _con.polyLines,
                ),
              ),
              Align(
                  child: Container(
                      height: height / 1.8,
                      child: SingleChildScrollView(
                        child: Column(
                            children: [
                              Container(
                                  height: height / 20,
                                  child: Row(
                                      children: [
                                        Text(
                                            loadkm
                                                ? "Estimated Arrival : " +
                                                    traveltime.toString() +
                                                    " Min"
                                                : "Estimated Arrival : ... Min",
                                            style: TextStyle(
                                                color: Color(0xff200303),
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12)),
                                        Text(
                                            loadkm
                                                ? "Distance : " +
                                                    kms.round().toString() +
                                                    " Kms"
                                                : "Distance :  .... kms",
                                            style: TextStyle(
                                                color: Color(0xff200303),
                                                fontWeight: FontWeight.w400))
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween),
                                  decoration: BoxDecoration(
                                      color: Color(0xffBAD600),
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(radius / 160))),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: width / 32,
                                      vertical: height / 1000),
                                  margin: EdgeInsets.only(bottom: height / 50)),
                              loaddata
                                  ? Container(
                                      //height: height / 5,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: width / 32),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text("Order ID: #" + widget.order.id,
                                              style: TextStyle(
                                                  color: Color(0xff200303),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(height: height / 90),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("PICK UP LOCATION",
                                                  style: TextStyle(
                                                      color: Color(0xff676666),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              SizedBox(height: height / 128),
                                              Text(_con.hotel.name.toString(),
                                                  style: TextStyle(
                                                      color: Color(0xff110202),
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 13)),
                                              SizedBox(height: height / 128),
                                              Text(
                                                  _con.hotel.address.toString(),
                                                  style: TextStyle(
                                                      color: Color(0xff110202),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 13)),
                                              SizedBox(height: height / 80),
                                              Text(
                                                  "Delivery Address"
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                      color: Color(0xff676666),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              SizedBox(height: height / 100),
                                              Text(_con.user.name.toString(),
                                                  style: TextStyle(
                                                      color: Color(0xff110202),
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                              SizedBox(height: height / 100),
                                              Text(
                                                widget.order.deliveryaddress
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Color(0xff110202),
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w500),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  : Center(
                                      child: CircularProgressIndicator(),
                                    ),
                              Container(
                                width: width,
                                child: Text("Location Navigation",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15)),
                                decoration: BoxDecoration(
                                  color: Color(0xffFCEAEA),
                                  // borderRadius: BorderRadius.all(Radius.circular(radius / 100)),
                                ),
                                margin:
                                    EdgeInsets.symmetric(vertical: height / 64),
                                padding: const EdgeInsets.all(10.0),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width / 32,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        openMap(widget.order.cusLoc.latitude,
                                            widget.order.cusLoc.longitude);
                                      },
                                      child: Container(
                                        child: Column(
                                          children: [
                                            CircleAvatar(
                                              //backgroundImage:,
                                              backgroundColor:
                                                  Color(0xffa11414),
                                              radius: 22,
                                              child: Center(
                                                child: Image.asset(
                                                    'assets/images/person.png'),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20.0,
                                            ),
                                            Text(
                                              "CUSTOMER",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xff200303),
                                                  fontWeight: FontWeight.w700),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        openMap(widget.order.resLoc.latitude,
                                            widget.order.resLoc.longitude);
                                      },
                                      child: Container(
                                        child: Column(
                                          children: [
                                            CircleAvatar(
                                              //backgroundImage:,
                                              backgroundColor:
                                                  Color(0xffa11414),
                                              radius: 22,
                                              child: Center(
                                                child: Image.asset(
                                                    'assets/images/fork.png'),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20.0,
                                            ),
                                            Text(
                                              "RESTAURANT",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xff200303),
                                                  fontWeight: FontWeight.w700),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Container(),
                                    Container(),
                                  ],
                                ),
                              ),
                              Container(
                                  height: height / 25,
                                  child: Row(
                                      children: [
                                        // Text(widget.order.orderStatus.status,
                                        //     style: TextStyle(
                                        //         color: Color(0xff181C02),
                                        //         fontWeight: FontWeight.w600,
                                        //         fontSize: 12)),
                                        // SizedBox(
                                        //   width: width / 16
                                        // ),,
                                        Text(
                                            _con.orderpick
                                                ? widget.order.paymentmethod ==
                                                        "razorpay"
                                                    ? "Mode of payment"
                                                    : "Amount To Be Collected"
                                                : "Food Order Details",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15)),
                                        _con.reachres
                                            ? OutlinedButton(
                                                onPressed: () {
                                                  _con.orderpick
                                                      ? null
                                                      : bottomsheet();
                                                },
                                                style: ButtonStyle(
                                                  //minimumSize: double.infinity,
                                                  side: MaterialStateProperty
                                                      .all(BorderSide(
                                                          color: Colors
                                                              .transparent)),
                                                ),
                                                child: Text(
                                                    _con.orderpick
                                                        ? loaddata
                                                            ? widget.order
                                                                        .paymentmethod ==
                                                                    "razorpay"
                                                                ? "Online"
                                                                : "₹ ${widget.order.totalAmount.toString()}"
                                                            : "..."
                                                        : "View Checklist",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            Color(0xffa11414))))
                                            : Container(),
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween),
                                  decoration: BoxDecoration(
                                    color: Color(0xffFCEAEA),
                                    // borderRadius: BorderRadius.all(Radius.circular(radius / 100)),
                                  ),
                                  margin: EdgeInsets.symmetric(
                                      vertical: height / 64),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: width / 25)),
                              loaddata
                                  ? Container(
                                      //height: height / 7.5,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width / 32,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Contact",
                                              style: TextStyle(
                                                  color: Color(0xff200303),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(height: height / 90),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  launch(
                                                      "tel:${_con.user.mobile}");
                                                },
                                                child: Container(
                                                  child: Column(
                                                    children: [
                                                      CircleAvatar(
                                                        //backgroundImage:,
                                                        backgroundColor:
                                                            Color(0xffBAD600),
                                                        radius: 22,
                                                        child: Center(
                                                          child: Image.asset(
                                                              'assets/images/person.png'),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 5.0,
                                                      ),
                                                      Text(
                                                        "CUSTOMER",
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            color: Color(
                                                                0xff200303),
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // SizedBox(width: width / 10),
                                              GestureDetector(
                                                onTap: () {
                                                  launch(
                                                      "tel:${_con.hotel.phone}");
                                                },
                                                child: Container(
                                                  child: Column(
                                                    children: [
                                                      CircleAvatar(
                                                        //backgroundImage:,
                                                        backgroundColor:
                                                            Color(0xffBAD600),
                                                        radius: 22,
                                                        child: Center(
                                                          child: Image.asset(
                                                              'assets/images/fork.png'),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 5.0,
                                                      ),
                                                      Text(
                                                        "RESTAURANT",
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            color: Color(
                                                                0xff200303),
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // SizedBox(width: width / 10),
                                              GestureDetector(
                                                onTap: () {
                                                  launch("tel:${18002085234}");
                                                },
                                                child: Container(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      CircleAvatar(
                                                        //backgroundImage:,
                                                        backgroundColor:
                                                            Color(0xffBAD600),
                                                        radius: 22,
                                                        child: Center(
                                                          child: Image.asset(
                                                              'assets/images/headphone.png'),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 5.0,
                                                      ),
                                                      Container(
                                                        width: width / 4.5,
                                                        child: Text(
                                                          "CUSTOMER SUPPORT",
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              color: Color(
                                                                  0xff200303),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // SizedBox(width: width / 10),
                                              _con.reachres
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        launch(
                                                            "tel:${18002085234}");
                                                      },
                                                      child: Container(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            CircleAvatar(
                                                              //backgroundImage:,
                                                              backgroundColor:
                                                                  Color(
                                                                      0xffBAD600),
                                                              radius: 22,
                                                              child: Center(
                                                                child: Image.asset(
                                                                    'assets/images/fork.png'),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 5.0,
                                                            ),
                                                            Container(
                                                              width: width / 6,
                                                              child: Text(
                                                                "TRANSFER ORDER",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Color(
                                                                        0xff200303),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  : Center(
                                      child: CircularProgressIndicator(),
                                    ),
                              // OutlinedButton(
                              //   onPressed: () async {
                              //     // _con.waitUntilgetotp();

                              //     // setState(() {
                              //     //   _con.reachres = true;
                              //     // });
                              //     // _con.orderpick
                              //     //     ? _con.waitUntilgetotp()
                              //     //     : bottomsheet();
                              //     if (_con.orderstatus.orderstatusid != '4' &&
                              //         _con.orderstatus.orderstatusid != '6' &&
                              //         _con.orderstatus.orderstatusid != '5') {
                              //       _con.nearres ? orderaction() : null;
                              //     } else if (_con.orderstatus.orderstatusid ==
                              //             '4' ||
                              //         _con.orderstatus.orderstatusid == '5') {
                              //       orderaction();
                              //     } else if (_con.orderstatus.orderstatusid ==
                              //         '6') {
                              //       _con.nearcus ? orderaction() : null;
                              //       //orderaction();
                              //     }
                              //     // print(Helper.distanceInMeters(
                              //     //         _con.driverloction, widget.order.resLoc)
                              //     //     .round()
                              //     //     .toDouble()
                              //     //     .toString());
                              //     // print(_con.driverloction.latitude.toString());
                              //   },
                              //   // color: Colors.greenAccent,
                              //   child: Container(
                              //     child: Center(
                              //       child: Text(
                              //           _con.orderpick
                              //               ? "ENTER CUSTOMER OTP"
                              //               : _con.orderpack
                              //                   ? "ORDER PICKED"
                              //                   : _con.reachres
                              //                       ? "ORDER PICKED"
                              //                       : "REACHED RESTAURANT",
                              //           style: TextStyle(
                              //               fontSize: 20,
                              //               fontWeight: FontWeight.w700,
                              //               color: Colors.white)),
                              //     ),
                              //     width: width,
                              //     height: height / 13,
                              //   ),
                              //   style: ButtonStyle(
                              //       //minimumSize: double.infinity,
                              //       side: MaterialStateProperty.all(
                              //           BorderSide(color: Color(0xffa11414))),
                              //       foregroundColor:
                              //           MaterialStateProperty.all(Colors.white),
                              //       backgroundColor:
                              //           MaterialStateProperty.all(_con.orderpick
                              //               ? _con.nearcus
                              //                   ? Color(0xffa11414)
                              //                   : Color(0xff817C7C)
                              //               : _con.orderpack
                              //                   ? Color(0xffa11414)
                              //                   : _con.reachres
                              //                       ? Color(0xff817C7C)
                              //                       : _con.nearres
                              //                           ? Color(0xffa11414)
                              //                           : Color(0xff817C7C))),
                              // )
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(radius / 100)),
                        // color: Color(0xfff7f7f7),
                        color: Colors.white,
                      )),
                  alignment: Alignment.bottomCenter)
            ],
          ),
        ),
      ),
    );
  }

  void orderaction() async {
    await _con.waitFororderstatus(widget.order.id);
    if (_con.orderstatus.orderstatusid != '4' &&
        _con.orderstatus.orderstatusid != '6' &&
        _con.orderstatus.orderstatusid != '5') {
      print(_con.orderstatus.orderstatusid);
      reach();
      print(_con.orderstatus.orderstatusid);
    } else if (_con.orderstatus.orderstatusid == '4' ||
        _con.orderstatus.orderstatusid == '5') {
      print(_con.orderstatus.orderstatusid);
      bottomsheet();
    } else if (_con.orderstatus.orderstatusid == '6') {
      print(_con.orderstatus.orderstatusid);
      if (widget.order.paymentmethod == 'razorpay') {
        _con.movto_otp(widget.order.id, 'OTP', '0');
      } else {
        _con.movto_otp(
            widget.order.id, 'Amount', widget.order.totalAmount.toString());
      }
    }
  }

  void bottomsheet() {
    showModalBottomSheet(
        isDismissible: true,
        enableDrag: true,
        context: context,
        builder: (BuildContext bc) {
          return Bottomsheet(
            fooddetails: _con.ordfood,
            orderid: widget.order.id,
          );
        }).then((value) => onback(value));
  }

  void reach() async {
    final sharedPrefs = await _sharedPrefs;
    Map<String, dynamic> reachbody = {
      "order_status_id": '4',
      "driver_id": sharedPrefs.getString("spDriverID"),
    };
    final value = await orderstatuschange(reachbody, widget.order.id);
    print(value);
    if (value['success']) {
      setState(() {
        _con.reachres = true;
        // _con.orderstatus.orderstatusid = value['data']['order_status_id'];
      });
      showModalBottomSheet(
          isDismissible: true,
          enableDrag: true,
          context: context,
          builder: (BuildContext bc) {
            return Bottomsheet(
              fooddetails: _con.ordfood,
              orderid: widget.order.id,
            );
          }).then((value) => onback(value));
    }
  }

  Future onback(value) async {
    if (value == 'Picked') {
      setState(() {
        _con.orderpick = true;
      });
    }
  }

  void updatePinOnMap() {
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    // final currentLocation = await location.getLocation();
    final GoogleMapController controller = _con.controller;
    final pinPosition =
        LatLng(driverLocation.latitude, driverLocation.longitude);
    CameraPosition cPosition = CameraPosition(
        zoom: 17.0,
        // tilt: CAMERA_TILT,
        // bearing: CAMERA_BEARING,
        target: pinPosition);
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // do this inside the setState() so Flutter gets notified
    // that a widget update is due
    setState(() {
      // updated position

      // the trick is to remove the marker (by id)
      // and add it again at the updated location
      _con.markers.removeWhere((m) => m.markerId.value == "driverPin");
      _con.markers.add(Marker(
          rotation: LocationData.fromMap(hp.locationToMap(pinPosition)).heading,
          markerId: MarkerId("driverPin"),
          position: pinPosition, // updated position
          icon: driverIcon));
    });
  }

  void showPinsOnMap() {
    Helper hp = new Helper.of(context);
    // get a LatLng for the source location
    // from the LocationData currentLocation object
    final pinPosition = widget.order.driLoc;
    final hotelPosition = widget.order.resLoc;
    final destPosition = widget.order.cusLoc;
    // add the initial source location pin
    setState(() {
      _con.markers.add(Marker(
          rotation: LocationData.fromMap(hp.locationToMap(pinPosition)).heading,
          markerId: MarkerId('driverPin'),
          position: pinPosition,
          icon: driverIcon));
      _con.markers.add(Marker(
          markerId: MarkerId('hotelPin'),
          position: hotelPosition,
          icon: hotelIcon));
      _con.markers.add(Marker(
          markerId: MarkerId('customerPin'),
          position: destPosition,
          icon: customerIcon));
    });
    // set the route lines on the map from source to destination
    // for more info follow this tutorial
    setLines();
  }

  void setSourceAndDestinationIcons() async {
    driverIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: height / width),
        'assets/images/driver_marker.png');
    hotelIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: height / width),
        'assets/images/restaurant_marker.png');
    customerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: height / width),
        'assets/images/customer_marker.png');
  }

  void setInitialLocation() {
    Helper hp = new Helper.of(context);
    final pinPosition = widget.order.driLoc;
    final hotelPosition = widget.order.resLoc;
    final destPosition = widget.order.cusLoc;
    customerLocation = LocationData.fromMap(hp.locationToMap(pinPosition));
    hotelLocation = LocationData.fromMap(hp.locationToMap(hotelPosition));
    driverLocation = LocationData.fromMap(hp.locationToMap(destPosition));
    _con.initialCameraPosition = CameraPosition(target: pinPosition, zoom: 25);
  }

  void setLines() async {
    final result = await _con.polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyA8LY3WgnfY0_FVP1ZwgLPibpOM_qk5X5Q",
        PointLatLng(
            widget.order.driLoc.latitude, widget.order.driLoc.longitude),
        PointLatLng(
            widget.order.cusLoc.latitude, widget.order.cusLoc.longitude));
    List<PointLatLng> points = result.points;
    if (points.isNotEmpty) {
      points.forEach((PointLatLng point) {
        _con.polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      setState(() {
        _con.polyLines.add(Polyline(
            width: 5, // set the width of the polylines
            polylineId: PolylineId("poly"),
            color: Color(0xffA11414),
            points: _con.polylineCoordinates));
      });
    }
  }

  static Future<void> openMap(latitude, longitude) async {
    // String googleUrl =
    //     'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    var googleUrl =
        Uri.parse("google.navigation:q=$latitude,$longitude&mode=d");
    if (await canLaunch(googleUrl.toString())) {
      await launch(googleUrl.toString());
    } else {
      throw 'Could not open the map.';
    }
  }

  void onMapCreated(GoogleMapController controller) {
    _con.controller = controller;
    showPinsOnMap();
  }

  void getData() async {
    final sharedPrefs = await _sharedPrefs;
    _con.waitForDriverData(sharedPrefs.getString("spDriverID"));
    _con.waitForHotelData(widget.order.hotelID);
    // _con.waitForOrderedFood(widget.order.orderID);
    // hp.lockScreenRotation();
    // set custom marker pins
    setSourceAndDestinationIcons();
    // set the initial location
    setInitialLocation();
    location.onLocationChanged.listen((LocationData cLoc) async {
      // cLoc contains the lat and long of the
      // current user's position in real time,
      // so we're holding on to it
      driverLocation = cLoc;
      var body = {
        "order_id": widget.order.id,
        "driver_lat": cLoc.latitude.toString(),
        "driver_lang": cLoc.longitude.toString()
      };
      await _con.waitUntilUpdateLocation(body);
      if (_con.data.status && _con.data.response.success) updatePinOnMap();
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
