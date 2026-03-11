import 'package:flutter/material.dart';
import 'package:getbike_admin/utils/navigations.dart';
import 'package:getbike_admin/views/login.dart';


class EnhancedSplashScreen extends StatefulWidget {
  @override
  _EnhancedSplashScreenState createState() => _EnhancedSplashScreenState();
}

class _EnhancedSplashScreenState extends State<EnhancedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );
    
    // Start animation
    _controller.forward();
    
    // Navigate after 4 seconds
    Future.delayed(Duration(seconds: 4), () {
      Navigations.pushAndRemoveUntil(SignInPage(), context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo
            ScaleTransition(
              scale: _animation,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                 
                ),
                child: Center(
                  child: Image.asset('assets/images/getbikelogo.png')
                ),
              ),
            ),
            SizedBox(height: 30),
            // App name with fade animation
            FadeTransition(
              opacity: _animation,
              child: Text(
                'Get Bike',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 40),
            // Loading progress indicator
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
