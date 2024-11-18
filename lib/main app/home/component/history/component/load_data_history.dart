import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> loadDataHistory(String userId, DateTime date) async {
  final firestore = FirebaseFirestore.instance;

  String dateSelected = date.toIso8601String().substring(0, 10); // Lấy ngày hiện tại theo định dạng "YYYY-MM-DD"

  // Tạo tham chiếu tới collection 'actions' cho ngày cụ thể
  final actionsRef = firestore
      .collection('users')
      .doc(userId)
      .collection('history')
      .doc(dateSelected) 
      .collection('actions');

  // Lấy các document từ collection 'actions' và sắp xếp theo 'timestamp'
  final querySnapshot = await actionsRef.orderBy('timestamp', descending: true).get();

  // Ánh xạ các document thành danh sách các hành động với giờ thực hiện
  List<Map<String, dynamic>> actions = querySnapshot.docs.map((doc) {
    DateTime timestamp = doc['timestamp']?.toDate();
    String timeOnly = "${timestamp.hour}:${timestamp.minute}:${timestamp.second}"; // Chỉ lấy giờ, phút, giây

    return {
      'action': doc['action'],
      'time': timeOnly, // Lưu giờ thực hiện thay vì toàn bộ ngày giờ
    };
  }).toList();

  return actions;
}