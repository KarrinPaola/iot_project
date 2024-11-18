import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iot_project/authenitation/components/data_service.dart';
import 'package:iot_project/authenitation/pages/sign_up_page.dart';
import 'package:iot_project/main%20app/main_control_page.dart';
import 'package:iot_project/main%20app/set%20up%20first/name%20in%20app%20home/name_in_app_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../check_login.dart';
import '../../userID_Store.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../components/square_tile.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final usernameController = TextEditingController();

  final passwordController = TextEditingController();

  bool stateLogin = false;

  DatabaseService databaseService = DatabaseService();

  // sign user in method
  void signUserIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Show loading dialog
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Firebase login
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      String userId = userCredential.user!.uid;
      UserStorage.userId = userId; // Store userId
      UserStorage.email = usernameController.text;
      UserStorage.password = passwordController.text;
      print('User ID: $userId');

      // Update login status
      setState(() {
        stateLogin = true;
        isLogined = true;
      });

      Navigator.pop(context); // Close loading dialog

      // Check if first login
      final bool? isFirstLogin = prefs.getBool('isFirstLogin');
      print(isFirstLogin);

      // Navigate based on login state
      if (isFirstLogin == false) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MainControlPage()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NameInAppHome()),
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close loading dialog

      // Handle specific error codes
      switch (e.code) {
        case 'user-not-found':
          showErrorDialog('Không tìm thấy tài khoản nào với email này.');
          break;
        case 'wrong-password':
          showErrorDialog('Sai mật khẩu. Vui lòng thử lại.');
          break;
        case 'invalid-email':
          showErrorDialog('Email không hợp lệ. Vui lòng kiểm tra lại.');
          break;
        case 'user-disabled':
          showErrorDialog('Tài khoản của bạn đã bị vô hiệu hóa.');
          break;
        case 'network-request-failed':
          showErrorDialog('Mất kết nối. Vui lòng kiểm tra kết nối mạng.');
          break;
        default:
          showErrorDialog('Có lỗi xảy ra: ${e.message}');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      showErrorDialog('Một lỗi không xác định đã xảy ra. Vui lòng thử lại.');
    }
  }

// Helper function to show error dialog
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Đăng nhập thất bại'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close error dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.width / 10),

                // logo
                Icon(
                  Icons.lock,
                  size: MediaQuery.of(context).size.width / 6,
                ),

                SizedBox(height: MediaQuery.of(context).size.width / 10),

                // welcome back, you've been missed!
                Text(
                  'Chào mừng bạn quay trở lại!!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.width / 16),

                // username textfield
                MyTextField(
                  controller: usernameController,
                  hintText: 'Tên đăng nhập hoặc Email',
                  obscureText: false,
                ),

                SizedBox(height: MediaQuery.of(context).size.width / 25),

                // password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Mật khẩu',
                  obscureText: true,
                ),

                SizedBox(height: MediaQuery.of(context).size.width / 25),

                // forgot password?
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Bạn đã quên mật khẩu?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.width / 16),

                // sign in button
                MyButton(
                  onTap: signUserIn,
                  title: "Đăng nhập",
                ),

                SizedBox(height: MediaQuery.of(context).size.width / 15),

                // or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Hoặc đăng nhập với',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.width / 15),

                // google + apple sign in buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // google button
                    const SquareTile(
                        imagePath: 'lib/authenitation/images/google.png'),

                    SizedBox(width: MediaQuery.of(context).size.width / 16),

                    // apple button
                    const SquareTile(
                        imagePath: 'lib/authenitation/images/apple.png')
                  ],
                ),

                SizedBox(height: MediaQuery.of(context).size.width / 15),

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bạn chưa có tài khoản?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpPage()),
                        );
                      },
                      child: const Text(
                        'Đăng ký ngay',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
