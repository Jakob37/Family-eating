import 'package:flutter/material.dart';
import 'models/dish.dart';

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

class WeekMenuCard extends StatelessWidget {
  final String day;
  final String? dish;
  final bool cooked;
  final Color cardColor;
  final VoidCallback onTap;
  final ValueChanged<bool?> onCookedChanged;

  const WeekMenuCard({
    super.key,
    required this.day,
    required this.dish,
    required this.cooked,
    required this.cardColor,
    required this.onTap,
    required this.onCookedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (dish != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          dish!,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black54),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 1.4,
                child: Checkbox(
                  value: cooked,
                  onChanged: dish == null ? null : onCookedChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
