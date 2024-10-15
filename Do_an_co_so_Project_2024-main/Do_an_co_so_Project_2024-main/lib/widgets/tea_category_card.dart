import 'package:flutter/material.dart';
import 'package:tea_man_pka/screens/teachers/list_lecturer/list_other_tea_screen.dart';
import '../screens/teachers/schedule/list_personal_schedule_screen.dart';
import '../screens/teachers/request/list_personal_request_screen.dart';
import '../screens/teachers/salary/personal_salary_screen.dart';
import 'category.dart';

class TeaCategoryCard extends StatelessWidget {
  const TeaCategoryCard({Key? key, required this.category, required this.teacherData}) : super(key: key);
  final Category category;
  final Map<String, dynamic> teacherData;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        switch (category.name) {
          case 'Lịch Giảng':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ListPersonalScheduleScreen(teacherData: teacherData)),
            );
            break;
          case 'Gửi Yêu Cầu':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ListPersonalRequestScreen(teacherData: teacherData)),
            );
            break;
          case 'Danh Sách Giảng Viên':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ListOtherTeaScreen(teacherData: teacherData)),
            );
            break;
          case 'Lương':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PersonalSalaryScreen(teacherData: teacherData)),
            );
            break;
        }
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.1),
              blurRadius: 4.0,
              spreadRadius: .05,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Image.asset(category.thumbnail, height: 100),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                category.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
