import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/dish.dart';

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

class WeeksMenuEntry {
  final String? dishName;
  final bool cooked;
  WeeksMenuEntry({this.dishName, this.cooked = false});

  factory WeeksMenuEntry.fromJson(Map<String, dynamic> json) => WeeksMenuEntry(
        dishName: json['dishName'] as String?,
        cooked: json['cooked'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'dishName': dishName,
        'cooked': cooked,
      };
}

class DishStorageWeeksMenu {
  static const String _weeksMenuKey = 'weeks_menu_data';
  static const String _weeksMenuLabelKey = 'weeks_menu_label';

  static Future<Map<String, WeeksMenuEntry>> loadWeeksMenu(
      List<String> daysOfWeek) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_weeksMenuKey);
    if (jsonString != null) {
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      return {
        for (final day in daysOfWeek)
          day: jsonMap[day] != null
              ? WeeksMenuEntry.fromJson(jsonMap[day])
              : WeeksMenuEntry(),
      };
    } else {
      return {for (final day in daysOfWeek) day: WeeksMenuEntry()};
    }
  }

  static Future<void> saveWeeksMenu(Map<String, WeeksMenuEntry> menu) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode({
      for (final entry in menu.entries) entry.key: entry.value.toJson(),
    });
    await prefs.setString(_weeksMenuKey, jsonString);
  }

  static Future<String> loadWeeksMenuLabel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_weeksMenuLabelKey) ?? '';
  }

  static Future<void> saveWeeksMenuLabel(String label) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weeksMenuLabelKey, label);
  }
}

class WeeksMenuHistoryEntry {
  final String label;
  final Map<String, WeeksMenuEntry> menu;
  WeeksMenuHistoryEntry({required this.label, required this.menu});

  factory WeeksMenuHistoryEntry.fromJson(Map<String, dynamic> json) =>
      WeeksMenuHistoryEntry(
        label: json['label'] as String,
        menu: (json['menu'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, WeeksMenuEntry.fromJson(v))),
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'menu': {
          for (final entry in menu.entries) entry.key: entry.value.toJson()
        },
      };
}

class DishStorageWeeksMenuHistory {
  static const String _weeksMenuHistoryKey = 'weeks_menu_history';

  static Future<List<WeeksMenuHistoryEntry>> loadWeeksMenuHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_weeksMenuHistoryKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((e) => WeeksMenuHistoryEntry.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  static Future<void> saveWeeksMenuHistory(
      List<WeeksMenuHistoryEntry> history) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(history.map((e) => e.toJson()).toList());
    await prefs.setString(_weeksMenuHistoryKey, jsonString);
  }
}

class DishStorageCategories {
  static const String _customCategoriesKey = 'custom_categories';

  static Future<List<String>> loadCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_customCategoriesKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.cast<String>();
    } else {
      return [];
    }
  }

  static Future<void> saveCustomCategories(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(categories);
    await prefs.setString(_customCategoriesKey, jsonString);
  }
}
