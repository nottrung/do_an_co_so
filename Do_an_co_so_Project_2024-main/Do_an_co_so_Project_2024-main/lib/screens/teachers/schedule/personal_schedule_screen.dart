import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PersonalScheduleScreen extends StatefulWidget {
  const PersonalScheduleScreen({super.key, required this.scheduleId, required this.scheduleData});

  final String scheduleId;
  final Map<String, dynamic> scheduleData;

  @override
  State<PersonalScheduleScreen> createState() => _PersonalScheduleScreenState();
}

class _PersonalScheduleScreenState extends State<PersonalScheduleScreen> {
  Map<String, dynamic> _currentScheduleData = {};
  String? teacherImageUrl;

  @override
  void initState() {
    super.initState();
    _currentScheduleData = widget.scheduleData;
    _loadTeacherImage();
  }

  Future<void> _loadTeacherImage() async {
    try {
      var teacherQuerySnapshot = await FirebaseFirestore.instance
          .collection('teachers')
          .where('teacherId', isEqualTo: _currentScheduleData['teacherId'])
          .get();

      if (teacherQuerySnapshot.docs.isNotEmpty) {
        var data = teacherQuerySnapshot.docs.first.data();
        setState(() {
          teacherImageUrl = data['imageUrl'];
        });
      } else {
        print('Không tìm thấy tài liệu về giảng viên!');
      }
    } catch (e) {
      print('Không tìm thấy dữ liệu giảng viên: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết lịch giảng'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Phần 1: Thông tin giảng viên
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
                    backgroundImage: teacherImageUrl != null && teacherImageUrl!.isNotEmpty
                        ? NetworkImage(teacherImageUrl!) as ImageProvider<Object>?
                        : AssetImage('assets/login_img/default_avatar.png') as ImageProvider<Object>?,
                    backgroundColor: Colors.grey,
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentScheduleData['teacherName'] ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 10),
                        _buildInfoItem('Mã giảng viên', _currentScheduleData['teacherId']),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
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
                    _buildInfoItem('Môn học', _currentScheduleData['courseTitle']),
                    _buildInfoItem('Học kỳ', _currentScheduleData['semester']),
                    _buildInfoItem('Ngày bắt đầu', _currentScheduleData['startDate']),
                    _buildInfoItem('Ngày kết thúc', _currentScheduleData['endDate']),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ngày giảng dạy:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  ..._currentScheduleData['teachDays'].map<Widget>((teachDay) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text('${teachDay['dayOfWeek']} - ${teachDay['date']}'),
                        subtitle: Text('Thời gian: ${teachDay['startTime']} - ${teachDay['endTime']}, Phòng: ${teachDay['room']}'),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            SizedBox(height: 20),
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
