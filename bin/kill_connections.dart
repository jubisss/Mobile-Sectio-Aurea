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
    print("Connecting to list processes...");
    final conn1 = await MySqlConnection.connect(settings);
    print("Connected!");

    final results1 = await conn1.query("SHOW PROCESSLIST");
    List<int> idsToKill = [];
    for (var r in results1) {
      int id = r[0];
      String user = r[1] ?? '';
      print("  Thread ID: $id, User: $user, Cmd: ${r[4]}");
      if (user == 'cl204214') {
        idsToKill.add(id);
      }
    }
    await conn1.close();

    if (idsToKill.isEmpty) {
      print("No other connections to kill.");
      return;
    }

    print("\nConnecting to kill processes...");
    final conn2 = await MySqlConnection.connect(settings);
    print("Connected!");
    
    // Get current connection ID to avoid suicide
    final currentIdRow = await conn2.query("SELECT CONNECTION_ID()");
    int currentId = 0;
    for (var r in currentIdRow) {
      currentId = r[0];
    }
    print("Current Connection ID: $currentId");

    for (var id in idsToKill) {
      if (id != currentId) {
        try {
          await conn2.query("KILL $id");
          print("  Killed connection ID $id");
        } catch (e) {
          print("  Error killing connection ID $id: $e");
        }
      }
    }
    await conn2.close();
    print("Done!");
  } catch (e) {
    print("Error: $e");
  }
}
