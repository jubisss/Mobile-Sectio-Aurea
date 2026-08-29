import 'package:flutter/material.dart';

class BotaoIcone extends StatelessWidget {
  final Color? cor;
  final Color? corIcone;
  final VoidCallback funcao;
  final Icon? icone;
  final double radius;

  const BotaoIcone({
    super.key,
    this.cor,
    this.corIcone,
    required this.funcao,
    this.icone,
    this.radius = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (cor ?? Colors.black).withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Material(
        color: cor ?? Colors.black,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: funcao,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              icone?.icon ?? Icons.arrow_forward,
              color: corIcone ?? Colors.white,
              size: radius,
            ),
          ),
        ),
      ),
    );
  }
}
