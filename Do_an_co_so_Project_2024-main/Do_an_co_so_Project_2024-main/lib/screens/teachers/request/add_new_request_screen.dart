import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tea_man_pka/screens/teachers/tea_navbar.dart';

class AddNewRequestScreen extends StatefulWidget {
  final Map<String, dynamic> teacherData;

  const AddNewRequestScreen({super.key, required this.teacherData});

  @override
  _AddNewRequestScreenState createState() => _AddNewRequestScreenState();
}

class _AddNewRequestScreenState extends State<AddNewRequestScreen> {
  final TextEditingController _teacherIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _requestContentController = TextEditingController();
  final TextEditingController _requestReasonController = TextEditingController();
  final TextEditingController _dayOfWeekController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _requestOptionController = TextEditingController();

  String? _selectedSubject;
  List<String> _subjects = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _teacherIdController.text = widget.teacherData['teacherId'] ?? '';
    _nameController.text = widget.teacherData['name'] ?? '';
    _departmentController.text = widget.teacherData['department'] ?? '';
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('schedules')
        .where('teacherId', isEqualTo: widget.teacherData['teacherId'])
        .get();

    List<String> subjects = querySnapshot.docs
        .map((doc) => doc['courseTitle'].toString())
        .toSet()
        .toList();

    setState(() {
      _subjects = subjects;
    });
  }

  Future<String> _generateRequestId() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return 'RQ00001';
    }

    String latestRequestId = querySnapshot.docs.first['requestId'];
    int numericId = int.parse(latestRequestId.substring(2)) + 1;
    return 'RQ${numericId.toString().padLeft(5, '0')}';
  }

  Future<void> _fetchScheduleDetails(String courseTitle) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('schedules')
        .where('teacherId', isEqualTo: widget.teacherData['teacherId'])
        .where('courseTitle', isEqualTo: courseTitle)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var schedule = querySnapshot.docs.first.data() as Map<String, dynamic>?;
      setState(() {
        _dayOfWeekController.text = schedule?['dayOfWeek'] ?? '';
        _timeController.text = '${schedule?['startTime'] ?? ''} - ${schedule?['endTime'] ?? ''}';
        _semesterController.text = schedule?['semester'] ?? '';
        _roomController.text = schedule?['room'] ?? '';
      });
    }
  }

  void _sendRequest() async {
    if (_requestOptionController.text.isEmpty || _requestContentController.text.isEmpty || _requestReasonController.text.isEmpty || _selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Các trường thông tin không được để trống')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String requestId = await _generateRequestId();
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore.collection('requests').add({
        'requestId': requestId,
        'teacherId': _teacherIdController.text,
        'name': _nameController.text,
        'department': _departmentController.text,
        'subject': _selectedSubject,
        'requestOption': _requestOptionController.text,
        'requestContent': _requestContentController.text,
        'requestReason': _requestReasonController.text,
        'status': 'đang chờ',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gửi yêu cầu thành công')),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => TeaNavigationBar(teacherData: widget.teacherData)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gửi Yêu Cầu')),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  _buildTextField(_teacherIdController, 'Mã giảng viên', readOnly: true),
                  _buildTextField(_nameController, 'Tên giảng viên', readOnly: true),
                  _buildTextField(_departmentController, 'Khoa', readOnly: true),
                  _buildDropdownField('Môn học', _subjects, (value) {
                    setState(() {
                      _selectedSubject = value;
                      _fetchScheduleDetails(value!);
                    });
                  }),
                  _buildTextField(_dayOfWeekController, 'Ngày trong tuần', readOnly: true),
                  _buildTextField(_timeController, 'Thời gian', readOnly: true),
                  _buildTextField(_semesterController, 'Học kỳ', readOnly: true),
                  _buildTextField(_roomController, 'Phòng', readOnly: true),
                  _buildTextField(_requestOptionController, 'Option', hintText: 'Đổi lịch giảng'),
                  _buildTextField(_requestContentController, 'Nội dung yêu cầu'),
                  _buildTextField(_requestReasonController, 'Lý do yêu cầu'),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Theme.of(context).canvasColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _sendRequest,
                      child: Text(
                        'Gửi Yêu Cầu',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: SizedBox(
                  width: 80.0,
                  height: 80.0,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    backgroundColor: Colors.blue,
                    strokeWidth: 6.0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool readOnly = false, VoidCallback? onTap, String? hintText}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Trường này không được để trống';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        value: _selectedSubject,
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Container(
              width: 280,
              child: Text(
                item,
                style: TextStyle(fontSize: 16),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Trường này không được để trống';
          }
          return null;
        },
      ),
    );
  }

}
