import 'package:flutter/material.dart';

class CommonButton extends StatefulWidget {
  final String title;
  final Color color;
  final void Function()? onTap;

  const CommonButton({
    super.key,
    required this.title,
    required this.color,
    this.onTap,
  });

  @override
  State<CommonButton> createState() => _CommonButtonState();
}

class _CommonButtonState extends State<CommonButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isPressed = true;
        });

        if (widget.onTap != null) {
          widget.onTap!();
        }

        Future.delayed(const Duration(milliseconds: 200), () {
          setState(() {
            isPressed = false;
          });
        });
      },
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: isPressed
            ? widget.color.withOpacity(0.3)
            : widget.color.withOpacity(0.1),
        fixedSize: const Size.fromHeight(34),
      ),
      child: Text(
        widget.title,
        style: TextStyle(
          color: widget.color,
          fontSize: 14,
          fontWeight: FontWeight.w200,
        ),
      ),
    );
  }
}
