import 'package:flutter/material.dart';
import 'package:tea_man_pka/screens/admin/tea_profile_manager/list_all_tea_screen.dart';
import 'setting_screen.dart';
import 'ad_home_screen.dart';

class AdNavigationBar extends StatefulWidget {
  @override
  _AdNavigationBarState createState() => _AdNavigationBarState();
}

class _AdNavigationBarState extends State<AdNavigationBar> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    AdHomeScreen(),
    SettingsScreen(),
    ListAllTeaScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _selectedIndex == 0
                ? Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(
                Icons.home,
                color: Colors.white,
              ),
            )
                : Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 1
                ? Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(
                Icons.settings,
                color: Colors.white,
              ),
            )
                : Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
