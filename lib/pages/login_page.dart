import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodigo_driver_app/controllers/order_controller.dart';
import 'package:foodigo_driver_app/controllers/user_controller.dart';
import 'package:foodigo_driver_app/helpers/custom_trace.dart';
import 'package:foodigo_driver_app/helpers/validator.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repos/user_repository.dart' as userRepo;

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginPageState();
}

//,width: width
class LoginPageState extends StateMVC<LoginPage> {
  UserController _con;
  //FirebaseMessaging fcm = FirebaseMessaging.instance;
  String tokenFCM;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  TextEditingController uc = new TextEditingController(),
      pc = new TextEditingController();
  RegExp erx = new RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  LoginPageState() : super(UserController()) {
    _con = controller;
  }

  MediaQueryData get dimensions => MediaQuery.of(context);
  double get height => dimensions.size.height;
  double get width => dimensions.size.width;
  double get size => sqrt(pow(height, 2) + pow(width, 2));

  @override
  void initState() {
    super.initState();
    push();

    // putData();
    // fcm_listener();
  }

  // void fcm_listener() async {
  //   // fcm.getToken().then((token) {
  //   //   print("Token is:" + token);
  //   //   setState(() {
  //   //     fcm_token = token;
  //   //   });
  //   // });
  //   fcm_token = await fcm.getToken();
  //   print("Token is:" + fcm_token);
  // }

  void push() async {
    final sharedPrefs = await _sharedPrefs;
    if (sharedPrefs.getString("spDriverID") != null) {
      _con.waitForcurrenttask(sharedPrefs.getString("spDriverID"), "Login");
    } else if (sharedPrefs.getString("spDriverID") == null) {
      getToken();
    }

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // var token = prefs.getString('apiToken');
    // print(token);
    // if (token != null) {
    //   Navigator.of(context).pushReplacementNamed('/pages', arguments: 0);
    // }
  }

  // void putData() async {
  //   Firebase.initializeApp(
  //           name: "com.foodigo.driver",
  //           options: FirebaseOptions(
  //               apiKey: "AIzaSyDkAmR5qa7tVYbpYyaJuGqgCYVNFqYCEAs",
  //               appId: "1:189510283821:android:efe3295aaf2c9bba81bea4",
  //               messagingSenderId: "Foodigo",
  //               projectId: "driver-29e3f"))
  //       .then((value) {
  //     final firebaseMessaging = FirebaseMessaging.instance;
  //     configureFirebase(firebaseMessaging);
  //   }).catchError((e) {
  //     print("Hi");
  //     print(e);
  //     print("Hi");
  //   });
  // }

  // void configureFirebase(FirebaseMessaging _firebaseMessaging) async {
  //   try {
  //     // final fireApp =
  //     //     await Firebase.initializeApp(name: "com.foodigo.customer");
  //     final perms = await _firebaseMessaging.requestPermission(
  //         sound: true, badge: true, alert: true);
  //     final notSet = await _firebaseMessaging.getNotificationSettings();
  //     final token1 = await _firebaseMessaging.getAPNSToken();
  //     final token2 = await _firebaseMessaging.getToken();
  //     // final msg = await _firebaseMessaging.getInitialMessage();
  //     print(perms);
  //     print("Device Token: " + token2);
  //     print(token1);
  //     print(notSet);
  //     // print("Token 1:" + token2);
  //     // print(fireApp);
  //   } catch (e) {
  //     print(CustomTrace(StackTrace.current, message: e.toString()));
  //     print(CustomTrace(StackTrace.current, message: 'Error Config Firebase'));
  //   }
  // }
  getToken() async {
    tokenFCM = await FirebaseMessaging.instance.getToken();
    setState(() {
      tokenFCM = tokenFCM;
      _con.user.deviceToken = tokenFCM;
    });
    print("Device token Login : $tokenFCM");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _con.scaffoldKey,
      body: SingleChildScrollView(
          child: Form(
              child: Column(
                  children: [
                    Image.asset("assets/images/logo.png", height: height / 3.2),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (input) => _con.user.email = input,
                      cursorColor: Color(0xffa11414),
                      controller: uc,
                      validator: Validator.validateemail,
                      decoration: InputDecoration(
                          hintText: "Email",
                          filled: true,
                          fillColor: Colors.black12,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(size / 100),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(size / 100),
                          )),
                    ),
                    SizedBox(height: height / 20),
                    TextFormField(
                      obscureText: true,
                      cursorColor: Color(0xffa11414),
                      controller: pc,
                      onSaved: (input) => _con.user.password = input,
                      validator: Validator.notEmpty,
                      decoration: InputDecoration(
                          hintText: "Password",
                          filled: true,
                          fillColor: Colors.black12,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(size / 100),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(size / 100),
                          )),
                    ),
                    SizedBox(height: height / 100),
                    // InkWell(
                    //   child: Text("Forgot Password",
                    //       style: TextStyle(
                    //           color: Color(0xffa11414),
                    //           fontWeight: FontWeight.w600)),
                    //   onTap: () {},
                    // ),
                    SizedBox(
                      height: height / 20,
                    ),
                    TextButton(
                        onPressed: () {
                          _con.login();
                          print("username: ${uc.text}");
                          print("password: ${pc.text}");
                        },
                        // () {
                        //   if (_con.loginFormKey.currentState.validate()) {
                        //     _con.login();
                        //   }
                        // },
                        child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                vertical: height / 50, horizontal: width / 20),
                            child: Center(
                                child: Text("SIGN IN",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white))),
                            decoration: BoxDecoration(
                                color: Color(0xffa11414),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(size / 160)))))
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start),
              key: _con.loginFormKey),
          padding: EdgeInsets.symmetric(horizontal: width / 12.8)),
      bottomNavigationBar: OutlinedButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/register');
        },
        child: Container(
          child: Center(
            child: Text("REGISTER",
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
            side:
                MaterialStateProperty.all(BorderSide(color: Color(0xffa11414))),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            backgroundColor: MaterialStateProperty.all(Color(0xffa11414))),
      ),
    );
  }
}
