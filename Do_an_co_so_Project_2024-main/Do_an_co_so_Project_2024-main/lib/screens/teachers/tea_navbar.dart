import 'package:flutter/material.dart';
import 'package:tea_man_pka/screens/teachers/tea_home_screen.dart';
import 'package:tea_man_pka/screens/teachers/tea_setting_screen.dart';

class TeaNavigationBar extends StatefulWidget {
  final Map<String, dynamic> teacherData;

  const TeaNavigationBar({super.key, required this.teacherData});

  @override
  _TeaNavigationBarState createState() => _TeaNavigationBarState();
}

class _TeaNavigationBarState extends State<TeaNavigationBar> {
  int _selectedIndex = 0;

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      TeaHomeScreen(teacherData: widget.teacherData),
      TeaSettingsScreen(),
    ];
  }

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
