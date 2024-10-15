import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ad_custom_drawer.dart';
import '../../widgets/category.dart';
import '../../widgets/category_card.dart';

class AdHomeScreen extends StatefulWidget {
  const AdHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdHomeScreen> createState() => _AdHomeScreenState();
}

class _AdHomeScreenState extends State<AdHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(),
          SizedBox(height: 20),
          Body(),
        ],
      ),
      endDrawer: AdCustomDrawer(),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/login_img/admin.png'),
                ),
                SizedBox(width: 15),
                Text(
                  'Xin chào, \nAdmin',
                  style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white),
                ),
              ],
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

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userEmail = user.email ?? '';

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('teachers')
            .where('internalEmail', isEqualTo: userEmail)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot document = querySnapshot.docs.first;
          return document.data() as Map<String, dynamic>;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print('Lỗi truy xuất dữ liệu: $e');
      return null;
    }
  }
}

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          itemCount : categoryList.length,
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 20,
            mainAxisSpacing: 24,
          ),
          itemBuilder: (context, index) {
            return CategoryCard(
              category: categoryList[index],
            );
          },
        ),
      ],
    );
  }
}
