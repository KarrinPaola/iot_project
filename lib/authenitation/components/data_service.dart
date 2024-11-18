import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final databaseReference = FirebaseDatabase.instance.ref();

  // Hàm kiểm tra email đã được đăng ký chưa
  Future<List<String>> checkEmailExistence(String email) async {
    try {
      return await _auth.fetchSignInMethodsForEmail(email.trim());
    } catch (e) {
      print('Error checking email existence: $e');
      return [];
    }
  }

  // Hàm tạo tài khoản trong Firestore
  Future<void> createUserMainDeviceFirestore(
    String userId,
    String typeAccount,
  ) async {
    try {
      // Thêm thông tin người dùng vào Firestore
      await _firestore.collection('users').doc(userId).set({
        'nameInApp': "", // Lưu tên người dùng trong ứng dụng
        'typeAccount': typeAccount, // Lưu loại tài khoản
        'userId': userId,
      });
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('participants')
          .doc('someParticipantId')
          .set({
        'participantName':
            'John Doe', // Tên của người tham gia chung (có thể thay đổi tùy vào tham số bạn muốn)
        'participantId': 'someParticipantId', // ID của người tham gia
      });
      // Tạo lịch sử mở/đóng cửa theo ngày trong sub-collection "history"
      String currentDate = DateTime.now()
          .toIso8601String()
          .substring(0, 10); // Lấy ngày hiện tại theo định dạng "YYYY-MM-DD"

      // Thêm hành động mở/đóng cửa vào lịch sử
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .doc(currentDate)
          .set(
              {
            'actions': FieldValue.arrayUnion([
              // Dùng arrayUnion để thêm hành động mới vào mảng actions
              {
                'action': 'open', // Hành động mở
                'timestamp':
                    DateTime.now(), // Thời gian thực hiện
              },
              {
                'action': 'close', // Hành động đóng
                'timestamp':
                    DateTime.now(), // Thời gian thực hiện
              },
            ]),
          },
              SetOptions(
                  merge:
                      true)); // merge: true để giữ lại các dữ liệu cũ, chỉ thêm mới nếu có
    } catch (e) {
      print('Error creating user in Firestore: $e');
    }
  }

  Future<void> createUserMemberFirestore(
    String userId,
    String typeAccount,
  ) async {
    try {
      // Thêm thông tin người dùng vào Firestore
      await _firestore.collection('users').doc(userId).set({
        'nameInApp': '', // Lưu tên người dùng trong ứng dụng
        'typeAccount': typeAccount, // Lưu loại tài khoản
        'userId': userId,
        'userIDDevice': '',
      });
    } catch (e) {
      print('Error creating user in Firestore: $e');
    }
  }

  // Hàm tạo tài khoản trong Realtime Database
  Future<void> createUserRealtimeDB(String userId) async {
    try {
      await databaseReference.child('users').child('aloso').set({
        'locked': false,
        'opened': false,
      });
      print('User created successfully in Realtime Database');
    } catch (e) {
      print('Error creating user in Realtime Database: $e');
    }
  }

  // Hàm kiểm tra xem nameInApp đã được nhập hay chưa
  Future<String?> getNameInApp(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      // Check if the document exists and has data
      if (userDoc.exists && userDoc.data() != null) {
        var data = userDoc.data() as Map<String, dynamic>;

        // Return nameInApp if it exists and is not empty
        if (data['nameInApp'] != null &&
            data['nameInApp'].toString().isNotEmpty) {
          return data['nameInApp'].toString();
        }
      }
      return null; // Return null if nameInApp is not found or empty
    } catch (e) {
      print('Error retrieving nameInApp: $e');
      return null;
    }
  }

  // Hàm để lưu chuỗi vào nameInApp
  Future<void> setNameInApp(String userId, String name) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'nameInApp': name, // Cập nhật nameInApp với giá trị name truyền vào
      });
      print('NameInApp set successfully');
    } catch (e) {
      print('Error setting nameInApp: $e');
    }
  }

  // Hàm xác thực lại người dùng bằng mật khẩu hiện tại
  Future<bool> reauthenticateUser(String currentPassword) async {
    try {
      // Lấy người dùng hiện tại
      User? user = _auth.currentUser;

      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );

        // Xác thực lại người dùng
        await user.reauthenticateWithCredential(credential);
        return true; // Xác thực thành công
      } else {
        print('Người dùng chưa đăng nhập');
        return false;
      }
    } catch (e) {
      print('Error reauthenticating user: $e');
      return false; // Xác thực thất bại
    }
  }

  // Hàm cập nhật mật khẩu mới
  Future<String> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        await user.updatePassword(newPassword);
        return 'Đổi mật khẩu thành công';
      } else {
        return 'Người dùng chưa đăng nhập';
      }
    } catch (e) {
      print('Error updating password: $e');
      return 'Lỗi khi đổi mật khẩu';
    }
  }

  Future<String?> getPasswordLock(String userId) async {
  try {
    // Lấy dữ liệu từ Firebase
    final snapshot = await databaseReference.child(userId).get();
    
    // Kiểm tra xem dữ liệu có tồn tại hay không
    if (snapshot.exists) {
      // Lấy giá trị của passWord từ snapshot
      Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);
      String password = data['passWord'] ?? '';  // Trả về mật khẩu, nếu không có sẽ là chuỗi rỗng
      return password;
    } else {
      print('No data available.');
      return null; // Nếu không có dữ liệu, trả về null
    }
  } catch (e) {
    print("Error fetching password: $e");
    return null; // Nếu có lỗi, trả về null
  }
}

  Future<String> updatePasswordLock(String userId, String newPassword) async {
    try {
      // Cập nhật mật khẩu mới trong cơ sở dữ liệu
      await databaseReference.child(userId).update({
        'passWord': newPassword,
      });
      return "Đổi mật khẩu khoá thành công!"; // Cập nhật thành công
    } catch (e) {
      print("Error updating password: $e");
      return "Lỗi khi đổi mật khẩu!"; // Cập nhật thất bại
    }
  }
}
