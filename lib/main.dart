import 'package:flutter/material.dart';

class AppConstants {
  static const double dishFontSize = 16.0;
  static const double dishVerticalSpacing = 8.0;
}

const Color kCardColor = Color(0xFFBBDEFB); // Colors.blue[100]

enum DishCategory { egg, pork, beef, fish, tofu, other }

class Dish {
  final String name;
  int count;
  final DishCategory category;

  Dish({required this.name, required this.count, required this.category});
}

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  static final List<Dish> dishes = [
    Dish(name: 'Varma mackor', count: 6, category: DishCategory.egg),
    Dish(name: 'Kyckling + potatis', count: 3, category: DishCategory.other),
    Dish(name: 'Pannkakor', count: 4, category: DishCategory.egg),
    Dish(name: 'Pastasallad', count: 3, category: DishCategory.other),
    Dish(name: 'Fiskburgare', count: 3, category: DishCategory.fish),
    Dish(name: 'Korv + rösti', count: 1, category: DishCategory.pork),
    Dish(name: 'Kyckling i ugn', count: 2, category: DishCategory.other),
    Dish(name: 'Lax teriyaki', count: 1, category: DishCategory.fish),
    Dish(
        name: 'Stekta ägg och kinesisk pannkaka',
        count: 2,
        category: DishCategory.egg),
    Dish(name: 'Tomat crumbled eggs', count: 3, category: DishCategory.egg),
    Dish(
        name: 'Kyckling och rostad potatis',
        count: 1,
        category: DishCategory.other),
    Dish(
        name: 'Tofu, nudlar, grönsaker', count: 2, category: DishCategory.tofu),
    Dish(name: 'Våfflor', count: 1, category: DishCategory.egg),
    Dish(name: 'Fiskpinnar och potatis', count: 1, category: DishCategory.fish),
    Dish(name: 'Korv med bröd', count: 1, category: DishCategory.pork),
    Dish(name: 'Currykyckling', count: 1, category: DishCategory.other),
    Dish(
        name: 'Köttbullar och potatismos',
        count: 1,
        category: DishCategory.beef),
    Dish(name: 'Pytt i panna med keso', count: 2, category: DishCategory.other),
    Dish(name: 'Lax och potatis', count: 1, category: DishCategory.fish),
    Dish(name: 'Veganköttbullar', count: 1, category: DishCategory.tofu),
    Dish(name: 'Quesadilla', count: 1, category: DishCategory.other),
    Dish(
        name: 'Grillat kött med potatis',
        count: 1,
        category: DishCategory.beef),
  ];

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late List<Dish> _dishes;
  DishCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _dishes = MainApp.dishes
        .map((d) => Dish(name: d.name, count: d.count, category: d.category))
        .toList();
  }

  void _incrementDishCount(String dishName) {
    setState(() {
      final dish = _dishes.firstWhere((d) => d.name == dishName);
      dish.count += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter dishes by selected category if set
    final filteredDishes = _selectedCategory == null
        ? _dishes
        : _dishes.where((d) => d.category == _selectedCategory).toList();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Food planning'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Filter: ', style: TextStyle(fontSize: 16)),
                  DropdownButton<DishCategory?>(
                    value: _selectedCategory,
                    hint: const Text('All'),
                    items: [
                      const DropdownMenuItem<DishCategory?>(
                        value: null,
                        child: Text('All'),
                      ),
                      ...DishCategory.values
                          .map((cat) => DropdownMenuItem<DishCategory?>(
                                value: cat,
                                child: Text(categoryToString(cat)),
                              )),
                    ],
                    onChanged: (cat) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: DishList(
                  dishes: filteredDishes,
                  onIncrement: _incrementDishCount,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
                        color: kCardColor,
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
                                _categoryToString(dish.category),
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

  String _categoryToString(DishCategory category) {
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
}

class DishDetailPage extends StatelessWidget {
  final Dish dish;
  final VoidCallback onIncrement;

  const DishDetailPage(
      {super.key, required this.dish, required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dish.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Category: ${_categoryToString(dish.category)}',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            const Text(
              'Placeholder info about this dish.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            Text(
              'Cooked: ${dish.count} times',
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                onIncrement();
                Navigator.of(context).pop();
              },
              child: const Text('I cooked this!'),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryToString(DishCategory category) {
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
