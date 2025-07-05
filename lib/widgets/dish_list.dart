import 'package:flutter/material.dart';

import '../models.dart';
import '../pages/dish_detail_page.dart';

class DishList extends StatelessWidget {
  final List<Dish> dishes;
  final void Function(String dishName) onIncrement;

  const DishList({super.key, required this.dishes, required this.onIncrement});

  void _openDishDetail(BuildContext context, Dish dish) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DishDetailPage(
          dish: dish,
          onIncrement: () => onIncrement(dish.name),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedDishes = [...dishes]..sort((a, b) {
      final countCompare = b.count.compareTo(a.count);
      if (countCompare != 0) return countCompare;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppConstants.dishVerticalSpacing),
          ...sortedDishes.map((dish) => Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: InkWell(
                      onTap: () => _openDishDetail(context, dish),
                      child: Card(
                        color: kCategoryColors[dish.category] ?? kCardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  dish.name,
                                  style: TextStyle(
                                    fontSize: AppConstants.dishFontSize,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${dish.count}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                categoryToString(dish.category),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppConstants.dishVerticalSpacing),
                ],
              )),
        ],
      ),
    );
  }
}
