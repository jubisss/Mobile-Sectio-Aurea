import 'package:flutter/material.dart';

class Botao extends StatelessWidget {
  final Color? cor;
  final String? texto;
  final String? fontFamily;
  final FontWeight? fontWeight;
  final double? fontSize;
  final Color? corTexto;
  final VoidCallback funcao;
  final double? height;
  final double? width;
  final Widget? child;

  const Botao({
    super.key,
    this.cor,
    this.texto,
    this.fontFamily,
    this.fontWeight,
    this.fontSize,
    this.corTexto,
    required this.funcao,
    this.height,
    this.width,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      child: ElevatedButton(
        onPressed: funcao,
        style: ElevatedButton.styleFrom(
          backgroundColor: cor ?? Colors.black,
          foregroundColor: corTexto ?? const Color(0xfff4f1eb),
          elevation: 4,
          shadowColor: (cor ?? Colors.black).withOpacity(0.3),
          fixedSize: Size(width ?? 180, height ?? 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: cor == const Color(0xfff4f1eb)
                ? const BorderSide(color: Colors.black12, width: 1.5)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: child ?? Text(
          texto ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: fontFamily ?? 'Poppins',
            fontWeight: fontWeight ?? FontWeight.w600,
            fontSize: fontSize ?? 15,
            color: corTexto ?? const Color(0xfff4f1eb),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
