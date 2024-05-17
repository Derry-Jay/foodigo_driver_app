import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_driver_app/elements/CircularLoadingWidget.dart';
import 'package:foodigo_driver_app/elements/dash_deliver_history_item.dart';
import 'package:foodigo_driver_app/elements/delivered_history_item_widget.dart';
import 'package:foodigo_driver_app/elements/grid_item_widget.dart';
import 'package:foodigo_driver_app/elements/my_switch.dart';
import 'package:foodigo_driver_app/models/order.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/user_controller.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends StateMVC<HomePage> {
  UserController _con;
  int a = 10, b = 100, c;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  bool val;
  bool check = false;
  Timer timer;
  MediaQueryData get dimensions => MediaQuery.of(context);
  double get height => dimensions.size.height;
  double get width => dimensions.size.width;
  double get size => sqrt(pow(height, 2) + pow(width, 2));
  HomePageState() : super(UserController()) {
    _con = controller;
  }

  void setValues() async {
    final sharedPrefs = await _sharedPrefs;
    setState(() {
      // val = sharedPrefs.containsKey("state")
      //     ? sharedPrefs.getBool("state")
      //     : false;
      val = _con.dashbrd.available == "1" ? true : false;
      c = sharedPrefs.containsKey("flag") ? sharedPrefs.getInt("flag") : 0;
    });
    await sharedPrefs.setBool("state", val);
  }

  Future<void> getdashdata() async {
    final sharedPrefs = await _sharedPrefs;
    Map<String, dynamic> body = {
      "driver_id": sharedPrefs.getString("spDriverID"),
      "page": "1"
    };
    await _con.waitForcurrenttask(
        sharedPrefs.getString("spDriverID"), "Dashboard");
    await _con.dashboard(sharedPrefs.getString("spDriverID"));
    setValues();
    await _con.getwalletdata(sharedPrefs.getString("spDriverID"));
    await _con.waitFordeliveredorders(body);

    setState(() {
      check = true;
    });
    await _con.waitForDriverData(sharedPrefs.getString("spDriverID"));
    await _con.userloc();
    final a = await sharedPrefs.setString(
        "latitude", _con.driverloction.latitude.toString());
    final g = await sharedPrefs.setString(
        "longitude", _con.driverloction.longitude.toString());
    startTimer();
  }

  checkFCM() {
    print("FCM method trigger");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _con.getconnect_status(context);
    getdashdata();
  }

  startTimer() async {
    timer =
        Timer.periodic(Duration(minutes: 1), (Timer t) => driverlocupdate());
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: () {
        exit(0);
      },
      child: Scaffold(
          body: !check
              ? CircularLoadingWidget()
              : RefreshIndicator(
                  onRefresh: getdashdata,
                  child: Container(
                    color: Colors.white,
                    height: double.infinity,
                    child: SingleChildScrollView(
                        physics: ScrollPhysics(),
                        child: Column(
                            children: [
                              Row(
                                  children: [
                                    Text(
                                      "Ready To Deliver",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xffa11414),
                                          fontWeight: FontWeight.w800),
                                    ),
                                    SizedBox(
                                      height: height / 20,
                                    ),
                                    Flexible(
                                        child: MySwitch(
                                      value: val,
                                      activeColor: Color(0xff54e346),
                                      onChanged: (flag) async {
                                        final sharedPrefs = await _sharedPrefs;

                                        Map<String, dynamic> body1 = {
                                          "user_id": sharedPrefs
                                              .getString("spDriverID"),
                                          "status": val ? "0" : "1"
                                        };
                                        final statusResult = await _con
                                            .waitupdatedriverstatus(body1);
                                        if (statusResult) {
                                          setState(() {
                                            val = flag;
                                          });
                                          final b = await sharedPrefs.setBool(
                                              "state", val);
                                          //startTimer();
                                          print(val);
                                          if (val) {
                                            // Map<String, dynamic> body = {
                                            //   "user_id": sharedPrefs
                                            //       .getString("spDriverID"),
                                            //   "latitude": _con
                                            //       .driverloction.latitude
                                            //       .toString(),
                                            //   "longitude": _con
                                            //       .driverloction.longitude
                                            //       .toString(),
                                            // };
                                            // await _con.waitupdatedriverloc(body);
                                            startTimer();
                                            await driverlocupdate();
                                          } else {
                                            timer.cancel();
                                          }
                                          if (val && b && c == 0) {
                                            setState(() => ++c);
                                            final d = await sharedPrefs.setInt(
                                                "flag", c);
                                            print(d);

                                            Navigator.of(context).pushNamed(
                                                "/pages",
                                                arguments: 2);
                                          }
                                        }
                                      },
                                    ))
                                  ],
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween),
                              SizedBox(height: height / 25),
                              Text(
                                "DASHBOARD",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18),
                              ),
                              SizedBox(height: height / 80),
                              GridView.count(
                                shrinkWrap: true,
                                crossAxisCount: 2,
                                // mainAxisSpacing: 20,
                                childAspectRatio: width * 2.7 / height,
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  GridItemWidget(
                                      contents: [
                                        "Delivered Today",
                                        check
                                            ? "Orders : " +
                                                _con.dashbrd.todayorders
                                                    .toString()
                                            : "Orders : ",
                                        check
                                            ? "Revenue : " +
                                                "₹ ${_con.dashbrd.todayrevenue.toString()}"
                                            : "Revenue : "
                                      ],
                                      color: "9ccaac",
                                      height: height,
                                      width: width,
                                      radius: size / 80),
                                  GridItemWidget(
                                      contents: [
                                        "Cancelled Today",
                                        check
                                            ? "Orders : " +
                                                _con.dashbrd.canceltdyorders
                                                    .toString()
                                            : "Orders : ",
                                        check
                                            ? "Revenue : " +
                                                "₹ ${_con.dashbrd.canceltdyrevenue.toString()}"
                                            : "Revenue : "
                                      ],
                                      color: "ffa9a3",
                                      height: height,
                                      width: width,
                                      radius: size / 80),
                                  GridItemWidget(
                                      contents: [
                                        "Last Week",
                                        check
                                            ? "Orders : " +
                                                _con.dashbrd.lastwkorders
                                                    .toString()
                                            : "Orders : ",
                                        check
                                            ? "Revenue : " +
                                                "₹ ${_con.dashbrd.lastwkrevenue.toString()}"
                                            : "Revenue : "
                                      ],
                                      color: "ffb703",
                                      height: height,
                                      width: width,
                                      radius: size / 80),
                                  GridItemWidget(
                                      contents: [
                                        "Last Month",
                                        check
                                            ? "Orders : " +
                                                _con.dashbrd.lastmthorders
                                                    .toString()
                                            : "Orders : ",
                                        check
                                            ? "Revenue : " +
                                                "₹ ${_con.dashbrd.lastmthrevenue.toString()}"
                                            : "Revenue : "
                                      ],
                                      color: "6dbbe8",
                                      height: height,
                                      width: width,
                                      radius: size / 80),
                                  GridItemWidget(
                                      contents: [
                                        "wallet ",
                                        check
                                            ? "wallet Limit : " +
                                                "₹ ${_con.dashbrd.valetlimit.toString()}"
                                            : "wallet Limit : ",
                                        check
                                            ? "wallet Total : " +
                                                "₹ ${_con.dashbrd.valettotal.toString()}"
                                            : "wallet Total : "
                                      ],
                                      color: "FE83F2",
                                      height: height,
                                      width: width,
                                      radius: size / 80)
                                ],
                                //childAspectRatio: width * 2.3 / height
                              ),
                              SizedBox(height: height / 90),
                              Text("Delivery History".toUpperCase(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14)),
                              Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.only(top: height / 40),
                                  child: getList(_con.del_orders)),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly),
                        padding: EdgeInsets.symmetric(horizontal: width / 32)),
                  ),
                )),
    );
  }

  Future<void> driverlocupdate() async {
    final sharedPrefs = await _sharedPrefs;
    if (val) {
      await _con.userloc();
      final a = await sharedPrefs.setString(
          "latitude", _con.driverloction.latitude.toString());
      final g = await sharedPrefs.setString(
          "longitude", _con.driverloction.longitude.toString());
      Map<String, dynamic> body = {
        "user_id": sharedPrefs.getString("spDriverID"),
        "latitude": _con.driverloction.latitude.toString(),
        "longitude": _con.driverloction.longitude.toString(),
      };
      await _con.waitupdatedriverloc(body);
    } else {
      timer.cancel();
    }
  }

  Widget getList(List<Order> del_orders) {
    return check == false
        ? Container()
        : del_orders.length == 0
            ? Center(
                child: Text(
                  "No Orders Found",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffa11414)),
                ),
              )
            : ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: del_orders.length <= 3 ? del_orders.length : 3,
                itemBuilder: (context, index) =>
                    DashdeliverHistory(order: _con.del_orders[index]));
  }
}
