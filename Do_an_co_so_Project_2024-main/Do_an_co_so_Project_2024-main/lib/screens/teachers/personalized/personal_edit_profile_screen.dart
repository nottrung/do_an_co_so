import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tea_man_pka/screens/teachers/tea_navbar.dart';

class PersonalEditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> teacherData;

  const PersonalEditProfileScreen({super.key, required this.teacherData});

  @override
  _PersonalEditProfileScreenState createState() => _PersonalEditProfileScreenState();
}

class _PersonalEditProfileScreenState extends State<PersonalEditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _teacherIdController = TextEditingController();
  final TextEditingController _educationLevelController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentAddressController = TextEditingController();
  final TextEditingController _internalEmailController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  String? _selectedGender;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.teacherData['name'] ?? '';
    _teacherIdController.text = widget.teacherData['teacherId'] ?? '';
    _educationLevelController.text = widget.teacherData['educationLevel'] ?? '';
    _phoneController.text = widget.teacherData['phone'] ?? '';
    _dobController.text = widget.teacherData['dob'] ?? '';
    _emailController.text = widget.teacherData['email'] ?? '';
    _currentAddressController.text = widget.teacherData['currentAddress'] ?? '';
    _internalEmailController.text = widget.teacherData['internalEmail'] ?? '';
    _departmentController.text = widget.teacherData['department'] ?? '';
    _selectedGender = widget.teacherData['gender'];
  }

  void _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      QuerySnapshot querySnapshot = await firestore
          .collection('teachers')
          .where('teacherId', isEqualTo: _teacherIdController.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference documentRef = querySnapshot.docs.first.reference;

        await documentRef.update({
          'phone': _phoneController.text,
          'email': _emailController.text,
          'currentAddress': _currentAddressController.text,
          'dob': _dobController.text,
          'internalEmail': _internalEmailController.text,

        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật thành công')),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => TeaNavigationBar(teacherData: {
            'name': _nameController.text,
            'teacherId': _teacherIdController.text,
            'educationLevel': _educationLevelController.text,
            'phone': _phoneController.text,
            'dob': _dobController.text,
            'email': _emailController.text,
            'currentAddress': _currentAddressController.text,
            'department': _departmentController.text,
            'gender': _selectedGender,
            'internalEmail': _internalEmailController.text,
            'imageUrl': widget.teacherData['imageUrl'],
            'workPoint': widget.teacherData['workPoint'],
            'subsidize': widget.teacherData['subsidize'],
            'salaryPerDay': widget.teacherData['salaryPerDay'],
            'salary': widget.teacherData['salary'],
            'salaryFactor': widget.teacherData['salaryFactor'],
            'bonusSalary': widget.teacherData['bonusSalary'],
            'penatySalary': widget.teacherData['penatySalary'],
            'totalSalary': widget.teacherData['totalSalary'],
            'note' : widget.teacherData['note']
          })),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy giảng viên')),
        );
      }
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
      appBar: AppBar(
        title: Text('Chỉnh sửa Profile giảng viên'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 75,
                    backgroundImage: NetworkImage(widget.teacherData['imageUrl'] ?? 'assets/login_img/acc_img.png'),
                    backgroundColor: Colors.grey,
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(_internalEmailController, 'Email nội bộ', readOnly: true),
                _buildTextField(_nameController, 'Tên giảng viên', readOnly: true),
                _buildTextField(_teacherIdController, 'Mã giảng viên', readOnly: true),
                _buildTextField(_departmentController, 'Khoa', readOnly: true),
                _buildTextField(_educationLevelController, 'Trình độ học vấn', readOnly: true),
                _buildTextField(_dobController, 'Ngày sinh'),
                _buildTextField(_phoneController, 'Số điện thoại'),
                _buildTextField(_emailController, 'Email cá nhân'),
                _buildTextField(_currentAddressController, 'Địa chỉ hiện tại'),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Theme.of(context).canvasColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _updateProfile,
                  child: Text('Cập nhật', style: TextStyle(fontSize: 20)),
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
                )
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
