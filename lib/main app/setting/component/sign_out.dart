import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../authenitation/pages/login_page.dart';
import '../../../check_login.dart';
import '../../../userID_Store.dart';

void signUserOut(BuildContext context) {
    FirebaseAuth.instance.signOut();
    UserStorage.userId = "";
    isLogined = false;

    // Navigate back to the login page after signing out
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
}