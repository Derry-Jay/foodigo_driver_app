import 'dart:math';
import '../models/user.dart';

import 'package:flutter/material.dart';
import 'package:foodigo_driver_app/controllers/user_controller.dart';
import 'package:foodigo_driver_app/helpers/helper.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileUpdatePage extends StatefulWidget {
  final User user;
  ProfileUpdatePage(this.user);
  ProfileUpdatePageState createState() => ProfileUpdatePageState();
}

class ProfileUpdatePageState extends StateMVC<ProfileUpdatePage> {
  Helper hp;
  UserController _con;
  TextEditingController nc = new TextEditingController(),
      mc = new TextEditingController(),
      pc = new TextEditingController();
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  ProfileUpdatePageState() : super(UserController()) {
    _con = controller;
  }
  @override
  void initState() {
    super.initState();
    hp = Helper.of(context);
    final user = widget.user;
    nc.text = user.name;
    mc.text = user.email;
    pc.text = user.mobile;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
          title: Text("Edit Profile",
              style: TextStyle(fontWeight: FontWeight.w500)),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: Color(0xffFBFBFB),
          foregroundColor: Colors.black,
          backwardsCompatibility: false,
          elevation: 0),
      body: SingleChildScrollView(
          child: Center(
              child: Form(
            key: _con.loginFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                    child: TextFormField(
                        controller: nc,
                        style: TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter the name";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            hintText: "Name",
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(radius / 100),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(radius / 100),
                            ))),
                    // decoration: BoxDecoration(
                    //     color: Color(0xfff7f7f7),
                    //     border: Border.all(
                    //         color: Color(
                    //             0xffBAD600))),
                    padding: EdgeInsets.symmetric(
                        horizontal: width / 25, vertical: height / 50)),
                Container(
                    child: TextFormField(
                        controller: mc,
                        style: TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter email";
                          } else if (!RegExp(
                                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                              .hasMatch(value)) {
                            return "Please enter valid email";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            hintText: "Email",
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(radius / 100),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(radius / 100),
                            ))),
                    padding: EdgeInsets.symmetric(
                        horizontal: width / 25, vertical: height / 50)),
                Container(
                    child: TextFormField(
                        controller: pc,
                        style: TextStyle(color: Colors.black),
                        readOnly: true,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter mobile number";
                          } else if (!RegExp(r'(^(?:[+0]9)?[0-9]{10}$)')
                              .hasMatch(value)) {
                            return "Please enter valid mobile number";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            hintText: "Mobile",
                            filled: true,
                            fillColor: Colors.grey[300],
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(radius / 100),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(radius / 100),
                            ))),
                    padding: EdgeInsets.symmetric(
                        horizontal: width / 25, vertical: height / 50)),
                TextButton(
                    onPressed: () async {
                      final sharedPrefs = await SharedPreferences.getInstance();
                      if (_con.loginFormKey.currentState.validate()) {
                        Map<String, dynamic> body = {
                          "user_id": sharedPrefs.getString("spDriverID"),
                          "name": nc.text,
                          "email": mc.text,
                          "mobileno": pc.text
                        };
                        _con.waitUntilProfileUpdate(body);
                      }
                    },
                    child: Text("SAVE",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(radius / 100)))),
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xffa11414)),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white)))
              ],
            ),
          )),
          padding: EdgeInsets.symmetric(horizontal: width / 50)),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
