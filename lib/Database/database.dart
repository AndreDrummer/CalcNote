import 'package:calcnote/Model/note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataBaseHandler {

   Future<Database> database;

   DataBaseHandler._constructor();
   static final DataBaseHandler instance = DataBaseHandler._constructor();

  void initDB() async {
    database = openDatabase(
      join(await getDatabasesPath(), 'calcnote.db'),
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE CalcNotes(id INTEGER PRIMARY KEY, tema TEXT, cardColor TEXT)'
        );
        await db.execute(
            'CREATE TABLE Anotation(id INTEGER PRIMARY KEY, title TEXT, type TEXT, value REAL, day STRING, month TEXT, year STRING, tema TEXT)'
        );
      },
      version: 1,
    );
  }

  Future<void> insert(data, String table) async {
    final Database db = await database;

    await db.insert(table, data.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<void> update(data, table) async {
    final db =  await database;

    await db.update(table, data.toMap(),
      where: "id = ?",
      whereArgs: [data.id]
    );
  }

  Future<void> delete(id, table) async {
     final db =  await database;

     await db.delete(table,
         where: "id = ?",
         whereArgs: [id]
     );
   }

   Future<List> queryParams(param, table) async {
     final db =  await database;

     final List<Map<String, dynamic>> notes = await db.query(table,
         where: "tema = ?",
         whereArgs: [param]
     );

     return notes;
   }

  Future<List> getAnotation() async {
    final Database db = await database;

    final List<Map<String, dynamic>> notes = await db.query('Anotation');

    return notes;

//    return List.generate(maps.length, (i) {
//      return Anotation(
//          title: maps[i]['title'],
//          type: maps[i]['type'],
//          value: maps[i]['value'],
//          day: maps[i]['day'],
//          month: maps[i]['month'],
//          year: maps[i]['year'],
//      );
//    });
  }

  Future<List<CalcNote>> getCalcNotes() async {
     final Database db = await database;

     final List<Map<String, dynamic>> maps = await db.query('CalcNotes');

     return List.generate(maps.length, (i) {
       return CalcNote(
           id: maps[i]['id'],
           tema: maps[i]['tema'],
           cardColor: maps[i]['cardColor']
       );
     });
   }
}