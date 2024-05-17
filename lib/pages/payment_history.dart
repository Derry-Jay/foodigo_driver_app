import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_driver_app/controllers/order_controller.dart';
import 'package:foodigo_driver_app/elements/delivered_history_item_widget.dart';
import 'package:foodigo_driver_app/elements/payment_history_item_widget.dart';
import 'package:foodigo_driver_app/models/paymentHistory.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../elements/CircularLoadingWidget.dart';
import '../models/order.dart';

class PaymentHistory extends StatefulWidget {
  @override
  PaymentHistorypage createState() => PaymentHistorypage();
}

class PaymentHistorypage extends StateMVC<PaymentHistory> {
  OrderController _con;
  int page = 1;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  PaymentHistorypage() : super(OrderController()) {
    _con = controller;
  }
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool loaddata = false;
  List paydata = [];

  void getData() async {
    final sharedPrefs = await _sharedPrefs;
    Map<String, dynamic> body = {
      "driver_id": sharedPrefs.getString("spDriverID"),
      "page": '1'
    };
    await _con.waitForPaymenthistory(body);
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
          title: Text("Payment history"),
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
          child: Container(
              color: Colors.white, child: getList(_con.paymentHistory))),
    );
  }

  Widget getList(List<Paymenthistory> paymentHistory) {
    return loaddata == false
        ? CircularLoadingWidget()
        : paymentHistory.length == 0
            ? Center(
                child: Text(
                  "No Records Found",
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
                  Map<String, dynamic> body = {
                    "driver_id": sharedPrefs.getString("spDriverID"),
                    "page": page.toString()
                  };
                  await _con.waitForPaymenthistory(body);
                },
                child: Scrollbar(
                  child: ListView.builder(
                      itemCount: paymentHistory.length,
                      itemBuilder: (context, index) {
                        // if (index == paymentHistory.length - 1) {
                        //   return Center(child: CircularLoadingWidget());
                        // } else {
                        return PaymenthistoryWidget(
                            paymenthistory: _con.paymentHistory[index]);
                        // }
                      }),
                ),
              );
  }
}
