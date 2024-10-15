import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tea_man_pka/screens/teachers/personalized/personal_profile_screen.dart';
import '../../widgets/logout_widget.dart';
import '../theme_selection_screen.dart';

class TeaSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBar(),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: FutureBuilder<Map<String, dynamic>?>(
              future: getUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi khi tải dữ liệu người dùng.'));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: Text('Không tìm thấy thông tin người dùng.'));
                } else {
                  var userData = snapshot.data!;
                  var imageUrl = userData['imageUrl'] ?? '';

                  return Column(
                    children: [
                      ListTile(
                        title: Row(
                          children: [
                            Text(
                              'Hồ sơ cá nhân',
                              style: TextStyle(
                                fontSize: 17,
                              ),
                            ),
                            Spacer(),
                            imageUrl.isNotEmpty
                                ? CircleAvatar(
                              backgroundImage: NetworkImage(imageUrl),
                            )
                                : CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PersonalProfileScreen(teacherData: userData),
                            ),
                          );
                          },
                      ),
                      ListTile(
                        title: Text(
                          'Đổi giao diện',
                          style: TextStyle(
                            fontSize: 17,
                            // fontWeight: FontWeight.bold,
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
                  );
                }
              },
            ),
          ),
          Expanded(child: Container()),
          LogOut(),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userEmail = user.email?.toLowerCase() ?? '';

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('teachers')
            .get();

        for (var doc in querySnapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          String internalEmail = data['internalEmail']?.toString().toLowerCase() ?? '';

          if (internalEmail == userEmail) {
            return data;
          }
        }
        return null;
      } else {
        return null;
      }
    } catch (e) {
      print('Lỗi truy xuất dữ liệu: $e');
      return null;
    }
  }
}

class AppBar extends StatelessWidget {
  const AppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 80, 20, 20),
      child: Text(
        'Cài đặt',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
      ),
    );
  }
}
