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

    print("Inserting test user...");
    var result = await conn.query(
      "INSERT INTO PI_Usuario (nome, email, senha, plano, tipo_dom, clas_inteli, ativo) VALUES (?, ?, ?, ?, ?, ?, ?)",
      ["Test User", "test@sectio.com", "password123", "Gratuito", "Lógico-matemática", "0xffffbd59", 1]
    );
    int newId = result.insertId ?? 1;
    print("Inserted test user with ID: $newId");

    print("Querying the test user...");
    var selectResult = await conn.query("SELECT * FROM PI_Usuario WHERE id_usuario = ?", [newId]);
    print("Found ${selectResult.length} rows.");
    for (var r in selectResult) {
      print("User Row: id=${r[0]}, nome=${r[1]}, email=${r[2]}, tipo_dom=${r[7]}, clas_inteli=${r[8]}");
    }

    print("Deleting test user...");
    await conn.query("DELETE FROM PI_Usuario WHERE id_usuario = ?", [newId]);
    print("Deleted test user.");

    await conn.close();
  } catch (e) {
    print("Error during test: $e");
  }
}
