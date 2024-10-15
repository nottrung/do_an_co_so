import 'package:flutter/material.dart';
import 'package:tea_man_pka/screens/admin/request_manager/list_request_screen.dart';
import 'package:tea_man_pka/screens/admin/schedule_manager/list_schedule_screen.dart';
import 'package:tea_man_pka/screens/admin/tea_profile_manager/list_all_tea_screen.dart';
import 'category.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    Key? key,
    required this.category,
  }) : super(key: key);

  final Category category;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        switch (category.name) {
          case 'Thông Tin':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ListAllTeaScreen())
            );
            break;
          case 'Lịch Giảng':
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListScheduleScreen())
            );
            break;
          case 'Yêu Cầu':
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListRequestScreen())
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
              child: Image.asset(category.thumbnail, height: 100,),
            ),
            SizedBox(height: 10,),
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
