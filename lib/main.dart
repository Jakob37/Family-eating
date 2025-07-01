import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static const List<String> dishes = [
    'Spaghetti Bolognese',
    'Chicken Curry',
    'Vegetable Stir Fry',
    'Beef Tacos',
    'Salmon Teriyaki',
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Header'),
          centerTitle: true,
        ),
        body: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: DishList(),
        ),
      ),
    );
  }
}

class DishList extends StatelessWidget {
  const DishList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < MainApp.dishes.length; i++) ...[
          SizedBox(
            width: double.infinity,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(MainApp.dishes[i]),
              ),
            ),
          ),
          if (i != MainApp.dishes.length - 1) const SizedBox(height: 12),
        ]
      ],
    );
  }
}
