import 'package:flutter/material.dart';
import 'package:sectio_aurea/widgets/imagem_perfil.dart';
import 'package:sectio_aurea/telas/abas/inicio.dart';
import 'package:sectio_aurea/telas/abas/relogio.dart';
import 'package:sectio_aurea/telas/abas/criar.dart';
import 'package:sectio_aurea/telas/abas/revisao.dart';
import 'package:sectio_aurea/telas/abas/perfil.dart';

class Home extends StatefulWidget {
  final Map<String, dynamic> u;

  const Home({super.key, required this.u});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  late Map<String, dynamic> _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.u;
  }

  void _updateUser(Map<String, dynamic> updatedUser) {
    setState(() {
      _currentUser = updatedUser;
    });
  }

  Color _getAccentColor() {
    String? colorHex = _currentUser["clas_inteli"];
    if (colorHex == null || colorHex.isEmpty) {
      return Colors.blueGrey;
    }
    try {
      return Color(int.parse(colorHex));
    } catch (_) {
      return Colors.blueGrey;
    }
  }

  List<Widget> _getTabs() {
    return [
      InicioTab(u: _currentUser),
      RelogioTab(u: _currentUser),
      CriarHubTab(u: _currentUser),
      RevisaoTab(u: _currentUser),
      PerfilTab(u: _currentUser, onUserUpdated: _updateUser),
    ];
  }

  @override
  Widget build(BuildContext context) {
    Color accentColor = _getAccentColor();
    Color titleColor = accentColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;

    String photo = _currentUser["foto"]?.toString() ?? "";
    ImageProvider? profileImage = getProfileImageProvider(photo);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color navBgColor = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final Color unselectedColor = isDark ? Colors.white30 : Colors.black26;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: accentColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: const SizedBox(width: 48),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/LogoPreta.png",
              width: 28,
              color: titleColor,
            ),
            const SizedBox(width: 8),
            Text(
              "Sectio Aurea",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: titleColor,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                _currentIndex = 4;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: titleColor.withOpacity(0.2),
                backgroundImage: profileImage,
                child: profileImage == null
                    ? Icon(Icons.person, color: titleColor, size: 20)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: _getTabs()[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: navBgColor,
        selectedItemColor: accentColor,
        unselectedItemColor: unselectedColor,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.access_time_outlined),
            activeIcon: Icon(Icons.access_time),
            label: 'Tempo',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 13,
              backgroundColor: Colors.black12,
              child: const Icon(Icons.add, color: Colors.black54, size: 18),
            ),
            activeIcon: CircleAvatar(
              radius: 13,
              backgroundColor: accentColor,
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
            label: 'Criar',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Revisão',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 13,
              backgroundColor: Colors.black12,
              child: const Icon(Icons.person_outline, color: Colors.black54, size: 16),
            ),
            activeIcon: CircleAvatar(
              radius: 13,
              backgroundColor: accentColor,
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
