import '../helpers/custom_trace.dart';

class OrderStatusid {
  String orderid;
  String orderstatusid;
  String orderotp;

  OrderStatusid();

  OrderStatusid.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      orderid = jsonMap['id'].toString();
      orderstatusid = jsonMap['order_status_id'].toString();
      orderotp = jsonMap['orderotp'].toString();
    } catch (e) {
      orderid = '';
      orderstatusid = '';
      orderotp = '';
      print(CustomTrace(StackTrace.current, message: e));
    }
  }
}
