import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Để sử dụng FilteringTextInputFormatter

class MyTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  final bool isNumberOnly;  // Thêm tùy chọn cho phép chỉ nhập số

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.isNumberOnly = false,  // Mặc định là không giới hạn nhập số
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 16),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: isNumberOnly ? TextInputType.number : TextInputType.text,  // Kiểu bàn phím
        inputFormatters: isNumberOnly ? [FilteringTextInputFormatter.digitsOnly] : [],  // Chỉ cho phép số nếu isNumberOnly là true
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),
    );
  }
}