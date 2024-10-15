import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tea_man_pka/screens/admin/ad_home_screen.dart';

class AddTeaScreen extends StatefulWidget {
  const AddTeaScreen({Key? key}) : super(key: key);

  @override
  State<AddTeaScreen> createState() => _AddTeaScreenState();
}

class _AddTeaScreenState extends State<AddTeaScreen> {
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _salaryFactorController = TextEditingController();
  final TextEditingController _totalSalaryController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentAddressController = TextEditingController();
  final TextEditingController _educationLevelController = TextEditingController();

  DateTime? _selectedDate;
  File? _selectedImage;
  bool _isLoading = false;

  String _teacherId = 'PKA00001';
  String _internalEmail = '';
  String _password = '';
  String _selectedDepartment = '';

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

  String _selectedGender = '';
  final List<String> _genders = [
    'Nam',
    'Nữ',
  ];

  bool _nameValid = true;
  bool _dobValid = true;
  bool _phoneValid = true;
  bool _emailValid = true;
  bool _departmentValid = true;
  bool _imageValid = true;
  bool _ageValid = true;
  bool _genderValid = true;



  @override
  void initState() {
    super.initState();
    _salaryController.addListener(_calculateTotalSalary);
    _salaryFactorController.addListener(_calculateTotalSalary);
    _generateTeacherIdEmailPassword();
  }

  @override
  void dispose() {
    _dobController.dispose();
    _ageController.dispose();
    _salaryController.dispose();
    _salaryFactorController.dispose();
    _totalSalaryController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _currentAddressController.dispose();
    _educationLevelController.dispose();
    super.dispose();
  }

