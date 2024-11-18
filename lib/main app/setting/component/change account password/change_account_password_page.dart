import 'package:flutter/material.dart';
import '../../../../authenitation/components/data_service.dart';
import '../../../../authenitation/components/my_button.dart';
import '../../../../authenitation/components/my_textfield.dart';
 // Đảm bảo đã nhập lớp DatabaseService

class ChangeAccountPasswordPage extends StatefulWidget {
  const ChangeAccountPasswordPage({super.key});

  @override
  State<ChangeAccountPasswordPage> createState() => _ChangeAccountPasswordPageState();
}

class _ChangeAccountPasswordPageState extends State<ChangeAccountPasswordPage> {
  // text editing controllers
  final oldPasswordController = TextEditingController();
  final passwordController = TextEditingController();
  final reEnterPasswordController = TextEditingController();

  final DatabaseService databaseService = DatabaseService();

  // Hàm đổi mật khẩu
  void signUserIn() async {
    String oldPassword = oldPasswordController.text.trim();
    String newPassword = passwordController.text.trim();
    String reEnterPassword = reEnterPasswordController.text.trim();

    // Kiểm tra mật khẩu mới có ít nhất 6 ký tự
    if (newPassword.length < 6) {
      _showErrorDialog('Mật khẩu mới phải có ít nhất 6 ký tự');
      return;
    }

    // Kiểm tra mật khẩu mới và nhập lại mật khẩu có khớp
    if (newPassword != reEnterPassword) {
      _showErrorDialog('Mật khẩu mới và xác nhận mật khẩu không khớp');
      return;
    }

    // Kiểm tra mật khẩu cũ bằng cách xác thực lại người dùng
    bool isReauthenticated = await databaseService.reauthenticateUser(oldPassword);
    if (!isReauthenticated) {
      _showErrorDialog('Mật khẩu cũ không đúng');
      return;
    }

    // Đổi mật khẩu thành công
    String result = await databaseService.updatePassword(newPassword);
    _showSuccessDialog(result);
  }

  // Hàm hiển thị thông báo lỗi
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Lỗi'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Hàm hiển thị thông báo thành công
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Thành công'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Đóng màn hình đổi mật khẩu
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Đổi mật khẩu tài khoản", style: TextStyle(
          fontWeight: FontWeight.bold
        ),),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             SizedBox(height: MediaQuery.of(context).size.height/6),
        
            // old password textfield
            MyTextField(
              controller: oldPasswordController,
              hintText: 'Mật khẩu hiện tại',
              obscureText: true,
            ),
        
            const SizedBox(height: 20),
        
            // new password textfield
            MyTextField(
              controller: passwordController,
              hintText: 'Mật khẩu mới',
              obscureText: true,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 0, left: 25),
              child: Text(
                'Mật khẩu phải có ít nhất 6 ký tự',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
        
            const SizedBox(height: 10),
        
            // re-enter password textfield
            MyTextField(
              controller: reEnterPasswordController,
              hintText: 'Nhập lại mật khẩu mới',
              obscureText: true,
            ),
        
            // Quy tắc mật khẩu
            const Padding(
              padding: EdgeInsets.only(top: 0, left: 25),
              child: Text(
                'Mật khẩu phải có ít nhất 6 ký tự',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
        
            const SizedBox(height: 25),
        
            // change password button
            MyButton(
              title: "Đổi mật khẩu",
              onTap: () => signUserIn(),
            ),
          ],
        ),
      ),
    );
  }
}