import 'package:flutter/material.dart';

import '../dish_storage.dart';
import '../models.dart';

class DishDetailPage extends StatefulWidget {
  final Dish dish;
  final VoidCallback onIncrement;
  final List<Dish> defaultDishes;

  const DishDetailPage({
    super.key,
    required this.dish,
    required this.onIncrement,
    required this.defaultDishes,
  });

  @override
  State<DishDetailPage> createState() => _DishDetailPageState();
}

class _DishDetailPageState extends State<DishDetailPage> {
  late DishCategory? _selectedCategory;
  List<String> _customCategories = [];
  String? _selectedCustomCategory;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.dish.category;
    _loadCustomCategories();
  }

  Future<void> _loadCustomCategories() async {
    final cats = await DishStorageCategories.loadCustomCategories();
    setState(() {
      _customCategories = cats;
      _loading = false;
      if (_selectedCategory == DishCategory.other &&
          cats.contains(widget.dish.name)) {
        _selectedCustomCategory = widget.dish.name;
      }
    });
  }

  Future<void> _saveCustomCategories() async {
    await DishStorageCategories.saveCustomCategories(_customCategories);
  }

  void _updateCategory(DishCategory? cat, [String? customCat]) async {
    setState(() {
      _selectedCategory = cat;
      _selectedCustomCategory = customCat;
    });
    if (cat == DishCategory.other &&
        customCat != null &&
        customCat.isNotEmpty) {
      if (!_customCategories.contains(customCat)) {
        setState(() {
          _customCategories.add(customCat);
        });
        await _saveCustomCategories();
      }
      setState(() {
        widget.dish.category = DishCategory.other;
      });
    } else if (cat != null) {
      setState(() {
        widget.dish.category = cat;
      });
    }
    // Save dish update to storage
    final dishes = await DishStorage.loadDishes(widget.defaultDishes);
    final idx = dishes.indexWhere((d) => d.name == widget.dish.name);
    if (idx != -1) {
      dishes[idx].category = widget.dish.category;
      await DishStorage.saveDishes(dishes);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dish.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Category: ',
                    style: TextStyle(fontSize: 16, color: Colors.black54)),
                DropdownButton<DishCategory>(
                  value: _selectedCategory,
                  items: [
                    ...DishCategory.values.map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(categoryToString(cat)),
                        )),
                  ],
                  onChanged: (cat) {
                    if (cat == DishCategory.other) {
                      setState(() {
                        _selectedCategory = cat;
                        _selectedCustomCategory = null;
                      });
                    } else {
                      _updateCategory(cat);
                    }
                  },
                ),
                if (_selectedCategory == DishCategory.other)
                  const SizedBox(width: 8),
                if (_selectedCategory == DishCategory.other)
                  DropdownButton<String>(
                    value: _selectedCustomCategory,
                    hint: const Text('Custom'),
                    items: [
                      ..._customCategories.map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          )),
                      const DropdownMenuItem<String>(
                        value: '__add_new__',
                        child: Text('Add new...'),
                      ),
                    ],
                    onChanged: (val) async {
                      if (val == '__add_new__') {
                        final newCat = await showDialog<String>(
                          context: context,
                          builder: (context) {
                            String input = '';
                            return AlertDialog(
                              title: const Text('Add new category'),
                              content: TextField(
                                autofocus: true,
                                decoration:
                                    const InputDecoration(labelText: 'Category name'),
                                onChanged: (v) => input = v,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(input),
                                  child: const Text('Add'),
                                ),
                              ],
                            );
                          },
                        );
                        if (newCat != null && newCat.trim().isNotEmpty) {
                          _updateCategory(DishCategory.other, newCat.trim());
                        }
                      } else if (val != null) {
                        _updateCategory(DishCategory.other, val);
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Placeholder info about this dish.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            Text(
              'Cooked: ${widget.dish.count} times',
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                widget.onIncrement();
                Navigator.of(context).pop();
              },
              child: const Text('I cooked this!'),
            ),
          ],
        ),
      ),
    );
  }
}
