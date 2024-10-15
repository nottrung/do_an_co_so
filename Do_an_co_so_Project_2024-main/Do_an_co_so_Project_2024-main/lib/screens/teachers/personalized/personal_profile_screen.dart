import 'package:flutter/material.dart';
import 'package:tea_man_pka/screens/teachers/personalized/personal_edit_profile_screen.dart';
import '../../change_pass_screen.dart';
import '../tea_custom_drawer.dart';

class PersonalProfileScreen extends StatelessWidget {
  final Map<String, dynamic> teacherData;

  const PersonalProfileScreen({Key? key, required this.teacherData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hồ sơ cá nhân'),
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
      endDrawer: TeaCustomDrawer(teacherData: teacherData),
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
            // Các thông tin cá nhân của giảng viên
            Card(
              // color: Colors.white,
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
                        Text(''),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // Navigate to EditTeaProfileScreen with current teacher data
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PersonalEditProfileScreen(teacherData: teacherData),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    _buildInfoItem('Email', teacherData['internalEmail']),
                    _buildInfoItem('Khoa', teacherData['department']),
                    _buildInfoItem('Giới tính', teacherData['gender']),
                    _buildInfoItem('Số điện thoại', teacherData['phone']),
                    _buildInfoItem('Ngày sinh', teacherData['dob']),
                    _buildInfoItem('Email cá nhân', teacherData['email']),
                    _buildInfoItem('Địa chỉ hiện tại', teacherData['currentAddress']),
                    _buildInfoItem('Trình độ học vấn', teacherData['educationLevel']),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePassScreen()),
                );
              },
              child: Text('Đổi mật khẩu', style: TextStyle(fontSize: 16),),
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).canvasColor,
                onPrimary: Colors.white,
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
