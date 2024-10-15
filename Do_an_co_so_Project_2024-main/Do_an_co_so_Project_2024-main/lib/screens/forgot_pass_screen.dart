import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class ForgotPassScreen extends StatefulWidget {
  const ForgotPassScreen({super.key});

  @override
  _ForgotPassScreenState createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {
  final TextEditingController _internalEmailController = TextEditingController();
  final TextEditingController _teacherNameController = TextEditingController();
  final TextEditingController _teacherIdController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _optionController = TextEditingController(text: 'Cấp lại mật khẩu');
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _internalEmailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    _internalEmailController.dispose();
    _teacherNameController.dispose();
    _teacherIdController.dispose();
    _reasonController.dispose();
    _contentController.dispose();
    _optionController.dispose();
    super.dispose();
  }

  Future<void> _validateEmail() async {
    String email = _internalEmailController.text.trim();
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('teachers')
          .where('internalEmail', isEqualTo: email)
          .get();

      if (email.isEmpty) {
        setState(() {
          _emailError = 'Hãy nhập Email';
        });
      } else if (querySnapshot.docs.isEmpty) {
        setState(() {
          _emailError = 'Email không khớp với hệ thống';
        });
      } else {
        setState(() {
          _emailError = null;
          var data = querySnapshot.docs.first.data() as Map<String, dynamic>;
          _teacherNameController.text = data['name'] ?? '';
          _teacherIdController.text = data['teacherId'] ?? '';
        });
      }
    } catch (e) {
      setState(() {
        _emailError = 'Đã xảy ra lỗi khi kiểm tra email';
      });
    }
  }

  Future<String> _generateRequestId() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return 'FG00001';
    }

    String latestRequestId = querySnapshot.docs.first['requestId'];
    int numericId = int.parse(latestRequestId.substring(2)) + 1;
    return 'FG${numericId.toString().padLeft(5, '0')}';
  }

  void _sendRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String requestId = await _generateRequestId();
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        await firestore.collection('requests').add({
          'requestId': requestId,
          'internalEmail': _internalEmailController.text,
          'name': _teacherNameController.text,
          'teacherId': _teacherIdController.text,
          'requestOption': 'Cấp lại mật khẩu',
          'requestContent': _contentController.text,
          'requestReason': _reasonController.text,
          'status': 'đang chờ',
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gửi yêu cầu thành công')),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
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
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Gửi yêu cầu cấp lại mật khẩu', style: TextStyle(fontSize: 20)),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/login_img/logo.png', width: 250,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _internalEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email nội bộ',
                          hintText: 'Nhập Email',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          errorText: _emailError,
                          errorMaxLines: 2,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildReadOnlyTextField(_teacherNameController, 'Tên giảng viên'),
                      _buildReadOnlyTextField(_teacherIdController, 'Mã giảng viên'),
                      _buildReadOnlyTextField(_optionController, 'Option'),
                      _buildTextField(_contentController, 'Nội dung yêu cầu'),
                      _buildTextField(_reasonController, 'Lý do yêu cầu'),
                      SizedBox(height: 0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: Theme.of(context).canvasColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _sendRequest,
                          child: Text('Gửi Yêu Cầu', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ],
                  ),
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      backgroundColor: Colors.white,
                      strokeWidth: 6.0,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Nhập $label',
          hintStyle: TextStyle(color: Colors.black26),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Hãy nhập $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildReadOnlyTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Nhập $label',
          hintStyle: TextStyle(color: Colors.black26),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        readOnly: true,
      ),
    );
  }
}
