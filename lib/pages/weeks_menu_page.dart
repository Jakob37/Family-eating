import 'package:family_eating/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../dish_storage.dart';
import '../models/dish.dart';
import '../ui_components.dart';

class WeeksMenuPage extends StatefulWidget {
  const WeeksMenuPage({super.key});

  static const List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  State<WeeksMenuPage> createState() => WeeksMenuPageState();
}

class WeeksMenuPageState extends State<WeeksMenuPage> {
  Map<String, WeeksMenuEntry> _menu = {
    for (final day in WeeksMenuPage.daysOfWeek) day: WeeksMenuEntry()
  };
  String _label = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMenuAndLabel();
  }

  Future<void> _loadMenuAndLabel() async {
    final loaded =
        await DishStorageWeeksMenu.loadWeeksMenu(WeeksMenuPage.daysOfWeek);
    String label = await DishStorageWeeksMenu.loadWeeksMenuLabel();
    if (label.isEmpty) {
      final now = DateTime.now();
      final weekOfYear = int.parse(DateFormat('w').format(now));
      final year = now.year;
      label = 'Week $weekOfYear, $year';
    }
    setState(() {
      _menu = loaded;
      _label = label;
      _loading = false;
    });
  }

  Future<void> _saveMenu() async {
    await DishStorageWeeksMenu.saveWeeksMenu(_menu);
  }

  Future<void> _saveLabel(String label) async {
    await DishStorageWeeksMenu.saveWeeksMenuLabel(label);
  }

  Future<void> _selectDish(BuildContext context, String day) async {
    final allDishes = MainApp.dishes;
    DishCategory? filterCategory;
    String? selected = _menu[day]?.dishName;
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final filteredDishes = filterCategory == null
                ? allDishes
                : allDishes.where((d) => d.category == filterCategory).toList();
            return AlertDialog(
              title: Text('Select dish for $day'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text('Filter: '),
                        DropdownButton<DishCategory?>(
                          value: filterCategory,
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
                          onChanged: (cat) => setState(() => filterCategory = cat),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 1,
                        childAspectRatio: 3.5,
                        shrinkWrap: true,
                        children: filteredDishes.map((dish) {
                          final isSelected = dish.name == selected;
                          return GestureDetector(
                            onTap: () => Navigator.of(context).pop(dish.name),
                            child: Card(
                              color: isSelected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.2)
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                side: isSelected
                                    ? BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 2)
                                    : BorderSide(
                                        color: Colors.grey.shade300, width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        dish.name,
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: kCategoryColors[dish.category]
                                            ?.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        getDishCategoryLabel(dish),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
    if (result != null) {
      setState(() {
        _menu[day] = WeeksMenuEntry(dishName: result, cooked: false);
      });
      _saveMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: WeeksMenuPage.daysOfWeek.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _label,
                  decoration: const InputDecoration(
                    labelText: 'Week label',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _label = val;
                    });
                    _saveLabel(val);
                  },
                ),
              ),
            ],
          );
        }
        final day = WeeksMenuPage.daysOfWeek[index - 1];
        final entry = _menu[day] ?? WeeksMenuEntry();
        final dish = entry.dishName;
        final cooked = entry.cooked;
        Color cardColor = kCardColor;
        if (dish != null) {
          final selectedDish = MainApp.dishes.firstWhere(
            (d) => d.name == dish,
            orElse: () => Dish(name: '', count: 0, category: DishCategory.other),
          );
          cardColor = kCategoryColors[selectedDish.category] ?? kCardColor;
        }
        return WeekMenuCard(
          day: day,
          dish: dish,
          cooked: cooked,
          cardColor: cardColor,
          onTap: () => _selectDish(context, day),
          onCookedChanged: (val) {
            if (dish == null) return;
            setState(() {
              _menu[day] = WeeksMenuEntry(dishName: dish, cooked: val ?? false);
            });
            _saveMenu();
          },
        );
      },
    );
  }

  Future<void> clearWeek() async {
    final label = _label;
    final menuCopy = {
      for (final e in _menu.entries)
        e.key: WeeksMenuEntry(dishName: e.value.dishName, cooked: e.value.cooked)
    };
    final entry = WeeksMenuHistoryEntry(label: label, menu: menuCopy);
    final history = await DishStorageWeeksMenuHistory.loadWeeksMenuHistory();
    history.add(entry);
    await DishStorageWeeksMenuHistory.saveWeeksMenuHistory(history);
    setState(() {
      _menu = {
        for (final day in WeeksMenuPage.daysOfWeek) day: WeeksMenuEntry()
      };
    });
    DishStorageWeeksMenu.saveWeeksMenu(_menu);
  }
}
