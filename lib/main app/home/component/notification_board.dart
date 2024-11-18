import 'package:flutter/material.dart';

class NotificationBoard extends StatefulWidget {
  NotificationBoard({super.key, this.doorState});

  int? doorState;

  @override
  State<NotificationBoard> createState() => _NotificationBoardState();
}

class _NotificationBoardState extends State<NotificationBoard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.5,
      height: MediaQuery.of(context).size.width / 4,
      margin: EdgeInsets.all(MediaQuery.of(context).size.width / 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.width / 12,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8)),
              ),
              child: const Center(
                child: Text(
                  'TRẠNG THÁI CỬA',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  returnTextDependState(widget.doorState),
                  style: TextStyle(
                    color: getColorDependState(widget.doorState),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String returnTextDependState(int? doorState) {
  switch (doorState) {
    case -1:
      return "Có truy cập trái phép".toUpperCase();
    case 0:
      return "Cửa đang đóng".toUpperCase();
    case 1:
      return "Cửa đang mở".toUpperCase();
    case 2:
      return "Cửa đã khoá\n Không thể nhập mật khẩu".toUpperCase();
    default:
      return "Mất kết nối với cửa".toUpperCase();
  }
}

Color getColorDependState(int? doorState) {
  switch (doorState) {
    case -1:
      return Colors.red; // Màu đỏ cho truy cập trái phép
    case 0:
      return Colors.green; // Màu xanh lá cho cửa đóng
    case 1:
      return Colors.blue; // Màu xanh dương cho cửa mở
    case 2:
      return Colors.orange; // Màu cam cho cửa đã khoá
    case null:
      return Colors.grey; // Màu xám cho trạng thái không xác định
    default:
      return Colors.grey; // Màu xám cho mất kết nối
  }
}