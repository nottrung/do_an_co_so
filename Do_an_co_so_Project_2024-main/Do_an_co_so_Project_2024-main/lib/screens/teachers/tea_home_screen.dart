import 'package:flutter/material.dart';
import 'package:tea_man_pka/screens/teachers/personalized/personal_profile_screen.dart';

import '../../widgets/category.dart';
import '../../widgets/category_card.dart';
import '../../widgets/tea_category_card.dart';
import 'tea_custom_drawer.dart';

class TeaHomeScreen extends StatelessWidget {
  final Map<String, dynamic> teacherData;

  const TeaHomeScreen({super.key, required this.teacherData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            imageUrl: teacherData['imageUrl'] ?? '',
            userName: teacherData['name'] ?? '',
            teacherData: teacherData,
          ),
          SizedBox(height: 15,),
          CustomBody(teacherData: teacherData,),
        ],
      ),
      endDrawer: TeaCustomDrawer(teacherData: teacherData),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  final String imageUrl;
  final String userName;
  final Map<String, dynamic> teacherData;

  const CustomAppBar({super.key, required this.imageUrl, required this.userName, required this.teacherData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonalProfileScreen(teacherData: teacherData),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.only(top: 50, left: 20, right: 20),
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor, Theme.of(context).canvasColor, Theme.of(context).backgroundColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : AssetImage('assets/login_img/default_avatar.png') as ImageProvider,
            ),
            SizedBox(width: 15),
            Expanded(
              child: Row(
                children: [
                  Text(
                    'Hello, \n$userName',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CustomBody extends StatelessWidget {
  const CustomBody({super.key, required this.teacherData});

  final Map<String, dynamic> teacherData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          itemCount: categoryList3.length,
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 20,
            mainAxisSpacing: 24,
          ),
          itemBuilder: (context, index) {
            return TeaCategoryCard(
              category: categoryList3[index], teacherData: teacherData,
            );
          },
        ),
      ],
    );
  }
}
