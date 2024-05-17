import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../helpers/custom_trace.dart';

class Dashboard {
  String id,
      todayorders,
      todayrevenue,
      canceltdyorders,
      canceltdyrevenue,
      lastwkorders,
      lastwkrevenue,
      lastmthorders,
      lastmthrevenue,
      valetlimit,
      valettotal,
      available;
  // double earning, deliveryFee, credit, debit, balance;
  // DateTime dateTime;

  Dashboard();

  Dashboard.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      todayorders = jsonMap['delivered_today'].toString();
      todayrevenue = jsonMap['delivered_today_revenue'].toString();
      canceltdyorders = jsonMap['cancelled_today'].toString();
      canceltdyrevenue = jsonMap['cancelled_today_revenue'].toString();
      lastwkorders = jsonMap['last_week'].toString();
      lastwkrevenue = jsonMap['last_week_revenue'].toString();
      lastmthorders = jsonMap['last_month'].toString();
      lastmthrevenue = jsonMap['last_month_revenue'].toString();
      valetlimit = jsonMap['valetlimit'].toString();
      valettotal = jsonMap['valettotal'].toString();
      available = jsonMap['available'].toString();
      // ifsc = jsonMap['ifsc'].toString();
      // earning =
      //     jsonMap['earning'] != null ? jsonMap['earning'].toDouble() : 0.0;
      // credit = jsonMap['credit'] != null ? jsonMap['credit'].toDouble() : 0.0;
      // debit = jsonMap['debit'] != null ? jsonMap['debit'].toDouble() : 0.0;
      // balance =
      //     jsonMap['balance'] != null ? jsonMap['balance'].toDouble() : 0.0;
      // deliveryFee = jsonMap['delivery_fee'] != null
      //     ? jsonMap['delivery_fee'].toDouble()
      //     : 0.0;
      // dateTime = DateTime.parse(jsonMap['updated_at'] ?? "2021-03-03 04:58:52");
      // userID = jsonMap['user_id'] == null ? "" : jsonMap['user_id'].toString();
    } catch (e) {
      todayorders = '';
      todayrevenue = '';
      canceltdyorders = '';
      canceltdyrevenue = '';
      lastwkorders = '';
      lastwkrevenue = '';
      lastmthorders = '';
      lastmthrevenue = '';
      valetlimit = '';
      valettotal = '';
      // ifsc = '';
      // earning = 0.0;
      // deliveryFee = 0.0;
      // credit = 0.0;
      // debit = 0.0;
      // balance = 0.0;
      // dateTime = DateTime(0);
      // userID = "";
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    return other is Dashboard && this.id == other.id;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => this.id.hashCode;
}
