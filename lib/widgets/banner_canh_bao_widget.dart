import 'package:flutter/material.dart';

import '../core/app_theme.dart';

// Banner canh bao mau vang: sap het han goi, gan het han muc...
class BannerCanhBao extends StatelessWidget {
  final String text;
  final String? actionText;
  final VoidCallback? onAction;

  const BannerCanhBao({
    super.key,
    required this.text,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kWarning.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kWarning),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: kWarning, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14, height: 1.35)),
          ),
          if (actionText != null)
            TextButton(onPressed: onAction, child: Text(actionText!)),
        ],
      ),
    );
  }
}
