import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_driver_app/controllers/user_controller.dart';
import 'package:foodigo_driver_app/elements/drawer.dart';
import 'package:foodigo_driver_app/models/route_argument.dart';
import 'package:foodigo_driver_app/pages/home_page.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:new_version/new_version.dart';

import 'driver_location_page.dart';
import 'driver_tasks_page.dart';

// ignore: must_be_immutable
class AppPages extends StatefulWidget {
  dynamic currentTab;
  Widget currentPage;
  RouteArgument routeArgument;
  DateTime currentBackPressTime;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  // State?c
  AppPages({
    Key key,
    this.currentTab,
  }) {
    print("------------");
    print(currentTab);
    print("_________");
    if (currentTab != null) {
      if (currentTab is RouteArgument) {
        routeArgument = currentTab;
        currentTab = int.parse(currentTab.id);
      }
    } else if (currentTab is int) {
      switch (currentTab) {
        case 0:
          // widget.currentPage = OrdersWidget(parentScaffoldKey: widget.scaffoldKey);
          currentPage = HomePage();
          break;
        case 1:
          currentPage = DriverTasksPage();
          // widget.currentPage = ProfileWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 2:
          currentPage = DriverLocationPage();
          break;
        // case 3:
        //   widget.currentPage = MapWidget(parentScaffoldKey: widget.scaffoldKey, routeArgument: widget.routeArgument);
        //   break;
      }
    } else {
      currentTab = 0;
    }
  }
  @override
  State<StatefulWidget> createState() => AppPagesState();
}

class AppPagesState extends StateMVC<AppPages> {
  UserController _con;
  AppPagesState() : super(UserController()) {
    _con = controller;
  }
  MediaQueryData get dimensions => MediaQuery.of(context);
  double get height => dimensions.size.height;
  double get width => dimensions.size.width;
  double get size => sqrt(pow(height, 2) + pow(width, 2));
  final scaffoldKey = GlobalKey<ScaffoldState>();

  void selectTab(int a) {
    setState(() {
      widget.currentTab = a == 4 ? 0 : a;
      switch (a) {
        case 0:
          widget.currentPage = HomePage();
          break;
        case 1:
          widget.currentPage = DriverTasksPage();
          break;
        case 2:
          widget.currentPage = DriverLocationPage();
          break;
        // case 3:
        // widget.currentPage = OrdersWidget(parentScaffoldKey: widget.scaffoldKey);
        //   widget.currentPage = MapWidget(parentScaffoldKey: widget.scaffoldKey, routeArgument: widget.routeArgument);
        //   break;
      }
    });
  }

  void checkversion() async {
    final newversion = NewVersion(
      androidId: "com.foodigo.driver",
    );
    final status = await newversion.getVersionStatus();
    // print("Version status");
    // print(status.appStoreLink);
    newversion.showAlertIfNecessary(context: context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkversion();
    selectTab(widget.currentTab);
  }

  @override
  void didUpdateWidget(covariant AppPages oldWidget) {
    // TODO: implement didUpdateWidget
    widget.currentTab = 0;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        key: _con.scaffoldKey,
        drawer: MyDrawer(),
        appBar: AppBar(
            backgroundColor: Color(0xfffbfbfb),
            // actions: [
            //   IconButton(
            //       onPressed: () {},
            //       icon: Icon(Icons.notifications, color: Color(0xffa11414)))
            // ],
            leading: IconButton(
                onPressed: () {
                  _con.scaffoldKey.currentState.openDrawer();
                },
                icon: Icon(
                  Icons.notes,
                  color: Colors.black,
                )),
            elevation: 0),
        body: widget.currentPage,
        bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Home",
                  backgroundColor: Color(0xfff5f4f4)),
              BottomNavigationBarItem(
                  icon: Icon(Icons.inbox_sharp),
                  label: "Request",
                  backgroundColor: Color(0xfff5f4f4)),
              BottomNavigationBarItem(
                  icon: Icon(Icons.location_on),
                  label: "Map",
                  backgroundColor: Color(0xfff5f4f4)),
              // BottomNavigationBarItem(
              //     icon: Icon(Icons.calendar_today_sharp),
              //     label: "Work",
              //     backgroundColor: Color(0xfff5f4f4))
              // BottomNavigationBarItem(icon: Icon(Icons.))
            ],
            currentIndex: widget.currentTab,
            onTap: selectTab,
            unselectedItemColor: Color(0xff929292),
            selectedItemColor: Color(0xffa11414),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Color(0xffF1F1F1),
            unselectedLabelStyle: TextStyle(
                color: Color(0xff929292),
                fontWeight: FontWeight.w500,
                fontSize: 10),
            selectedLabelStyle: TextStyle(
                color: Color(0xffa11414),
                fontWeight: FontWeight.w500,
                fontSize: 10)));
  }
}
