import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

final databaseReference = FirebaseDatabase.instance.ref();
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class Services {
  Future<void> openDoor(String userId) async {
    await databaseReference.child(userId).update({
      'isopened': true,
    });
  }

  Future<void> lockDoor(String userId) async {
    await databaseReference.child(userId).update({
      'islocked': true,
      'isopened': false,
    });
    String currentDate = DateTime.now()
        .toIso8601String()
        .substring(0, 10); // Lấy ngày hiện tại theo định dạng "YYYY-MM-DD"

    // Thêm hành động mở cửa vào lịch sử trong Firestore
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .doc(currentDate)
        .collection('actions')
        .add({
      'action': 'lock', // Hành động mở cửa
      'timestamp': FieldValue.serverTimestamp(), // Thời gian thực hiện
    });
  }

  Future<void> closeDoor(String userId) async {
    await databaseReference.child(userId).update({
      'isopened': false,
    });
  }

  Future<void> unlockDoor(String userId) async {
    await databaseReference.child(userId).update({
      'islocked': false,
    });
    String currentDate = DateTime.now()
        .toIso8601String()
        .substring(0, 10); // Lấy ngày hiện tại theo định dạng "YYYY-MM-DD"

    // Thêm hành động mở cửa vào lịch sử trong Firestore
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .doc(currentDate)
        .collection('actions')
        .add({
      'action': 'unlock', // Hành động mở cửa
      'timestamp': FieldValue.serverTimestamp(), // Thời gian thực hiện
    });
  }

  Future<void> setTempPassword(String userId, String tempPassword) async {
    await databaseReference.child(userId).update({
      'tempPassword': tempPassword,
    });
  }

  Future<int?> stateDoor(String userId) async {
    final snapshot = await databaseReference.child(userId).get();
    if (snapshot.exists) {
      Map<String, dynamic> data =
          Map<String, dynamic>.from(snapshot.value as Map);
      bool isOpened = data['isopened'] ?? false;
      bool isLocked = data['islocked'] ?? false;

      if (isOpened) {
        return 1; // Cửa mở
      } else if (isLocked) {
        return 2; // Cửa khóa
      } else {
        return 0; // Cửa đóng
      }
    } else {
      print('No data available.');
      return null;
    }
  }

  Future<bool?> checkBoardOnline(String userId) async {
    final snapshot = await databaseReference.child(userId).get();
    if (snapshot.exists) {
      Map<String, dynamic> data =
          Map<String, dynamic>.from(snapshot.value as Map);
      bool isOnline = data['isOnline'] ?? false;

      if (isOnline) {
        return true;
      } else {
        return false; // Cửa đóng
      }
    } else {
      print('No data available.');
      return null;
    }
  }
}
