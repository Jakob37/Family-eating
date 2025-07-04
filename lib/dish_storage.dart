import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart'; // For the Dish class and MainApp.dishes

class DishStorage {
  static const String _storageKey = 'dishes_data';

  static Future<List<Dish>> loadDishes(List<Dish> defaultDishes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((e) => Dish.fromJson(e)).toList();
    } else {
      await saveDishes(defaultDishes);
      return defaultDishes;
    }
  }

  static Future<void> saveDishes(List<Dish> dishes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(dishes.map((d) => d.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }
}
