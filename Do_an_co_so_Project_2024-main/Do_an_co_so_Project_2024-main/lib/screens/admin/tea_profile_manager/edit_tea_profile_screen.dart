import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../ad_navbar.dart';

class EditTeaProfileScreen extends StatefulWidget {
  final Map<String, dynamic> teacherData;

  const EditTeaProfileScreen({super.key, required this.teacherData});

  @override
  _EditTeaProfileScreenState createState() => _EditTeaProfileScreenState();
}

class _EditTeaProfileScreenState extends State<EditTeaProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _teacherIdController = TextEditingController();
  final TextEditingController _educationLevelController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentAddressController = TextEditingController();
  String? _selectedDepartment;
  String? _selectedGender;
  bool _isLoading = false;

  final List<String> _departments = [
    'Công nghệ thông tin',
    'Cơ khí - cơ điện tử',
    'Khoa học và kĩ thuật vật liệu',
    'Kỹ thuật ô tô và năng lượng',
    'Điện - điện tử',
    'Công nghệ sinh học hóa học và kỹ thuật môi trường',
    'Kỹ thuật y học',
    'Dược',
    'Điều dưỡng',
    'Khoa học cơ bản',
    'Kinh tế và kinh doanh',
    'Du lịch',
    'Khoa đào tạo ngoại ngữ'
  ];

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
    _selectedDepartment = widget.teacherData['department'];
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
          'name': _nameController.text,
          'department': _selectedDepartment,
          'educationLevel': _educationLevelController.text,
          'currentAddress': _currentAddressController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật thành công')),
        );

        Future.delayed(Duration(seconds: 0), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AdNavigationBar()),
          );
        });
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
        title: Text('Chỉnh sửa thông tin giảng viên'),
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
                _buildTextField(_nameController, 'Tên giảng viên'),
                _buildTextField(_teacherIdController, 'Mã giảng viên', readOnly: true),
                _buildDropdownField('Khoa', _selectedDepartment, _departments, (value) {
                  setState(() {
                    _selectedDepartment = value;
                  });
                }),
                _buildTextField(_educationLevelController, 'Trình độ học vấn'),
                _buildTextField(_phoneController, 'Số điện thoại', readOnly: true),
                _buildTextField(_emailController, 'Email cá nhân', readOnly: true),
                _buildTextField(_dobController, 'Ngày sinh', readOnly: true),
                _buildTextField(_currentAddressController, 'Địa chỉ hiện tại', readOnly: true),


                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
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

  Widget _buildDropdownField(
      String label, String? selectedValue, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: _showDepartmentSelectionDialog,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Text(selectedValue ?? 'Chọn khoa'),
        ),
      ),
    );
  }

  void _showDepartmentSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chọn khoa'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _departments.map((department) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDepartment = department;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(department),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}