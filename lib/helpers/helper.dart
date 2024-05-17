import 'dart:async';
import 'dart:math';
import 'dart:math' as Math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:foodigo_driver_app/controllers/order_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:html/parser.dart';

import '../../generated/l10n.dart';
import '../elements/CircularLoadingWidget.dart';
import '../models/food_order.dart';
import '../models/order.dart';
import '../repos/settings_repository.dart';

class Helper {
  BuildContext context;
  Helper.of(BuildContext _context) {
    this.context = _context;
  }

  // for mapping data retrieved form json array
  static getData(Map<String, dynamic> data) {
    return data['data'] ?? [];
  }

  static int getIntData(Map<String, dynamic> data) {
    return (data['data'] as int) ?? 0;
  }

  static bool getBoolData(Map<String, dynamic> data) {
    return (data['data'] as bool) ?? false;
  }

  static getObjectData(Map<String, dynamic> data) {
    return data['data'] ?? new Map<String, dynamic>();
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  static Future<Marker> getMarker(Map<String, dynamic> res) async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/img/marker.png', 120);
    final Marker marker = Marker(
        markerId: MarkerId(res['id']),
        icon: BitmapDescriptor.fromBytes(markerIcon),
//        onTap: () {
//          //print(res.name);
//        },
        anchor: Offset(0.5, 0.5),
        infoWindow: InfoWindow(
            title: res['name'],
            snippet: res['distance'].toStringAsFixed(2) + ' mi',
            onTap: () {
              print('infowi tap');
            }),
        position: LatLng(
            double.parse(res['latitude']), double.parse(res['longitude'])));

    return marker;
  }

  static Future<Marker> getOrderMarker(Map<String, dynamic> res) async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/img/marker.png', 120);
    final Marker marker = Marker(
        markerId: MarkerId(res['id']),
        icon: BitmapDescriptor.fromBytes(markerIcon),
//        onTap: () {
//          //print(res.name);
//        },
        anchor: Offset(0.5, 0.5),
        infoWindow: InfoWindow(
            title: res['address'],
            snippet: '',
            onTap: () {
              print('infowi tap');
            }),
        position: LatLng(res['latitude'], res['longitude']));

