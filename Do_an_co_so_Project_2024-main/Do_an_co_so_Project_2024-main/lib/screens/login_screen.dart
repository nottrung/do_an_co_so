import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tea_man_pka/screens/teachers/tea_home_screen.dart';
import 'package:tea_man_pka/screens/teachers/tea_navbar.dart';

import '../widgets/background_login.dart';
import 'admin/ad_navbar.dart';
import 'admin/ad_home_screen.dart';
import 'change_pass_screen.dart';
import 'forgot_pass_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailAndPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;
        if (user != null) {
          String enteredEmail = _emailController.text.trim();

          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('teachers')
              .where('internalEmail', isEqualTo: enteredEmail)
              .limit(1)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            Map<String, dynamic> teacherData = querySnapshot.docs.first.data() as Map<String, dynamic>;
            String option = teacherData['option'];

            if (option == 'admin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AdHomeScreen()),
              );
            } else if (option == 'teacher') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TeaHomeScreen(teacherData: teacherData)),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Tài khoản không có quyền truy cập.'),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Không tìm thấy thông tin người dùng.'),
              ),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tài khoản hoặc mật khẩu không đúng.'),
            ),
          );
        } else if (e.code == 'invalid-email') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Email không hợp lệ.'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xảy ra lỗi: ${e.message}'),
            ),
          );
        }
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
        body: BackgroundLogin(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 150, left: 20, right: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/login_img/logo_nen.png', width: 100, height: 100,),
                        const SizedBox(height: 50),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Hãy nhập Email';
                            }
                            if (!value.contains('@')) {
                              return 'Email không hợp lệ';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            label: Text('Email'),
                            hintText: 'Nhập Email',
                            hintStyle: TextStyle(
                              color: Colors.black26,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Hãy nhập mật khẩu';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            label: Text('Mật khẩu'),
                            hintText: 'Nhập mật khẩu',
                            hintStyle: TextStyle(
                              color: Colors.black26,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ChangePassScreen()),
                                );
                              },
                              child: Stack(
                                children: <Widget>[
                                  Text(
                                    'Đổi mật khẩu?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 1
                                        ..color = Colors.white,
                                    ),
                                  ),
                                  const Text(
                                    'Đổi mật khẩu?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepOrangeAccent,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ForgotPassScreen()),
                                );
                              },
                              child: Stack(
                                children: <Widget>[
                                  Text(
                                    'Quên mật khẩu?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 1
                                        ..color = Colors.white,
                                    ),
                                  ),
                                  const Text(
                                    'Quên mật khẩu?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepOrangeAccent,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _signInWithEmailAndPassword,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text(
                              'Đăng nhập',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.blue,
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
        ),
      ),
    );
  }
}