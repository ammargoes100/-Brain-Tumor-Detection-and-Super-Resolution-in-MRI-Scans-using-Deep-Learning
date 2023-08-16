import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_mobileapp/Views/OnboardingScreen/onboarding_screen.dart';

import 'LoginScree.dart';

class Authenticate extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser != null) {
      return OnboardingScreen();
    } else {
      return LoginScreen();
    }
  }
}
