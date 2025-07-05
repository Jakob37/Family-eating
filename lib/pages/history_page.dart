import 'package:flutter/material.dart';

import '../dish_storage.dart';
import '../models.dart';
import 'weeks_menu_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<WeeksMenuHistoryEntry> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await DishStorageWeeksMenuHistory.loadWeeksMenuHistory();
    setState(() {
      _history = history.reversed.toList(); // Show most recent first
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_history.isEmpty) {
      return const Center(child: Text('No previous weeks yet.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final entry = _history[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.label,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...WeeksMenuPage.daysOfWeek.map((day) {
                  final dishEntry = entry.menu[day];
                  return Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(day,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      if (dishEntry?.dishName != null)
                        Expanded(
                          child: Text(
                            dishEntry!.dishName!,
                            style: TextStyle(
                              color: dishEntry.cooked
                                  ? Colors.green
                                  : Colors.black87,
                              decoration: dishEntry.cooked
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        )
                      else
                        const Expanded(child: Text('-')),
                      if (dishEntry?.cooked == true)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.check, color: Colors.green, size: 18),
                        ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}
