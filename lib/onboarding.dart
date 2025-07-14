import 'package:flutter/material.dart';
import 'package:intellexa/const/string.dart';
import 'package:intellexa/my_home_page.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    'You AI Assistant',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    onboardingText,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Image.asset('assets/onboarding.png'),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Continue', style: TextStyle(color: Colors.white)),
                    SizedBox(width: 5),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
