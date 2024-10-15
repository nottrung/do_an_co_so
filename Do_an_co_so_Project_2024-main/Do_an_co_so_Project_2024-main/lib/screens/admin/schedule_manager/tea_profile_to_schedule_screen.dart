import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tea_man_pka/screens/admin/schedule_manager/detail_tea_schedule_screen.dart';

import '../ad_custom_drawer.dart';

class TeaProfileToScheduleScreen extends StatefulWidget {
  final Map<String, dynamic> scheduleData;

  const TeaProfileToScheduleScreen({
    Key? key,

    required this.scheduleData,
  }) : super(key: key);

  @override
  _TeaProfileToScheduleScreenState createState() => _TeaProfileToScheduleScreenState();
}

class _TeaProfileToScheduleScreenState extends State<TeaProfileToScheduleScreen> {
  late List<Map<String, dynamic>> schedules = [];
  String? teacherImageUrl;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
    _loadTeacherInfo();
  }

  Future<void> _loadSchedules() async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('schedules')
        .where('teacherId', isEqualTo: widget.scheduleData['teacherId'])
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        schedules = querySnapshot.docs.map((doc) => doc.data()).toList();
      });
    }
  }

  Future<void> _loadTeacherInfo() async {
    try {
      var teacherQuerySnapshot = await FirebaseFirestore.instance
          .collection('teachers')
          .where('teacherId', isEqualTo: widget.scheduleData['teacherId'])
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
        title: Text('Lịch giảng của GV'),
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
                          widget.scheduleData['teacherName'] ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 10),
                        _buildInfoItem('Mã giảng viên', widget.scheduleData['teacherId']),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                var schedule = schedules[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailTeaScheduleScreen(
                          scheduleId: schedule['scheduleId'], // Sử dụng id của lịch giảng
                          scheduleData: schedule as Map<String, dynamic>,
                        ),
                      ),
                    );
                  },
                  child: Card(
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
                          _buildInfoItem('Môn học', schedule['courseTitle']),
                          _buildInfoItem('Ngày', schedule['dayOfWeek']),
                          _buildInfoItem('Phòng học', schedule['room']),
                          _buildInfoItem('Thời gian',
                              '${schedule['startTime']} - ${schedule['endTime']}'),
                          _buildInfoItem('Ngày bắt đầu', schedule['startDate']),
                          _buildInfoItem('Ngày kết thúc', schedule['endDate']),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
