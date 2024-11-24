import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:iot_project/authenitation/components/my_button.dart';
import 'package:iot_project/authenitation/components/my_textfield.dart';
import 'package:iot_project/main%20app/main_control_page.dart';
import 'package:iot_project/userID_Store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BluetoothSetupPage extends StatefulWidget {
  const BluetoothSetupPage({Key? key}) : super(key: key);

  @override
  _BluetoothSetupPageState createState() => _BluetoothSetupPageState();
}

class _BluetoothSetupPageState extends State<BluetoothSetupPage> {
  bool isConnected =
      false; //kiểm tra xem đã kết nối với module bluetooth hay chưa
  bool isLoading = false;
  BluetoothConnection? connection;
  String? hc06MacAddress;
  final TextEditingController wifiIdController = TextEditingController();
  final TextEditingController wifiPasswordController = TextEditingController();
  Timer? responseTimer;

  @override
  void initState() {
    super.initState();
    initializeBluetoothConnection();
  }

  Future<void> initializeBluetoothConnection() async {
    FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;

    try {
      // Lấy danh sách các thiết bị đã ghép nối
      List<BluetoothDevice> bondedDevices = await bluetooth.getBondedDevices();
      for (BluetoothDevice device in bondedDevices) {
        if (device.name == 'HC-06') {
          hc06MacAddress = device.address;
          break;
        }
      }

      // Cập nhật trạng thái kết nối
      setState(() {
        isConnected = hc06MacAddress != null;
      });

      // Nếu tìm thấy HC-06, thực hiện kết nối
      if (isConnected == true && hc06MacAddress != null) {
        connection = await BluetoothConnection.toAddress(hc06MacAddress!);
        print("Đã kết nối với HC-06");
      } else {
        print("Không tìm thấy HC-06. Vui lòng ghép nối thiết bị trước.");
      }
    } catch (e) {
      print("Lỗi khi kết nối với HC-06: $e");
      setState(() {
        isConnected = false; // Đảm bảo cập nhật trạng thái nếu lỗi
      });
    }
  }

  void sendWifiData() async {
    String wifiId = wifiIdController.text.trim();
    String wifiPassword = wifiPasswordController.text.trim();
    String wifiDataToSend =
        "w,$wifiId,$wifiPassword,${UserStorage.email},${UserStorage.password}\n"; // Gói Wi-Fi bắt đầu bằng "w,"
    String userIdDataToSend =
        "id,${UserStorage.userId}\n"; // Gói userID bắt đầu bằng "id,"

    // Kiểm tra kết nối Bluetooth
    if (connection == null || !connection!.isConnected) {
      _showErrorDialog("Chưa kết nối với HC-06");
      return;
    }

    setState(() {
      isLoading = true; // Hiển thị trạng thái đang tải
    });

    try {
      // Gửi thông tin Wi-Fi
      connection!.output.add(Uint8List.fromList(wifiDataToSend.codeUnits));
      await connection!.output.allSent;
      print("Đã gửi thông tin Wi-Fi đến HC-06: $wifiDataToSend");

      // Thiết lập bộ đếm thời gian timeout (15 giây)
      responseTimer = Timer(const Duration(seconds: 15), () {
        setState(() {
          isLoading = false;
        });
        _showTimeoutDialog(); // Hiển thị thông báo khi hết thời gian chờ
      });

      // Lắng nghe phản hồi từ ESP8266
      connection!.input!.listen((Uint8List data) {
        String response = String.fromCharCodes(data).trim();
        print("Phản hồi từ ESP8266: $response");

        // Hủy bộ đếm thời gian khi nhận được phản hồi
        responseTimer?.cancel();
        setState(() {
          isLoading = false;
        });

        // Kiểm tra phản hồi
        if (response == "y") {
          // Nếu kết nối Wi-Fi thành công, gửi tiếp userID
          sendUserId(userIdDataToSend);
        } else if (response == "n") {
          // Nếu kết nối Wi-Fi thất bại, hiển thị thông báo lỗi
          _showErrorDialog(
              "Thông tin Wi-Fi không chính xác. Vui lòng thử lại.");
        } else {
          // Nếu phản hồi không phải 'y' hoặc 'n', cho rằng có lỗi không xác định
          _showErrorDialog("Lỗi không xác định. Vui lòng thử lại.");
        }
      }).onError((error) {
        setState(() {
          isLoading = false;
        });
        _showErrorDialog("Lỗi khi nhận phản hồi: $error");
      });
    } catch (e) {
      print("Lỗi trong quá trình gửi hoặc nhận dữ liệu: $e");
      setState(() {
        isLoading = false;
      });
      _showErrorDialog("Đã xảy ra lỗi. Vui lòng thử lại.");
    }
  }

  void sendUserId(String userIdData) async {
    try {
      // Gửi userID qua Bluetooth (với "id," ở đầu)
      connection!.output.add(Uint8List.fromList(userIdData.codeUnits));
      await connection!.output.allSent;
      print("Đã gửi userID: $userIdData");

      // Xác nhận đã truyền đầy đủ dữ liệu isFirstLogin = true
      setFirstLoginStatus();
      // Chuyển đến trang chính
      _navigateToMainControlPage();
    } catch (e) {
      print("Lỗi khi gửi userID: $e");
      _showErrorDialog("Gửi userID thất bại. Vui lòng thử lại.");
    }
  }

  void _navigateToMainControlPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainControlPage()),
    );
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Không có phản hồi từ thiết bị"),
          content: const Text("Kiểm tra lại thông tin Wi-Fi và thử lại."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                sendWifiData(); // Thử lại việc gửi Wi-Fi
              },
              child: const Text(
                "Thử lại",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text(
                "Hủy",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

// Dialog thông báo lỗi chung
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Lỗi"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text("Đóng"),
            ),
          ],
        );
      },
    );
  }

  Future<void> setFirstLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isFirstLogin', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Bluetooth Setup'),
      ),
      body: SafeArea(
        child: Center(
          child: isConnected
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyTextField(
                      controller: wifiIdController,
                      hintText: "Nhập tên Wifi",
                      obscureText: false,
                    ),
                    const SizedBox(height: 20),
                    MyTextField(
                      controller: wifiPasswordController,
                      hintText: "Nhập mật khẩu Wifi",
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    MyButton(
                      onTap: () {
                        sendWifiData();
                      },
                      title: "Xác nhận",
                    ),
                    if (isLoading) const CircularProgressIndicator(),
                  ],
                )
              : const Text('Vui lòng kết nối Bluetooth với HC-06'),
        ),
      ),
    );
  }
}
