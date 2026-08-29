import 'package:mysql1/mysql1.dart';

void main() async {
  final settings = ConnectionSettings(
    host: '143.106.241.4',
    port: 3306,
    user: 'cl204214',
    db: 'cl204214',
    password: 'cl*19072008',
    timeout: const Duration(seconds: 4),
  );

  try {
    print("Connecting...");
    final conn = await MySqlConnection.connect(settings);
    print("Connected!");

    final results = await conn.query("SELECT id_tipo, nome, metodo, cor FROM PI_Inteligencias");
    print("Inteligencias found: ${results.length}");
    for (var r in results) {
      print("id_tipo: ${r[0]}, nome: ${r[1]}, cor: ${r[3]}");
      print("metodo: ${r[2]}");
      print("-" * 40);
    }

    await conn.close();
  } catch (e) {
    print("Error: $e");
  }
}
