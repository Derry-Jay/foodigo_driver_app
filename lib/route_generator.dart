import 'package:flutter/material.dart';
// import 'package:foodigo_customer_app/models/route_argument.dart';

import 'package:foodigo_driver_app/models/order.dart';
import 'package:foodigo_driver_app/models/order_status_check.dart';
import 'package:foodigo_driver_app/pages/amount_collect.dart';
import 'package:foodigo_driver_app/pages/app_pages.dart';
import 'package:foodigo_driver_app/pages/changepassword.dart';
import 'package:foodigo_driver_app/pages/delivered_history.dart';
import 'package:foodigo_driver_app/pages/help&support.dart';
import 'package:foodigo_driver_app/pages/login_page.dart';
import 'package:foodigo_driver_app/pages/order_tracking_page.dart';
import 'package:foodigo_driver_app/pages/payment_history.dart';
import 'package:foodigo_driver_app/pages/profile_update.dart';
import 'package:foodigo_driver_app/pages/register_page.dart';

import 'models/user.dart';
import 'pages/order_otp_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterWebview());
      case '/changepassword':
        return MaterialPageRoute(builder: (_) => PasswordUpdatePage());
      case '/profileupdate':
        return MaterialPageRoute(
            builder: (_) => ProfileUpdatePage(args as User));
      case '/pages':
        return MaterialPageRoute(
            builder: (_) => AppPages(
                  currentTab: args as int,
                ));
      case '/locateCustomer':
        return MaterialPageRoute(
            builder: (_) => OrderTrackingPage(
                  order: args as Order,
                ));
      case '/otpconfrim':
        return MaterialPageRoute(builder: (_) => Otpconfrim(orderid: args));
      case '/amountconfrim':
        return MaterialPageRoute(
            builder: (_) => Amountconfrim(
                  amount: args,
                  orderid: args,
                ));
      case '/help&support':
        return MaterialPageRoute(builder: (_) => HelpandSupport());
      case '/deliveredhistory':
        return MaterialPageRoute(builder: (_) => DeliveredHistory());
      case '/paymenthistory':
        return MaterialPageRoute(builder: (_) => PaymentHistory());
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return MaterialPageRoute(
            builder: (_) =>
                Scaffold(body: SafeArea(child: Text('Route Error'))));
    }
  }
}
// MaterialPageRoute(builder: (_) => Page())
