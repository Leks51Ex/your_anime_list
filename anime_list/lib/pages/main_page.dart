import 'package:anime_list/pages/concrete_list_page.dart';
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
  int? selectedListId;
  String? selectedListTitle;

  void onItemChange(int index) {
    setState(() {
      selectedIndex = index;
      selectedListId = null;
      selectedListTitle = null;
    });
  }

  void onListSelect(int id, String title) {
    setState(() {
      selectedListId = id;
      selectedListTitle = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    Widget body;
    if (selectedIndex == 0) {
      body = selectedListId == null
          ? ListPage(onSelect: onListSelect)
          : ConcreteList(
              listId: selectedListId!,
              text: selectedListTitle ?? '',
              onBack: () {
                setState(() {
                  selectedListId = null;
                  selectedListTitle = null;
                });
              },
            );
    } else {
      body = const SettingsPage();
    }

    // смартфоны / узкие экраны
    if (width < 600) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            selectedIndex == 0
                ? (selectedListTitle ?? 'Наши крутые списочки')
                : 'Настройки',
          ),
          leading: selectedListId != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      selectedListId = null;
                      selectedListTitle = null;
                    });
                  },
                )
              : null,
        ),
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onItemChange,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.list_alt),
              label: 'Списочки',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Настройки',
            ),
          ],
        ),
      );
    }

    // планшеты / десктоп — старый layout с NavigationDrawer
    return Scaffold(
      body: Row(
        children: [
          NavigationDrawer(
            selectedIndex: selectedIndex,
            onDestinationSelected: onItemChange,
            children: const [
              SizedBox(
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
