import 'food.dart';

class FoodBase {
  final bool success;
  final String message;
  final List<Food> orderedFood;
  FoodBase(this.success, this.message, this.orderedFood);
  factory FoodBase.fromMap(Map<String, dynamic> json) {
    return FoodBase(
        json['success'],
        json['message'],
        json['data'] == null
            ? <Food>[]
            : List.from(json['data']).map((e) => Food.fromJSON(e)).toList());
  }
}
