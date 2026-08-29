import 'package:flutter/material.dart';

class WorkspaceTutorialDialog extends StatefulWidget {
  const WorkspaceTutorialDialog({super.key});

  @override
  State<WorkspaceTutorialDialog> createState() => _WorkspaceTutorialDialogState();
}

class _WorkspaceTutorialDialogState extends State<WorkspaceTutorialDialog> {
  int _currentStep = 1;

  final List<Map<String, dynamic>> _steps = [
    {
      "title": "Escolha o local",
      "icon": Icons.home_work_outlined,
      "description": "Busque um lugar silencioso, bem iluminado e livre de distrações. Um ambiente calmo faz toda a diferença na concentração.",
    },
    {
      "title": "Celular longe",
      "icon": Icons.phonelink_ring_outlined,
      "description": "Deixe o celular no modo silencioso e fora do seu alcance. Notificações são as maiores vilãs do foco nos estudos.",
    },
    {
      "title": "Mantenha-se hidratado",
      "icon": Icons.local_drink_outlined,
      "description": "Tenha sempre uma garrafa de água por perto. A hidratação ajuda o cérebro a funcionar melhor.",
    },
    {
      "title": "Organize o material",
      "icon": Icons.folder_open_outlined,
      "description": "Separe todo o material antes de começar: livros, cadernos, canetas. Assim você não perde tempo procurando depois.",
    },
    {
      "title": "Metas e pausas",
      "icon": Icons.alarm_on_outlined,
      "description": "Defina quanto tempo vai estudar e quando vai fazer pausas. Use o timer ou pomodoro do seu Relógio de Estudos.",
    },
    {
      "title": "Objetivos claros",
      "icon": Icons.gps_fixed_outlined,
      "description": "Tenha em mente o que quer aprender nessa sessão. Fica mais fácil manter o foco quando você sabe exatamente o que fazer.",
    },
  ];

  void _next() {
    if (_currentStep < 6) {
      setState(() {
        _currentStep++;
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _back() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stepData = _steps[_currentStep - 1];
    const Color maroonColor = Color(0xff9f042c);
    const Color greyColor = Color(0xff707b7c);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 8,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              stepData["title"],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Icon Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xff00bf63).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                stepData["icon"],
                color: const Color(0xff00bf63),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),

            // Description
            Text(
              stepData["description"],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // Indicator
            Text(
              "$_currentStep de 6",
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: Colors.black38,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 28),

            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_currentStep > 1) ...[
                  ElevatedButton(
                    onPressed: _back,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greyColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      fixedSize: const Size(100, 42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Voltar",
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroonColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    fixedSize: Size(_currentStep > 1 ? 100 : 130, 42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _currentStep == 6 ? "Pronto!" : "Próximo",
                    style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
