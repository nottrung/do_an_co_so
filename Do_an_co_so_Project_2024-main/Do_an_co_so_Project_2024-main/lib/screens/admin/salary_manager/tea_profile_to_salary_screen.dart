import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../ad_custom_drawer.dart';
import 'edit_tea_salary_screen.dart';

class TeaProfileToSalaryScreen extends StatefulWidget {
  final Map<String, dynamic> teacherData;

  const TeaProfileToSalaryScreen({Key? key, required this.teacherData}) : super(key: key);

  @override
  _TeaProfileToSalaryScreenState createState() => _TeaProfileToSalaryScreenState();
}

class _TeaProfileToSalaryScreenState extends State<TeaProfileToSalaryScreen> {
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

  Future<void> _updateNote() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      QuerySnapshot querySnapshot = await firestore
          .collection('teachers')
          .where('teacherId', isEqualTo: widget.teacherData['teacherId'])
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference documentRef = querySnapshot.docs.first.reference;

        await documentRef.update({'note': _noteController.text});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật Note thành công')),
        );

        setState(() {
          widget.teacherData['note'] = _noteController.text;
          isEditingNote = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi')),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin lương'),
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
                    backgroundImage: NetworkImage(widget.teacherData['imageUrl'] ?? ''),
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
            SizedBox(height: 20),
            Card(
              // color: Theme.of(context).cardColor,
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditTeaSalaryScreen(teacherData: widget.teacherData),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
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
            SizedBox(height: 20),
            _buildNoteSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, dynamic value, String label2) {
    String displayValue = value?.toString() ?? '0';

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
      // color: Theme.of(context).cardColor,
      margin: EdgeInsets.symmetric(vertical: 0),
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
                IconButton(
                  icon: Icon(isEditingNote ? Icons.save : Icons.edit),
                  onPressed: isEditingNote ? _updateNote : _toggleEditMode,
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
                hintText: 'Viết ghi chú...',
              ),
            ),
            SizedBox(height: 10,),
            if (isEditingNote)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _updateNote,
                  child: Text('Cập nhật'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
