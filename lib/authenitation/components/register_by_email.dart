import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart'; // Import file database_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/login_page.dart';
import 'data_service.dart';

final databaseReference = FirebaseDatabase.instance.ref();
Future<void> registerUser({
  required BuildContext context,
  required TextEditingController usernameController,
  required TextEditingController passwordController,
  required TextEditingController reenterPasswordController,
  required String typeAccount,
}) async {
  final DatabaseService dbService = DatabaseService();

  // Kiểm tra mật khẩu nhập lại có khớp hay không
  if (passwordController.text != reenterPasswordController.text) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Đăng ký thất bại'),
          content: const Text('Mật khẩu không khớp.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    return;
  }

  // Kiểm tra xem email đã được đăng ký chưa
  try {
    List<String> signInMethods =
        await dbService.checkEmailExistence(usernameController.text);

    if (signInMethods.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Đăng ký thất bại'),
            content: const Text(
                'Email này đã được sử dụng. Vui lòng sử dụng email khác.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }
  } catch (e) {
    print('Lỗi kiểm tra email: $e');
    return;
  }

  // Hiển thị hộp thoại tải lên
  showDialog(
    context: context,
    builder: (context) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );

  try {
    // Tạo tài khoản người dùng trên Firebase
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: usernameController.text.trim(),
      password: passwordController.text.trim(),
    );

    String userId = userCredential.user!.uid;

    // Lưu thông tin người dùng trong Realtime Database
    databaseReference.child(userId).set({
      'userID': userId,
      'isopened': false,
      'islocked': false,
      'tempPassword': '',
      'passWord': '123456',
      'isOnline': true,
    });

    // Tạo hồ sơ thiết bị chính trong Firestore
    await dbService.createUserMainDeviceFirestore(userId, typeAccount);

    // Xóa dữ liệu trong ô nhập liệu
    usernameController.clear();
    passwordController.clear();
    reenterPasswordController.clear();

    Navigator.pop(context); // Đóng hộp thoại tải lên

    // Hiển thị thông báo đăng ký thành công
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Đăng ký thành công'),
          content: const Text('Tài khoản của bạn đã được tạo.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    // Đặt trạng thái đăng nhập ban đầu trong shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isFirstLogin', false);
  } on FirebaseAuthException catch (e) {
    Navigator.pop(context); // Đóng hộp thoại tải lên

    // Xử lý các lỗi FirebaseAuth cụ thể
    switch (e.code) {
      case 'weak-password':
        showErrorDialog(
            context, 'Mật khẩu quá yếu. Vui lòng sử dụng mật khẩu mạnh hơn.');
        break;
      case 'invalid-email':
        showErrorDialog(
            context, 'Địa chỉ email không hợp lệ. Vui lòng kiểm tra lại.');
        break;
      case 'email-already-in-use':
        showErrorDialog(
            context, 'Email này đã được sử dụng. Vui lòng sử dụng email khác.');
        break;
      case 'operation-not-allowed':
        showErrorDialog(context,
            'Đăng ký tài khoản bị vô hiệu hóa. Vui lòng liên hệ hỗ trợ.');
        break;
      case 'network-request-failed':
        showErrorDialog(
            context, 'Lỗi mạng. Vui lòng kiểm tra kết nối internet.');
        break;
      default:
        showErrorDialog(context, 'Đã xảy ra lỗi: ${e.message}');
    }
  }
}

// Hàm trợ giúp để hiển thị hộp thoại lỗi
void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Đăng ký thất bại'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
