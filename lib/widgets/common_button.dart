import 'package:flutter/material.dart';

class CommonButton extends StatefulWidget {
  final String title;
  final Color color;
  final void Function()? onTap;
  final Duration animationDuration;

  const CommonButton({
    super.key,
    required this.title,
    required this.color,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<CommonButton> createState() => _CommonButtonState();
}

class _CommonButtonState extends State<CommonButton> {
  bool _isPressed = false;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _handleTap() async {
    if (_isPressed) return;

    // Update pressed state
    if (!_isDisposed) {
      setState(() => _isPressed = true);
    }

    // Execute the onTap callback
    widget.onTap?.call();

    // Delay for visual feedback
    await Future.delayed(widget.animationDuration);

    // Only update state if widget is still mounted
    if (!_isDisposed && mounted) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _handleTap,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: _isPressed
            ? widget.color.withOpacity(0.3)
            : widget.color.withOpacity(0.1),
        fixedSize: const Size.fromHeight(34),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
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