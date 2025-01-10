import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart' as path;
import '../screens/session.dart';

import '../models/note.dart';

String dbName = 'text_and_pen_2025_01_09';

class DbNotes {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();

    // required this.id,
    // required this.dateCreated,
    // required this.dateModified,
    // required this.text,
    // required this.scribbles,
    // required this.scribblePreview,

    return sql.openDatabase(
      path.join(dbPath, '$dbName.db'),
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
            CREATE TABLE $dbName (
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              dateCreated TEXT,
              dateModified TEXT,
              text TEXT,
              scribbles TEXT,
              scribblePreview TEXT
            )
            ''');
      },
    );
  }

  static Future<List<Note>> getNotesList() async {
    final db = await DbNotes.database();

    List<Map<String, dynamic>> rawNotesList;
    final List<Note> notesList = [];

    print('(TO-DO) somehow reduce the amount of data being pulled from this query method...');
    print('(it will crash with moderately complex drawings because a row gets too long...)');
    rawNotesList = await db.query(dbName, orderBy: 'dateModified DESC');

    for (var rawNote in rawNotesList) {
      final newNote = Note(
        id: rawNote['id'],
        dateCreated: rawNote['dateCreated'],
        dateModified: rawNote['dateModified'],
        text: rawNote['text'],
        scribbles: rawNote['scribbles'],
        scribblePreview: rawNote['scribblePreview'],
        scribblePreviewStrokes: deserializeStrokes(rawNote['scribblePreview']),
      );

      notesList.add(newNote);
    }

    return notesList;
  }

  // createNote()
  static Future<int> createNote(Note note) async {
    final db = await DbNotes.database();

    return db.insert(dbName, {
      'dateCreated': note.dateCreated,
      'dateModified': note.dateModified,
      'text': note.text,
      'scribbles': note.scribbles,
      'scribblePreview': note.scribblePreview,
    });
  }

  // updateNote(Note note)
  static Future<int> updateNote(Note note) async {
    final db = await DbNotes.database();

    return db.update(
      dbName,
      {
        'dateCreated': note.dateCreated,
        'dateModified': note.dateModified,
        'text': note.text,
        'scribbles': note.scribbles,
        'scribblePreview': note.scribblePreview,
      },
      where: 'id == ?',
      whereArgs: [note.id],
    );
  }

  // deleteNote(int ID)
  static Future<int> deleteNote(int id) async {
    final db = await DbNotes.database();

    return db.delete(
      dbName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
