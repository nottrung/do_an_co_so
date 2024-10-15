import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/theme_provider.dart';
import '../themes/app_themes.dart';

class ThemeSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn giao diện'),
      ),

      body: ListView(
        children: [
          SizedBox(height: 30),
          ListTile(
            title: Text('Giao diện sáng', style: TextStyle(fontSize: 17.0),),
            contentPadding: EdgeInsets.symmetric(horizontal: 30.0),
            onTap: () {
              Provider.of<ThemeProvider>(context, listen: false).setTheme(AppThemes.lightTheme);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Giao diện tối', style: TextStyle(fontSize: 17.0),),
            contentPadding: EdgeInsets.symmetric(horizontal: 30.0),
            onTap: () {
              Provider.of<ThemeProvider>(context, listen: false).setTheme(AppThemes.darkTheme);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Giao diện xanh dương', style: TextStyle(fontSize: 17.0),),
            contentPadding: EdgeInsets.symmetric(horizontal: 30.0),
            onTap: () {
              Provider.of<ThemeProvider>(context, listen: false).setTheme(
                AppThemes.blueTheme,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
