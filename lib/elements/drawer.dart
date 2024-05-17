import 'dart:async';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:foodigo_driver_app/controllers/user_controller.dart';
import 'package:foodigo_driver_app/helpers/helper.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends StateMVC<MyDrawer> {
  UserController _con;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  var name, email, mobile, profpic, s3url;
  Helper hp;
  _MyDrawerState() : super(UserController()) {
    _con = controller;
  }
  void initState() {
    getdata();
    super.initState();
  }

  void getdata() async {
    final sharedPrefs = await _sharedPrefs;
    setState(() {
      name = sharedPrefs.getString("name");
      email = sharedPrefs.getString("email");
      mobile = sharedPrefs.getString("mobile");
      profpic = sharedPrefs.getString("fullimgurl");
      s3url = sharedPrefs.getString("s3url");
    });
    await _con.waitForDriverData(sharedPrefs.getString("spDriverID"));
  }

  FutureOr onGoBack(dynamic value) async {
    final sharedPrefs = await _sharedPrefs;
    setState(() {
      _con.waitForDriverData(sharedPrefs.getString("spDriverID"));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xffBAD600),
              ),
              child: FittedBox(
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: s3url == null
                          ? AssetImage("assets/images/user.png")
                          : NetworkImage(profpic.toString()),
                      backgroundColor: Colors.transparent,
                      radius: 35,
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          name.toString(),
                          textScaleFactor: 1.0,
                          style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff200303),
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          email.toString(),
                          textScaleFactor: 1.0,
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xff200303),
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          mobile.toString(),
                          textScaleFactor: 1.0,
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xff200303),
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    GestureDetector(
                        child: CircleAvatar(
                          backgroundColor: Color(0xffa11414),
                          // backgroundImage:
                          //     AssetImage("assets/images/edit2.png"),
                          radius: radius / 100,
                          child: Icon(
                            Icons.edit,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed('/profileupdate',
                              arguments: _con.driver);
                        })
                  ],
                ),
              ),
            ),
            SizedBox(
              height: height / 60,
            ),
            Customdrawer(Icons.home, 'Payment History', () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/paymenthistory');
            }),
            SizedBox(
              height: height / 70,
            ),
            Customdrawer(Icons.account_circle, 'Delivered History', () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/deliveredhistory');
            }),
            SizedBox(
              height: height / 70,
            ),
            Customdrawer(Icons.account_circle, 'Change Password', () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/changepassword');
            }),
            SizedBox(
              height: height / 70,
            ),
            Customdrawer(Icons.live_help, 'Help & Support', () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/help&support');
            }),
            SizedBox(
              height: height / 70,
            ),
            Customdrawer(Icons.power_settings_new, 'Logout', () async {
              logout();
              await FirebaseMessaging.instance.deleteToken();
            }),
          ],
        ),
      ),
    );
  }

  Future<void> logout() async {
    final sharedPrefs = await _sharedPrefs;
    Map<String, dynamic> body1 = {
      "user_id": sharedPrefs.getString("spDriverID"),
      "status": "0"
    };
    final statusResult = await _con.waitupdatedriverstatus(body1);
    if (statusResult) {
      SharedPreferences local_data = await SharedPreferences.getInstance();
      local_data.clear();
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}

class Customdrawer extends StatelessWidget {
  IconData icon;
  String text;
  Function onTap;
  Customdrawer(this.icon, this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 0, 8.0, 0),
        child: InkWell(
          splashColor: Color(0xffBAD600),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Image.asset('assets/images/drawer-list.png'),
                SizedBox(
                  width: 15.0,
                ),
                Text(
                  text,
                  style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff200303),
                      fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ));
  }
}