  void _generateTeacherIdEmailPassword() {
    FirebaseFirestore.instance
        .collection('teachers')
        .orderBy('teacherId', descending: true)
        .limit(1)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.size > 0) {
        var lastDocument = querySnapshot.docs.first;
        int lastIdNumber = int.parse(lastDocument['teacherId'].substring(3, 8));
        _teacherId = 'PKA${(lastIdNumber + 1).toString().padLeft(5, '0')}';
      } else {
        _teacherId = 'PKA00001';
      }
      _internalEmail = '$_teacherId@phenikaa-uni.edu.vn';
      _password = _teacherId;
      setState(() {});
    }).catchError((error) {
      _showErrorSnackBar(error);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
        _ageController.text = _calculateAge(picked).toString();
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _calculateTotalSalary() {
    double salary = double.tryParse(_salaryController.text) ?? 0.0;
    double factor = double.tryParse(_salaryFactorController.text) ?? 0.0;
    double totalSalary = salary * factor + 1.2;
    _totalSalaryController.text = totalSalary.toStringAsFixed(3);
    _findSalaryPerDay(totalSalary);
  }

  double? _salaryPerDay;
  void _findSalaryPerDay(double totalSalary) {
    double salaryPerday = totalSalary / 26;
    _salaryPerDay = double.parse(salaryPerday.toStringAsFixed(3));
  }

  void _submitData() {
    setState(() {
      _nameValid = _nameController.text.isNotEmpty;
      _dobValid = _dobController.text.isNotEmpty;
      _phoneValid = _phoneController.text.isNotEmpty;
      // _emailValid = _emailController.text.isNotEmpty;
      _departmentValid = _selectedDepartment.isNotEmpty;
      // _imageValid = _selectedImage != null;
      _ageValid = _ageController.text.isNotEmpty;
      _genderValid = _selectedGender.isNotEmpty;
    });

    if(_validateFields()){
      String name = _nameController.text;
      String phone = _phoneController.text;
      String email = _emailController.text;
      String currentAddress = _currentAddressController.text;
      String educationLevel = _educationLevelController.text;
      String dob = _dobController.text;
      String age = _ageController.text;
      String salary = _salaryController.text;
      String salaryFactor = _salaryFactorController.text;
      String totalSalary = _totalSalaryController.text;

      _uploadImageAndSaveData(
          name, phone, email, currentAddress, educationLevel, dob, age, salary,
          salaryFactor, totalSalary, _selectedImage, _selectedDepartment, _selectedGender
      );
    }
  }

  bool _validateFields() {
    return _nameValid && _departmentValid && _dobValid && _ageValid && _genderValid && _phoneValid;
  }

  void _uploadImageAndSaveData(String name, String phone, String email, String currentAddress, String educationLevel, String dob,
      String age, String salary, String salaryFactor, String totalSalary, File? imageFile, String department, String? gender) {

    if (imageFile == null) {
      _showErrorSnackBar('Không có ảnh nào được chọn');
      return;
    }

    // Hiển thị biểu tượng loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Đang thêm giảng viên...'),
              ],
            ),
          ),
        );
      },
    );

    String imageName = 'teacher_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference storageRef = FirebaseStorage.instance.ref().child('teachers').child(imageName);
    UploadTask uploadTask = storageRef.putFile(imageFile);

    uploadTask.then((TaskSnapshot snapshot) {
      snapshot.ref.getDownloadURL().then((imageUrl) {
        FirebaseFirestore.instance.collection('teachers').add({
          'name': name,
          'phone': phone,
          'email': email,
          'currentAddress': currentAddress,
          'educationLevel': educationLevel,
          'dob': dob,
          'age': age,
          'salary': salary,
          'salaryFactor': salaryFactor,
          'totalSalary': totalSalary,
          'imageUrl': imageUrl,
          'teacherId': _teacherId,
          'internalEmail': _internalEmail,
          'password': _password,
          'option': 'teacher',
          'department': department,
          'gender': gender,
          'workPoint' : '26',
          'bonusSalary' : '0',
          'penatySalary' : '0',
          'salaryPerDay' : _salaryPerDay,
          'subsidize' : '1.2',
          'note' : ''
        }).then((DocumentReference docRef) {
          FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _internalEmail,
            password: _password,
          ).then((UserCredential userCredential) {
            Navigator.pop(context); // Đóng biểu tượng loading
            _showSuccessDialog();
          }).catchError((error) {
            Navigator.pop(context); // Đóng biểu tượng loading
            _showErrorSnackBar(error.toString());
          });
        }).catchError((error) {
          Navigator.pop(context); // Đóng biểu tượng loading
          _showErrorSnackBar(error.toString());
        });
      }).catchError((error) {
        Navigator.pop(context); // Đóng biểu tượng loading
        _showErrorSnackBar(error.toString());
      });
    }).catchError((error) {
      Navigator.pop(context); // Đóng biểu tượng loading
      _showErrorSnackBar(error.toString());
    });
  }


  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lỗi: ${message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Thêm giảng viên thành công'),
          content: Text('Tài khoản giảng viên đã được thêm thành công.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => AdHomeScreen()),
                      (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showDepartmentSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: _departments.map((String department) {
              return ListTile(
                title: Text(department),
                onTap: () {
                  setState(() {
                    _selectedDepartment = department;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showGenderSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _genders.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(_genders[index]),
                onTap: () {
                  setState(() {
                    _selectedGender = _genders[index];
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm giảng viên'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: PickPicture(
                      onImagePicked: (File image) {
                        setState(() {
                          _selectedImage = image;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Form(
                    child: Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            _showDepartmentSelection(context);
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Chọn khoa',
                              errorText: _departmentValid ? null : 'Vui lòng chọn khoa',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(color: Colors.black12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    _selectedDepartment.isNotEmpty ? _selectedDepartment : 'Chọn khoa',
                                    style: TextStyle(fontSize: 16),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 10),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Tên giảng viên',
                            errorText: _nameValid ? null : 'Vui lòng nhập tên giảng viên',
                            hintText: 'Nguyễn Văn A',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Colors.black12),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _dobController,
                                readOnly: true,
                                onTap: () => _selectDate(context),
                                decoration: InputDecoration(
                                  labelText: 'Ngày sinh',
                                  errorText: _dobValid ? null : 'Chưa nhập ngày sinh',
                                  hintText: '01/01/1980',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    borderSide: BorderSide(color: Colors.black12,),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _ageController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Tuổi',
                                  errorText: _ageValid ? null : 'Tuổi đang trống',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    borderSide: BorderSide(color: Colors.black12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            _showGenderSelection(context);
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Chọn giới tính',
                              errorText: _genderValid ? null : 'Vui lòng chọn giới tính',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(color: Colors.black12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  _selectedGender.isNotEmpty ? _selectedGender : 'Chọn giới tính',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) return 'Hãy nhập Email';
                          //   if (!value.contains('@')) return 'Email không hợp lệ';
                          //   return null;
                          // },
                          decoration: InputDecoration(
                            labelText: 'Email cá nhân',
                            // errorText: _emailValid ? null : 'Vui lòng nhập email',
                            hintText: 'Nhập email cá nhân',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Colors.black12),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            labelText: 'Số điện thoại',
                            errorText: _phoneValid ? null : 'Vui lòng nhập số điện thoại',
                            hintText: '0987654321',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Colors.black12),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _currentAddressController,
                          decoration: InputDecoration(
                            labelText: 'Địa chỉ hiện tại',
                            hintText: 'Thôn/Xóm/Số nhà, Xã/Phường, Huyện/Thành phố, Tỉnh/Thành phố',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Colors.black12),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _educationLevelController,
                          decoration: InputDecoration(
                            labelText: 'Trình độ học vấn',
                            hintText: 'Thạc sĩ',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Colors.black12),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            child: TextFormField(
                              controller: _salaryController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}$')),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Lương cơ bản',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(color: Colors.black12),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _salaryFactorController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}$')),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Hệ số lương',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(color: Colors.black12),
                                ),
                              ),
                            ),
                          ),
                        ],),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _totalSalaryController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Tổng lương',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Colors.black12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitData,
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).canvasColor,
                        onPrimary: Colors.white,
                        padding: EdgeInsets.all(15.0),
                      ),
                      child: Text('Thêm giảng viên', style: TextStyle(fontSize: 20),),
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
                )
            ),
        ],
      ),
    );
  }
}

class PickPicture extends StatefulWidget {
  final Function(File) onImagePicked;
  const PickPicture({required this.onImagePicked, Key? key}) : super(key: key);

  @override
  _PickPictureState createState() => _PickPictureState();
}

class _PickPictureState extends State<PickPicture> {
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _selectedImage != null ? Image.file(_selectedImage!, width: 250, height: 250, fit: BoxFit.cover)
            : Image.asset('assets/login_img/acc_img.png', width: 200, height: 200, fit: BoxFit.cover),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _showImageSourceActionSheet(context),
          child: const Text('Chọn ảnh'),
          style: ElevatedButton.styleFrom(
            primary: Theme.of(context).canvasColor,
            onPrimary: Colors.white,
          ),
        ),
      ],
    );
  }
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Thư viện'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Máy ảnh'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
      );
      if (croppedImage != null) {
        setState(() {
          _selectedImage = File(croppedImage.path);
          widget.onImagePicked(_selectedImage!);
        });
      }
    }
  }
}

