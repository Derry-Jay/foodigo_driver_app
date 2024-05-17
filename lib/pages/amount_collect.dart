import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_driver_app/controllers/order_controller.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Amountconfrim extends StatefulWidget {
  final String amount;
  final String orderid;

  const Amountconfrim({Key key, this.amount, this.orderid}) : super(key: key);
  @override
  Amountconfrimpage createState() => Amountconfrimpage();
}

class Amountconfrimpage extends StateMVC<Amountconfrim> {
  OrderController _con;
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  double get size1 => sqrt(pow(height, 2) + pow(width, 2));
  Amountconfrimpage() : super(OrderController()) {
    _con = controller;
  }

  TextEditingController amount = new TextEditingController();
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController pin = TextEditingController();
  bool checkbox = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _con.waitFororderstatus(widget.orderid);
    setState(() {
      amount.text = widget.amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
            backgroundColor: Color(0xfffbfbfb),
            title: Text("Amount Conformation"),
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
            child: Stack(children: [
          Padding(
            padding: EdgeInsets.only(
                top: height / 8, left: width / 10, right: width / 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    width: width / 1.3,
                    child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            style: TextStyle(
                                color: Color(0xff110202),
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                            children: <TextSpan>[
                              TextSpan(text: 'Collect the '),
                              TextSpan(
                                text: 'Amount '.toUpperCase(),
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              TextSpan(text: 'from the customer'),
                            ]))
                    // Text(
                    //   'Ask OTP to the customer for the conformation of the delivery',
                    //   style: TextStyle(
                    //       color: Color(0xff110202),
                    //       fontWeight: FontWeight.bold,
                    //       fontSize: 16),
                    //   textAlign: TextAlign.center,
                    // ),
                    ),
                SizedBox(
                  height: height / 30,
                ),
                TextFormField(
                  readOnly: true,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: Color(0xffa11414),
                  controller: amount,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                      hintText: "Aomunt",
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black12),
                        borderRadius: BorderRadius.circular(size1 / 100),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black12),
                        borderRadius: BorderRadius.circular(size1 / 100),
                      )),
                ),
                SizedBox(
                  height: height / 30,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      checkbox = !checkbox;
                    });
                  },
                  child: Container(
                    child: Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.white,
                          activeColor: Colors.red,
                          value: checkbox,
                          onChanged: (bool value) async {
                            setState(() {
                              checkbox = value;
                            });
                          },
                        ),
                        SizedBox(
                          width: width / 15,
                        ),
                        Text(
                          "Amount Collected",
                          style: TextStyle(
                              color: !checkbox ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: OutlinedButton(
              onPressed: () {
                !checkbox ? null : _con.movto_otp(widget.orderid, 'OTP', '0');
              },
              child: Container(
                child: Center(
                  child: Text("amount collected".toUpperCase(),
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
                  backgroundColor: MaterialStateProperty.all(
                      !checkbox ? Color(0xff817C7C) : Color(0xffa11414))),
            ),
          )
        ])));
  }
}
