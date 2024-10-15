import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../ad_navbar.dart';

class EditTeaSalaryScreen extends StatefulWidget {
  final Map<String, dynamic> teacherData;

  const EditTeaSalaryScreen({super.key, required this.teacherData});

  @override
  State<EditTeaSalaryScreen> createState() => _EditTeaSalaryScreenState();
}

class _EditTeaSalaryScreenState extends State<EditTeaSalaryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workPointController = TextEditingController();
  final _salaryController = TextEditingController();
  final _salaryFactorController = TextEditingController();
  final _bonusSalaryController = TextEditingController();
  final _penaltySalaryController = TextEditingController();
  late Map<String, dynamic> _teacherData;

  @override
  void initState() {
    super.initState();
    _teacherData = widget.teacherData;
    _initializeFields();
  }

  void _initializeFields() {
    _workPointController.text = toDouble(_teacherData['workPoint']).toString();
    _salaryController.text = toDouble(_teacherData['salary']).toString();
    _salaryFactorController.text = toDouble(_teacherData['salaryFactor']).toString();
    _bonusSalaryController.text = toDouble(_teacherData['bonusSalary']).toString();
    _penaltySalaryController.text = toDouble(_teacherData['penatySalary']).toString();
  }

  Future<void> _updateTeacherSalary() async {
    if (_formKey.currentState!.validate()) {
      double salary = double.parse(_salaryController.text);
      double salaryFactor = double.parse(_salaryFactorController.text);
      double workPoint = double.parse(_workPointController.text);
      double bonusSalary = double.parse(_bonusSalaryController.text);
      double penaltySalary = double.parse(_penaltySalaryController.text);
      double subsidize = toDouble(_teacherData['subsidize']);
      double salaryPerDay = (salary * salaryFactor) / 26;
      double totalSalary = (salaryPerDay * workPoint) + bonusSalary + subsidize - penaltySalary;

      try {
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        QuerySnapshot querySnapshot = await firestore
            .collection('teachers')
            .where('teacherId', isEqualTo: _teacherData['teacherId'])
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentReference documentRef = querySnapshot.docs.first.reference;

          await documentRef.update({
            'workPoint': workPoint,
            'salary': salary,
            'salaryFactor': salaryFactor,
            'bonusSalary': bonusSalary,
            'penatySalary': penaltySalary,
            'salaryPerDay': double.parse(salaryPerDay.toStringAsFixed(3)), // Formatting to 3 decimal places
            'subsidize': subsidize,
            'totalSalary': double.parse(totalSalary.toStringAsFixed(3)), // Formatting to 3 decimal places
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cập nhật lương thành công')),
          );

          Future.delayed(Duration(seconds: 0), () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => AdNavigationBar()),
            );
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh sửa lương giảng viên'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextFormField(_workPointController, 'Ngày công'),
              _buildTextFormField(_salaryController, 'Lương cơ bản'),
              _buildTextFormField(_salaryFactorController, 'Hệ số lương'),
              _buildTextFormField(_bonusSalaryController, 'Lương thưởng'),
              _buildTextFormField(_penaltySalaryController, 'Lương phạt'),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Theme.of(context).canvasColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: _updateTeacherSalary,
                child: Text('Cập nhật', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập $label';
          }
          return null;
        },
      ),
    );
  }
}

double toDouble(dynamic value) {
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  } else if (value is double) {
    return value;
  } else if (value is int) {
    return value.toDouble();
  } else {
    return 0.0;
  }
}
