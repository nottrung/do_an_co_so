import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';

class ChangePassScreen extends StatefulWidget {
  const ChangePassScreen({Key? key}) : super(key: key);

  @override
  State<ChangePassScreen> createState() => _ChangePassScreenState();
}

class _ChangePassScreenState extends State<ChangePassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _emailError;
  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _validateEmail() async {
    String email = _emailController.text.trim();
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('teachers')
          .where('internalEmail', isEqualTo: email)
          .get();

      if (email.isEmpty) {
        setState(() {
          _emailError = 'Hãy nhập Email';
        });
      }
      else if (querySnapshot.docs.isEmpty) {
        setState(() {
          _emailError = 'Email không khớp với hệ thống';
        });
      } else {
        setState(() {
          _emailError = null;
        });
      }
    } catch (e) {
      setState(() {
        _emailError = 'Đã xảy ra lỗi khi kiểm tra email';
      });
    }
  }

  void _validateNewPassword(String password) {
    setState(() {
      if (password.isEmpty) {
        _newPasswordError = 'Chưa nhập mật khẩu mới';
      } else if (password.length < 8 || password.length > 15) {
        _newPasswordError = 'Mật khẩu mới phải nằm trong khoảng 8-15 kí tự';
      } else if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d!@#$&_]{8,15}$').hasMatch(password)) {
        _newPasswordError = 'Mật khẩu mới phải chứa ít nhất 1 chữ cái và 1 chữ số (các kí tự !, @, #, \$, &, _, nếu có)';
      } else {
        _newPasswordError = null;
      }
    });
  }

  void _validateConfirmPassword(String password) {
    setState(() {
      if (password.isEmpty) {
        _confirmPasswordError = 'Chưa nhập lại mật khẩu mới';
      } else if (password != _newPasswordController.text) {
        _confirmPasswordError = 'Mật khẩu mới chưa khớp';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String email = _emailController.text.trim();
        String oldPassword = _oldPasswordController.text.trim();
        String newPassword = _newPasswordController.text.trim();
        String confirmPassword = _confirmPasswordController.text.trim();

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('teachers')
            .where('internalEmail', isEqualTo: email)
            .get();

        if (querySnapshot.docs.isEmpty) {
          throw Exception('Không tìm thấy tài khoản với email này.');
        }

        String userId = querySnapshot.docs.first.id;
        DocumentSnapshot userDoc = querySnapshot.docs.first;

        String internalEmail = userDoc.get('internalEmail');
        String dbPassword = userDoc.get('password');

        if (email != internalEmail) {
          throw Exception('Email không khớp với tài khoản hiện tại.');
        }

        if (oldPassword != dbPassword) {
          throw Exception('Mật khẩu cũ không chính xác.');
        }

        if (newPassword != confirmPassword) {
          throw Exception('Mật khẩu mới và mật khẩu xác nhận không khớp.');
        }

        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('Người dùng chưa được xác thực');
        }

        AuthCredential credential = EmailAuthProvider.credential(
          email: email,
          password: oldPassword,
        );
        await user.reauthenticateWithCredential(credential);

        await user.updatePassword(newPassword);

        await FirebaseFirestore.instance.collection('teachers').doc(userId).update({
          'password': newPassword,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đổi mật khẩu thành công!'),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'wrong-password') {
          errorMessage = 'Mật khẩu cũ không chính xác.';
        } else {
          errorMessage = 'Đã xảy ra lỗi: ${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
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
          title: Text('Đổi mật khẩu', style: TextStyle(fontSize: 20)),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/login_img/logo.png',
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Nhập Email',
                      hintStyle: TextStyle(
                        color: Colors.black26,
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
                  TextFormField(
                    controller: _oldPasswordController,
                    obscureText: !_showOldPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Hãy nhập mật khẩu cũ';
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu cũ',
                      hintText: 'Nhập mật khẩu cũ',
                      hintStyle: TextStyle(color: Colors.black26),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showOldPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _showOldPassword = !_showOldPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: !_showNewPassword,
                    onChanged: _validateNewPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Hãy nhập mật khẩu mới';
                      if (value.length < 6) return 'Mật khẩu mới phải có ít nhất 6 ký tự';
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu mới',
                      hintText: 'Nhập mật khẩu mới',
                      hintStyle: TextStyle(color: Colors.black26),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      errorText: _newPasswordError,
                      errorMaxLines: 2,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showNewPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _showNewPassword = !_showNewPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_showConfirmPassword,
                    onChanged: _validateConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Hãy nhập xác nhận mật khẩu';
                      if (value != _newPasswordController.text) return 'Mật khẩu xác nhận không khớp';
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Xác nhận mật khẩu mới',
                      hintText: 'Nhập xác nhận mật khẩu mới',
                      hintStyle: TextStyle(color: Colors.black26),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      errorText: _confirmPasswordError,
                      errorMaxLines: 2,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _showConfirmPassword = !_showConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _changePassword,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        backgroundColor: Theme.of(context).canvasColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        'Đổi mật khẩu',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
