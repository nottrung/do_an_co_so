import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestDetailScreen extends StatefulWidget {
  final Map<String, dynamic> requestData;
  final String requestId;

  const RequestDetailScreen({Key? key, required this.requestData, required this.requestId}) : super(key: key);

  @override
  _RequestDetailScreenState createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  late TextEditingController _requestOptionController;
  late TextEditingController _requestContentController;
  late TextEditingController _teacherIdController;
  late TextEditingController _nameController;
  late TextEditingController _departmentController;
  late TextEditingController _subjectController;
  late TextEditingController _requestReasonController;
  String _status = 'đang chờ';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _requestOptionController = TextEditingController(text: widget.requestData['requestOption']);
    _requestContentController = TextEditingController(text: widget.requestData['requestContent']);
    _teacherIdController = TextEditingController(text: widget.requestData['teacherId']);
    _nameController = TextEditingController(text: widget.requestData['name']);
    _departmentController = TextEditingController(text: widget.requestData['department']);
    _subjectController = TextEditingController(text: widget.requestData['subject']);
    _requestReasonController = TextEditingController(text: widget.requestData['requestReason']);
    _status = widget.requestData['status'] ?? 'đang chờ';
  }

  void _updateRequest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('requests').doc(widget.requestId).update({
        'requestOption': _requestOptionController.text,
        'requestContent': _requestContentController.text,
        'teacherId': _teacherIdController.text,
        'name': _nameController.text,
        'department': _departmentController.text,
        'subject': _subjectController.text,
        'requestReason': _requestReasonController.text,
        'status': _status,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thành công')),
      );

      Navigator.pop(context);
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
      appBar: AppBar(title: Text('Cập nhật yêu cầu')),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                _buildTextField(_teacherIdController, 'Mã giảng viên', readOnly: true),
                _buildTextField(_nameController, 'Tên giảng viên', readOnly: true),
                _buildTextField(_requestOptionController, 'Option', readOnly: true),
                if (widget.requestData['requestOption'] != 'Cấp lại mật khẩu') ...[
                  _buildTextField(_departmentController, 'Khoa', readOnly: true),
                  _buildTextField(_subjectController, 'Môn học', readOnly: true),
                ],
                _buildTextField(_requestContentController, 'Nội dung yêu cầu', readOnly: true),
                _buildTextField(_requestReasonController, 'Lý do yêu cầu', readOnly: true),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: DropdownButtonFormField<String>(
                    value: _status,
                    items: ['đang chờ', 'được duyệt', 'từ chối']
                        .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _status = value ?? 'đang chờ';
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Trạng thái',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
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
                    onPressed: _isLoading ? null : _updateRequest,
                    child: _isLoading
                        ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : Text('Cập nhật', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ],
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
      {bool readOnly = false, VoidCallback? onTap}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }
}
