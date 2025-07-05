import 'package:flutter/material.dart';

class AppConstants {
  static const double dishFontSize = 16.0;
  static const double dishVerticalSpacing = 8.0;
}

const Color kCardColor = Color(0xFFBBDEFB); // Colors.blue[100]

const Map<DishCategory, Color> kCategoryColors = {
  DishCategory.egg: Color(0xFFFFF9C4), // light yellow
  DishCategory.pork: Color(0xFFFFCCBC), // light orange
  DishCategory.beef: Color(0xFFD7CCC8), // light brown
  DishCategory.fish: Color(0xFFB3E5FC), // light blue
  DishCategory.tofu: Color(0xFFC8E6C9), // light green
  DishCategory.other: Color(0xFFE0E0E0), // light grey
};

enum DishCategory { egg, pork, beef, fish, tofu, other }

class Dish {
  final String name;
  int count;
  DishCategory category;

  Dish({required this.name, required this.count, required this.category});

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      name: json['name'] as String,
      count: json['count'] as int,
      category: DishCategory.values[json['category'] as int],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'count': count,
        'category': category.index,
      };
}

// Helper for category display names
String categoryToString(DishCategory category) {
  switch (category) {
    case DishCategory.egg:
      return 'Egg';
    case DishCategory.pork:
      return 'Pork';
    case DishCategory.beef:
      return 'Beef';
    case DishCategory.fish:
      return 'Fish';
    case DishCategory.tofu:
      return 'Tofu';
    case DishCategory.other:
      return 'Other';
  }
}
