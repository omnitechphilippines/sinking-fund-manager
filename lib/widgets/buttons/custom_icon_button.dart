import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Icon? icon;
  final String label;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final double borderRadius;
  final Size size;
  final double? fontSize;
  final FontWeight? fontWeight;

  const CustomIconButton({super.key, this.onPressed, this.icon, required this.label, this.foregroundColor = Colors.white, this.backgroundColor = const Color(0xFF0099FC), this.borderRadius = 0, this.size = const Size(100, 48), this.fontSize, this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: backgroundColor, minimumSize: size, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius))),
      icon: icon,
      label: Text(label, style: TextStyle(color: foregroundColor, fontSize: fontSize, fontWeight: fontWeight)),
    );
  }
}
