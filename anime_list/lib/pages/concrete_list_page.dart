import 'package:flutter/material.dart';

class ConcreteList extends StatelessWidget {
  final String text;
  final VoidCallback onBack;

  const ConcreteList({super.key, required this.text, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: FloatingActionButton(
                child: Icon(Icons.arrow_back),
                onPressed: onBack,
              ),
            ),
              Align(
              alignment: Alignment.topRight,
              child: FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: (){
                  
                },
              ),
            ),
          ],
        ),
        Expanded(
          child: Center(
            child: Text(text, style: TextStyle(fontSize: 24)),
          ),
        ),
      ],
    );
  }
}