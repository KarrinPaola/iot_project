import 'package:flutter/material.dart';

class FunctionButton extends StatefulWidget {
  FunctionButton({
    super.key,
    required this.onTap,
    required this.title,
    this.onLongPress,
    required this.isLocked,
    required this.isActive,
  });

  final bool isLocked;
  final String title;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isActive;

  @override
  State<FunctionButton> createState() => _FunctionButtonState();
}

class _FunctionButtonState extends State<FunctionButton> {
  bool isPressed = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.isActive) {
      setState(() {
        isPressed = true;
      });
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isActive) {
      setState(() {
        isPressed = false;
      });
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isActive ? _onTapDown : null,
      onTapUp: widget.isActive ? _onTapUp : null,
      onTapCancel: () {
        if (widget.isActive) {
          setState(() {
            isPressed = false;
          });
        }
      },
      onLongPress: widget.isActive ? widget.onLongPress : null,
      child: Container(
        width: (MediaQuery.of(context).size.width /
                (widget.isLocked == true ? 1.5 : 3) +
            (widget.isLocked == true ? 10 : 0)),
        height: MediaQuery.of(context).size.width /
            (widget.isLocked == true ? 4.5 : 3),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: widget.isActive
              ? (isPressed ? Colors.black : Colors.white)
              : Colors.grey, // Đổi màu nếu không kích hoạt
          border: Border.all(
            color: widget.isActive ? Colors.black : Colors.grey,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: widget.isActive
              ? [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(2, 4),
                  ),
                ]
              : [], // Không có bóng khi không kích hoạt
        ),
        child: Center(
          child: Text(
            widget.title,
            style: TextStyle(
              color: widget.isActive
                  ? (isPressed ? Colors.white : Colors.black)
                  : Colors.white, // Văn bản sẽ luôn màu trắng nếu không kích hoạt
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}