import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodigo_driver_app/controllers/user_controller.dart';
import 'package:foodigo_driver_app/helpers/helper.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordUpdatePage extends StatefulWidget {
  PasswordUpdatePageState createState() => PasswordUpdatePageState();
}

class PasswordUpdatePageState extends StateMVC<PasswordUpdatePage> {
  Helper hp;
  UserController _con;
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  PasswordUpdatePageState() : super(UserController()) {
    _con = controller;
  }
  @override
  void initState() {
    super.initState();
    hp = Helper.of(context);
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
          title: Text("Change Password",
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
                        controller: _con.oldpass,
                        style: TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter the old password";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            hintText: "Old password",
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(radius / 100),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: _con.iswrong
                                      ? Colors.red
                                      : Colors.black12),
                              borderRadius: BorderRadius.circular(radius / 100),
                            ))),
                    // decoration: BoxDecoration(
                    //     color: Color(0xfff7f7f7),
                    //     border: Border.all(
                    //         color: Color(
                    //             0xffBAD600))),
                    padding: EdgeInsets.symmetric(
                        horizontal: width / 25, vertical: height / 50)),
                _con.iswrong
                    ? Text(
                        "Wrong Password",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.red),
                      )
                    : Container(),
                Container(
                    child: TextFormField(
                        controller: _con.newpass,
                        style: TextStyle(color: Colors.black),
                        readOnly: false,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter the new password";
                          } else if (value.length < 8) {
                            return "Please enter the minimum 8 characters";
                          }
                          return null;
                        },
                        onTap: () async {
                          final sharedPrefs = await _sharedPrefs;
                          Map<String, dynamic> body = {
                            "user_id": sharedPrefs.getString("spDriverID"),
                            "password": _con.oldpass.text,
                          };
                          await _con.waitUntilPasswordcheck(body);
                          setState(() {});
                        },
                        decoration: InputDecoration(
                            hintText: "New password",
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
                        style: TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter the confrim new password";
                          } else if (value != _con.newpass.text) {
                            return "Password mismatch !";
                          }
                          return null;
                        },
                        controller: _con.confrimnewpass,
                        decoration: InputDecoration(
                            hintText: "Confrim new password",
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
                TextButton(
                    onPressed: () async {
                      final sharedPrefs = await _sharedPrefs;
                      if (_con.loginFormKey.currentState.validate()) {
                        Map<String, dynamic> body1 = {
                          "user_id": sharedPrefs.getString("spDriverID"),
                          "password": _con.oldpass.text,
                        };
                        await _con.waitUntilPasswordcheck(body1);
                        Map<String, dynamic> body = {
                          "user_id": sharedPrefs.getString("spDriverID"),
                          "current_password": _con.oldpass.text,
                          "new_password": _con.newpass.text,
                          "confirm_password": _con.confrimnewpass.text,
                        };
                        _con.iswrong
                            ? await Fluttertoast.showToast(
                                msg: "Invalid Old Password",
                                gravity: ToastGravity.BOTTOM)
                            : await _con.waitUntilPasswordUpdate(body);
                        setState(() {});
                      }
                    },
                    child: Text("Update",
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
