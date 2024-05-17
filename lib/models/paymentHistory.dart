import '../helpers/custom_trace.dart';

class Paymenthistory {
  String id,
      user_id,
      method,
      amount,
      paid_date,
      totalamount,
      credit,
      debit,
      balance,
      transaction_id,
      transaction_status;
  // double earning, deliveryFee, credit, debit, balance;
  // DateTime dateTime;

  Paymenthistory();

  Paymenthistory.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      user_id = jsonMap['user_id'].toString();
      method = jsonMap['method'].toString();
      amount = jsonMap['amount'].toString();
      paid_date = jsonMap['paid_date'].toString();
      totalamount = jsonMap['totalamount'].toString();
      credit = jsonMap['credit'].toString();
      debit = jsonMap['debit'].toString();
      balance = jsonMap['balance'].toString();
      transaction_id = jsonMap['transaction_id'].toString();
      transaction_status = jsonMap['transaction_status'].toString();
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
      id = '';
      user_id = '';
      method = '';
      amount = '';
      paid_date = '';
      totalamount = '';
      credit = '';
      debit = '';
      balance = '';
      transaction_id = '';
      transaction_status = '';
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
    return other is Paymenthistory && this.id == other.id;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => this.id.hashCode;
}
