import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tea_man_pka/screens/admin/ad_home_screen.dart';
import '../ad_custom_drawer.dart';
import '../ad_navbar.dart';
import '../salary_manager/tea_profile_to_salary_screen.dart';
import '../schedule_manager/tea_profile_to_schedule_screen.dart';
import 'edit_tea_profile_screen.dart';
import 'view_tea_account_screen.dart';

class ViewTeaProfileScreen extends StatelessWidget {
  final Map<String, dynamic> teacherData;

  const ViewTeaProfileScreen({Key? key, required this.teacherData}) : super(key: key);

  Future<void> _deleteTeacher(BuildContext context) async {
    String teacherId = teacherData['teacherId'];
    String email = teacherData['internalEmail'];
    String password = teacherData['password'];

    // Hiển thị dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Đang xóa giảng viên...'),
              ],
            ),
          ),
        );
      },
    );


    try {
      // Xóa dữ liệu trong bảng teachers
      QuerySnapshot teacherQuery = await FirebaseFirestore.instance
          .collection('teachers')
          .where('teacherId', isEqualTo: teacherId)
          .get();
      for (DocumentSnapshot doc in teacherQuery.docs) {
        await doc.reference.delete();
      }

      // Xóa dữ liệu trong bảng schedules
      QuerySnapshot scheduleQuery = await FirebaseFirestore.instance
          .collection('schedules')
          .where('teacherId', isEqualTo: teacherId)
          .get();
      for (DocumentSnapshot doc in scheduleQuery.docs) {
        await doc.reference.delete();
      }

      // Xóa dữ liệu trong bảng requests (nếu có)
      QuerySnapshot requestQuery = await FirebaseFirestore.instance
          .collection('requests')
          .where('teacherId', isEqualTo: teacherId)
          .get();
      for (DocumentSnapshot doc in requestQuery.docs) {
        await doc.reference.delete();
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      await user?.delete();

      // Đóng dialog loading
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa thông tin giảng viên và tài khoản thành công.')),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AdHomeScreen()),
      );
    } catch (e) {
      // Đóng dialog loading
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi xóa thông tin giảng viên.')),
      );
      print(e);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Có chắc chắn muốn xóa giảng viên?'),
          actions: <Widget>[
            TextButton(
              child: Text('Không'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Có'),
              onPressed: () {
                _deleteTeacher(context);
                // Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin giảng viên'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: AdCustomDrawer(),
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
            SizedBox(height: 20),
            Card(
              margin: EdgeInsets.symmetric(vertical: 10),
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
                        IconButton(
                          onPressed: () => _confirmDelete(context),
                          icon: Icon(Icons.delete_forever),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditTeaProfileScreen(teacherData: teacherData),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    _buildInfoItem('Khoa', teacherData['department']),
                    _buildInfoItem('Trình độ học vấn', teacherData['educationLevel']),
                    _buildInfoItem('Số điện thoại', teacherData['phone']),
                    _buildInfoItem('Email cá nhân', teacherData['email']),
                    _buildInfoItem('Giới tính', teacherData['gender']),
                    _buildInfoItem('Ngày sinh', teacherData['dob']),
                    _buildInfoItem('Tuổi', teacherData['age']),
                    _buildInfoItem('Địa chỉ hiện tại', teacherData['currentAddress']),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: _buildFeatureItem(Icons.monetization_on, 'Lương', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeaProfileToSalaryScreen(teacherData: teacherData),
                      ),
                    );
                  }),
                ),
                Flexible(
                  child: _buildFeatureItem(Icons.account_circle, 'Tài khoản', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewTeaAccountScreen(teacherData: teacherData),
                      ),
                    );
                  }),
                ),
                Flexible(
                  child: _buildFeatureItem(Icons.schedule, 'Lịch giảng', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeaProfileToScheduleScreen(
                          scheduleData: {
                            'teacherName': teacherData['name'],
                            'teacherId': teacherData['teacherId'],
                            'courseTitle': teacherData['courseTitle'],
                            'room': teacherData['room'],
                            'dayOfWeek': teacherData['dayOfWeek'],
                            'startTime': teacherData['startTime'],
                            'endTime': teacherData['endTime'],
                            'startDate': teacherData['startDate'],
                            'endDate': teacherData['endDate'],
                          },
                        ),
                      ),
                    );
                  }),
                ),
              ],
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

  Widget _buildFeatureItem(IconData iconData, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Builder(
        builder: (BuildContext context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 50.0,
                height: 50.0,
                child: Icon(
                  iconData,
                  size: 40.0,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
