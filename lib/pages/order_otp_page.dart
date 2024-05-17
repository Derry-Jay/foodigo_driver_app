import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_driver_app/controllers/order_controller.dart';
import 'package:foodigo_driver_app/models/order_status.dart';
import 'package:foodigo_driver_app/models/order_status_check.dart';
import 'package:foodigo_driver_app/pages/order_tracking_page.dart';
import 'package:foodigo_driver_app/repos/orders_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Otpconfrim extends StatefulWidget {
  final String orderid;

  const Otpconfrim({Key key, this.orderid}) : super(key: key);
  @override
  Otpconfrimpage createState() => Otpconfrimpage();
}

class Otpconfrimpage extends StateMVC<Otpconfrim> {
  OrderController _con;
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  Otpconfrimpage() : super(OrderController()) {
    _con = controller;
  }
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController pin = TextEditingController();
  bool haserror = false;
  bool checkotp = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _con.waitFororderstatus(widget.orderid);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
            backgroundColor: Color(0xfffbfbfb),
            title: Text("Delivery Conformation"),
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
                              TextSpan(text: 'Ask '),
                              TextSpan(
                                text: 'OTP ',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              TextSpan(
                                  text:
                                      'to the customer for the conformation of the delivery'),
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
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: height / 4.3,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: PinCodeTextField(
                pinBoxHeight: 45,
                pinBoxWidth: 40,
                pinBoxRadius: 5,
                autofocus: true,
                controller: pin,
                hideCharacter: true,
                highlight: true,
                highlightColor: Colors.red,
                defaultBorderColor: Color(0xffBAD600),
                hasTextBorderColor: Color(0xffBAD600),
                errorBorderColor: Colors.red,
                maxLength: 6,
                hasError: haserror,
                maskCharacter: "*", //😎
                onTextChanged: (text) {
                  if (text.toString() != _con.orderstatus.orderotp.toString()) {
                    print(pin.text);
                    setState(() {
                      checkotp = false;
                    });
                  }
                },
                onDone: (text) async {
                  final sharedPrefs = await _sharedPrefs;
                  if (text.toString() == _con.orderstatus.orderotp.toString()) {
                    setState(() {
                      checkotp = true;
                      haserror = false;
                    });
                  } else {
                    setState(() {
                      haserror = true;
                      pin.clear();
                    });
                    scaffoldKey.currentState
                        .showSnackBar(SnackBar(content: Text("Invalid OTP")));
                  }
                  // print("DONE $text");
                  // print(pin.text);
                  // setState(() {
                  //   haserror = false;
                  // });
                },
                wrapAlignment: WrapAlignment.spaceEvenly,
                pinBoxDecoration:
                    ProvidedPinBoxDecoration.defaultPinBoxDecoration,
                pinTextStyle: TextStyle(fontSize: 35.0),
                pinTextAnimatedSwitcherTransition:
                    ProvidedPinBoxTextAnimation.scalingTransition,
                //                    pinBoxColor: Colors.green[100],
                pinTextAnimatedSwitcherDuration: Duration(milliseconds: 300),
                //                    highlightAnimation: true,
                //highlightPinBoxColor: Colors.red,
                highlightAnimationBeginColor: Colors.black,
                highlightAnimationEndColor: Colors.white12,
                keyboardType: TextInputType.number,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: OutlinedButton(
              onPressed: () async {
                checkotp ? complete_order() : null;
              },
              child: Container(
                child: Center(
                  child: Text("ORDER DELIVERED",
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
                      !checkotp ? Color(0xff817C7C) : Color(0xffa11414))),
            ),
          )
        ])));
  }

  void complete_order() async {
    if (pin.text.toString() == _con.orderstatus.orderotp.toString()) {
      final sharedPrefs = await _sharedPrefs;
      Map<String, dynamic> reachbody = {
        "order_status_id": '8',
        "driver_id": sharedPrefs.getString("spDriverID"),
      };
      final value = await orderstatuschange(reachbody, widget.orderid);
      print(value);
      if (value['success']) {
        Map<String, dynamic> body = {
          "currenttask": widget.orderid,
          "uses_id": sharedPrefs.getString("spDriverID"),
        };
        _con.waitUntilOrderDelivered(body);
      }
    }
  }
}
