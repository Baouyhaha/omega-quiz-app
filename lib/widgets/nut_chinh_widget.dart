import 'package:flutter/material.dart';

// Nut hanh dong chinh mau tim, dung o hau het cac man hinh.
// Nut phu dung OutlinedButton mac dinh cua theme.
class NutChinh extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  const NutChinh({super.key, required this.text, required this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return ElevatedButton(onPressed: onPressed, child: Text(text));
    }
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(text),
    );
  }
}
