import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../ad_navbar.dart';

class EditScheduleScreen extends StatefulWidget {
  final String scheduleId;
  final Map<String, dynamic> teachDayData;

  const EditScheduleScreen({
    Key? key,
    required this.scheduleId,
    required this.teachDayData,
  }) : super(key: key);

  @override
  _EditScheduleScreenState createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> {
  late TextEditingController _dateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _roomController;
  late String _selectedDate;
  late String _selectedDayOfWeek;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.teachDayData['date'] ?? ''; // Đảm bảo giá trị không null
    _selectedDayOfWeek = widget.teachDayData['dayOfWeek'] ?? ''; // Đảm bảo giá trị không null
    _dateController = TextEditingController(text: _selectedDate);
    _startTimeController = TextEditingController(text: widget.teachDayData['startTime'] ?? '');
    _endTimeController = TextEditingController(text: widget.teachDayData['endTime'] ?? '');
    _roomController = TextEditingController(text: widget.teachDayData['room'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh sửa lịch giảng'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildDatePicker(),
            _buildReadOnlyField('Thứ', _selectedDayOfWeek),
            _buildTextField('Thời gian bắt đầu', _startTimeController),
            _buildTextField('Thời gian kết thúc', _endTimeController),
            _buildTextField('Phòng', _roomController),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _updateTeachDay(),
                child: Text('Cập nhật', style: TextStyle(fontSize: 20),),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: TextEditingController(text: value),
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Ngày: ',
            style: TextStyle(fontSize: 18),
          ),
          Expanded(
            child: Text(
              _selectedDate,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today, color: Theme.of(context).iconTheme.color),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
    );
  }



  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateFormat('dd/MM/yyyy').parse(_selectedDate), // Parse ngày từ chuỗi sang DateTime
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = DateFormat('dd/MM/yyyy').format(pickedDate); // Format lại ngày tháng thành chuỗi
        _dateController.text = _selectedDate;
        _selectedDayOfWeek = DateFormat('EEEE').format(pickedDate); // Cập nhật thứ dựa trên ngày đã chọn
      });
    }
  }

  Future<void> _updateTeachDay() async {
    try {
      // Dữ liệu teachDay cần cập nhật
      Map<String, dynamic> updatedTeachDay = {
        'date': _selectedDate,
        'startTime': _startTimeController.text,
        'endTime': _endTimeController.text,
        'room': _roomController.text,
        'dayOfWeek': _selectedDayOfWeek, // Cập nhật thứ dựa trên ngày đã chọn
      };

      // Lấy tài liệu lịch từ Firestore
      DocumentReference scheduleRef = FirebaseFirestore.instance.collection('schedules').doc(widget.scheduleId);
      DocumentSnapshot scheduleSnapshot = await scheduleRef.get();
      Map<String, dynamic>? scheduleData = scheduleSnapshot.data() as Map<String, dynamic>?;

      if (scheduleData != null) {
        // Tìm chỉ mục của teachDay cần cập nhật
        List<dynamic> teachDays = List.from(scheduleData['teachDays']);
        int index = teachDays.indexWhere((element) =>
        element['date'] == widget.teachDayData['date'] &&
            element['startTime'] == widget.teachDayData['startTime']);

        // Cập nhật teachDay
        if (index != -1) {
          teachDays[index] = updatedTeachDay;
          await scheduleRef.update({'teachDays': teachDays});

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Cập nhật thành công!'),
          ));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdNavigationBar()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Không tìm thấy ngày giảng dạy để cập nhật.'),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Không tìm thấy lịch để cập nhật.'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lỗi khi cập nhật: $e'),
      ));
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _roomController.dispose();
    super.dispose();
  }
}
