import 'package:flutter/material.dart';
import 'dish_storage.dart';
import 'package:flutter/services.dart';

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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDishes();
  }

  Future<void> _loadDishes() async {
    _dishes = await DishStorage.loadDishes(MainApp.dishes
        .map((d) => Dish(name: d.name, count: d.count, category: d.category))
        .toList());
    setState(() {
      _loading = false;
    });
  }

  void _incrementDishCount(String dishName) {
    setState(() {
      final dish = _dishes.firstWhere((d) => d.name == dishName);
      dish.count += 1;
    });
    DishStorage.saveDishes(_dishes);
  }

  Future<void> showAddDishDialog(
      BuildContext context, void Function(Dish) onAdd) async {
    final _formKey = GlobalKey<FormState>();
    String name = '';
    DishCategory? category;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Dish'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Dish Name'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Please enter a name'
                      : null,
                  onChanged: (value) => name = value,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<DishCategory>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: DishCategory.values
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(categoryToString(cat)),
                          ))
                      .toList(),
                  onChanged: (cat) => category = cat,
                  validator: (value) =>
                      value == null ? 'Please select a category' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  onAdd(Dish(name: name.trim(), count: 0, category: category!));
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter dishes by selected category if set
    final filteredDishes = _selectedCategory == null
        ? _dishes
        : _dishes.where((d) => d.category == _selectedCategory).toList();

    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Family Eating'),
              centerTitle: true,
              bottom: const TabBar(
                tabs: [
                  Tab(text: "Week's Menu"),
                  Tab(text: 'Food Planning'),
                ],
              ),
            ),
            body: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      const WeeksMenuPage(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Text('Filter: ',
                                    style: TextStyle(fontSize: 16)),
                                DropdownButton<DishCategory?>(
                                  value: _selectedCategory,
                                  hint: const Text('All'),
                                  items: [
                                    const DropdownMenuItem<DishCategory?>(
                                      value: null,
                                      child: Text('All'),
                                    ),
                                    ...DishCategory.values.map((cat) =>
                                        DropdownMenuItem<DishCategory?>(
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
                    ],
                  ),
            floatingActionButton: Builder(
              builder: (context) {
                final tabController = DefaultTabController.of(context);
                return AnimatedBuilder(
                  animation: tabController,
                  builder: (context, child) {
                    // Show FAB only on the Food Planning tab (index 1)
                    return tabController.index == 1
                        ? FloatingActionButton(
                            onPressed: () async {
                              await showAddDishDialog(context, (newDish) {
                                setState(() {
                                  _dishes.add(newDish);
                                });
                                DishStorage.saveDishes(_dishes);
                              });
                            },
                            child: const Icon(Icons.add),
                          )
                        : const SizedBox.shrink();
                  },
                );
              },
            ),
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

class WeeksMenuPage extends StatelessWidget {
  const WeeksMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Ongoing week\'s menu will appear here.'),
    );
  }
}
