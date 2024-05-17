import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpandSupport extends StatefulWidget {
  @override
  HelpandSupportpage createState() => HelpandSupportpage();
}

class HelpandSupportpage extends StateMVC<HelpandSupport> {
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
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
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
            backgroundColor: Color(0xfffbfbfb),
            title: Text("Help & Support",
                style: TextStyle(
                    color: Color(0xff200303),
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
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
            padding: EdgeInsets.symmetric(
              horizontal: width / 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height / 15),
                Text("CONTACT NUMBER",
                    style: TextStyle(
                        color: Color(0xff200303),
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: height / 30),
                GestureDetector(
                  onTap: () {
                    launch("tel:18002085234");
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.call,
                        size: 20.0,
                        color: Color(0xffBAD600),
                      ),
                      SizedBox(width: width / 20),
                      Text("18002085234",
                          style: TextStyle(
                              color: Color(0xff200303),
                              fontSize: 17,
                              fontWeight: FontWeight.w600)),
                      SizedBox(width: width / 20),
                    ],
                  ),
                ),
                // SizedBox(height: height / 90),
                // GestureDetector(
                //   onTap: () {
                //     launch("tel:18002085234");
                //   },
                //   child: Row(
                //     children: [
                //       Icon(
                //         Icons.call,
                //         size: 20.0,
                //         color: Color(0xffBAD600),
                //       ),
                //       SizedBox(width: width / 20),
                //       Text("18002085234",
                //           style: TextStyle(
                //               color: Color(0xff200303),
                //               fontSize: 17,
                //               fontWeight: FontWeight.w600)),
                //       SizedBox(width: width / 20),
                //     ],
                //   ),
                // ),
                SizedBox(height: height / 15),
                Text("MAIL ID",
                    style: TextStyle(
                        color: Color(0xff200303),
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: height / 30),
                GestureDetector(
                  onTap: () {
                    launch("mailto:customercare@foodigo.in");
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.mail,
                        size: 20.0,
                        color: Color(0xffBAD600),
                      ),
                      SizedBox(width: width / 20),
                      Text("customercare@foodigo.in",
                          style: TextStyle(
                              color: Color(0xff200303),
                              fontSize: 17,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                // SizedBox(height: height / 90),
                // GestureDetector(
                //   onTap: () {
                //     launch("mail:info@spidergerms.com");
                //   },
                //   child: Row(
                //     children: [
                //       Icon(
                //         Icons.mail,
                //         size: 20.0,
                //         color: Color(0xffBAD600),
                //       ),
                //       SizedBox(width: width / 20),
                //       Text("info@spidergerms.com",
                //           style: TextStyle(
                //               color: Color(0xff200303),
                //               fontSize: 17,
                //               fontWeight: FontWeight.w600)),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ])));
  }
}
