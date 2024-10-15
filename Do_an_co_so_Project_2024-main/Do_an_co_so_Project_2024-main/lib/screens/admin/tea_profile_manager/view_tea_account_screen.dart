import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../ad_navbar.dart';

class ViewTeaAccountScreen extends StatelessWidget {
  final Map<String, dynamic> teacherData;
  const ViewTeaAccountScreen({Key? key, required this.teacherData}) : super(key: key);

  Future<void> _resetPassword(BuildContext context) async {
    String email = teacherData['internalEmail'];
    String newPassword = teacherData['teacherId'];
    String? oldPassword;

    try {
      // Tìm tài khoản trong Firestore bằng email
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('teachers')
          .where('internalEmail', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy tài khoản với email này.')),
        );
        return;
      }

      // Lấy uid và mật khẩu hiện tại của tài khoản từ Firestore
      String uid = querySnapshot.docs.first.id;
      oldPassword = querySnapshot.docs.first['password'];

      // Đăng nhập với email và mật khẩu hiện tại
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: oldPassword!);
      User? user = userCredential.user;

      if (user != null) {
        // Cập nhật mật khẩu trong Firebase Authentication
        await user.updatePassword(newPassword);

        // Cập nhật mật khẩu trong Firestore
        await FirebaseFirestore.instance
            .collection('teachers')
            .doc(uid)
            .update({'password': newPassword});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đặt lại mật khẩu thành công.')),
        );

        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể cập nhật mật khẩu.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi đặt lại mật khẩu.')),
      );
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin tài khoản nội bộ'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(teacherData['imageUrl'] ?? ''),
                    backgroundColor: Colors.grey,
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teacherData['name'] ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 10),
                        _buildInfoItem('Mã giảng viên', teacherData['teacherId']),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Card(
              // color: Theme.of(context).cardColor,
              margin: EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.grey, width: 1),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(''),
                        TextButton(
                          onPressed: () => _resetPassword(context),
                          child: Text(
                            'Reset Password',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    _buildInfoItem('Email', teacherData['internalEmail']),
                    _buildInfoItem('Password', teacherData['password']),
                    // Additional information items
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, dynamic value) {
    String displayValue = value?.toString() ?? 'Chưa cập nhật';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(displayValue),
          ),
        ],
      ),
    );
  }
}
