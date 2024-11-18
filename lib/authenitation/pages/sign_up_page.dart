import 'package:flutter/material.dart';
import 'package:iot_project/authenitation/components/register_by_email.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../components/square_tile.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

enum TypeAccountLabel {
  main('Chủ thiết bị'),
  member('Thành viên');

  // Constructor của enum, chỉ nhận nhãn hiển thị
  const TypeAccountLabel(this.label);
  final String label; // Nhãn hiển thị cho mỗi tùy chọn
}

class _SignUpPageState extends State<SignUpPage> {
  // text editing controllers
  final usernameController = TextEditingController();

  final passwordController = TextEditingController();

  final re_enterPasswordController = TextEditingController();

  String typeAccount = "Chủ thiết bị";

  TypeAccountLabel? selectedAccount;

  List<String> options = [
    'Chủ thiết bị',
    'Thành viên',
  ];
  // sign user in method
  void signUserIn() {}

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
                SizedBox(height: MediaQuery.of(context).size.width / 16),

                // logo
                Icon(
                  Icons.lock,
                  size: MediaQuery.of(context).size.width / 10,
                ),

                SizedBox(height: MediaQuery.of(context).size.width / 20),

                // welcome back, you've been missed!
                Text(
                  'Chào mừng bạn đăng kí tài khoản!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.width / 20),


                DropdownMenu<TypeAccountLabel>(
                  menuStyle: MenuStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  initialSelection: TypeAccountLabel.main, // Giá trị mặc định
                  label: const Text('Tài khoản'), // Nhãn hiển thị trên dropdown
                  onSelected: (TypeAccountLabel? typeAccount) {
                    // Hàm được gọi khi một mục được chọn
                    setState(() {
                      selectedAccount = typeAccount; // Cập nhật màu đã chọn
                    });
                  },
                  // Các mục trong menu dropdown
                  dropdownMenuEntries: TypeAccountLabel.values
                      .map<DropdownMenuEntry<TypeAccountLabel>>(
                          (TypeAccountLabel typeAccount) {
                    return DropdownMenuEntry<TypeAccountLabel>(
                      value: typeAccount, // Giá trị của mục
                      label: typeAccount.label,
                      style: MenuItemButton.styleFrom(
                        foregroundColor:
                            Colors.black, // Màu chữ theo màu đã chọn
                      ), // Nhãn hiển thị của mục
                    );
                  }).toList(),
                ),

                SizedBox(height: MediaQuery.of(context).size.width / 20),

                // username textfield
                MyTextField(
                  controller: usernameController,
                  hintText: 'Tên đăng nhập hoặc Email',
                  obscureText: false,
                ),

                SizedBox(height: MediaQuery.of(context).size.width / 20),

                // password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Nhập mật khẩu',
                  obscureText: true,
                ),
                const Padding(
                padding: EdgeInsets.only(top: 0, left: 0),
                child: Text(
                  'Mật khẩu phải có ít nhất 6 ký tự',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),

                SizedBox(height: MediaQuery.of(context).size.width / 40),

                // password textfield
                MyTextField(
                  controller: re_enterPasswordController,
                  hintText: 'Nhập lại mật khẩu',
                  obscureText: true,
                ),
                const Padding(
                padding: EdgeInsets.only(top: 0, left: 0),
                child: Text(
                  'Mật khẩu phải có ít nhất 6 ký tự',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),

                SizedBox(height: MediaQuery.of(context).size.width / 25),

                // sign in button
                MyButton(
                  title: "Đăng ký",
                  onTap: () {
                    registerUser(
                        context: context,
                        usernameController: usernameController,
                        passwordController: passwordController,
                        reenterPasswordController: re_enterPasswordController,
                        typeAccount: typeAccount);
                  },
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
                    const SquareTile(imagePath: 'lib/authenitation/images/apple.png')
                  ],
                ),

                SizedBox(height: MediaQuery.of(context).size.width / 15),

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bạn đã có tài khoản?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Đăng nhập ngay',
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

