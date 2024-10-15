import 'package:flutter/material.dart';
import 'ad_home_screen.dart';
import 'request_manager/list_request_screen.dart';
import 'schedule_manager/list_schedule_screen.dart';
import 'tea_profile_manager/list_all_tea_screen.dart';
import '../theme_selection_screen.dart';
import '../../widgets/logout_widget.dart';

class AdCustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Trang chủ'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdHomeScreen()),
              );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(60,0,0,0),
            leading: Icon(Icons.view_list_rounded),
            title: Text('Danh sách giảng viên'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListAllTeaScreen()),
              );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(60,0,0,0),
            leading: Icon(Icons.calendar_month_rounded),
            title: Text('Quản lý lịch giảng'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListScheduleScreen()),
              );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(60,0,0,0),
            leading: Icon(Icons.done_all_rounded),
            title: Text('Quản lý yêu cầu'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListRequestScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.change_circle_outlined),
            title: Text('Đổi giao diện'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ThemeSelectionScreen()),
              );
            },
          ),
          Divider(height: 100),
          LogOut(),
        ],
      ),
    );
  }
}
