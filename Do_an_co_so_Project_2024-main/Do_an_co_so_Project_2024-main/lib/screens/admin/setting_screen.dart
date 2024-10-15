import 'package:flutter/material.dart';
import 'ad_custom_drawer.dart';
import '../../widgets/logout_widget.dart';
import '../theme_selection_screen.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: AdCustomDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBar(),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Đổi giao diện',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ThemeSelectionScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          Spacer(),
          LogOut(),
        ],
      ),
    );
  }
}

class AppBar extends StatelessWidget {
  const AppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 80, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Cài đặt',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          IconButton(
            icon: Icon(Icons.menu, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ],
      ),
    );
  }
}
