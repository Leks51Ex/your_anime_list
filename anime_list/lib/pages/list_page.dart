import 'package:flutter/material.dart';

class ListPage extends StatelessWidget {
  final Function(String) onSelect;

  ListPage({super.key, required this.onSelect});

  final List<String> oursLists = [
    'Книги',
    'Фильмы',
    'Аниме',
    'Сериалы',
    'Презервативы'
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: oursLists.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: ElevatedButton(
            onPressed: () {
              onSelect(oursLists[index]);
            },
            child: Text(oursLists[index]),
          ),
        );
      },
    );
  }
}