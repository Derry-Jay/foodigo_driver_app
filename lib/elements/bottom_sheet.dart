import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodigo_driver_app/controllers/order_controller.dart';
import 'package:foodigo_driver_app/pages/order_tracking_page.dart';
import 'package:foodigo_driver_app/repos/orders_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bottomsheet extends StatefulWidget {
  final List fooddetails;
  final String orderid;

  const Bottomsheet({Key key, this.fooddetails, this.orderid})
      : super(key: key);
  @override
  Bottomsheetpage createState() => Bottomsheetpage();
}

class Bottomsheetpage extends StateMVC<Bottomsheet> {
  OrderController _con;
  OrderTrackingPageState con;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  //Timer timer;
  // String note;
  // List orderdetails;
  // Function onTap;
  // Bottomsheet(this.note, this.onTap, this.orderdetails);
  Bottomsheetpage() : super(OrderController()) {
    _con = controller;
  }

  @override
  void initState() {
    // TODO: implement initState
    //timer = Timer.periodic(Duration(seconds: 5), (Timer t) => setstatus());
    setState(() {
      for (var i = 0; i < widget.fooddetails.length; i++) {
        _con.checked.add(false);
      }
    });
    super.initState();
  }

  // void setstatus() async {
  //   //print('timer working');
  //   await _con.waitFororderstatus(widget.orderid);
  //   print(_con.orderstatus.orderstatusid);
  // }

  @override
  // ignore: missing_return
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height / 2,
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width / 32,
                      ),
                      child: Text("FOOD CHECKLIST",
                          style: TextStyle(
                              color: Color(0xff200303),
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: height / 50),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: widget.fooddetails.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Checkbox(
                                  checkColor: Colors.white,
                                  activeColor: Colors.red,
                                  value: _con.checked[index],
                                  onChanged: (bool value) async {
                                    setState(() {
                                      _con.checked[index] = value;
                                    });
                                    if (index == 0) {
                                      await _con
                                          .waitFororderstatus(widget.orderid);
                                    }
                                    if (value == true) {
                                      int check = 0;
                                      for (var i = 0;
                                          i < _con.checked.length;
                                          i++) {
                                        if (_con.checked[i] == false) {
                                          setState(() {
                                            check = check + 1;
                                          });
                                        }
                                      }

                                      print(_con.orderstatus.orderstatusid);
                                      if (check == 0 &&
                                          _con.orderstatus.orderstatusid ==
                                              '5') {
                                        setState(() {
                                          _con.orderpack = true;
                                        });
                                      }
                                    } else if (value == false) {
                                      setState(() {
                                        _con.orderpack = false;
                                      });
                                    }
                                  },
                                ),
                                SizedBox(width: width / 10),
                                Expanded(
                                  child: Text(
                                      "${widget.fooddetails[index]['quantity']}   X   ${widget.fooddetails[index]['name']}",
                                      style: TextStyle(
                                          color: Color(0xff110202),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                ),
                              ],
                            ),
                          );
                        }),
                    SizedBox(height: height / 50),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width / 32,
                      ),
                      child: Text('Note: ',
                          style: TextStyle(
                              color: Color(0xff110202),
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ),
                    SizedBox(height: height / 60),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width / 32,
                      ),
                      child: Text("Please check all the foods and verify",
                          //'It is a long established fact that reader will be distracted by the readable content of a page  when looking as its layout',
                          style: TextStyle(
                              color: Color(0xff110202),
                              fontWeight: FontWeight.normal,
                              fontSize: 16)),
                    ),
                    SizedBox(height: height / 8),
                  ],
                ),
              )),
          Align(
              alignment: Alignment.bottomCenter,
              child: OutlinedButton(
                // onPressed: widget.onTap,
                onPressed: () async {
                  print(_con.orderstatus.orderstatusid);
                  if (_con.orderstatus.orderstatusid == '5') {
                    int check = 0;
                    for (var i = 0; i < _con.checked.length; i++) {
                      if (_con.checked[i] == false) {
                        setState(() {
                          check = check + 1;
                        });
                      }
                    }
                    if (check == 0) {
                      final sharedPrefs = await _sharedPrefs;
                      Map<String, dynamic> reachbody = {
                        "order_status_id": '6',
                        "driver_id": sharedPrefs.getString("spDriverID"),
                      };
                      final value =
                          await orderstatuschange(reachbody, widget.orderid);
                      print(value);
                      Navigator.pop(context, 'Picked');
                      if (value['success']) {
                        setState(() {
                          _con.orderpick = true;
                          //_con.orderstatus.orderstatusid = value['data']['order_status_id'];
                        });

                        await _con.waitFororderstatus(widget.orderid);
                      }
                      //Navigator.of(context).pop();
                      // Navigator.pop(context, 'Picked');
                    }
                  }
                },
                child: Container(
                  child: Center(
                    child: Text("ORDER PICKED",
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
                    backgroundColor: MaterialStateProperty.all(_con.orderpack
                        ? Color(0xffa11414)
                        : Color(0xff817C7C))),
              )),
        ],
      ),
    );
  }
}
