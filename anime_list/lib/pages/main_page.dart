import 'package:anime_list/pages/concrete_list_page.dart';
import 'package:anime_list/pages/list_page.dart';
import 'package:anime_list/pages/settings_page.dart';
import 'package:flutter/material.dart';

// main_page.dart
import 'package:anime_list/pages/list_page.dart';
import 'package:anime_list/pages/settings_page.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;
  String? selectedList;

  void onItemChange(int index) {
    setState(() {
      selectedIndex = index;
      selectedList = null; 
    });
  }

  void onListSelect(String text) {
    setState(() {
      selectedList = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (selectedIndex == 0) {
      body = selectedList == null
          ? ListPage(onSelect: onListSelect)
          : ConcreteList(text: selectedList!, onBack: () {
              setState(() {
                selectedList = null;
              });
            });
    } else {
      body = SettingsPage();
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationDrawer(
            selectedIndex: selectedIndex,
            onDestinationSelected: onItemChange,
            children: [
              Container(
                height: 80,
                child: DrawerHeader(child: Text('Наши крутые списочки')),
              ),
              NavigationDrawerDestination(
                icon: Icon(Icons.heart_broken),
                label: Text('Наши списочки'),
              ),
              SizedBox(height: 10),
              NavigationDrawerDestination(
                icon: Icon(Icons.settings),
                label: Text('Настройки'),
              ),
            ],
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
