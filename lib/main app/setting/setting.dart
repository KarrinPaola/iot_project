import 'package:flutter/material.dart';
import 'package:iot_project/main%20app/home/component/setting_button.dart';
import 'package:iot_project/main%20app/setting/component/change%20account%20password/change_account_password_page.dart';
import 'package:iot_project/main%20app/setting/component/change%20lock%20password/change_lock_password.dart';
import 'package:iot_project/main%20app/setting/component/reset_status.dart';
import 'package:iot_project/main%20app/setting/component/sign_out.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xffffffff),
        automaticallyImplyLeading: false,
        title: const Text(
          "Cài đặt",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  SettingButton(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChangeAccountPasswordPage()),
                      );
                    },
                    title: "Đổi mật khẩu tài khoản",
                    logOut: false,
                  ),
                  SettingButton(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChangeLockPassword()),
                      );
                    },
                    title: "Đổi mật khẩu khoá",
                    logOut: false,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width / 12,
                  ),
                  SettingButton(
                    onTap: () {
                      signUserOut(context);
                    },
                    title: "Đăng xuất",
                    logOut: true,
                  ),
                  SettingButton(
                    onTap: () {
                      resetStatus(context);
                    },
                    title: "Thiết lập lại khoá",
                    logOut: true,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
