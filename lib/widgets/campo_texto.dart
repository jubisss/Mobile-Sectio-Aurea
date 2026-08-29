import 'package:flutter/material.dart';

class CampoTexto extends StatelessWidget {
  final String labelText;
  final double? width;
  final double? height;
  final Color? cor;
  final TextEditingController controller;
  final String? helperText;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;

  const CampoTexto({
    Key? key,
    required this.labelText,
    this.width,
    this.height,
    this.cor,
    required this.controller,
    this.helperText,
    required this.obscureText,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: width ?? 280,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              helperText: helperText,
              helperStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: isDark ? Colors.white30 : Colors.black38,
              ),
              filled: true,
              fillColor: cor ?? (isDark ? const Color(0xff1e1e1e) : Colors.white),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: isDark ? Colors.white70 : Colors.black45, size: 20)
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12, width: 1.2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? Colors.tealAccent : Colors.black87, width: 1.8),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
