import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:iot_project/main%20app/home/component/function_button.dart';
import 'package:iot_project/main%20app/home/component/history/history_home.dart';
import 'package:iot_project/userID_Store.dart';
import 'component/notification_board.dart';
import 'component/services.dart';
import 'dart:async';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int? doorState = null;
  bool isActive = false;
  final databaseReference = FirebaseDatabase.instance.ref();
  final Services services = Services();
  String? userId = UserStorage.userId;

  String generateSixDigitString() {
    Random random = Random();
    int number = 100000 + random.nextInt(900000); // Tạo số từ 100000 đến 999999
    return number.toString(); // Chuyển thành chuỗi
  }

  // Timer to check data changes every 2 seconds
  late Timer _periodicTimer;

  Future<void> _checkBoardConnect() async {
    String? userId = UserStorage.userId;
    await databaseReference.child(userId!).update({
      'isOnline': false,
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    bool? isOnline = false;
    int timeout = 10;
    for (int i = 0; i < timeout; i++) {
      isOnline = await services.checkBoardOnline(userId);
      if (isOnline!) {
        setState(() {
          isActive = true;
        });
        Navigator.of(context).pop();
        return;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    Navigator.of(context).pop();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            "Lỗi kết nối",
            style: TextStyle(color: Colors.red),
          ),
          content: const Text(
              "Mạch không được kết nối với internet.\nBạn muốn thử kết nối lại?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                setState(() {
                  doorState = null;
                  isActive = false;
                });
              },
              child: const Text(
                "Thoát",
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                // Kết nối lại và thử kiểm tra lại
                Navigator.of(context).pop(); // Đóng dialog
                _checkBoardConnect();
              },
              child: const Text(
                "Kết nối lại",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _setUpDoorState() async {
    String? userId = UserStorage.userId;
    int? temp = await services.stateDoor(userId!);
    setState(() {
      doorState = temp; // Cập nhật trạng thái cửa
    });
  }

  Future<void> _openDoor() async {
    String? userId = UserStorage.userId;
    isActive = false;
    await _checkBoardConnect();
    if (isActive) {
      await services.openDoor(userId!);
      await _setUpDoorState();
    }
  }

  Future<void> _closeDoor() async {
    String? userId = UserStorage.userId;
    isActive = false;
    await _checkBoardConnect();
    if (isActive) {
      await services.closeDoor(userId!);
      await _setUpDoorState();
    }
  }

  Future<void> _lockDoor() async {
    String? userId = UserStorage.userId;
    isActive = false;
    await _checkBoardConnect();
    if (isActive) {
      await services.lockDoor(userId!);
      await _setUpDoorState();
    }
  }

  Future<void> _unlockDoor() async {
    String? userId = UserStorage.userId;
    isActive = false;
    await _checkBoardConnect(); // Kiểm tra kết nối ngay khi ứng dụng khởi động
    if (isActive) {
      await services.unlockDoor(userId!);
      await _setUpDoorState();
    }
  }

  Future<void> _initialize() async {
    // Kiểm tra kết nối trước khi load dữ liệu
    await _checkBoardConnect();
    if (isActive) {
      await _setUpDoorState();
    }
  }

  @override
  void initState() {
    super.initState();
    _initialize(); // Gọi hàm kiểm tra kết nối và load dữ liệu khi ứng dụng khởi động
    // Start periodic checking every 2 seconds
    _periodicTimer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
      _setUpDoorState(); // Update door state every 2 seconds
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _periodicTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: const Color(0xffffffff),
        automaticallyImplyLeading: false,
        title: Text(
          'Xin chào ${UserStorage.nameInApp}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Nội dung chính của giao diện
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FunctionButton(
                    isActive: isActive,
                    onTap: () {
                      if (doorState == 2) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: const Text(
                                  "Cảnh báo",
                                  style: TextStyle(),
                                ),
                                content: const Text(
                                    "Cửa đang khoá.\n\nBạn cần mở khoá trước!"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Đóng dialog mà không làm gì
                                      },
                                      child: const Text(
                                        "Hủy",
                                        style: TextStyle(color: Colors.black),
                                      )),
                                  TextButton(
                                      onPressed: () {
                                        // Thực hiện hành động khi nhấn "Xác nhận"
                                        _unlockDoor();
                                        Navigator.of(context)
                                            .pop(); // Đóng dialog sau khi xác nhận
                                      },
                                      child: const Text(
                                        "Mở khoá",
                                        style: TextStyle(color: Colors.black),
                                      )),
                                ],
                              );
                            });
                      } else if (doorState == 1) {
                      } else {
                        _openDoor();
                      }
                    },
                    title: 'MỞ CỬA',
                    isLocked: false,
                  ),
                  FunctionButton(
                    isActive: isActive,
                    onTap: () {
                      if (doorState == 2) {
                      } else if (doorState == 0) {
                      } else {
                        _closeDoor();
                      }
                    },
                    title: 'ĐÓNG CỬA',
                    isLocked: false,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FunctionButton(
                    isActive: isActive,
                    onTap: () {
                      if (doorState != 2) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: const Text(
                                  "Cảnh báo",
                                  style: TextStyle(),
                                ),
                                content: const Text(
                                    "Khoá cửa sẽ vô hiệu quá trình nhập mật khẩu và xoá mật khẩu tạm thời.\n\nChắc chắn muốn khoá?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Đóng dialog mà không làm gì
                                    },
                                    child: const Text("Hủy",
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Thực hiện hành động khi nhấn "Xác nhận"
                                      _lockDoor();
                                      services.setTempPassword(
                                          UserStorage.userId!, "");
                                      Navigator.of(context)
                                          .pop(); // Đóng dialog sau khi xác nhận
                                    },
                                    child: const Text(
                                      "Xác nhận",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              );
                            });
                      }
                    },
                    title: 'KHOÁ CỬA',
                    isLocked: true,
                    onLongPress: () {
                      if (doorState == 2) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: const Text(
                                  "Cảnh báo",
                                  style: TextStyle(),
                                ),
                                content: const Text(
                                    "Mở khoá sẽ cho phép nhập mật khẩu qua numpad\n\nChắc chắn muốn mở khoá?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Đóng dialog mà không làm gì
                                    },
                                    child: const Text("Hủy",
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Thực hiện hành động khi nhấn "Xác nhận"
                                      _unlockDoor();
                                      Navigator.of(context)
                                          .pop(); // Đóng dialog mà không làm gì
                                    },
                                    child: const Text(
                                      "Mở khoá",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              );
                            });
                      }
                    },
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FunctionButton(
                    isActive: isActive,
                    onTap: () {
                      if (doorState == 2) {
                        String tempPassword = generateSixDigitString();
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: const Text(
                                  "Thông báo",
                                  style: TextStyle(),
                                ),
                                content: const Text(
                                    "Cửa đang khoá\n\nMở khoá trước khi tạo mật khẩu tạm thời!!"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Đóng dialog mà không làm gì
                                    },
                                    child: const Text("Hủy",
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _unlockDoor();
                                      Navigator.of(context)
                                          .pop(); // Đóng dialog sau khi xác nhận
                                    },
                                    child: const Text(
                                      "Mở khoá",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              );
                            });
                      } else {
                        String tempPassword = generateSixDigitString();
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: const Text(
                                  "Thông báo",
                                  style: TextStyle(),
                                ),
                                content: Text(
                                    "Mật khẩu tạm thời là: $tempPassword\n\nMật khẩu sẽ có hiệu lực trong 10 phút!"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Đóng dialog mà không làm gì
                                    },
                                    child: const Text("Hủy",
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      services.setTempPassword(
                                          UserStorage.userId!, tempPassword);
                                      Timer(const Duration(minutes: 10), () {
                                        services.setTempPassword(
                                            UserStorage.userId!,
                                            ""); // Đặt lại tempPassword thành ""
                                      });
                                      Navigator.of(context)
                                          .pop(); // Đóng dialog sau khi xác nhận
                                    },
                                    child: const Text(
                                      "Xác nhận",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              );
                            });
                      }
                    },
                    title: 'TẠO MẬT KHẨU\nTẠM THỜI',
                    isLocked: false,
                  ),
                  FunctionButton(
                    isActive: isActive,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HistoryHome()),
                      );
                    },
                    title: 'LỊCH SỬ\nMỞ KHOÁ',
                    isLocked: false,
                  ),
                ],
              ),
              NotificationBoard(doorState: doorState),
            ],
          ),
        ],
      ),
    );
  }
}