    return marker;
  }

  static Future<Marker> getMyPositionMarker(
      double latitude, double longitude) async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/img/my_marker.png', 120);
    final Marker marker = Marker(
        markerId: MarkerId(Random().nextInt(100).toString()),
        icon: BitmapDescriptor.fromBytes(markerIcon),
        anchor: Offset(0.5, 0.5),
        position: LatLng(latitude, longitude));

    return marker;
  }

  static List<Icon> getStarsList(double rate, {double size = 18}) {
    var list = <Icon>[];
    list = List.generate(rate.floor(), (index) {
      return Icon(Icons.star, size: size, color: Color(0xFFFFB24D));
    });
    if (rate - rate.floor() > 0) {
      list.add(Icon(Icons.star_half, size: size, color: Color(0xFFFFB24D)));
    }
    list.addAll(
        List.generate(5 - rate.floor() - (rate - rate.floor()).ceil(), (index) {
      return Icon(Icons.star_border, size: size, color: Color(0xFFFFB24D));
    }));
    return list;
  }

  static Widget getPrice(double myPrice, BuildContext context,
      {TextStyle style}) {
    if (style != null) {
      style = style.merge(TextStyle(fontSize: style.fontSize + 2));
    }
    try {
      if (myPrice == 0) {
        return Text('-', style: style ?? Theme.of(context).textTheme.subtitle1);
      }
      return RichText(
        softWrap: false,
        overflow: TextOverflow.fade,
        maxLines: 1,
        text: setting.value?.currencyRight != null &&
                setting.value?.currencyRight == false
            ? TextSpan(
                text: setting.value?.defaultCurrency,
                style: style ?? Theme.of(context).textTheme.subtitle1,
                children: <TextSpan>[
                  TextSpan(
                      text: myPrice.toStringAsFixed(2) ?? '',
                      style: style ?? Theme.of(context).textTheme.subtitle1),
                ],
              )
            : TextSpan(
                text: myPrice.toStringAsFixed(2) ?? '',
                style: style ?? Theme.of(context).textTheme.subtitle1,
                children: <TextSpan>[
                  TextSpan(
                      text: setting.value?.defaultCurrency,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: style != null
                              ? style.fontSize - 4
                              : Theme.of(context).textTheme.subtitle1.fontSize -
                                  4)),
                ],
              ),
      );
    } catch (e) {
      return Text('');
    }
  }

  static double getTotalOrderPrice(FoodOrder foodOrder) {
    double total = foodOrder.price;
    foodOrder.extras.forEach((extra) {
      total += extra.price != null ? extra.price : 0;
    });
    total *= foodOrder.quantity;
    return total;
  }

  static double getOrderPrice(FoodOrder foodOrder) {
    double total = foodOrder.price;
    foodOrder.extras.forEach((extra) {
      total += extra.price != null ? extra.price : 0;
    });
    return total;
  }

  static double getTaxOrder(Order order) {
    double total = 0;
    order.foodOrders.forEach((foodOrder) {
      total += getTotalOrderPrice(foodOrder);
    });
    total += order.deliveryFee;
    return order.tax * total / 100;
  }

  static double getTotalOrdersPrice(Order order) {
    double total = 0;
    order.foodOrders.forEach((foodOrder) {
      total += getTotalOrderPrice(foodOrder);
    });
    total += order.deliveryFee;
    total += order.tax * total / 100;
    return total;
  }

  static double getSubTotalOrdersPrice(Order order) {
    double total = 0;
    order.foodOrders.forEach((foodOrder) {
      total += getTotalOrderPrice(foodOrder);
    });
    return total;
  }

  static double price(List food) {
    double total = 0;
    for (var i = 0; i < food.length; i++) {
      var sub = food[i]['quantity'] * food[i]['price'];
      total = total + sub;
    }
    return total;
  }

  static String getDistance(double distance, String unit) {
    String _unit = setting.value.distanceUnit;
    if (_unit == 'km') {
      distance *= 1.60934;
    }
    return distance != null ? distance.toStringAsFixed(2) + " " + unit : "";
  }

  static String skipHtml(String htmlString) {
    try {
      var document = parse(htmlString);
      String parsedString = parse(document.body.text).documentElement.text;
      return parsedString;
    } catch (e) {
      return '';
    }
  }

  void navigateTo(String route, dynamic arguments, FutureOr<dynamic> onGoBack) {
    Navigator.pushNamed(context, route, arguments: arguments).then(onGoBack);
  }

  static Html applyHtml(context, String html, {TextStyle style}) {
    return Html(
      // blockSpacing: 0,
      data: html ?? '',
      // defaultTextStyle: style ?? Theme.of(context).textTheme.bodyText1.merge(TextStyle(fontSize: 14)),
      // useRichText: false,
      // customRender: (node, children) {
      //   if (node is dom.Element) {
      //     switch (node.localName) {
      //       case "br":
      //         return SizedBox(
      //           height: 0,
      //         );
      //       case "p":
      //         return Padding(
      //           padding: EdgeInsets.only(top: 0, bottom: 0),
      //           child: Container(
      //             width: double.infinity,
      //             child: Wrap(
      //               crossAxisAlignment: WrapCrossAlignment.center,
      //               alignment: WrapAlignment.start,
      //               children: children,
      //             ),
      //           ),
      //         );
      //     }
      //   }
      //   return null;
      // },
    );
  }

  static OverlayEntry overlayLoader(context) {
    OverlayEntry loader = OverlayEntry(builder: (context) {
      final size = MediaQuery.of(context).size;
      return Positioned(
        height: size.height,
        width: size.width,
        top: 0,
        left: 0,
        child: Material(
          color: Theme.of(context).primaryColor.withOpacity(0.85),
          child: CircularLoadingWidget(height: 200),
        ),
      );
    });
    return loader;
  }

  static hideLoader(OverlayEntry loader) {
    Timer(Duration(milliseconds: 500), () {
      try {
        loader?.remove();
      } catch (e) {}
    });
  }

  static String limitString(String text,
      {int limit = 24, String hiddenText = "..."}) {
    return text.substring(0, min<int>(limit, text.length)) +
        (text.length > limit ? hiddenText : '');
  }

  static String getCreditCardNumber(String number) {
    String result = '';
    if (number != null && number.isNotEmpty && number.length == 16) {
      result = number.substring(0, 4);
      result += ' ' + number.substring(4, 8);
      result += ' ' + number.substring(8, 12);
      result += ' ' + number.substring(12, 16);
    }
    return result;
  }

  static Uri getUri(String path) {
    String _path = Uri.parse(GlobalConfiguration().getString('base_url')).path;
    if (!_path.endsWith('/')) {
      _path += '/';
    }
    Uri uri = Uri(
        scheme: Uri.parse(GlobalConfiguration().getString('base_url')).scheme,
        host: Uri.parse(GlobalConfiguration().getString('base_url')).host,
        port: Uri.parse(GlobalConfiguration().getString('base_url')).port,
        path: _path + path);
    return uri;
  }

  String trans(String text) {
    switch (text) {
      case "App\\Notifications\\StatusChangedOrder":
        return S.of(context).order_satatus_changed;
      case "App\\Notifications\\NewOrder":
        return S.of(context).new_order_from_costumer;
      case "App\\Notifications\\AssignedOrder":
        return S.of(context).your_have_an_order_assigned_to_you;
      case "km":
        return S.of(context).km;
      case "mi":
        return S.of(context).mi;
      default:
        return "";
    }
  }

  static double haversineDistance(LatLng a, LatLng b) {
    return (12742 *
        asin(sqrt(1 -
            cos((a.latitude - b.latitude).abs()) +
            (cos(a.latitude) *
                cos(b.latitude) *
                (1 - cos((a.longitude - b.longitude).abs()))))));
  }

  static double distanceInMeters(LatLng a, LatLng b) {
    var _distanceInMeters = Geolocator.distanceBetween(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );

    return _distanceInMeters;
  }

  static double travelTime(LatLng a, LatLng b, LatLng c, LatLng d) {
    var _distanceInMeters1 = Geolocator.distanceBetween(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
    var _distanceInMeters2 = Geolocator.distanceBetween(
      c.latitude,
      c.longitude,
      d.latitude,
      d.longitude,
    );
    var meters = _distanceInMeters1 + _distanceInMeters2;
    var time = meters / 600;
    return time;
  }

  static double getDistanceFromLatLonInKm(LatLng loc_a, LatLng loc_b) {
    var R = 6371; // Radius of the earth in km
    var dLat =
        (loc_b.latitude - loc_a.latitude) * (Math.pi / 180); // deg2rad below
    var dLon = (loc_b.longitude - loc_a.longitude) * (Math.pi / 180);
    var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos((loc_a.latitude) * (Math.pi / 180)) *
            Math.cos((loc_b.latitude) * (Math.pi / 180)) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2);
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    var d = R * c; // Distance in km
    return d;
  }

  Map<String, double> locationToMap(LatLng a) {
    Map<String, double> map = {
      "longitude": a.longitude,
      "latitude": a.latitude
    };
    return map;
  }
}
