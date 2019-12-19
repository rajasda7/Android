import 'package:Softnotes/models/Note.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper{
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colDate = 'date';

  DatabaseHelper.createInstance();
  factory DatabaseHelper(){
    if(_databaseHelper == null){
      _databaseHelper = DatabaseHelper.createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async{
    if(_database == null){
        _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async{
      await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT,'
          '$colDescription TEXT, $colDate TEXT)');
  }

  // fetch operation
  Future<List<Map<String, dynamic>>> getNotesMapList() async{
    Database db = await this.database;
    var result = await db.rawQuery('SELECT * FROM $noteTable order by $colId DESC'); // can use order by
    return result;
  }

  Future<List<Note>> getNoteList() async{
    var noteMapList = await getNotesMapList();
    int count = noteMapList.length;
    List<Note> noteList = List<Note>();

    for(int i = 0; i < count; i++){
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }

  // insert operation
Future<int> insertNote(Note note) async{
  Database db = await this.database;
  var result = db.insert(noteTable, note.noteToMap());
  return result;
}

// Update operation
  Future<int> updateNote(Note note) async{
    var db = await this.database;
    var result = await db.update(noteTable, note.noteToMap(), where:  '$colId = ?',  whereArgs: [note.id]);
    return result;
  }

// Delete Operation
  Future<int> deleteNote(int id) async{
    var db = await this.database;
    var result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }
}