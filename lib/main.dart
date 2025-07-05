import 'package:flutter/material.dart';
import 'dish_storage.dart';
import 'ui_components.dart';
import 'models.dart';
import 'widgets/dish_list.dart';
import 'pages/weeks_menu_page.dart';
import 'pages/history_page.dart';


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
  final GlobalKey<WeeksMenuPageState> _weeksMenuKey =
      GlobalKey<WeeksMenuPageState>();

  @override
  void initState() {
    super.initState();
    _loadDishes();
  }

  Future<void> _loadDishes() async {
    _dishes = await DishStorage.loadDishes(MainApp.dishes
        .map((d) => Dish(
              name: d.name,
              count: d.count,
              category: d.category,
              customCategory: d.customCategory,
              info: d.info,
            ))
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

  @override
  Widget build(BuildContext context) {
    // Filter dishes by selected category if set
    final filteredDishes = _selectedCategory == null
        ? _dishes
        : _dishes.where((d) => d.category == _selectedCategory).toList();

    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(
              toolbarHeight: 0,
              centerTitle: true,
              bottom: const TabBar(
                tabs: [
                  Tab(text: "Week's Menu"),
                  Tab(text: 'Food Planning'),
                  Tab(text: 'History'),
                ],
              ),
            ),
            body: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      WeeksMenuPage(key: _weeksMenuKey, allDishes: _dishes),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                defaultDishes: MainApp.dishes,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const HistoryPage(),
                    ],
                  ),
            floatingActionButton: Builder(
              builder: (context) {
                final tabController = DefaultTabController.of(context);
                return AnimatedBuilder(
                  animation: tabController,
                  builder: (context, child) {
                    if (tabController.index == 0) {
                      // Week's Menu tab
                      return FloatingActionButton.extended(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Finish Week'),
                              content: const Text(
                                  'Are you sure you want to clear the week?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Yes, clear'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            // Clear the week
                            _weeksMenuKey.currentState?.clearWeek();
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Week is done'),
                      );
                    } else if (tabController.index == 1) {
                      // Food Planning tab
                      return FloatingActionButton(
                        onPressed: () async {
                          await showAddDishDialog(context, (newDish) {
                            setState(() {
                              _dishes.add(newDish);
                            });
                            DishStorage.saveDishes(_dishes);
                          });
                        },
                        child: const Icon(Icons.add),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
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



