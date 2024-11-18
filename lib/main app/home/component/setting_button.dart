import 'package:flutter/material.dart';

class SettingButton extends StatefulWidget {
  const SettingButton({
    super.key,
    required this.onTap,
    required this.title,
    required this.logOut,
  });

  final String title;
  final VoidCallback onTap;
  final bool logOut;

  @override
  State<SettingButton> createState() => _SettingButtonState();
}

class _SettingButtonState extends State<SettingButton> {
  bool isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      isPressed = false;
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () {
        setState(() {
          isPressed = false;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.2,
        height: MediaQuery.of(context).size.width / 7,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isPressed
              ? const Color(0xFF9ba1a8) // Màu khi nhấn vào nút
              : (widget.logOut ? Colors.black : Colors.white),
          border: Border.all(
            color: Colors.black,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.title,
            style: TextStyle(
              color: isPressed
                  ? Colors.white
                  : (widget.logOut ? Colors.white : Colors.black),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}