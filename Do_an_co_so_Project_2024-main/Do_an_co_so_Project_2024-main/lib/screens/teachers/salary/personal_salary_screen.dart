import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PersonalSalaryScreen extends StatefulWidget {
  final Map<String, dynamic> teacherData;

  const PersonalSalaryScreen({Key? key, required this.teacherData}) : super(key: key);

  @override
  _PersonalSalaryScreenState createState() => _PersonalSalaryScreenState();
}

class _PersonalSalaryScreenState extends State<PersonalSalaryScreen> {
  bool isEditingNote = false;
  TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _noteController.text = widget.teacherData['note'] ?? '';
  }

  void _toggleEditMode() {
    setState(() {
      isEditingNote = !isEditingNote;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin lương giảng viên'),
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
                    backgroundImage: NetworkImage(widget.teacherData['imageUrl'] ?? ''),
                    // Placeholder image or default avatar if imageUrl is null
                    backgroundColor: Colors.grey, // Optional: Background color while loading
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.teacherData['name'] ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 10),
                        _buildInfoItem('Mã giảng viên', widget.teacherData['teacherId'], ''),
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
                    SizedBox(height: 10),
                    _buildInfoItem('Ngày công', widget.teacherData['workPoint'], '        '),
                    _buildInfoItem('Trợ cấp', widget.teacherData['subsidize'], 'triệu'),
                    _buildInfoItem('Lương theo ngày', widget.teacherData['salaryPerDay'], 'triệu'),
                    _buildInfoItem('Lương cơ bản', widget.teacherData['salary'], 'triệu'),
                    _buildInfoItem('Hệ số lương', widget.teacherData['salaryFactor'], '        '),
                    _buildInfoItem('Lương thưởng', widget.teacherData['bonusSalary'], 'triệu'),
                    _buildInfoItem('Lương phạt', widget.teacherData['penatySalary'], 'triệu'),
                    _buildInfoItem('TỔNG LƯƠNG', widget.teacherData['totalSalary'], 'TRIỆU'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 0),
            _buildNoteSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, dynamic value, String label2) {
    String displayValue = value?.toString() ?? 'Chưa cập nhật';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            children: [
              Text(displayValue),
              SizedBox(width: 8),
              Text(
                label2,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection() {
    return Card(
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
                Text(
                  'Ghi chú',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: _noteController,
              readOnly: !isEditingNote,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ghi chú...',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
