import 'dart:async';
import 'dart:math';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/material.dart';
import 'package:foodigo_driver_app/controllers/order_controller.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterWebview extends StatefulWidget {
  @override
  RegisterWebviewpage createState() => RegisterWebviewpage();
}

class RegisterWebviewpage extends StateMVC<RegisterWebview> {
  OrderController _con;
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  RegisterWebviewpage() : super(OrderController()) {
    _con = controller;
  }
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool haserror = false;
  bool checkotp = false;
  var url;
  final gc = new GlobalConfiguration();

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      url = Uri.parse(gc.getValue('base_url') + "driverregister");
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Completer<WebViewController> _controller =
        Completer<WebViewController>();
    // TODO: implement build
    return Scaffold(
        key: scaffoldKey,
        // appBar: AppBar(
        //     backgroundColor: Color(0xfffbfbfb),
        //     title: Text("Delivery Conformation"),
        //     leading: IconButton(
        //         onPressed: () {
        //           Navigator.of(context).pop();
        //         },
        //         icon: Icon(
        //           Icons.arrow_back,
        //           color: Colors.black,
        //         )),
        //     elevation: 0),
        body: SafeArea(
          child: WebviewScaffold(
            // supportMultipleWindows: true,
            // withLocalUrl: true,
            // withJavascript: true,
            // url = "https://applive.foodigo.in/driverregister";
            url: url.toString(),
            withLocalStorage: true,
          ),
          //     WebView(
          //   initialUrl: "https://app.foodigo.in/driverregister",
          //   javascriptMode: JavascriptMode.unrestricted,
          //   onWebViewCreated: (WebViewController webviewcontroller) {
          //     _controller.complete(webviewcontroller);
          //   },
          // )
        ));
  }
}
