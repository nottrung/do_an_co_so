import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../ad_navbar.dart';

class CreateScheduleScreen extends StatefulWidget {
  @override
  _CreateScheduleScreenState createState() => _CreateScheduleScreenState();
}

class _CreateScheduleScreenState extends State<CreateScheduleScreen> {
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _lecturerIdController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String _selectedDayOfWeek = 'Monday';
  String? _selectedLecturerInfo;
  List<DocumentSnapshot> _lecturers = [];
  List<Map<String, String>> _calculatedDates = [];

  bool _isLecturerSelected = true;
  bool _isCourseEntered = true;
  bool _isRoomEntered = true;
  bool _isSemesterEntered = true;

  @override
  void initState() {
    super.initState();
    _fetchLecturers();
  }

  Future<void> _fetchLecturers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('teachers')
        .where('option', isEqualTo: 'teacher')
        .get();
    setState(() {
      _lecturers = snapshot.docs;
    });
  }

  Future<String> _generateScheduleId() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('schedules')
        .orderBy('scheduleId', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) {
      return 'SC00001';
    } else {
      String lastId = snapshot.docs.first['scheduleId'];
      if (lastId.length >= 2) {
        int nextIdNumber = int.parse(lastId.substring(2)) + 1;
        return 'SC${nextIdNumber.toString().padLeft(5, '0')}';
      } else {
        // Xử lý trường hợp lastId không có độ dài tối thiểu
        return 'SC00001';
      }
    }
  }

  void _calculateScheduleDates() {
    _calculatedDates.clear();
    if (_selectedStartDate != null && _selectedEndDate != null) {
      DateTime current = _selectedStartDate!;
      while (current.isBefore(_selectedEndDate!) || current.isAtSameMomentAs(_selectedEndDate!)) {
        if (current.weekday == _getWeekdayInt(_selectedDayOfWeek)) {
          _calculatedDates.add({
            'dayOfWeek': _selectedDayOfWeek,
            'date': DateFormat('dd/MM/yyyy').format(current),
            'startTime': _startTimeController.text,
            'endTime': _endTimeController.text,
            'room': _roomController.text,
          });
        }
        current = current.add(Duration(days: 1));
      }
    }
  }

  int _getWeekdayInt(String day) {
    switch (day) {
      case 'Monday':
        return 1;
      case 'Tuesday':
        return 2;
      case 'Wednesday':
        return 3;
      case 'Thursday':
        return 4;
      case 'Friday':
        return 5;
      case 'Saturday':
        return 6;
      case 'Sunday':
        return 7;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tạo lịch giảng'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedLecturerInfo,
              items: _lecturers.map((doc) {
                String lecturerInfo = '${doc['name']} - ${doc['department']}';
                return DropdownMenuItem<String>(
                  value: lecturerInfo,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 280),
                    child: Text(
                      lecturerInfo,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLecturerInfo = value;
                  _lecturerIdController.text = _lecturers
                      .firstWhere((doc) =>
                  '${doc['name']} - ${doc['department']}' == value)['teacherId'];
                  _isLecturerSelected = true;
                });
              },
              decoration: InputDecoration(
                labelText: 'Chọn giảng viên',
                errorText: _isLecturerSelected ? null : 'Chưa chọn giảng viên!',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: _isLecturerSelected ? Colors.grey : Colors.red),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: _isLecturerSelected ? Colors.blue : Colors.red),
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
            ),

            TextFormField(
              controller: _lecturerIdController,
              decoration: InputDecoration(
                labelText: 'Mã giảng viên',
                errorText: _isLecturerSelected ? null : '',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: _isLecturerSelected ? Colors.grey : Colors.red),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: _isLecturerSelected ? Colors.blue : Colors.red),
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              readOnly: true,
            ),
            TextFormField(
              controller: _semesterController,
              decoration: InputDecoration(
                labelText: 'Học kỳ',
                errorText: _isSemesterEntered ? null : 'Chưa nhập học kỳ!',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: _isSemesterEntered ? Colors.grey : Colors.red),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: _isSemesterEntered ? Colors.blue : Colors.red),
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _isSemesterEntered = value.isNotEmpty;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _courseController,
              decoration: InputDecoration(
                labelText: 'Tên môn học',
                errorText: _isCourseEntered ? null : 'Chưa nhập tên môn học!',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: _isCourseEntered ? Colors.grey : Colors.red),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: _isCourseEntered ? Colors.blue : Colors.red),
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _isCourseEntered = value.isNotEmpty;
                });
              },
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Text('Ngày bắt đầu:'),
                ),
                TextButton(
                  onPressed: () => _selectStartDate(context),
                  child: Text(_selectedStartDate == null
                      ? 'Chọn ngày'
                      : DateFormat('dd/MM/yyyy').format(_selectedStartDate!)),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text('Ngày kết thúc:'),
                ),
                TextButton(
                  onPressed: () => _selectEndDate(context),
                  child: Text(_selectedEndDate == null
                      ? 'Chọn ngày'
                      : DateFormat('dd/MM/yyyy').format(_selectedEndDate!)),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _startTimeController,
              decoration: InputDecoration(
                  labelText: 'Thời gian bắt đầu (HH:mm)'),
            ),
            TextFormField(
              controller: _endTimeController,
              decoration: InputDecoration(
                  labelText: 'Thời gian kết thúc (HH:mm)'),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _roomController,
              decoration: InputDecoration(
                labelText: 'Phòng học',
                errorText: _isRoomEntered ? null : 'Chưa nhập phòng học!',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: _isRoomEntered ? Colors.grey : Colors.red),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: _isRoomEntered ? Colors.blue : Colors.red),
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _isRoomEntered = value.isNotEmpty;
                });
              },
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedDayOfWeek,
              items: [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday'
              ].map((day) => DropdownMenuItem<String>(
                value: day,
                child: Text(day),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDayOfWeek = value!;
                  _calculateScheduleDates();
                });
              },
              decoration: InputDecoration(labelText: 'Ngày'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _saveSchedule(),
              child: Text('Tạo lịch giảng'),
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).canvasColor,
                onPrimary: Colors.white,
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 16.0),
            if (_calculatedDates.isNotEmpty)
              ..._calculatedDates.map((date) {
                return Card(
                  child: ListTile(
                    title: Text('${date['dayOfWeek']} - ${date['date']}'),
                    subtitle: Text('Thời gian: ${date['startTime']} - ${date['endTime']}, Phòng: ${date['room']}'),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  void _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
        _calculateScheduleDates();
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedEndDate = picked;
        _calculateScheduleDates();
      });
    }
  }

  void _saveSchedule() async {
    setState(() {
      _isLecturerSelected = _selectedLecturerInfo != null;
      _isCourseEntered = _courseController.text.isNotEmpty;
      _isRoomEntered = _roomController.text.isNotEmpty;
      _isSemesterEntered = _semesterController.text.isNotEmpty;
    });

    if (_isLecturerSelected && _isCourseEntered && _isRoomEntered && _isSemesterEntered) {
      try {
        String scheduleId = await _generateScheduleId();
        await FirebaseFirestore.instance.collection('schedules').add({
          'scheduleId': scheduleId,
          'teacherName': _selectedLecturerInfo,
          'teacherId': _lecturerIdController.text,
          'courseTitle': _courseController.text,
          'startDate': _selectedStartDate != null ? DateFormat('dd/MM/yyyy').format(_selectedStartDate!) : '',
          'endDate': _selectedEndDate != null ? DateFormat('dd/MM/yyyy').format(_selectedEndDate!) : '',
          'startTime': _startTimeController.text,
          'endTime': _endTimeController.text,
          'room': _roomController.text,
          'dayOfWeek': _selectedDayOfWeek,
          'teachDays': _calculatedDates,
          'semester': _semesterController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Tạo lịch giảng thành công!'),
        ));

        // Delay for 1 second and then navigate to another screen
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdNavigationBar()),
          );
        });

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi khi tạo lịch giảng: $e'),
        ));
      }
    }
  }
}
