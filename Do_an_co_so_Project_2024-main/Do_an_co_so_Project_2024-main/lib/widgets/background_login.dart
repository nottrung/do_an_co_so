import 'package:flutter/material.dart';

class BackgroundLogin extends StatelessWidget {
  const BackgroundLogin({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            Image.asset(
              'assets/login_img/pka_wl.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity ,
              opacity: AlwaysStoppedAnimation<double>(0.5),
            ),
            SafeArea(child: child!,)
          ],
        )
    );
  }
}
