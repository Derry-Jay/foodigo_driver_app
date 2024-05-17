import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_driver_app/controllers/order_controller.dart';
import 'package:foodigo_driver_app/elements/delivered_history_item_widget.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../elements/CircularLoadingWidget.dart';
import '../models/order.dart';

class DeliveredHistory extends StatefulWidget {
  @override
  DeliveredHistorypage createState() => DeliveredHistorypage();
}

class DeliveredHistorypage extends StateMVC<DeliveredHistory> {
  OrderController _con;
  int page = 1;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  DeliveredHistorypage() : super(OrderController()) {
    _con = controller;
  }
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool loaddata = false;

  void getData() async {
    final sharedPrefs = await _sharedPrefs;
    print(int.tryParse(sharedPrefs.getString("spDriverID")));
    Map<String, dynamic> body = {
      "driver_id": sharedPrefs.getString("spDriverID"),
      "page": page.toString()
    };
    await _con.waitFordeliveredorders(body);
    setState(() {
      loaddata = true;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _con.getconnect_status(context);
    getData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Delivered history"),
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
              )),
          elevation: 0),
      body: SafeArea(
          child: Container(color: Colors.white, child: getList(_con.orders))),
    );
  }

  Widget getList(List<Order> orders) {
    return loaddata == false
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
                  page++;
                  Map<String, dynamic> body = {
                    "driver_id": sharedPrefs.getString("spDriverID"),
                    "page": page.toString()
                  };
                  await _con.waitFordeliveredorders(body);
                },
                child: Scrollbar(
                  child: ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        // if (index == orders.length - 1) {
                        //   return Center(child: CircularLoadingWidget());
                        // } else {
                        return DeliveredhistoryWidget(
                            order: _con.orders[index]);
                        // }
                      }),
                ),
              );
  }
}
