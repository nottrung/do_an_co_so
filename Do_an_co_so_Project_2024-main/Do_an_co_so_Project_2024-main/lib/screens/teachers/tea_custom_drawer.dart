import 'package:flutter/material.dart';
import 'list_lecturer/list_other_tea_screen.dart';
import 'personalized/personal_profile_screen.dart';
import 'request/list_personal_request_screen.dart';
import 'salary/personal_salary_screen.dart';
import 'schedule/list_personal_schedule_screen.dart';
import 'tea_home_screen.dart';
import '../theme_selection_screen.dart';
import '../../widgets/logout_widget.dart';

class TeaCustomDrawer extends StatelessWidget {
  final Map<String, dynamic> teacherData;

  const TeaCustomDrawer({super.key, required this.teacherData});

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
                MaterialPageRoute(builder: (context) => TeaHomeScreen(teacherData: teacherData)),
              );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(60,0,0,0),
            leading: Icon(Icons.person_outline_rounded),
            title: Text('Hồ sơ cá nhân'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PersonalProfileScreen(teacherData: teacherData)),
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
                MaterialPageRoute(builder: (context) => ListOtherTeaScreen(teacherData: teacherData)),
              );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(60,0,0,0),
            leading: Icon(Icons.calendar_month_rounded),
            title: Text('Xem lịch giảng'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListPersonalScheduleScreen(teacherData: teacherData)),
              );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(60,0,0,0),
            leading: Icon(Icons.attach_money_rounded),
            title: Text('Thông tin lương'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PersonalSalaryScreen(teacherData: teacherData)),
              );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(60,0,0,0),
            leading: Icon(Icons.done_all_rounded),
            title: Text('Gửi yêu cầu'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListPersonalRequestScreen(teacherData: teacherData)),
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
