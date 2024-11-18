import 'package:flutter/material.dart';
import 'package:iot_project/authenitation/components/data_service.dart';
import 'package:iot_project/main%20app/main_control_page.dart';
import 'package:iot_project/main%20app/set%20up%20first/connect%20bluetooth/sent_data_to_iot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../authenitation/components/my_button.dart';
import '../../../authenitation/components/my_textfield.dart';
import '../../../userID_Store.dart';

class NameInAppHome extends StatefulWidget {
  const NameInAppHome({super.key});

  @override
  State<NameInAppHome> createState() => _NameInAppHomeState();
}

class _NameInAppHomeState extends State<NameInAppHome> {
  // text editing controllers
  final nameInAppController = TextEditingController();
  DatabaseService databaseService = DatabaseService();

  // sign user in method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // welcome back, you've been missed!

              // username textfield
              MyTextField(
                controller: nameInAppController,
                hintText: 'Nhập tên đại diện',
                obscureText: false,
              ),

              const SizedBox(height: 25),

              // sign in button
              MyButton(
                onTap: () async {
                  databaseService.setNameInApp(
                      UserStorage.userId!, nameInAppController.text);
                  UserStorage.nameInApp = nameInAppController.text;
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool('isEnterName', true);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BluetoothSetupPage()),
                  );
                },
                title: "Tiếp tục",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
